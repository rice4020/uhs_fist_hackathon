import 'dart:convert';
import 'package:http/http.dart' as http;

import 'server_info.dart';
import 'package:hackathon/study_together_data.dart';

Future<List<StudyTogetherData>> studyParticipationList(String inputUser) async {
  try{
    final url = '$serverUrl/user/studies?username=$inputUser';
    List<StudyTogetherData> result = [];

    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      // 요청 성공
      print("test data : ${response.body}");
      final data = jsonDecode(response.body);
      List<dynamic> list = data["studies"];
      for (var item in list) {
        StudyTogetherData study = StudyTogetherData();
        study.studyTogetherName = item['study_name'];
        study.studyTogetherTarget = item['target'];
        study.dayOfWeek = item['weekday'];
        study.startTime = item['start_time'];
        study.endTime = item['end_time'];
        study.studyTogetherRequirements = item['requirements'];
        study.studyTogetherLocation = item['location'];
        result.add(study);
      }
      return result;
    } else {
      // 요청 실패
      print('Request failed with status: ${response.statusCode}.\n${response.body}');
      return [];
    }
  } catch (e) {
    print('Error: $e');
    return [];
  }  
}