import 'dart:convert';
import 'package:http/http.dart' as http;

import 'server_info.dart';

Future<String> studyLeave(String studyName, String username) async {
  try{
    final url = '$serverUrl/study/leave';
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      'study_name': studyName,
      'username': username,
    });

    final response = await http.delete(
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