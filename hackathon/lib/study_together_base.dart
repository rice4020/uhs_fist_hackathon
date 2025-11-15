import 'package:flutter/material.dart';

import 'study_together_user.dart';
import 'study_together_main.dart';
import 'study_together_inquiry.dart';
import 'study_together_create.dart';

class StudyTogetherBase extends StatefulWidget {
  @override
  State<StudyTogetherBase> createState() => _StudyTogetherBaseState();
}

class _StudyTogetherBaseState extends State<StudyTogetherBase> {
  int _pageIndex = 0;
  List<Widget> pages = [
    StudyTogetherMain(),
    StudyTogetherInquiry(),
    StudyTogetherCreate(),
    userState(),
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.black87,     // 선택된 아이콘 색상 고정
          unselectedItemColor: Colors.grey,  // 선택 안된 아이콘 색상 고정
          backgroundColor: Colors.white,     // 배경색 고정
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Study Together'),
        ),
        body: pages[_pageIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _pageIndex,
          onTap: (index) {
            print(_pageIndex);
            print(index);
            setState(() {
            _pageIndex = index; // 탭 변경
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '메인',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '조회',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.create),
              label: '생성',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '유저',
           ),
          ],
          
        )
      ),
    );
  }
}