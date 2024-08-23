
import 'dart:async';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flex_gpt/ai_provider.dart';
import 'package:flex_gpt/storage.dart';
import 'package:flex_gpt/style.dart';
import 'package:flex_gpt/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:macos_ui/macos_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int id = 0;
  final List<types.Message> _messages = [];
  TextEditingController textController = TextEditingController();
  final _user = const types.User(id: 'me');
  final _assistant = const types.User(id: 'assistant');

  @override
  void initState() {
   textController.addListener((){
    setState(() {
      
    });
   });
    super.initState();
  }
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
  

  void showDialog() async {
    TextEditingController controller = TextEditingController();
    String? key = await Storage.getApiKey();
    showMacosAlertDialog(
  context: context,
  builder: (_) => MacosAlertDialog(
    appIcon: Image.asset('assets/icon/icon.png'),
    title: Text(
      'Modifica API Key',
      style: MacosTheme.of(context).typography.headline,
    ),
    message: Column(
      children: [
        Text(
          'API KEY attualmente in uso: *****${key!.substring(key.length-6)}',
          textAlign: TextAlign.center,
          style: MacosTypography.of(context).headline,
        ),
        const SizedBox(
          height: 12,
        ),
        MacosTextField(
          placeholder: 'Inserisci la tua API Key',
          controller: controller,
        )
      ],
    ),

    primaryButton: PushButton(
      controlSize: ControlSize.large,
      child: const Text('Salva API Key'),
      onPressed: () {
       Storage.saveApiKey(controller.text);
        Navigator.pop(context);
      },
    ),
     secondaryButton: PushButton(
      secondary: true,
      controlSize: ControlSize.large,
      child: const Text('Chiudi'),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  ),
);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.gray,
      body: Column(
        children: [
          
           Align(
            alignment: Alignment.topRight,
            child: Row(
              children: [
                Padding(
                  padding:  const EdgeInsets.all(8.0),
                  child: PushButton(
                    onPressed: () {
                      exit(0);
                    },
                    child:const  Text(
                    "Chiudi",
                  ), controlSize:ControlSize.large)
                ),
              
                 Expanded(
                  child:Container()
                  ),
                    Padding(
                  padding:  const EdgeInsets.all(8.0),
                  child: PushButton(
                    secondary: true,
                    onPressed: () {
                     Utils.goToUrl("https://chatgpt.com");
                    },
                    child:const  Text(
                    "Apri chatGPT",
                  ), controlSize:ControlSize.large)
                ), 
                   Padding(
                    
                  padding:  const EdgeInsets.all(8.0),
                  child: PushButton(
                    secondary: true,
                    onPressed: () {
                     showDialog();
                    },
                    child:const  Text(
                    "Modifica API Key",
                  ), controlSize:ControlSize.large)
                ),

              ],
            ),
          ),
          Expanded(
            child: Chat(
              user: _user,
              customBottomWidget: Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                child: MacosTextField(
                  textInputAction: TextInputAction.send,
                  maxLines: null,
                  suffix: Padding(
                    padding: const EdgeInsets.all(12),
                    child: MacosIcon(
                      CupertinoIcons.paperplane,
                     color: textController.text.isEmpty? Colors.grey: AppStyle.blue,
                      size: 24,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  controller: textController,
                  placeholder: "Scrivi un messaggio...",
                  onSubmitted: (value) {
                    _handleSendPressed(types.PartialText(text: value));
                    textController.clear();
                  },
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins'
                  ),
                  decoration: const BoxDecoration(
                    color: AppStyle.secondaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(8))
                  ),
                ),
              ),
              bubbleBuilder: (child, {required message, required nextMessageInGroup}) {
                return Container(
                  padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color:  message.author.id == "me"? AppStyle.blue:
                      AppStyle.ligthGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  child: child,
                
                );
              },
              textMessageBuilder: (p0, {required messageWidth, required showName}) {
                return TexMarkdown(
                  p0.text, 
                  followLinkColor: true,
                  style: const TextStyle(
                    color: 
                    Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins'
                  ),
                );  
              },
              theme: const DarkChatTheme(
                backgroundColor: Colors.transparent,
                inputTextStyle: TextStyle(
                  fontFamily: 'Poppins'
                )
              ),
              onSendPressed: _handleSendPressed,
              messages: _messages),
          ),
        ],
      ),
    );
  }
}