import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartoonResultPage extends StatefulWidget {
  final String cartoonUrl;
  final int diarySummaryCode;

  CartoonResultPage({required this.cartoonUrl, required this.diarySummaryCode});

  @override
  _CartoonResultPageState createState() => _CartoonResultPageState();
}

class _CartoonResultPageState extends State<CartoonResultPage> {
  late String cartoonUrl;
  final String baseUrl = 'http://10.0.2.2:8080';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    cartoonUrl = widget.cartoonUrl;
  }

  Future<void> regenerateCartoon() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/cartoon/create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'diarySummaryCode': widget.diarySummaryCode,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          cartoonUrl = response.body;
        });
      } else {
        throw Exception('Failed to regenerate cartoon');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('만화 재생성에 실패했습니다.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveCartoon() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/cartoon/save'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'cartoonPath': cartoonUrl,
          'diarySummaryCode': widget.diarySummaryCode,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('만화가 저장되었습니다.')),
        );
      } else {
        throw Exception('Failed to save cartoon');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('만화 저장에 실패했습니다.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('만화 결과'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              cartoonUrl,
              height: 300,
              width: 300,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: regenerateCartoon,
                  child: Text('재생성'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: saveCartoon,
                  child: Text('저장하기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}