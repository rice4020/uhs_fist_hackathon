import 'package:flutter/material.dart';

class StudyTogetherMain extends StatefulWidget {
  const StudyTogetherMain({super.key});

  @override
  State<StudyTogetherMain> createState() => _StudyTogetherMainState();
}

class _StudyTogetherMainState extends State<StudyTogetherMain> {



  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('나의 스터디'),
          FutureBuilder(
            future: null,
            builder: (context, snapshot) {
              return Text('스터디 리스트');
            },
          )
        ],
      ),
    );
  }
}

