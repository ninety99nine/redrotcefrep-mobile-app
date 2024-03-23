import '../../../core/constants/constants.dart' as constants;
import 'package:bonako_demo/core/shared_models/percentage.dart';
import 'package:bonako_demo/core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import 'package:bonako_demo/core/shared_widgets/Loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/progress_bar/progress_bar.dart';
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_text_form_field.dart';
import 'package:bonako_demo/features/api/providers/api_provider.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/core/shared_widgets/chips/custom_choice_chip.dart';
import 'package:bonako_demo/features/chat/models/ai_assistant.dart';
import 'package:bonako_demo/features/chat/models/ai_message_category.dart';
import 'package:bonako_demo/features/subscriptions/widgets/subscribe/subscribe_modal_bottom_sheet/subscribe_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/user/repositories/user_repository.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/utils/stream_utility.dart';
import 'package:bonako_demo/core/utils/error_utility.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import '../services/ai_service.dart';
import '../models/ai_message.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:async';

class AiChatContent extends StatefulWidget {

  final bool showingFullPage;

  const AiChatContent({
    super.key,
    this.showingFullPage = true
  });

  @override
  AiChatContentState createState() => AiChatContentState();
}

class AiChatContentState extends State<AiChatContent> {
  ScrollController scrollController = ScrollController();
  List<AiMessageCategory> aiMessageCategories = [];
  AiMessageCategory? selectedAiMessageCategory;
  List<AiMessage> aiMessages = <AiMessage>[];
  final FocusNode _focusNode = FocusNode();
  AudioPlayer audioPlayer = AudioPlayer();
  AiAssistant? aiAssistant;
  int totalAiMessages = 0;
  
  bool isLoadingAiMessageCategories = false;
  bool isLoadingAiAssistant = false;
  String userContent = '';
  bool isWritting = false;
  Map serverErrors = {};

  StreamUtility streamUtility = StreamUtility();

  void _startWrittingLoader() => setState(() => isWritting = true);
  void _stopWrittingLoader() => setState(() => isWritting = false);
  void _startAiAssistantLoader() => setState(() => isLoadingAiAssistant = true);
  void _stopAiAssistantLoader() => setState(() => isLoadingAiAssistant = false);
  void _startAiMessageCategoryLoader() => setState(() => isLoadingAiMessageCategories = true);
  void _stopAiMessageCategoryLoader() => setState(() => isLoadingAiMessageCategories = false);

  bool get hasAiAssistant => aiAssistant != null;
  bool get showingFullPage => widget.showingFullPage;
  UserRepository get userRepository => authProvider.userRepository;
  bool get hasAiMessageCategories => aiMessageCategories.isNotEmpty;
  bool get hasSelectedAiMessageCategory => selectedAiMessageCategory != null;
  ApiProvider get apiProvider => Provider.of<ApiProvider>(context, listen: false);
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  final GlobalKey<CustomTextFormFieldState> _customTextFormFieldState = GlobalKey<CustomTextFormFieldState>();

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalListViewInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalListViewInfiniteScrollState>();

  @override
  void initState() {
    super.initState();

    requestShowAiAssistant();
    requestShowAiMessageCategories();

    /// Add a listener on the initial streamController of the streamUtility
    addListenerToStreamController();

    /// After the listener of the initial streamController of the streamUtility is closed
    /// when the onDone() method is executed, we should have a new streamController. We 
    /// need to add a new listener on this new streamController so that we are able to
    /// capture the stream updates.
    streamUtility.onStreamControllerChanged = addListenerToStreamController;
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    audioPlayer.dispose();
    streamUtility.dispose();
  }

  void addListenerToStreamController() {
    streamUtility.streamController.stream
      .listen(updateAiMessage)
      .onError((e) {
        SnackbarUtility.showErrorMessage(message: 'Sorry, experienced a few issues while researching');
        _stopWrittingLoader();
        printError(info: e);
      });
  }

