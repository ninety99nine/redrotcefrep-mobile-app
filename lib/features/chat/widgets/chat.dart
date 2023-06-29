import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_text_form_field.dart';

import '../../../core/constants/constants.dart' as constants;
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../models/chat_message.dart';
import './../models/prompt.dart';
import 'dart:convert';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> {
  static const String openaiApiUrl = constants.openaiApiUrl;
  final List<ChatMessage> _messages = <ChatMessage>[];
  final List<Prompt> _prompts = <Prompt>[];
  AudioPlayer audioPlayer = AudioPlayer();
  bool isLoading = false;
  String question = '';

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);

  /// This allows us to access the state of CustomTextFormFieldState widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomTextFormFieldState> _customTextFormFieldState = GlobalKey<CustomTextFormFieldState>();

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void _handleSubmitted() async {

    /// Check if question is not empty
    if(question.isNotEmpty) {

      /// Add message to list of messages
      addMessage(question);

      /// Clear the text field controller
      _customTextFormFieldState.currentState!.controller.clear();

      try {

        /// Get response from OpenAI
        String openaiMessage = await _getOpenAIResponse();

        /// Add message to list of messages
        addMessage(openaiMessage, isSent: false);

      } catch (e) {

        print(e);
        
        /// Show error message
        SnackbarUtility.showErrorMessage(message: 'Bonako can\'t respond at the moment. Please try again later');

      }

    }else{

      /// Show info message
      SnackbarUtility.showInfoMessage(message: 'Enter a message');

    }
  }

  void addMessage(String text, { bool isSent = true }) {
    
    /// Create message
    ChatMessage message = ChatMessage(message: text, isSent: isSent);

    /// Add message to list of messages
    setState(() => _messages.insert(0, message));

  }

  Future<String> _getOpenAIResponse() async {

    /// Start loader
    _startLoader();
    
    /// Add prompt if it's empty
    if(_prompts.isEmpty) {

      /// Add system prompt
      _prompts.add(Prompt(
        content: 'Your name is Bonako. Instead of saying "As an AI language model" you say "As Bonako". You are a helpful assistant that gives smart counsel to entrepreneurs in botswana running any business',
        role: 'system'
      ));

    }

    /// Add user prompt
    _prompts.add(Prompt(content: question, role: 'user'));

    print(_prompts.map((prompt) => {
        "role": prompt.role,
        "content": prompt.content
      }).toList());

    /// Prepare headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer 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'
    };

    /// Prepare body
    String body = json.encode({
      "messages": _prompts.map((prompt) => {
        "role": prompt.role,
        "content": prompt.content
      }).toList(),
      "max_tokens": 200,
      "temperature": 0.5,
      "model": 'gpt-3.5-turbo',
    });

    /// Get response from OpenAI
    final response = await http.post(

      /// OpenAI API URL
      Uri.parse(openaiApiUrl),

      /// Headers
      headers: headers,

      /// Body
      body: body

    );

    if (response.statusCode == 200) {

      /// Decode response
      final data = json.decode(response.body);

      /// Get role
      final role = data['choices'][0]['message']['role'];

      /// Get content
      final content = data['choices'][0]['message']['content'];

      /// Add prompt
      _prompts.add(Prompt(content: content, role: role));

      /// Play success sound
      audioPlayer.play(AssetSource('sounds/success.mp3'));

      /// Stop loader
      _stopLoader();

      return content;

    } else {

      /// Stop loader
      _stopLoader();

      /// Error Message
      throw Exception('Failed to load response');

    }
    
  }

  Widget _buildChatMessage(ChatMessage message) {
    final bool isSent = message.isSent;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: isSent ? null : Colors.white,
              child: isSent ? const Text('Me') : Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.network(
                  'https://lh3.googleusercontent.com/drive-viewer/AAOQEOTMO9r3B6lgBoPe7hRd4n8cUAnJnl6lcJgCwcq1GABL0JXcFum4ESRwrDN7QkrjICkyEwqzgs1An9vDOf0BVuWSqHl2=s2560',
                ),
              )
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(isSent ? "You" : "Bonako", style: Theme.of(context).textTheme.titleMedium),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    message.message,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16, left: 24, right: 16),
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: <Widget>[
              Flexible(
                child: CustomTextFormField(
                  maxLength: 200,
                  initialValue: question,
                  hintText: "Ask a question",
                  key: _customTextFormFieldState,
                  onChanged: (String value) {
                    question = value;
                  },
                  onFieldSubmitted: (String value) {
                    _handleSubmitted();
                  },
                )
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _handleSubmitted(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[

        // Column with title and subtitle to inform the user that they can chat with Bonako
        SizedBox(
          width: double.infinity,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 500),
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              child: _messages.isNotEmpty ? Container() : Container(
                padding: const EdgeInsets.only(top: 24, bottom: 16, left: 16, right: 16),
                child: Column(
                  children: const [
            
                    /// Title
                    CustomTitleLargeText(
                      'Chat with Bonako',
                      margin: EdgeInsets.only(bottom: 16),
                    ),
            
                    /// Subtitle
                    CustomBodyText(
                      'Ask Bonako a question to help you with your business. Bonako can give smart counsel to entrepreneurs in Botswana running any business',
                      textAlign: TextAlign.center,
                      lightShade: true,
                    ),
            
                  ],
                ),
              ),
            ),
          )
        ),

        const Divider(),
    
        /// List of messages
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(16.0),
            itemCount: _messages.length,
            itemBuilder: (_, int index) => _buildChatMessage(_messages[index]),
          ),
        ),
    
        /// Loader
        isLoading 
          ? Container(
            margin: const EdgeInsets.only(bottom: 24.0),
            height: 20,
            width: 20,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
            )
          ) 
          : Container(),
    
        /// Text composer
        _buildTextComposer(),
        
      ],
    );
  }
}