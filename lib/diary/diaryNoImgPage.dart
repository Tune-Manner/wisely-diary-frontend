import 'package:flutter/material.dart';

class DiaryNoImgPage extends StatefulWidget {
  @override
  _DiaryNoImgPageState createState() => _DiaryNoImgPageState();
}

class _DiaryNoImgPageState extends State<DiaryNoImgPage> {
  bool _isGiftMenuVisible = false;

  void _toggleGiftMenu() {
    setState(() {
      _isGiftMenuVisible = !_isGiftMenuVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFF9F2), // 상단 배경 색상
        elevation: 0,
        leadingWidth: 100, // 두 개의 아이콘이 충분히 들어갈 공간을 확보하기 위해 너비 설정
        leading: Row(
          mainAxisSize: MainAxisSize.min, // Row의 크기를 최소화하여 아이콘들이 나란히 배치되도록 함
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
      body: Container(
        color: Color(0xFFFFF9F2), // 전체 배경 색상
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white, // 배경 흰색
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
                            overflow: TextOverflow.ellipsis, // 텍스트 오버플로우 방지
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.insert_emoticon, color: Color(0xFFE9D899)), // 감정 아이콘 색상
                            SizedBox(width: 4), // 아이콘 간 간격 줄이기
                            Icon(Icons.edit, color: Colors.black), // 수정 아이콘
                            SizedBox(width: 4), // 아이콘 간 간격 줄이기
                            Icon(Icons.delete, color: Colors.black), // 삭제 아이콘
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
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (_isGiftMenuVisible) ...[
                            IconButton(
                              icon: Icon(Icons.notes, color: Colors.black),
                              onPressed: () {
                                // 알림 노트 동작 정의
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.share, color: Colors.black),
                              onPressed: () {
                                // 공유 동작 정의
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.print, color: Colors.black),
                              onPressed: () {
                                // 출력 동작 정의
                              },
                            ),
                          ],
                          IconButton(
                            icon: Icon(Icons.card_giftcard, color: Colors.black), // 선물 아이콘
                            onPressed: _toggleGiftMenu,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
