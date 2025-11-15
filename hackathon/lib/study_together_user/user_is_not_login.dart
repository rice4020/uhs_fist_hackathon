import 'package:flutter/material.dart';

import 'user_create.dart';
import 'package:hackathon/study_together_data.dart';
import 'package:hackathon/server_communications/user_login_api.dart';

class isNotLogin extends StatefulWidget {
  const isNotLogin({super.key, required this.onUpdate});
  final VoidCallback onUpdate;

  @override
  State<isNotLogin> createState() => _isNotLoginState();
}

class _isNotLoginState extends State<isNotLogin> {
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
    return Container(
      margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.3, 0, MediaQuery.of(context).size.width * 0.3, 0),
      child: Column(
         children: [
          Text("로그인을 해주세요"),
          Form(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                TextFormField(
                  controller: _userIdController,
                  decoration: InputDecoration(
                    labelText: '학습자 아이디',
                  ),
                ),
                TextFormField(
                  controller: _authCodeController,
                  decoration: InputDecoration(
                    labelText: '학습자 식별 번호',
                  ),
                  obscureText: true,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1,),
                ElevatedButton(
                  onPressed: () async {
                    // 로그인 버튼 클릭 시 동작
                    if(_validate()){
                      UserData newUser = UserData();
                      newUser.userId = _userIdController.text;
                      newUser.authCode = _authCodeController.text;
                      String response = await userLogin(newUser);
                      if(response.startsWith('200') == false && context.mounted) {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('로그인 실패'),
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
                        isLoggedIn = true;
                        loginUser = newUser;
                        widget.onUpdate();
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
                  child: Text('로그인'),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UserCreate()));
                  },
                  child: Text('새로 왔어요!'),
                ),
              ],
            ),  
          )
         ],
      )
    );
  }
}