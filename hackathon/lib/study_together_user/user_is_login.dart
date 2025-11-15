import 'package:flutter/material.dart';

import 'package:hackathon/study_together_data.dart';

class isLogin extends StatefulWidget {
  const isLogin({super.key, required this.onUpdate});
  final VoidCallback onUpdate;

  @override
  State<isLogin> createState() => _isLoginState();
}

class _isLoginState extends State<isLogin> {
  @override

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.person),
            SizedBox(width: 8),
            Text('학습자 :  '),
            Text(loginUser.userId),
            SizedBox(width: MediaQuery.of(context).size.width * 0.4),
            ElevatedButton(
              onPressed: () {
                isLoggedIn = false;
                loginUser = UserData();
                widget.onUpdate();
              },
              child: Text('로그아웃'),
            ),
          ]),
        ],
      ),
    );
  }
}

