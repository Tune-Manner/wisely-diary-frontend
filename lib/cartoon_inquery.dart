import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartoonInquiryScreen extends StatefulWidget {
  final DateTime selectedDate;

  const CartoonInquiryScreen({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _CartoonInquiryScreenState createState() => _CartoonInquiryScreenState();
}

class _CartoonInquiryScreenState extends State<CartoonInquiryScreen> {
  List<Map<String, dynamic>> cartoons = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchCartoons();
  }

  Future<void> fetchCartoons() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        error = '사용자 인증에 실패했습니다.';
        isLoading = false;
      });
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/cartoon/inquiry?date=$formattedDate&memberId=${user.id}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("리스트${data}");
        setState(() {
          cartoons = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else if (response.statusCode == 204) {
        setState(() {
          cartoons = [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cartoons');
      }
    } catch (e) {
      setState(() {
        error = '만화를 불러오는 데 실패했습니다: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${DateFormat('yyyy년 MM월 dd일').format(widget.selectedDate)}의 만화'),
        backgroundColor: Color(0xFFFFF9F2),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : cartoons.isEmpty
          ? Center(child: Text('이 날 생성된 만화가 없습니다.'))
          : ListView.builder(
        itemCount: cartoons.length,
        itemBuilder: (context, index) {
          final cartoon = cartoons[index];
          final cartoonPath = cartoon['cartoonPath'] as String?;
          // final cartoonTitle = cartoon['cartoon_title'] as String?;
          print('cartoonPath: $cartoonPath');
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (cartoonPath != null && cartoonPath.isNotEmpty)
                  Image.network(
                    cartoonPath,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Text('이미지를 불러올 수 없습니다.');
                    },
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('이미지가 제공되지 않습니다.'),
                  ),
                // Padding(
                //   padding: EdgeInsets.all(8.0),
                //   child: Text(
                //     cartoonTitle ?? '제목 없음',
                //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}