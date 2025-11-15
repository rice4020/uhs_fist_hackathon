import 'package:flutter/material.dart';

import 'package:hackathon/study_together_data.dart';
import 'package:hackathon/server_communications/user_create_api.dart';

class UserCreate extends StatefulWidget {
  const UserCreate({super.key});

  @override
  State<UserCreate> createState() => _UserCreateState();
}

class _UserCreateState extends State<UserCreate> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _authCodeController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    _authCodeController.dispose();
    super.dispose();
  }

  bool _validate(){
    if(_userIdController.text.isEmpty || _authCodeController.text.isEmpty){
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새로 왔어요!'),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.3, 0, MediaQuery.of(context).size.width * 0.3, 0),
          child: Form(
            child: ListView(
              children: [
                TextFormField(
                  controller: _userIdController,
                  decoration: InputDecoration(
                    labelText: '사용할 학습자 아이디',
                  ),
                ),
                TextFormField(
                  controller: _authCodeController,
                  decoration: InputDecoration(
                    labelText: '사용할 식별 번호',
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if(_validate()){
                      UserData newUser = UserData();
                      newUser.userId = _userIdController.text;
                      newUser.authCode = _authCodeController.text;
                      String response = await userCreate(newUser);
                      if(response.startsWith('200') == false && context.mounted){
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('회원가입 실패'),
                              content: Text(response.substring(4)),
                              actions: [
                                TextButton(
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('확인'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      else{
                        if(context.mounted){
                          Navigator.pop(context);
                        }
                      }
                    }
                    else{
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('입력 오류'),
                            content: Text('모두 적어도 1자 이상 입력해주세요.'),
                            actions: [
                              TextButton(
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
                                child: Text('확인'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text('회원가입'),
                ),
              ],
            ),
          )
        )
      ),
    );
  }
}