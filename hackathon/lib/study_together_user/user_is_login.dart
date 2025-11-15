import 'package:flutter/material.dart';

import 'package:hackathon/study_together_data.dart';
import 'package:hackathon/server_communications/user_delete_api.dart';

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
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                Icon(Icons.person),
                SizedBox(width: 8),
                Text('학습자 :  '),
                Text(loginUser.userId),
                Expanded(child: SizedBox(),),
                ElevatedButton(
                  onPressed: () {
                    isLoggedIn = false;
                    loginUser = UserData();
                    widget.onUpdate();
                  },
                  child: Text('로그아웃'),
                ),
              ]),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            ElevatedButton(
              onPressed: () async {
                String response = await userDelete(loginUser.userId);
                print(response);
                if(response.startsWith('200') && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('회원 탈퇴가 성공적으로 완료되었습니다.')),
                  );
                  isLoggedIn = false;
                  loginUser = UserData();
                  widget.onUpdate();
                } else if(context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('회원 탈퇴에 실패했습니다: $response')),
                  );
                }
              },
              child:Text('회원 탈퇴'),
            )
          ],
        ),
      ),
    );
  }
}

