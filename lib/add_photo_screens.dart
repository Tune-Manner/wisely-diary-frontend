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

final logger = Logger(printer: PrettyPrinter());

void configureAndroidPhotoPicker() {
  final ImagePickerPlatform imagePickerImplementation = ImagePickerPlatform.instance;
  if (imagePickerImplementation is ImagePickerAndroid) {
    imagePickerImplementation.useAndroidPhotoPicker = true;
  }
}

// Events
abstract class AddPhotoEvent {}
class AddPhotos extends AddPhotoEvent {}
class RemovePhoto extends AddPhotoEvent {
  final int index;
  RemovePhoto(this.index);
}
class TogglePlayPause extends AddPhotoEvent {}
class ChangeVolume extends AddPhotoEvent {
  final double volume;
  ChangeVolume(this.volume);
}
class CreateDiary extends AddPhotoEvent {}

// State
class AddPhotoState {
  final List<File> imageFiles;
  final bool isPlaying;
  final double volume;
  final bool isLoading;
  final String userId;
  final String? cartoonUrl;
  final String? letterCartoonUrl;
  final String? error;

  const AddPhotoState({
    required this.imageFiles,
    required this.isPlaying,
    required this.volume,
    this.isLoading = false,
    this.userId = "",
    this.cartoonUrl,
    this.letterCartoonUrl,
    this.error,
  });

  AddPhotoState copyWith({
    List<File>? imageFiles,
    bool? isPlaying,
    double? volume,
    bool? isLoading,
    String? userId,
    String? cartoonUrl,
    String? letterCartoonUrl,
    String? error,
  }) {
    return AddPhotoState(
      imageFiles: imageFiles ?? this.imageFiles,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      isLoading: isLoading ?? this.isLoading,
      userId: userId ?? this.userId,
      cartoonUrl: cartoonUrl ?? this.cartoonUrl,
      letterCartoonUrl: letterCartoonUrl ?? this.letterCartoonUrl,
      error: error ?? this.error,
    );
  }
}

// BLoC
class AddPhotoBloc extends Bloc<AddPhotoEvent, AddPhotoState> {
  final AudioManager audioManager;
  final String transcription;

  AddPhotoBloc({required this.audioManager, required this.transcription})
      : super(AddPhotoState(
    imageFiles: [],
    isPlaying: audioManager.player.playing,
    volume: audioManager.player.volume,
  )) {
    on<AddPhotos>(_onAddPhotos);
    on<RemovePhoto>(_onRemovePhoto);
    on<TogglePlayPause>(_onTogglePlayPause);
    on<ChangeVolume>(_onChangeVolume);
    on<CreateDiary>(_onCreateDiary);
    _fetchUserId();
  }

  Future<void> _onAddPhotos(AddPhotos event, Emitter<AddPhotoState> emit) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        final newFiles = pickedFiles.map((xFile) => File(xFile.path)).toList();
        final updatedFiles = List<File>.from(state.imageFiles)..addAll(newFiles);
        emit(state.copyWith(imageFiles: updatedFiles));
      }
    } catch (e) {
      logger.e('Error adding photos: $e');
      emit(state.copyWith(error: 'Failed to add photos: $e'));
    }
  }

  void _onRemovePhoto(RemovePhoto event, Emitter<AddPhotoState> emit) {
    final updatedFiles = List<File>.from(state.imageFiles)..removeAt(event.index);
    emit(state.copyWith(imageFiles: updatedFiles));
  }

  void _onTogglePlayPause(TogglePlayPause event, Emitter<AddPhotoState> emit) {
    final isPlaying = audioManager.player.playing;
    if (isPlaying) {
      audioManager.player.pause();
    } else {
      audioManager.player.play();
    }
    emit(state.copyWith(isPlaying: !isPlaying));
  }

  void _onChangeVolume(ChangeVolume event, Emitter<AddPhotoState> emit) {
    audioManager.player.setVolume(event.volume);
    emit(state.copyWith(volume: event.volume));
  }

  Future<void> _fetchUserId() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final memberResponse = await Supabase.instance.client
          .from('member')
          .select('member_id')
          .eq('member_id', user.id)
          .single();
      emit(state.copyWith(userId: memberResponse['member_id']));
    }
  }

  Future<void> _onCreateDiary(CreateDiary event, Emitter<AddPhotoState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    audioManager.player.setVolume(0);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/cartoon/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'diaryCode': 30,
          'memberId': state.userId,
        }),
      );

      if (response.statusCode == 200) {
        final result = response.body;
        final urls = result.split(', ');
        if (urls.length >= 2) {
          final cartoonUrl = urls[0].replaceAll("Cartoon URL: ", "").trim();
          final letterCartoonUrl = urls[1].replaceAll("Letter Cartoon URL: ", "").trim();
          emit(state.copyWith(
            isLoading: false,
            cartoonUrl: cartoonUrl,
            letterCartoonUrl: letterCartoonUrl,
          ));
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to create diary: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error creating diary: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

// UI
class AddPhotoScreen extends StatelessWidget {
  final String transcription;

  const AddPhotoScreen({Key? key, required this.transcription}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    configureAndroidPhotoPicker();

    return BlocProvider(
      create: (context) => AddPhotoBloc(
        audioManager: AudioManager(),
        transcription: transcription,
      ),
      child: AddPhotoView(transcription: transcription),
    );
  }
}

class AddPhotoView extends StatelessWidget {
  final String transcription;

  const AddPhotoView({Key? key, required this.transcription}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddPhotoBloc, AddPhotoState>(
      listener: (context, state) {
        if (state.cartoonUrl != null && state.letterCartoonUrl != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DiarySummaryScreen(
                transcription: transcription,
                imageFiles: state.imageFiles,
                cartoonUrl: state.cartoonUrl!,
                letterCartoonUrl: state.letterCartoonUrl!,
              ),
            ),
          );
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(context, state),
          body: Stack(
            children: [
              _buildBody(context, state),
              if (state.isLoading) _buildLoadingOverlay(),
            ],
          ),
        );
      },
    );
  }
  AppBar _buildAppBar(BuildContext context, AddPhotoState state) {
    return AppBar(
      backgroundColor: const Color(0xfffdfbf0),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
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
          icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () => context.read<AddPhotoBloc>().add(TogglePlayPause()),
        ),
        SizedBox(
          width: 100,
          child: Slider(
            value: state.volume,
            min: 0.0,
            max: 1.0,
            onChanged: (newVolume) => context.read<AddPhotoBloc>().add(ChangeVolume(newVolume)),
          ),
        ),
      ],
    );
  }

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

  Widget _buildTopButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.read<AddPhotoBloc>().add(AddPhotos()),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('사진 추가'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => context.read<AddPhotoBloc>().add(CreateDiary()),
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

  Widget _buildPhotoGrid(BuildContext context, AddPhotoState state) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: state.imageFiles.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.file(state.imageFiles[index], fit: BoxFit.cover),
            Positioned(
              top: 5,
              right: 5,
              child: GestureDetector(
                onTap: () => context.read<AddPhotoBloc>().add(RemovePhoto(index)),
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

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
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
    );
  }
}