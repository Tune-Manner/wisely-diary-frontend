import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'main.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final String? title;
  final bool showAppBar;

  const CustomScaffold({
    Key? key,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.title,
    this.showAppBar = true,
  }) : super(key: key);

  void _navigateToHome(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false, arguments: userId);
  }

  void _navigateToPage(BuildContext context, String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
        backgroundColor: const Color(0xffffffff),
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: title != null
            ? Text(title!,
            style: TextStyle(color: Colors.black, fontSize: 15))
            : GestureDetector(
          onTap: () => _navigateToHome(context),
          child: Image.asset(
            'assets/wisely-diary-logo.png',
            height: 30,
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
        actions: [
          ...?actions,
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () => _signOut(context),
            tooltip: '로그아웃',
          ),
        ],
      )
          : null,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xfffffdf9),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/wisely-diary-logo.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '일기로운 슬기생활',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('홈', style: TextStyle(fontSize: 15.0)),
              onTap: () {
                Navigator.pop(context);
                _navigateToHome(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('마이페이지', style: TextStyle(fontSize: 15.0)),
              onTap: () {
                Navigator.pop(context);
                _navigateToPage(context, '/mypage');
              },
            ),
            ListTile(
              leading: Icon(Icons.analytics),
              title: Text('감정 통계', style: TextStyle(fontSize: 15.0)),
              onTap: () {
                Navigator.pop(context);
                _navigateToPage(context, '/statistics');
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('알림 설정', style: TextStyle(fontSize: 15.0)),
              onTap: () {
                Navigator.pop(context);
                _navigateToPage(context, '/notifications');
              },
            ),
          ],
        ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
