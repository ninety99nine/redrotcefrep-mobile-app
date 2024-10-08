import 'package:perfect_order/core/shared_widgets/emoji_picker/custom_emoji_picker_dialog.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class FriendGroupEmojiPicker extends StatelessWidget {

  final Emoji? emoji;
  final String? title;
  final String? instruction;
  final TriggerArrangement triggerArrangement;
  final Function(Category?, Emoji)? onEmojiSelected;

  const FriendGroupEmojiPicker({
    super.key,
    this.emoji,
    this.title,
    this.instruction,
    this.onEmojiSelected,
    this.triggerArrangement = TriggerArrangement.vertical
  });

  @override
  Widget build(BuildContext context) {
    return CustomEmojiPickerDialog(
      emoji: emoji,
      onEmojiSelected: onEmojiSelected,
      triggerArrangement: triggerArrangement,
      title: title ?? 'Pick Your Group Emoji',
      instruction: instruction ?? 'Add your group emoji',
    );
  }
}