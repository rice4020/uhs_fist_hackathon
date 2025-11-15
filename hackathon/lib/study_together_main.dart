import 'package:flutter/material.dart';
import 'package:hackathon/server_communications/study_leave_api.dart';

import 'study_together_data.dart';
import 'server_communications/study_participated_list_api.dart';
import 'server_communications/study_check_and_delete_api.dart';

class StudyTogetherMain extends StatefulWidget {
  const StudyTogetherMain({super.key});

  @override
  State<StudyTogetherMain> createState() => _StudyTogetherMainState();
}

class _StudyTogetherMainState extends State<StudyTogetherMain> {
  List<StudyTogetherData> studyTogetherList = [];
  @override
  void initState() {
    super.initState();
    if(isLoggedIn) {
      initializeData();
    }
  }

  void initializeData() async {
    studyTogetherList = await studyParticipationList(loginUser.userId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isLoggedIn == false ? Center(child: Text('로그인이 필요합니다.')):FutureBuilder(
        future: studyParticipationList(loginUser.userId),
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
                if(studyTogetherList.isEmpty){
                  return Center(
                    child:Text('참여한 스터디가 없습니다.') ,
                  );
                }
                return Container(
                  margin: EdgeInsets.all(MediaQuery.of(context).size.height * 0.05),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
                            onPressed: () async {
                              if(isLoggedIn){
                                String response = await studyLeave(study.studyTogetherName, loginUser.userId);
                                print(response);
                                if(response.startsWith('200') && context.mounted) {
                                  await studyCheckAndDelete(study);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('스터디 탈퇴가 성공적으로 완료되었습니다.')),
                                  );
                                } else if(context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('스터디 탈퇴에 실패했습니다: $response')),
                                  );
                                }
                              } else if(context.mounted){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('로그인이 필요합니다.')),
                                );
                              }
                              setState(() {});
                            },
                            child:Text('탈퇴하기'),
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

