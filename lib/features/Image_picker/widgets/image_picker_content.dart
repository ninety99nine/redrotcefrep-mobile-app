import 'dart:io';

import 'package:bonako_demo/core/utils/error_utility.dart';

import '../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/features/Image_picker/enums/image_picker_enums.dart';
import 'package:bonako_demo/core/shared_widgets/progress_bar/progress_bar.dart';
import 'package:bonako_demo/features/api/providers/api_provider.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class ImagePickerContent extends StatefulWidget {

  final String title;
  final String subtitle;
  final String fileName;
  final String? submitUrl;
  final String? deleteUrl;
  final SubmitMethod submitMethod;
  final Function(XFile)? onPickedFile;
  final Map<String, String> submitBody;
  final Map<String, String> deleteBody;
  final Function(dio.Response)? onDeletedFile;
  final Function(XFile, dio.Response)? onSubmittedFile;

  const ImagePickerContent({
    super.key,
    this.submitUrl,
    this.onPickedFile,
    this.onDeletedFile,
    required this.title,
    this.onSubmittedFile,
    required this.subtitle,
    required this.fileName,
    required this.deleteUrl,
    this.submitBody = const {},
    this.deleteBody = const {},
    required this.submitMethod,
  });

  @override
  State<ImagePickerContent> createState() => _ImagePickerContentState();
}

class _ImagePickerContentState extends State<ImagePickerContent> {
  
  XFile? _pickedFile;
  Map serverErrors = {};
  bool isDeleting = false;
  bool isSubmitting = false;
  int onSendProgressPercentage = 0;
  final ImagePicker _imagePicker = ImagePicker();

  String get title => widget.title;
  String get subtitle => widget.subtitle;

  List<Map> menus = [
    {
      'icon': Icons.camera_alt_outlined,
      'name': 'Take A Picture',
    },
    {
      'icon': Icons.photo_outlined,
      'name': 'Select From Gallery',
    }
  ];

  String get fileName => widget.fileName;
  String? get submitUrl => widget.submitUrl;
  String? get deleteUrl => widget.deleteUrl;
  bool get hasSubmitUrl => submitUrl != null;
  SubmitMethod get submitMethod => widget.submitMethod;
  Map<String, String> get submitBody => widget.submitBody;
  Map<String, String> get deleteBody => widget.deleteBody;
  Function(XFile)? get onPickedFile => widget.onPickedFile;
  Function(dio.Response)? get onDeletedFile => widget.onDeletedFile;
  bool get canShowProgressBar => isSubmitting && onSendProgressPercentage > 0;
  Function(XFile, dio.Response)? get onSubmittedFile => widget.onSubmittedFile;
  ApiProvider get apiProvider => Provider.of<ApiProvider>(context, listen: false);

  void _startDeleteLoader() => setState(() => isDeleting = true);
  void _stopDeleteLoader() => setState(() => isDeleting = false);
  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  @override
  void initState() {
    
    super.initState();

    if(deleteUrl != null) {
      menus.add({
        'icon': Icons.delete_outline_rounded,
        'name': 'Delete',
      });
    }

  }

  void onTap(String name) async {
    if(name == 'Take A Picture') {

      pickCameraImage();
    
    }else if(name == 'Select From Gallery') {
      
      pickGalleryImage();
    
    }else if(name == 'Delete') {
      
      deleteImage();
    
    }
  }

  void pickCameraImage() async {

    // Capture a photo
    final currentFile = await _imagePicker.pickImage(source: ImageSource.camera);

    if(currentFile != null) {
      setState(() => _pickedFile = XFile(currentFile.path));
      if(onPickedFile != null) onPickedFile!(_pickedFile!);
      submitImage();
    }

  }

  void pickGalleryImage() async {

    // Pick an image from the gallery
    final currentFile = await _imagePicker.pickImage(source: ImageSource.gallery);

    if(currentFile != null) {
      setState(() => _pickedFile = XFile(currentFile.path));
      if(onPickedFile != null) onPickedFile!(_pickedFile!);
      submitImage();
    }

  }

