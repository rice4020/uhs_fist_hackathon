import 'package:flutter/material.dart';
import 'package:hackathon/server_communications/study_inquiry_api.dart';

import 'study_together_data.dart';
import 'server_communications/study_participation_api.dart';
import 'ai_api.dart';

class StudyTogetherInquiry extends StatefulWidget {
  const StudyTogetherInquiry({super.key});

  @override
  State<StudyTogetherInquiry> createState() => _StudyTogetherInquiryState();
}

class _StudyTogetherInquiryState extends State<StudyTogetherInquiry> {

  List<StudyTogetherData> studyTogetherList = [];
  List<StudyTogetherData> aiFilteredStudyList = [];
  TextEditingController aiSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future<List<StudyTogetherData>> refreshData() async {
    if(aiFilteredStudyList.isEmpty){
      studyTogetherList = await studyInquiry();
      return studyTogetherList;
    } else{
      return aiFilteredStudyList;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width * 0.1,
                    MediaQuery.of(context).size.height * 0.05,
                    MediaQuery.of(context).size.width * 0.1,
                    MediaQuery.of(context).size.height * 0.05
                  ),
                  child: TextFormField(
                    controller: aiSearchController,
                    decoration: InputDecoration(
                      labelText: 'ai 스터디 검색 ex)나는 OOO공부를 하고 싶고 시간은 HH:MM ~ HH:MM 사이가 좋아',
                      border: UnderlineInputBorder()
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  String prompt = studyTogetherList.map((e) => e.toLineStrint()).join('\n');
                  prompt += 
                  '''
                  \n위 스터디들 중에서 내가 원하는 조건에 맞거나 추천하는 스터디 이름를 출력해줘 
                  스터디 이름들의 출력 방식은 ,로 구분해주고 다른 부가 설명은 하지마.
                  내 조건은 아래와 같아.\n\n 
                  ''';
                  prompt += aiSearchController.text;
                  print(prompt);
                  String result = await sendGeminiPrompt(prompt);
                  print(result);
                  for (var study in studyTogetherList) {
                    if (result.contains(study.studyTogetherName)) {
                      aiFilteredStudyList.add(study);
                    }
                  }
                  refreshData();
                  setState(() {});
                },
                child: Text('AI 검색'),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.1),
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: refreshData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: SizedBox(child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  studyTogetherList = snapshot.data!;
                  return ListView.builder(
                    itemCount: studyTogetherList.length,
                    itemBuilder: (context, index) {
                      final study = studyTogetherList[index];
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
                                      String response = await studyParticipation(study.studyTogetherName, loginUser.userId);
                                      print(response);
                                      if(response.startsWith('200') && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('스터디 참여가 성공적으로 완료되었습니다.')),
                                        );
                                      } else if(context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('스터디 참여에 실패했습니다: $response')),
                                        );
                                      }
                                    } else if(context.mounted){
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('로그인이 필요합니다.')),
                                      );
                                    }
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
            ),
          ),
        ],
      )
    );
  }
}