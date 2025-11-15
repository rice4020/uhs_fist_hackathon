import 'package:flutter/material.dart';
import 'package:hackathon/server_communications/study_inquiry_api.dart';

import 'study_together_data.dart';
import 'package:hackathon/study_together_inquiry.dart';

class StudyTogetherInquiry extends StatefulWidget {
  const StudyTogetherInquiry({super.key});

  @override
  State<StudyTogetherInquiry> createState() => _StudyTogetherInquiryState();
}

class _StudyTogetherInquiryState extends State<StudyTogetherInquiry> {

  List<StudyTogetherData> studyTogetherList = [];

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() async {
    studyTogetherList = await studyInquiry();
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: studyInquiry(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            studyTogetherList = snapshot.data!;
            return ListView.builder(
              itemCount: studyTogetherList.length,
              itemBuilder: (context, index) {
                final study = studyTogetherList[index];
                return Container(
                  margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('스터디 이름: ${study.studyTogetherName}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('대상: ${study.studyTogetherTarget}'),
                          Text('요일: ${study.dayOfWeek}'),
                          Text('시작 시간: ${study.startTime}'),
                          Text('종료 시간: ${study.endTime}'),
                          Text('요구 사항: ${study.studyTogetherRequirements}'),
                          Text('장소: ${study.studyTogetherLocation}'),
                          ElevatedButton(
                            onPressed: (){
                              
                            },
                            child:Text('참여하기'),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Text('No data available');
          }
        },
      )
    );
  }
}