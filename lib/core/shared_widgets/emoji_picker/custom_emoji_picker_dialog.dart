import 'package:perfect_order/core/shared_widgets/emoji_picker/custom_emoji_picker.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/core/shared_widgets/text_form_field/custom_search_text_form_field.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:perfect_order/core/utils/dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum TriggerArrangement {
  vertical,
  horizontal
}

class CustomEmojiPickerDialog extends StatefulWidget {

  final Emoji? emoji;
  final String title;
  final String instruction;
  final Function(Emoji?)? trigger;
  final TriggerArrangement triggerArrangement;
  final Function(Category?, Emoji)? onEmojiSelected;

  const CustomEmojiPickerDialog({
    super.key,
    this.emoji,
    this.trigger,
    this.onEmojiSelected,
    this.title = 'Select an emoji',
    this.instruction = 'Pick your emoji',
    this.triggerArrangement = TriggerArrangement.horizontal,
  });

  @override
  State<CustomEmojiPickerDialog> createState() => _CustomEmojiPickerDialogState();
}

class _CustomEmojiPickerDialogState extends State<CustomEmojiPickerDialog> {
  
  Emoji? emoji;
  String get title => widget.title;
  String get instruction => widget.instruction;

  bool get hasEmoji => emoji != null;
  Function(Emoji?)? get trigger => widget.trigger;
  TriggerArrangement get triggerArrangement => widget.triggerArrangement;
  Function(Category?, Emoji)? get onEmojiSelected => widget.onEmojiSelected;

  @override
  void initState() {
    super.initState();

    emoji = widget.emoji;
  }

  Widget get _trigger {

    /// Instruction
    final Widget instructionWidget = CustomBodyText(
      instruction,
      lightShade: true,
      textAlign: TextAlign.left,
    );

    final Widget emojiWidget = Container(
      width: 80,
      height: 80,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey.shade700),
        borderRadius: BorderRadius.circular(80)
      ),
      child: hasEmoji 
        ? Text(
            emoji!.emoji,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 60,)
          )
        : const Icon(Icons.add, size: 40)
    );

    Widget verticalArrangement = Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          
          instructionWidget,

          /// Spacer
          const SizedBox(height: 16,),
    
          emojiWidget
    
        ],
      ),
    );

    Widget horizontalArrangement = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
    
        emojiWidget,

        /// Spacer
        const SizedBox(width: 16,),
        
        instructionWidget,
    
      ],
    );

    return trigger == null ? (triggerArrangement == TriggerArrangement.vertical ? verticalArrangement : horizontalArrangement) : trigger!(emoji);
  }

  void _onEmojiSelected(Category? category, Emoji emoji) {
    setState(() {
      if(onEmojiSelected != null) onEmojiSelected!(category, emoji);
      this.emoji = emoji;
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        
        DialogUtility.showInfiniteScrollContentDialog(
          content: DialogContent(
            title: title,
            emoji: emoji,
            onEmojiSelected: _onEmojiSelected,
          ),
          heightRatio: 0.8,
          context: context,
        );
        
      },
      child: _trigger
    );

  }
}

class DialogContent extends StatefulWidget {

  final Emoji? emoji;
  final String title;
  final Function(Category?, Emoji)? onEmojiSelected;

  const DialogContent({
    super.key,
    this.emoji,
    required this.title,
    this.onEmojiSelected,
  });

  @override
  State<DialogContent> createState() => _DialogContentState();
}

class _DialogContentState extends State<DialogContent> {

  Emoji? emoji;
  String searchWord = '';
  List<Emoji> filteredEmojiEntities = [];

  String get title => widget.title;
  bool get isSearching => searchWord.isNotEmpty;
  bool get hasFilteredEmojies => filteredEmojiEntities.isNotEmpty;
  Function(Category?, Emoji)? get onEmojiSelected => widget.onEmojiSelected;

  @override
  void initState() {
    super.initState();

    emoji = widget.emoji;
  }

  Widget get filteredEmojies {
    
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0
      ), 
      itemCount: filteredEmojiEntities.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _onEmojiSelected(null, filteredEmojiEntities[index]);
          },
          child: Text(filteredEmojiEntities[index].emoji, style: const TextStyle(fontSize: 32),)
        );
      }
    );
  }

  Widget get unFilteredEmojies {
    return CustomEmojiPicker(
      onEmojiSelected: _onEmojiSelected,
    );
  }

  Widget get noResultsFound {
    return const CustomBodyText('No emojis found 😭', textAlign: TextAlign.center, fontSize: 20);
  }

  Widget get content {

    if(isSearching && hasFilteredEmojies) {

      return filteredEmojies;

    }else if(isSearching && !hasFilteredEmojies) {

      return noResultsFound;

    }else{

      return unFilteredEmojies;

    }

  }

  void _onEmojiSelected(Category? category, Emoji emoji) {
    setState(() {
      if(onEmojiSelected != null) onEmojiSelected!(category, emoji);
      this.emoji = emoji;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Title
        CustomTitleSmallText(title, padding: const EdgeInsets.all(16.0),),

        /// Search Text Form Field
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: CustomSearchTextFormField(
            isLoading: false,
            onChanged: (searchWord) async {
              final List<Emoji> newFilteredEmojiEntities = await EmojiPickerUtils().searchEmoji(searchWord, defaultEmojiSet);
              setState(() {
                this.searchWord = searchWord;
                filteredEmojiEntities = newFilteredEmojiEntities;
              });
            },
          ),
        ),

        /// Emoji Picker
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 500),
              child: AnimatedSwitcher(
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  key: ValueKey('$isSearching $hasFilteredEmojies'),
                  child: content,
                )
              )
            ),
          )
        ),

      ],
    );

  }
}