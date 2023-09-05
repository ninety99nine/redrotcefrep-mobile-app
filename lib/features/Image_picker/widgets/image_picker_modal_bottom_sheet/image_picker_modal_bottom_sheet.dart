import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import 'package:bonako_demo/features/Image_picker/enums/image_picker_enums.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../image_picker_content.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class ImagePickerModalBottomSheet extends StatefulWidget {
  
  final String title;
  final double? radius;
  final String subtitle;
  final String fileName;
  final String? submitUrl;
  final String? deleteUrl;
  final String triggerText;
  final IconData triggerIcon;
  final SubmitMethod submitMethod;
  final Function(XFile)? onPickedFile;
  final Map<String, String> submitBody;
  final Map<String, String> deleteBody;
  final Function(dio.Response)? onDeletedFile;
  final Widget Function(void Function())? trigger;
  final Function(XFile, dio.Response)? onSubmittedFile;

  const ImagePickerModalBottomSheet({
    super.key,
    this.radius,
    this.trigger,
    this.deleteUrl,
    this.submitUrl,
    this.onPickedFile,
    this.onDeletedFile,
    required this.title,
    this.onSubmittedFile,
    this.triggerText = '',
    required this.subtitle,
    required this.fileName,
    this.submitBody = const {},
    this.deleteBody = const {},
    required this.submitMethod,
    this.triggerIcon = Icons.camera_alt_outlined,
  });

  @override
  State<ImagePickerModalBottomSheet> createState() => _ImagePickerModalBottomSheetState();
}

class _ImagePickerModalBottomSheetState extends State<ImagePickerModalBottomSheet> {

  double? get radius => widget.radius;
  String get fileName => widget.fileName;
  String? get submitUrl => widget.submitUrl;
  String? get deleteUrl => widget.deleteUrl;
  String get triggerText => widget.triggerText;
  IconData get triggerIcon => widget.triggerIcon;
  SubmitMethod get submitMethod => widget.submitMethod;
  Map<String, String> get submitBody => widget.submitBody;
  Map<String, String> get deleteBody => widget.deleteBody;
  Function(XFile)? get onPickedFile => widget.onPickedFile;
  Widget Function(void Function())? get trigger => widget.trigger;
  Function(dio.Response)? get onDeletedFile => widget.onDeletedFile;
  Function(XFile, dio.Response)? get onSubmittedFile => widget.onSubmittedFile;

  String get title => widget.title;
  String get subtitle => widget.subtitle;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    final Widget defaultTrigger = DottedBorder(
      radius: Radius.circular(radius ?? 20),
      borderType: triggerText.isEmpty ? BorderType.Circle : BorderType.RRect,
      strokeCap: StrokeCap.butt,
      padding: EdgeInsets.zero,
      dashPattern: const [6, 3],
      color: Colors.grey,
      strokeWidth: 1,
      child: Material(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 20),
        ),
        color:Colors.grey.shade100,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius ?? 20),
          onTap: () => openBottomModalSheet(),
          child: Ink(
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: radius ?? 20,
              child: Wrap(
                children: [

                  /// Icon
                  Icon(triggerIcon, size: 16, color: Colors.grey.shade400,),

                  /// Spacer
                  if(triggerText.isNotEmpty) const SizedBox(width: 16,),

                  /// Text
                  if(triggerText.isNotEmpty) CustomBodyText(triggerText)

                ],
              ),
            ),
          ),
        ),
      ),
    );

    return trigger == null ? defaultTrigger : trigger!(openBottomModalSheet);

  }

  /// Open the bottom modal sheet to show the new order placed
  void openBottomModalSheet() {
    if(_customBottomModalSheetState.currentState != null) {
      _customBottomModalSheetState.currentState!.showBottomSheet(context);
    } 
  }

  void _onPickedFile(XFile file) {

    if(submitUrl == null) {

      /// Close the modal bottom sheet
      Get.back();

    }

    if(onPickedFile != null) onPickedFile!(file);
    
  }

  void _onSubmittedFile(XFile file, dio.Response response) {

    /// Close the modal bottom sheet
    Get.back();
    
    if(onSubmittedFile != null) onSubmittedFile!(file, response);
    
  }

  void _onDeletedFile(dio.Response response) {

    /// Close the modal bottom sheet
    Get.back();
    
    if(onDeletedFile != null) onDeletedFile!(response);
    
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      key: _customBottomModalSheetState,
      /// Trigger to open the bottom modal sheet
      trigger: _trigger,
      /// Content of the bottom modal sheet
      content: ImagePickerContent(
        title: title,
        subtitle: subtitle,
        fileName: fileName,
        submitUrl: submitUrl,
        deleteUrl: deleteUrl,
        submitBody: submitBody,
        deleteBody: deleteBody,
        submitMethod: submitMethod,
        onPickedFile: _onPickedFile,
        onDeletedFile: _onDeletedFile,
        onSubmittedFile: _onSubmittedFile
      ),
    );
  }
}