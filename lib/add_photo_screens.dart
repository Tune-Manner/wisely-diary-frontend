import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'AudioManager.dart';
import 'diary_summary_screens.dart';

// Logger 초기화
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,      // 스택 트레이스에서 보여줄 메서드 수
    errorMethodCount: 8, // 에러 발생 시 보여줄 메서드 수
    lineLength: 120,     // 로그 라인의 최대 길이
    colors: true,        // 컬러 로깅 활성화
    printEmojis: true,   // 이모지 출력 활성화
    printTime: true,     // 시간 출력 활성화
  ),
);

// Android Photo Picker 설정
void configureAndroidPhotoPicker() {
  // ImagePickerPlatform의 현재 인스턴스를 가져옵니다.
  final ImagePickerPlatform imagePickerImplementation = ImagePickerPlatform.instance;

  // 현재 플랫폼이 Android인지 확인합니다.
  if (imagePickerImplementation is ImagePickerAndroid) {
    // Android Photo Picker를 사용하도록 설정합니다.
    imagePickerImplementation.useAndroidPhotoPicker = true;
  }
}

// 이벤트 정의: BLoC 패턴에서 사용자 액션이나 시스템 이벤트를 나타냄
abstract class AddPhotoEvent {
  const AddPhotoEvent();
}

// 사진 추가 이벤트: 사용자가 사진을 추가하려고 할 때 발생
class AddPhotos extends AddPhotoEvent {
  const AddPhotos();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  final List<File> _imageFiles = [];
  final audioManager = AudioManager();
  late bool isPlaying;
  late double volume;
  String userId="";
  bool _isLoading = false;
// 사진 제거 이벤트: 사용자가 특정 사진을 제거하려고 할 때 발생
class RemovePhoto extends AddPhotoEvent {
  final int index;
  const RemovePhoto(this.index);
}

// 재생/일시정지 토글 이벤트: 오디오 재생 상태를 변경할 때 발생
class TogglePlayPause extends AddPhotoEvent {
  const TogglePlayPause();
}

// 볼륨 변경 이벤트: 오디오 볼륨을 조절할 때 발생
class ChangeVolume extends AddPhotoEvent {
  final double volume;
  const ChangeVolume(this.volume);
}

// 일기 생성 이벤트: 사용자가 일기를 생성하려고 할 때 발생
class CreateDiary extends AddPhotoEvent {
  const CreateDiary();
}

// 상태 정의: 현재 앱의 상태를 나타냄. 변경 불가능(immutable)하게 설계.
class AddPhotoState {
  final List<File> imageFiles;  // 선택된 이미지 파일들
  final bool isPlaying;         // 오디오 재생 중 여부
  final double volume;          // 현재 볼륨

  const AddPhotoState({
    required this.imageFiles,
    required this.isPlaying,
    required this.volume,
  });

  // 상태의 일부만 업데이트할 때 사용하는 메서드
  AddPhotoState copyWith({
    List<File>? imageFiles,
    bool? isPlaying,
    double? volume,
  }) {
    return AddPhotoState(
      imageFiles: imageFiles ?? this.imageFiles,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
    );
  }
}

// BLoC: 비즈니스 로직을 처리하고 상태를 관리
class AddPhotoBloc extends Bloc<AddPhotoEvent, AddPhotoState> {
  final AudioManager audioManager;

  AddPhotoBloc({required this.audioManager})
      : super(AddPhotoState(
      imageFiles: [],
      isPlaying: audioManager.player.playing,
      volume: audioManager.player.volume
  )) {
    on<AddPhotos>(_onAddPhotos);
    // 다른 이벤트 핸들러 등록은 이전과 동일...

    logger.i('AddPhotoBloc initialized');
  }