  void submitImage() async {

    if(hasSubmitUrl) {

      _startSubmittionLoader();

      apiProvider.apiRepository.post(
        url: submitUrl!,
        body: {fileName: _pickedFile},
        onSendProgress: onSendProgress
      ).then((response) {

        print('upload response');
        print(response.statusCode);
        print(response.statusMessage);
        print(response.data);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(onSubmittedFile != null) onSubmittedFile!(_pickedFile!, response);
          
          SnackbarUtility.showSuccessMessage(message: 'Uploaded successfully!');

          setState(() => onSendProgressPercentage = 0);

        }

      }).onError((dio.DioException exception, stackTrace) {
        
        print('validation error');

        ErrorUtility.setServerValidationErrors(setState, serverErrors, exception);

      }).catchError((error) {

        print(error);

        SnackbarUtility.showErrorMessage(message: 'Can\'t upload image');

      }).whenComplete(() {

        if(!mounted) return;

        _stopSubmittionLoader();

      });

    }

  }

  void deleteImage() {

    _startDeleteLoader();

    apiProvider.apiRepository.delete(url: deleteUrl!, body: deleteBody).then((response) {

      if(response.statusCode == 200) {

        if(onDeletedFile != null) onDeletedFile!(response);

        final message = response.data['message'] ?? 'Deleted successfully!';
        
        SnackbarUtility.showSuccessMessage(message: message);

      }

    }).whenComplete(() {

      _stopDeleteLoader();

    });
  }

  void onSendProgress(int sent, int total) {
    setState(() {
      if (total != 0 && isSubmitting) {
        double percentage = sent / total * 100;
        onSendProgressPercentage = percentage.round();
      }
    });
  }

  /// Content to show based on the specified view
  Widget get content {

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isSubmitting 
        ? Column(
          children: [

            CircleAvatar(
              radius: 100,
              backgroundColor: Colors.grey.shade100,
              backgroundImage: FileImage(File(_pickedFile!.path)),
            ),
            
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomCircularProgressIndicator(size: 16, strokeWidth: 2, margin: EdgeInsets.only(right: 8)),
                  CustomBodyText(onSendProgressPercentage == 100 ? 'Almost there...' : 'Uploading...'),
                ],
              ),
            ),

          ],
        ) 
        : ListView.separated(
        itemCount: menus.length,
        separatorBuilder: (_, __) => const Divider(height: 0,), 
        itemBuilder: (context, index) {

          final String name = menus[index]['name'];
          final IconData icon = menus[index]['icon'];

          return Material(                                                                                                                                           
            color: Colors.transparent,                                                                                                                                        
            child: InkWell(                                                                                                                                          
              child: ListTile(
                onTap: () => onTap(name),
                title: Row(
                  children: [
              
                    /// Icon
                    Icon(icon, size: 24, color: name == 'Delete' ? Colors.red: null),

                    /// Spacer
                    const SizedBox(width: 8,),

                    /// Name
                    CustomBodyText(name, color: name == 'Delete' ? Colors.red: null),

                  ],
                )
              ),
            ),
          );

        }, 
      ),
    );
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                        
              /// Wrap Padding around the following:
              /// Title, Subtitle, Filters
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 32, right: 32, bottom: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    CustomTitleMediumText(title, overflow: TextOverflow.ellipsis, margin: const EdgeInsets.only(top: 4, bottom: 4),),
                    
                    /// Subtitle
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomBodyText(subtitle),
                    ),

                    /// Progress Bar
                    AnimatedSize(
                      duration: const Duration(milliseconds: 500),
                      child: AnimatedSwitcher(
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        duration: const Duration(milliseconds: 500),
                        child: canShowProgressBar 
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: CustomProgressBar(percentage: onSendProgressPercentage)
                            )
                          : null
                      ),
                    )
                    
                  ],
                ),
              ),

              /// Content
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  alignment: Alignment.topCenter,
                  width: double.infinity,
                  color: Colors.white,
                  child: content,
                ),
              )
          
            ],
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Get.back(),
            ),
          )

        ],
      ),
    );
  }
}