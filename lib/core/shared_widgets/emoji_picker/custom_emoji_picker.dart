
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class CustomEmojiPicker extends StatelessWidget {

  final Function(Category?, Emoji)? onEmojiSelected;
  final TextEditingController? textEditingController;

  const CustomEmojiPicker({
    super.key,
    this.onEmojiSelected,
    this.textEditingController
  });

  @override
  Widget build(BuildContext context) {

    Color primaryColor = Theme.of(context).primaryColor;

    return EmojiPicker(
      onEmojiSelected: onEmojiSelected,
      textEditingController: textEditingController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
      config: Config(
        columns: 7,
        recentsLimit: 28,
        verticalSpacing: 0,
        horizontalSpacing: 0,
        enableSkinTones: true,
        bgColor: Colors.white,
        iconColor: Colors.grey,
        backspaceColor: primaryColor,
        indicatorColor: primaryColor,
        gridPadding: EdgeInsets.zero,
        initCategory: Category.SMILEYS,
        buttonMode: ButtonMode.MATERIAL,
        iconColorSelected: primaryColor,   
        categoryIcons: const CategoryIcons(),
        skinToneDialogBgColor: Colors.white,
        skinToneIndicatorColor: Colors.grey,
        recentTabBehavior: RecentTabBehavior.RECENT,
        tabIndicatorAnimDuration: kTabScrollDuration,
        loadingIndicator: const CustomCircularProgressIndicator(),   // Needs to be const Widget
        noRecents: const Text(
          'No Recents',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.black26),
        ), // Needs to be const Widget
      ),
  );
  }
}