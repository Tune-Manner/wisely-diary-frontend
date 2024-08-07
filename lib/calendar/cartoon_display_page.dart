import 'package:flutter/material.dart';

class CartoonDisplayPage extends StatelessWidget {
  final List<dynamic> cartoons;

  CartoonDisplayPage({required this.cartoons});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('만화 보기'),
      ),
      body: ListView.builder(
        itemCount: cartoons.length,
        itemBuilder: (context, index) {
          final cartoon = cartoons[index];
          return Card(
            child: Column(
              children: [
                Image.network(
                  'http://10.0.2.2:8080/cartoonImage/${cartoon['cartoonPath'].split('\\').last}',
                  errorBuilder: (context, error, stackTrace) {
                    return Text('이미지를 불러올 수 없습니다.');
                  },
                ),
                Text('생성 시간: ${cartoon['createdAt']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}