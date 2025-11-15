import 'dart:convert';
import 'package:http/http.dart' as http;

import 'server_info.dart';
import 'package:hackathon/study_together_data.dart';

Future<String> studyCreate(StudyTogetherData input) async {
  try{
    final url = '$serverUrl/study/create';
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      'study_name': input.studyTogetherName,
      'target': input.studyTogetherTarget,
      'weekday': input.dayOfWeek,
      'start_time': input.startTime,
      'end_time': input.endTime,
      'requirements': input.studyTogetherRequirements,
      'location': input.studyTogetherLocation,
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      // 요청 성공
      print("test data : ${response.body}");
      return '${response.statusCode}';
    } else {
      // 요청 실패
      print('Request failed with status: ${response.statusCode}.\n${response.body}');
      return '${response.statusCode} : ${response.body}';
    }
  } catch (e) {
    print('Error: $e');
    return '$e';
  }  
}