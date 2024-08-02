import 'package:flutter/material.dart';

class AlarmSettingPage extends StatefulWidget {
  const AlarmSettingPage({Key? key}) : super(key: key);

  @override
  _AlarmSettingPageState createState() => _AlarmSettingPageState();
}

class _AlarmSettingPageState extends State<AlarmSettingPage> {
  bool isAlarmEnabled = false;
  TimeOfDay selectedTime = TimeOfDay(hour: 11, minute: 30);

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFBF0), // 전체 배경색 설정
      appBar: AppBar(
        title: Text('알림 설정', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '알림 설정',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              Card(
                color: Color(0x80FFE76B), // 알림 활성화 박스 색상
                child: SwitchListTile(
                  title: Text('알림 활성화'),
                  value: isAlarmEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      isAlarmEnabled = value;
                    });
                  },
                  activeColor: Color(0x808D83FF),
                  inactiveThumbColor: Colors.grey,
                ),
              ),
              if (isAlarmEnabled)
                SizedBox(height: 16),
              if (isAlarmEnabled)
                Card(
                  color: Color(0x80FFE76B), // 시간 설정 박스 색상
                  child: ListTile(
                    title: Text('시간'),
                    subtitle: Center(
                      child: Text(
                        '${selectedTime.format(context)}',
                        style: TextStyle(fontSize: 48),
                      ),
                    ),
                    onTap: () {
                      _selectTime(context);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