  /// Request the AI Assistant
  void requestShowAiAssistant() {

    if(isLoadingAiAssistant) return;

    _startAiAssistantLoader();
    
    userRepository.showAiAssistant().then((dio.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {
        
        setState(() {

          aiAssistant = AiAssistant.fromJson(response.data);

        });

      }

    }).whenComplete(() {
      
      _stopAiAssistantLoader();

    });

  }

  /// Request the AI Message Categories
  void requestShowAiMessageCategories() {

    if(isLoadingAiMessageCategories) return;

    _startAiMessageCategoryLoader();
    
    apiProvider.apiRepository.get(
      url: apiProvider.apiHome!.links.showAiMessageCategories
    ).then((dio.Response response) async {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        aiMessageCategories = (response.data['data'] as List).map((aiMessageCategory) => AiMessageCategory.fromJson(aiMessageCategory)).toList();

        final int? lastSelectedAiMessageCategoryId = await AiService.getAiMessageCategoryIdFromDeviceStorage();
        
        setState(() {

          /// If the last selected AI Message category id exists
          if(lastSelectedAiMessageCategoryId != null) {

            /// Set the AI Message category that matches this specified category id
            selectedAiMessageCategory = aiMessageCategories.firstWhereOrNull((aiMessageCategory) => aiMessageCategory.id == lastSelectedAiMessageCategoryId);

          }

          /// If the selected AI Message category is still not set, then set the first AI Message category available on the list
          selectedAiMessageCategory ??= aiMessageCategories.first;

          /// If the last selected AI Message category id does not exist
          if(lastSelectedAiMessageCategoryId == null) {

            /// Save the selected AI Message category id on the device storage
            AiService.saveAiMessageCategoryIdOnDeviceStorage(selectedAiMessageCategory!.id);

          }

        });

      }

    }).whenComplete(() {
      
      _stopAiMessageCategoryLoader();

    });

  }

  void updateAiMessage(event) {

    if(_customVerticalListViewInfiniteScrollState.currentState != null) {

      final AiMessage? lastAiMessage = _customVerticalListViewInfiniteScrollState.currentState!.data.firstOrNull;

      if(lastAiMessage != null) {

        /// Make sure that this is not a validation response
        if(streamUtility.statusCode == 200 || streamUtility.statusCode == 201) {
          
          ///  Get the orginal message chunk
          String originalMessageChuck = utf8.decode(event);

          /// Remove '<END_STREAMING_SSE>' from the original message chuck string
          String messageChuck = originalMessageChuck.replaceAll('<END_STREAMING_SSE>', '');

          if(messageChuck.isNotEmpty) {

            /// Append the message content to the existing message content
            lastAiMessage.assistantContent += messageChuck;

            /// Update the message
            _customVerticalListViewInfiniteScrollState.currentState!.updateItemAt(0, lastAiMessage);
            
          }

          /// When we have reached the end of our stream
          if(originalMessageChuck.contains('<END_STREAMING_SSE>')) {

            scrollToTop();

            _stopWrittingLoader();

            audioPlayer.play(AssetSource('sounds/success.mp3'), mode: PlayerMode.lowLatency);

          }

        }

      }

    }

  }

  void requestCreateAiMessage() {

    if(isWritting) return;

    scrollToTop();

    _resetServerErrors();

    if(userContent.isNotEmpty) {

      _startWrittingLoader();

      /// Clear the text field controller
      _customTextFormFieldState.currentState!.controller.clear();

      /// Temporarily capture the user content
      final String currUserContent = userContent;

      /// Empty the user content
      userContent = '';

      final AiMessage aiMessage = AiMessage.fromJson({
        'id': null,
        'assistantContent': '',
        'userContent': currUserContent,
        'updatedAt': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      setState(() {

        /// Add the message
        if(_customVerticalListViewInfiniteScrollState.currentState != null) {
          _customVerticalListViewInfiniteScrollState.currentState!.insetItemAt(0, aiMessage);
          totalAiMessages = _customVerticalListViewInfiniteScrollState.currentState!.totalItems;
        }

      });

      userRepository.createAiMessageWhileStreaming(
        categoryId: selectedAiMessageCategory!.id,
        streamUtility: streamUtility,
        userContent: currUserContent
      ).then((response) async {

        if(streamUtility.statusCode == 200 || streamUtility.statusCode == 201) {
          
          requestShowAiAssistant();

        }

        /// The updateAiMessage will handle the stream response data
        
      }).onError((dio.DioException exception, stackTrace) {

        _stopWrittingLoader();

        removeLastAiMessage();

        ErrorUtility.setServerValidationErrors(setState, serverErrors, exception, streamUtility: streamUtility);

      }).catchError((error) {

        _stopWrittingLoader();

        printError(info: error.toString());

        removeLastAiMessage();

        SnackbarUtility.showErrorMessage(message: 'Can\'t show message');

      });

    }else{

      SnackbarUtility.showInfoMessage(message: 'Enter a message');

    }

  }

  void removeLastAiMessage() {

    if(_customVerticalListViewInfiniteScrollState.currentState != null) {
      
      /// Remove the last AI Message
      _customVerticalListViewInfiniteScrollState.currentState!.removeItemAt(0);
    
    }

  }

  Future<dio.Response> startRequest() {
    _customVerticalListViewInfiniteScrollState.currentState!.sentFirstRequest = false;
    return _customVerticalListViewInfiniteScrollState.currentState!.startRequest();
  }

  void scrollToTop() {
    return _customVerticalListViewInfiniteScrollState.currentState!.scrollToTop(milliseconds: 0);
  }

  void removeAiMessages() {
    _customVerticalListViewInfiniteScrollState.currentState!.removeAllItems();
  }

  /// Reset the server errors
  void _resetServerErrors() => setState(() => serverErrors = {});

  /// Render each request item as an OrderItem
  Widget onRenderItem(aiMessage, int index, List aiMessages, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) {

    final bool isNotFirstItem = index != 0;
  
    /// Show the existing content between the user and ai
    return _buildUserAndAiContent(aiMessages[index], showDivider: isNotFirstItem);

  }

  /// Render each request item as an AiMessage
  AiMessage onParseItem(aiMessage) => AiMessage.fromJson(aiMessage);
  Future<dio.Response> requestShowAiMessages(int page, String searchWord) async {

    return userRepository.showAiMessages(
      categoryId: selectedAiMessageCategory!.id
    ).then((dio.Response response) {

      if( response.statusCode == 200 ) {
        
        setState(() {

          totalAiMessages = response.data['total'];

        });

      }

      return response;

    });
  }

  Widget get _aiAssistantWidget {

    final Percentage? unusedTokensPercentage = aiAssistant?.attributes.unusedTokensPercentage;
    
    return AnimatedSize(
      clipBehavior: Clip.none,
      duration: const Duration(milliseconds: 500),
      child: SizedBox(
        width: double.infinity,
        child: AnimatedSwitcher(
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
          child: Container(
            key: ValueKey(hasAiAssistant),
            padding: EdgeInsets.only(
              top: hasAiAssistant ? 16 : 0,
              left: hasAiAssistant ? 16 : 0,
              right: hasAiAssistant ? (showingFullPage ? 16 : 0) : 0,
              bottom: hasAiAssistant ? (hasAiMessageCategories ? 4 : 16) : 0,
            ),
            child: Column(
              children: hasAiAssistant ? [
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    SizedBox(
                      width: 40,
                      child: Image.asset('assets/images/logo-simplified-black.png'),
                    ),
                    
                    /// Spacer
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// Subscription Left In Percentages
                          CustomBodyText('AI Usage (${unusedTokensPercentage!.valueSymbol} left)', lightShade: true,),
                      
                          /// Spacer
                          const SizedBox(height: 4),
                          
                          /// Subscription Left Progress Bar
                          CustomProgressBar(percentage: unusedTokensPercentage.value),
                    
                        ],
                      ),
                    ),
                    
                    if(!showingFullPage) ...[
                      
                      /// Spacer
                      const SizedBox(width: 16),

                      IconButton(
                        icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
                        onPressed: () => Get.back()
                      ),
                    ]
                    
                  ],
                )
          
              ] : [],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _categoryChoices {
    return AnimatedSize(
      clipBehavior: Clip.none,
      duration: const Duration(milliseconds: 500),
      child: SizedBox(
        width: double.infinity,
        child: AnimatedSwitcher(
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
          child: SingleChildScrollView(
            key: ValueKey(aiMessageCategories.length),
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                top: hasAiAssistant ? 0 : 8.0,
                bottom: hasAiAssistant ? 4.0 : 8.0,
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                alignment: WrapAlignment.start,
                spacing: 8,
                children: [
                  ...aiMessageCategories.map((aiMessageCategory) {
                  
                    final selected = aiMessageCategory.id == selectedAiMessageCategory?.id;
                
                    /// Return this choice chip option
                    return CustomChoiceChip(
                      label: aiMessageCategory.name,
                      selected: selected,
                      onSelected: (_) {
                        if(!isWritting) {
                          setState(() {
                            
                            selectedAiMessageCategory = aiMessageCategory;

                            /// Make a new request to load the AI Messages that match the selected category
                            startRequest();

                          });
                        }
                      }
                    );
                  
                  })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get _subscribeModalBottomSheet {

    return Column(
      children: [
        
        if(!isLoadingAiAssistant && aiAssistant?.requiresSubscription == true) ...[

          const SizedBox(height: 16,),

          SubscribeModalBottomSheet(
            subscribeButtonAlignment: Alignment.center,
            header: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Image.asset('assets/images/logo-simplified-black.png'), 
                ),
                const SizedBox(width: 16,),
                const CustomBodyText(constants.appAiName),
              ],
            ),
            onResumed: requestShowAiAssistant,
            generatePaymentShortcode: userRepository.generateAiAssistantPaymentShortcode()
          ),

          const SizedBox(height: 16,),

        ]

      ],
    );

  }

  Widget get _textComposer {

    return Container(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: EdgeInsets.only(top: showingFullPage ? 4 : 4, bottom: showingFullPage ? 4 : 32, left: 24, right: 16),
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                if(hasAiAssistant && aiAssistant?.requiresSubscription == true) ...[

                  const Expanded(
                    child: CustomBodyText(
                      'Please subscribe so that I can assist you. I can help answer any questions you have 😊', 
                      padding: EdgeInsets.symmetric(vertical: 16),
                      color: Colors.white
                    ),
                  )

                ],

                if(hasAiAssistant && aiAssistant?.requiresSubscription == false) ...[

                  Flexible(
                    child: CustomTextFormField(
                      maxLength: 200,
                      color: Colors.white,
                      focusNode: _focusNode,
                      initialValue: userContent,
                      cursorColor: Colors.white,
                      key: _customTextFormFieldState,
                      hintText: isWritting ? "I'm thinking..." : "Ask me anything...",
                      onChanged: (String value) {
                        userContent = value;
                      },
                      onFieldSubmitted: (String value) {
                        
                        /// Create AI Message
                        requestCreateAiMessage();

                        /// Hide the keypad
                        _focusNode.unfocus();
                      
                      },
                    )
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: isWritting 
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CustomCircularProgressIndicator(
                            strokeWidth: 1,
                            size: 8
                          )
                        ) 
                      : IconButton(
                        icon: const Icon(Icons.send, color: Colors.white,),
                        onPressed: () {

                          /// Create AI Message
                          requestCreateAiMessage();

                          /// Hide the keypad
                          _focusNode.unfocus();

                        }
                      ),
                  ),

                ] 
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get noContentWidget {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        
        AnimatedSize(
          duration: const Duration(milliseconds: 500),
          child: Container(
            clipBehavior: Clip.antiAlias,
            width: MediaQuery.of(context).size.width * 0.8,
            margin: const EdgeInsets.only(top: 16, bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20)
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: double.infinity,
              child: Image.asset('assets/images/team_2.jpeg')
            ),
          ),
        ),

        CustomBodyText(selectedAiMessageCategory!.description),

        const SizedBox(height: 20),

        const Divider(height: 0),

      ],
    );
  }

  Widget get noMoreContentWidget {
    return noContentWidget;
  }

  Widget _buildUserAndAiContent(AiMessage aiMessage, { bool showDivider = true }) {

    return Column(
      children: [

        /// Build the user content
        _buildUserContent(aiMessage.userContent),

        /// Divider
        const Divider(height: 0),

        /// Build the assistant content
        _buildAssistantContent(aiMessage.assistantContent),

        /// Divider
        if(showDivider) const Divider(height: 0),

      ],
    );

  }

  Widget _buildUserContent(String userContent) {

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor,
              child: const CustomBodyText('Me', fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold,)
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              child: convertMarkdown(userContent),
            ),
          ),
        ],
      ),
    );

  }

  Widget _buildAssistantContent(String assistantContent) {

    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: 32,
              child: Image.asset('assets/images/logo-simplified-black.png'), 
            ),
          ),
          
          assistantContent.isEmpty ? Container(
            margin: const EdgeInsets.only(top: 12),
            child: const CustomCircularProgressIndicator(
              strokeWidth: 1,
              size: 8
            ),
          ) : Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              child: convertMarkdown(assistantContent),
            ),
          ),
        ],
      ),
    );

  }

  Widget convertMarkdown(String text) {

    List<TextSpan> spans = [];

    RegExp exp = RegExp(r'\*(.*?)\*');
    Iterable<RegExpMatch> matches = exp.allMatches(text);

    int currentMatchEnd = 0;
      
    TextSpan textSpan;

    for (RegExpMatch match in matches) {

      if (match.start > currentMatchEnd) {

        /// Other Text
        textSpan = TextSpan(
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.normal,
            height: 1.4
          ),
          text: text.substring(currentMatchEnd, match.start),
        );

        spans.add(textSpan);

      }

      /// The Bolded Text
      textSpan = TextSpan(
        text: match.group(1)?.capitalize,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.bold,
          height: 1.4
        ),
      );

      spans.add(textSpan);

      currentMatchEnd = match.end;
    }

    if (currentMatchEnd < text.length) {

      /// Other Text
      textSpan = TextSpan(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.normal,
          height: 1.4
        ),
        text: text.substring(currentMatchEnd),
      );

      spans.add(textSpan);
    }

    return RichText(
      text: TextSpan(
        children: spans,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[

        /// AI Assistant
        _aiAssistantWidget,

        /// Category choices
        _categoryChoices,

        /// Divider
        if(hasAiAssistant && hasAiMessageCategories) const Divider(height: 0),

        /// Loader
        if(!hasSelectedAiMessageCategory) ...[

          const Expanded(child: CustomCircularProgressIndicator())

        ],

        /// List of AI messages
        if(hasSelectedAiMessageCategory) ...[

          Expanded(
            child: CustomVerticalListViewInfiniteScroll(
              reverse: true,
              showSearchBar: false,
              showSeparater: false,
              onParseItem: onParseItem, 
              onRenderItem: onRenderItem,
              listPadding: EdgeInsets.zero,
              noContentWidget: noContentWidget,
              noMoreContentWidget: noMoreContentWidget,
              catchErrorMessage: 'Can\'t show messages',
              key: _customVerticalListViewInfiniteScrollState,
              loaderMargin: const EdgeInsets.symmetric(vertical: 32),
              onRequest: (page, searchWord) => requestShowAiMessages(page, searchWord),
              headerPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 16, right: 16)
            ),
          ),
      
          /// Text composer
          _textComposer,

          /// Subscribe Modal Bottom Sheet
          _subscribeModalBottomSheet,

          /// Divider - Separate the AI Chat and the App Bottom Navigation
          const SizedBox(height: 1)

        ]
        
      ],
    );
  }
}