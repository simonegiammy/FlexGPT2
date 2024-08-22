import 'package:dart_openai/dart_openai.dart';
import 'package:flex_gpt/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
    await dotenv.load(fileName: ".env");

  OpenAI.apiKey =dotenv.env['OPENAI_KEY']!;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'FlexGPT',
      home:  HomePage(),
      theme: ThemeData.dark(),
    );

  }
}
