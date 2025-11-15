import 'package:flutter/material.dart';

import 'study_together_data.dart';
import 'server_communications/study_create_api.dart';
import 'server_communications/study_participation_api.dart';

class StudyTogetherCreate extends StatefulWidget {
  const StudyTogetherCreate({super.key});

  @override
  State<StudyTogetherCreate> createState() => _StudyTogetherCreateState();
}

class _StudyTogetherCreateState extends State<StudyTogetherCreate> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  StudyTogetherData newStudyTogether = StudyTogetherData();
  List<String> dayOfWeekItems = ['월', '화', '수', '목', '금', '토', '일'];

  Future<TimeOfDay> _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      );
    return time ?? TimeOfDay.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _requirementsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.0),
      child: Center(
        child: Form(
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '스터디 이름'),
              ),
              TextFormField(
                controller: _targetController,
                decoration: InputDecoration(labelText: '스터디 대상'),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Spacer(flex: 1,),
                  Text("스터디 모이는 요일 : "),
                  Spacer(flex: 1,),
                  DropdownButton<String>(
                    hint: Text(newStudyTogether.dayOfWeek == "" ? '요일 선택' : newStudyTogether.dayOfWeek),
                    items: dayOfWeekItems.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        newStudyTogether.dayOfWeek = value!;
                      });
                    }
                  ),
                  Spacer(flex: 3,),
                  Text("시작 시간 : "),
                  Spacer(flex: 1,),
                  OutlinedButton.icon(
                    onPressed: () async {
                      _startTime = await _pickTime();
                      print(_startTime);
                      setState(() {});
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text('${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                  Spacer(flex: 3,),
                  Text("종료 시간 : "),
                  Spacer(flex: 1,),
                  OutlinedButton.icon(
                    onPressed: () async {
                      _endTime = await _pickTime();
                      print(_endTime);
                      setState(() {});
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text('${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                  Spacer(flex: 1,),
                ],
              ),
              TextFormField(
                controller: _requirementsController,
                decoration: InputDecoration(labelText: '원할한 스터디를 위한 요구사항'),
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: '스터디 장소'),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.2,),
              ElevatedButton(
                onPressed: () async {
                  if(isLoggedIn == true){                  
                    newStudyTogether.studyTogetherName = _nameController.text;
                    newStudyTogether.studyTogetherTarget = _targetController.text;
                    newStudyTogether.startTime = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
                    newStudyTogether.endTime = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';
                    newStudyTogether.studyTogetherRequirements = _requirementsController.text;
                    newStudyTogether.studyTogetherLocation = _locationController.text;
                    String response = await studyCreate(newStudyTogether);
                    print(newStudyTogether.toLineStrint());
                    if(response.startsWith('200') == false && context.mounted) {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('스터디 생성 실패'),
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
                    else if (context.mounted){
                      studyParticipation(newStudyTogether.studyTogetherName, loginUser.userId);
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('스터디 생성 완료'),
                            content: Text('스터디가 성공적으로 생성되었습니다.'),
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
                      setState(() {});
                    }
                  }else{
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('로그인 필요'),
                          content: Text('스터디 생성을 위해서는 로그인이 필요합니다.'),
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
                  setState(() {});
                },
                child: Text('스터디 생성'),
              ),
            ],
          )
        ),
      )
    );
  }
}