  // 사진 추가 이벤트 처리
  Future<void> _onAddPhotos(AddPhotos event, Emitter<AddPhotoState> emit) async {
    logger.d('Adding photos');
    try {
      // ImagePickerPlatform의 인스턴스를 가져옵니다.
      final ImagePickerPlatform picker = ImagePickerPlatform.instance;

      // 현재 선택된 이미지 수를 계산합니다.
      final int currentImageCount = state.imageFiles.length;

      // 추가로 선택할 수 있는 이미지 수를 계산합니다. (최대 10장)
      final int remainingImagesAllowed = 10 - currentImageCount;

      // 이미지를 선택합니다.
      final List<XFile> pickedFiles = await picker.getMultiImageWithOptions(
        options: MultiImagePickerOptions(
          imageOptions: const ImageOptions(
            maxWidth: 1080, // 이미지의 최대 너비를 1080px로 제한합니다.
          ),
          // 선택 가능한 이미지 수를 제한합니다.
          limit: remainingImagesAllowed,
        ),
      );

      if (pickedFiles.isNotEmpty) {
        // 선택된 이미지를 File 객체로 변환합니다.
        final newFiles = pickedFiles.map((xFile) => File(xFile.path)).toList();
        // 기존 이미지 리스트에 새 이미지들을 추가합니다.
        final updatedFiles = List<File>.from(state.imageFiles)..addAll(newFiles);
        // 새로운 상태를 생성하고 emit합니다.
        emit(state.copyWith(imageFiles: updatedFiles));
        logger.i('${newFiles.length} photos added successfully');
      } else {
        logger.w('No photos selected');
      }
    });
    _fetchUserId();
    } catch (e) {
      logger.e('Error adding photos: $e');
    }
  }

  // 사진 제거 이벤트 처리
  void _onRemovePhoto(RemovePhoto event, Emitter<AddPhotoState> emit) {
    logger.d('Removing photo at index: ${event.index}');
    try {
      final updatedFiles = List<File>.from(state.imageFiles)..removeAt(event.index);
      emit(state.copyWith(imageFiles: updatedFiles));
      logger.i('Photo removed successfully');
    } catch (e) {
      logger.e('Error removing photo: $e');
    }
  }

  // 재생/일시정지 토글 이벤트 처리
  void _onTogglePlayPause(TogglePlayPause event, Emitter<AddPhotoState> emit) {
    logger.d('Toggling play/pause');
    try {
      final isPlaying = audioManager.player.playing;
      if (isPlaying) {
        audioManager.player.pause();
      } else {
        audioManager.player.play();
      }
      emit(state.copyWith(isPlaying: !isPlaying));
      logger.i('Audio ${!isPlaying ? 'playing' : 'paused'}');
    } catch (e) {
      logger.e('Error toggling play/pause: $e');
    }
  }

  // 볼륨 변경 이벤트 처리
  void _onChangeVolume(ChangeVolume event, Emitter<AddPhotoState> emit) {
    logger.d('Changing volume to: ${event.volume}');
    try {
      audioManager.player.setVolume(event.volume);
      emit(state.copyWith(volume: event.volume));
      logger.i('Volume changed successfully');
    } catch (e) {
      logger.e('Error changing volume: $e');
    }
  }

  Future<void> _fetchUserId() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final memberResponse = await Supabase.instance.client
          .from('member')
          .select('member_id')
          .eq('member_id', user.id)
          .single();

      setState(() {
        userId = memberResponse['member_id'];
      });

    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path));
      });
    }
  }
  // 일기 생성 이벤트 처리 (실제 로직은 UI에서 구현)
  void _onCreateDiary(CreateDiary event, Emitter<AddPhotoState> emit) {
    logger.i('Creating diary');
    // 일기 생성 로직은 UI에서 처리
  }
}

// UI 컴포넌트: BlocProvider를 사용하여 AddPhotoBloc을 제공
class AddPhotoScreen extends StatelessWidget {
  final String transcription;

  const AddPhotoScreen({Key? key, required this.transcription}) : super(key: key);
  Future<void> _createDiary() async {
    setState(() {
      _isLoading = true;
    });

    audioManager.player.setVolume(0);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/cartoon/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'diaryCode': 30,
          'memberId': userId,
        }),
      );

      if (response.statusCode == 200) {
        final result = response.body;
        final urls = result.split(', ');

        if (urls.length >= 2) {
          final cartoonUrl = urls[0].replaceAll("Cartoon URL: ", "").trim();
          final letterCartoonUrl = urls[1].replaceAll("Letter Cartoon URL: ", "").trim();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DiarySummaryScreen(
                transcription: widget.transcription,
                imageFiles: _imageFiles,
                cartoonUrl: cartoonUrl,
                letterCartoonUrl: letterCartoonUrl,
              ),
            ),
          );
        } else {
          _showErrorDialog('Unexpected response format');
        }
      } else {
        _showErrorDialog('Failed to create diary: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Android Photo Picker 설정을 호출합니다.
    configureAndroidPhotoPicker();

    return BlocProvider(
      create: (context) => AddPhotoBloc(
        audioManager: AudioManager(),
      ),
      child: AddPhotoView(transcription: transcription),
    );
  }
}

