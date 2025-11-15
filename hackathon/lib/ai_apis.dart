import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GeminiTestWidget extends StatefulWidget {
  @override
  _GeminiTestWidgetState createState() => _GeminiTestWidgetState();
}

class _GeminiTestWidgetState extends State<GeminiTestWidget> {
  String responseText = "응답 대기 중...";

  @override
  void initState() {
    super.initState();
    sendTestMessage();
  }

  Future<void> sendTestMessage() async {
    const apiKey = "AIzaSyDoH_odH-CrdrCn7eshXXIEcFGGqEH9Qbs";
    const apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

    final headers = {
      "Content-Type": "application/json",
      "x-goog-api-key": apiKey,
    };

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text": "안녕"
            }
          ]
        }
      ]
    });

    try {
      final response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 구조에 맞춰서 응답을 파싱해야 함
        print(data);
        final reply = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          responseText = reply;
        });
      } else {
        setState(() {
          responseText = "실패: ${response.statusCode} ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        responseText = "에러 발생: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(responseText);
  }
}
