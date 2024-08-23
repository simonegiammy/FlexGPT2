import 'package:dart_openai/dart_openai.dart';
import 'package:flex_gpt/home_page.dart';
import 'package:flex_gpt/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:macos_ui/macos_ui.dart';

void main() async {
    await dotenv.load(fileName: ".env");

   OpenAI.apiKey =dotenv.env['OPENAI_KEY']!;
   String? key = await Storage.getApiKey();
   if (key != null){
      OpenAI.apiKey= key;
   }
   else{
    Storage.saveApiKey(dotenv.env['OPENAI_KEY']!);
   }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  MacosApp(
      title: 'FlexGPT',
      home: const  HomePage(),
      theme: MacosThemeData.dark()
    );

  }
}
