import 'package:flutter/material.dart';
import 'wait_screens.dart';

class CreateDiaryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double imageSize = screenWidth * 0.2; // 이미지 크기 통일
    final double textSpacing = 5.0; // 이미지와 텍스트 사이 간격
    final double itemSpacing = 20.0; // 각 아이템 간의 간격

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
),


      body: Container(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              width: screenWidth,
              height: screenHeight * 0.9,
              child: Container(
                color: const Color(0xfffdfbf0),
              ),
            ),
            Positioned(
              left: 20,
              width: screenWidth - 40,
              child: Text(
                '00님\n오늘은 어떤 하루였나요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 20,
                  color: const Color(0xff2c2c2c),
                  fontWeight: FontWeight.normal,
                ),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 이미지와 텍스트를 나란히 배치
            _buildEmotionWidget(context, '분노', 'assets/분노.png', 0.25, 0.10, imageSize, textSpacing, itemSpacing),
            _buildEmotionWidget(context, '설렘', 'assets/설렘.png', 0.25, 0.25, imageSize, textSpacing, itemSpacing),
            _buildEmotionWidget(context, '편안', 'assets/편안.png', 0.25, 0.40, imageSize, textSpacing, itemSpacing),
            _buildEmotionWidget(context, '신나', 'assets/신나.png', 0.25, 0.55, imageSize, textSpacing, itemSpacing),
            _buildEmotionWidget(context, '감사', 'assets/감사.png', 0.25, 0.70, imageSize, textSpacing, itemSpacing),
            _buildEmotionWidget(context, '슬픔', 'assets/슬픔.png', 0.55, 0.10, imageSize, textSpacing, itemSpacing),
            _buildEmotionWidget(context, '당황', 'assets/당황.png', 0.55, 0.25, imageSize, textSpacing, itemSpacing),
            _buildEmotionWidget(context, '억울', 'assets/억울.png', 0.55, 0.40, imageSize, textSpacing, itemSpacing),
            _buildEmotionWidget(context, '뿌듯', 'assets/뿌듯.png', 0.55, 0.55, imageSize, textSpacing, itemSpacing),
            _buildEmotionWidget(context, '걱정', 'assets/걱정.png', 0.55, 0.70, imageSize, textSpacing, itemSpacing),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionWidget(BuildContext context, String label, String imagePath, double left, double top, double imageSize, double textSpacing, double itemSpacing) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      left: screenWidth * left,
      top: screenHeight * top,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WaitPage()),
          );
        },
        child: Column(
          children: [
            Image.asset(
              imagePath,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.contain,
            ),
            SizedBox(height: textSpacing),
            Text(
              label,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 14,
                color: const Color(0xff282034),
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: itemSpacing),
          ],
        ),
      ),
    );
  }
}
