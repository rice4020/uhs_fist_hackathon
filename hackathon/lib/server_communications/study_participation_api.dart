import 'dart:convert';
import 'package:http/http.dart' as http;

import 'server_info.dart';

Future<String> studyParticipation(String inputStudy, String inputUser) async {
  try{
    print('참여 API 진입');
    final url = '$serverUrl/study/join';
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      'study_name': inputStudy,
      'username': inputUser,
    });
    print('요청 준비');
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    print('요청 완료');
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