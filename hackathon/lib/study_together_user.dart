import 'package:flutter/material.dart';

import 'study_together_data.dart';
import 'study_together_user/user_is_login.dart';
import 'study_together_user/user_is_not_login.dart';


class userState extends StatefulWidget {
  const userState({super.key});

  @override
  State<userState> createState() => _userStateState();
}

class _userStateState extends State<userState> {
    void updateParent() {
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User State'),
      ),
      body: Center(
        child: isLoggedIn
            ? isLogin(onUpdate: updateParent,)
            : isNotLogin(onUpdate: updateParent,),
      ),
    );
  }
}