// 실제 UI를 구현하는 위젯
class AddPhotoView extends StatelessWidget {
  final String transcription;

  const AddPhotoView({Key? key, required this.transcription}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // BlocBuilder를 사용하여 상태 변화에 따라 UI를 다시 그림.
    return BlocBuilder<AddPhotoBloc, AddPhotoState>(
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(context, state),
          body: _buildBody(context, state),
        );
      },
    );
  }

  // AppBar 구성
  AppBar _buildAppBar(BuildContext context, AddPhotoState state) {
    return AppBar(
      backgroundColor: const Color(0xfffdfbf0),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          logger.d('Back button pressed');
          Navigator.of(context).pop();
        },
      ),
      title: Image.asset(
        'assets/wisely-diary-logo.png',
        height: 30,
        fit: BoxFit.contain,
      ),
      centerTitle: true,
      actions: [
        // 재생/일시정지 버튼
        IconButton(
          icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            logger.d('Play/Pause button pressed');
            context.read<AddPhotoBloc>().add(const TogglePlayPause());
          },
        ),
        // 볼륨 조절 슬라이더
        SizedBox(
          width: 100,
          child: Slider(
            value: state.volume,
            min: 0.0,
            max: 1.0,
            onChanged: (newVolume) {
              logger.d('Volume changed to: $newVolume');
              context.read<AddPhotoBloc>().add(ChangeVolume(newVolume));
            },
          ),
        ),
      ],
    );
  }

  // 화면 본문 구성
  Widget _buildBody(BuildContext context, AddPhotoState state) {
    return Container(
      color: const Color(0xfffdfbf0),
      child: Column(
        children: [
          _buildTopButtons(context),
          const SizedBox(height: 20),
          Expanded(child: _buildPhotoGrid(context, state)),
        ],
      ),
    );
  }

  // 상단 버튼 구성 (사진 추가 및 일기 생성 버튼)
  Widget _buildTopButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 사진 추가 버튼
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                logger.d('Add photos button pressed');
                context.read<AddPhotoBloc>().add(const AddPhotos());
              },
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('사진 추가'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 일기 생성 버튼
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                logger.d('Create diary button pressed');
                final state = context.read<AddPhotoBloc>().state;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiarySummaryScreen(
                      transcription: transcription,
                      imageFiles: state.imageFiles,
                    ),
                  ),
                );
              },
              child: const Text('일기 생성하기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 사진 그리드 구성
  Widget _buildPhotoGrid(BuildContext context, AddPhotoState state) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,  // 한 행에 3개의 이미지를 표시
        crossAxisSpacing: 10,  // 이미지 간 가로 간격
        mainAxisSpacing: 10,   // 이미지 간 세로 간격
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfffdfbf0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Image.asset(
          'assets/wisely-diary-logo.png',
          height: 30,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: togglePlayPause,
          ),
          Container(
            width: 100,
            child: Slider(
              value: volume,
              min: 0.0,
              max: 1.0,
              onChanged: changeVolume,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
            color: const Color(0xfffdfbf0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Image.asset(
                    'assets/File plus.png',
                    width: 60,
                    height: 60,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createDiary,
                  child: Text('생성하기'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '당신의 하루에 공감 중입니다...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '잠시만 기다려주세요',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      itemCount: state.imageFiles.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 선택된 이미지 표시
            Image.file(state.imageFiles[index], fit: BoxFit.cover),
            // 이미지 삭제 버튼
            Positioned(
              top: 5,
              right: 5,
              child: GestureDetector(
                onTap: () {
                  logger.d('Remove photo button pressed for index: $index');
                  context.read<AddPhotoBloc>().add(RemovePhoto(index));
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: Colors.red),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}