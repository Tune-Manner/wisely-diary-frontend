import 'package:flutter/material.dart';
import 'dart:async';

class WaitPage extends StatefulWidget {
  WaitPage({super.key});

  @override
  State<StatefulWidget> createState() => _WaitPageState();
}

class _WaitPageState extends State<WaitPage> {
  int _counter = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_counter > 1) {
        setState(() {
          _counter--;
        });
      } else {
        _timer?.cancel();
        Navigator.pushReplacementNamed(context, '/select-type');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        color: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: const Color(0xffffffff),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.9,
                child: Container(
                  color: const Color(0xfffdfbf0),
                ),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width * 0.1,
                top: MediaQuery.of(context).size.height * 0.10,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  '눈을 감고 \n오늘 하루를 돌아봅시다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 30,
                    color: const Color(0xff2c2c2c),
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 9999,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              Positioned(
                left: MediaQuery.of(context).size.width * 0.45,
                top: MediaQuery.of(context).size.height * 0.35,
                child: Text(
                  '$_counter',
                  style: TextStyle(
                    fontSize: 60,
                    color: const Color(0xff2c2c2c),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
