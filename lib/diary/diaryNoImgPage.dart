import 'package:flutter/material.dart';

class DiaryNoImgPage extends StatefulWidget {
  @override
  _DiaryNoImgPageState createState() => _DiaryNoImgPageState();
}

class _DiaryNoImgPageState extends State<DiaryNoImgPage> {
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;  // 추가: 오버레이 가시성 상태를 관리하는 변수

  void _toggleGiftMenu() {
    setState(() {
      if (!_isOverlayVisible) {
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context)!.insert(_overlayEntry!);
        _isOverlayVisible = true;
      } else {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _isOverlayVisible = false;
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: 90,
        right: 25,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 75,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Image.asset('assets/music_icon.png'),
                    SizedBox(height: 4),
                    Text('맞춤노래', style: TextStyle(fontSize: 10)),
                  ],
                ),
                SizedBox(height: 16),
                Column(
                  children: [
                    Image.asset('assets/cuttoon_icon.png'),
                    SizedBox(height: 4),
                    Text('네컷만화', style: TextStyle(fontSize: 10)),
                  ],
                ),
                SizedBox(height: 16),
                Column(
                  children: [
                    Image.asset('assets/letter_icon.png'),
                    SizedBox(height: 4),
                    Text('위로의 편지', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFF9F2),
        elevation: 0,
        leadingWidth: 100,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                // 햄버거 메뉴 클릭 시 동작 정의
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: Color(0xFFFFF9F2),
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '2024.09.30 수요일',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.insert_emoticon, color: Color(0xFFE9D899)),
                                SizedBox(width: 4),
                                Icon(Icons.edit, color: Colors.black),
                                SizedBox(width: 4),
                                Icon(Icons.delete, color: Colors.black),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        Expanded(
                          child: Text(
                            '일기 요약본이 여기에 표시된다. 오늘은 기획이 바뀌어서 바쁜 하루였다. 할게 너무 많아서 슬펐다. 주말도 해야되나 걱정이 되었다. 열심히 해서 주말엔 모두가 쉴 수 있으면 좋겠다.',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            right: 25,
            child: GestureDetector(
              onTap: _toggleGiftMenu,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(0xFF8D83FF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.white, // 이미지 색상을 하얀색으로 변경
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      'assets/gift_icon.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
