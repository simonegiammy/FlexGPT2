
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class AIProvider {
 
 
  static Stream<OpenAIStreamChatCompletionModel>? generateResponse(List<types.Message> messages){
    print(messages.map((e) => (e as types.TextMessage).author.id).toList());
    try {
      final chatStream = OpenAI.instance.chat.createStream(
        model: "gpt-3.5-turbo",
        seed: 6,
        messages: [
          for (types.Message message in messages.reversed.toList())
            OpenAIChatCompletionChoiceMessageModel(
                role: message.author.id == "assistant"? OpenAIChatMessageRole.assistant: OpenAIChatMessageRole.user,
                content: [
                  OpenAIChatCompletionChoiceMessageContentItemModel.text((message as types.TextMessage).text),
                ]),
        ],
        temperature: 0.4,
        maxTokens: 3500,
      );

      return chatStream;
    } catch (e) {
      print(e);
    }
    return null;
    // Processa
  }
}
