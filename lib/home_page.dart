
import 'dart:async';

import 'package:dart_openai/dart_openai.dart';
import 'package:flex_gpt/ai_provider.dart';
import 'package:flex_gpt/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:gpt_markdown/gpt_markdown.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int id = 0;
  List<types.Message> _messages = [];
  final _user = const types.User(
    id: 'me',
  );
   final _assistant = const types.User(
    id: 'assistant',
  );

   void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: "${id++}", 
      text: message.text,
    );

    _addMessage(textMessage);
    
    _generateResponse();
  }
  
  void _generateResponse() async {
   
    Stream<OpenAIStreamChatCompletionModel>? chatStream = AIProvider.generateResponse(_messages);
    final textMessage = types.TextMessage(
      author: _assistant,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: "${id++}", 
      text: "",
    );  
    _messages.insert(0, textMessage);
    StreamSubscription<OpenAIStreamChatCompletionModel>? _subscription = 
     chatStream!.listen(
            (streamChatCompletion) {
              final content = streamChatCompletion.choices.last.delta.content;
              if (content?.first?.text != null) {
                setState(() {
                 final lastMessage = _messages.first;
                  _messages.removeAt(0);
                  _messages.insert(0, types.TextMessage(
                     author: _assistant,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: lastMessage.id, 
      text: (lastMessage as types.TextMessage).text + content!.first!.text!,
                  ));
                });
              }
            },
            onDone: () async {
             
              return;
            },
          );
  }
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppStyle.secondaryColor.withOpacity(0.6),
      body: Chat(
        
        user: _user,
        bubbleBuilder: (child, {required message, required nextMessageInGroup}) {
          return Container(
            padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color:  message.author.id == "me"? AppStyle.secondaryColor.withOpacity(0.1):
                AppStyle.secondaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            child: child,
          
          );
        },
        textMessageBuilder: (p0, {required messageWidth, required showName}) {
          return TexMarkdown(
            p0.text, 
            followLinkColor: true,
            style: TextStyle(
              color: 
              Colors.white,
              fontSize: 16,
              fontFamily: 'Poppins'
            ),
           
          );



        },
        theme: DarkChatTheme(
          inputTextStyle: TextStyle(
            fontFamily: 'Poppins'
          )
        ),
        onSendPressed: _handleSendPressed,
        messages: _messages),
    );
  }
}