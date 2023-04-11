import 'dart:convert';

import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/features/Image_picker/enums/image_picker_enums.dart';
import 'package:bonako_demo/features/api/providers/api_provider.dart';
import 'package:bonako_demo/features/api/services/api_service.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ImagePickerContent extends StatefulWidget {

  final String fileName;
  final String submitUrl;
  final String? deleteUrl;
  final SubmitMethod submitMethod;
  final Function(XFile)? onPickedFile;
  final Map<String, String> submitBody;
  final Map<String, String> deleteBody;
  final Function(http.Response)? onDeletedFile;
  final Function(XFile, http.Response)? onSubmittedFile;

  const ImagePickerContent({
    super.key,
    this.onPickedFile,
    this.onDeletedFile,
    this.onSubmittedFile,
    required this.fileName,
    required this.submitUrl,
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
  bool isLoading = false;
  final ImagePicker _imagePicker = ImagePicker();

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
  String get submitUrl => widget.submitUrl;
  String? get deleteUrl => widget.deleteUrl;
  SubmitMethod get submitMethod => widget.submitMethod;
  Map<String, String> get submitBody => widget.submitBody;
  Map<String, String> get deleteBody => widget.deleteBody;
  Function(XFile)? get onPickedFile => widget.onPickedFile;
  Function(http.Response)? get onDeletedFile => widget.onDeletedFile;
  Function(XFile, http.Response)? get onSubmittedFile => widget.onSubmittedFile;
  ApiProvider get apiProvider => Provider.of<ApiProvider>(context, listen: false);

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);

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

    http.MultipartRequest request;

    if(submitMethod == SubmitMethod.post) {

      request = http.MultipartRequest('POST', Uri.parse(submitUrl));

    }else{

      request = http.MultipartRequest('PUT', Uri.parse(submitUrl));

    }

    /// Add the bearer token on the request header
    request.headers.addAll(<String, String> {
      'Authorization': 'Bearer ${apiProvider.apiRepository.bearerToken}'
    });

    print('url: ${request.url}');
    print('method: ${request.method}');
    print('Headers');
    print(request.headers);

    /// Prepare the file to be uploaded
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(fileName, _pickedFile!.path);
    
    /// Add the file on the request
    request.files.add(multipartFile);

    /// Add the fields on the request
    request.fields.addAll(submitBody);    

    print('Files');
    print(request.files);  

    print('Fields');
    print(request.fields);

    print('SEND!');

    _startLoader();

    /// Send the file
    var streamedResponse = await request.send();

    /// Wait for a response
    http.Response.fromStream(streamedResponse).then((response) {

      ApiService.handleRequestFailure(response: response, ignoreValidationErrors: true);

      final responseBody = jsonDecode(response.body);

      print('DONE!');
      print(response.statusCode);
      print(responseBody);

      if ( response.statusCode == 200 || response.statusCode == 201) {

        if(onSubmittedFile != null) onSubmittedFile!(_pickedFile!, response);
        
        SnackbarUtility.showSuccessMessage(message: 'Uploaded successfully!');

      }else if(response.statusCode == 422) {

        final Map<String, dynamic> validationErrors = responseBody['errors'];
        
        /**
         *  validationErrors = {
         *    "logo": ["The logo size must not exceed 2MB"]
         *  }
         */
        validationErrors.forEach((key, value) {
          SnackbarUtility.showErrorMessage(message: value[0]);
        });

      }

    }).catchError((e) {
        
        SnackbarUtility.showErrorMessage(message: 'Failed to upload!');

    })
    .whenComplete(() {

      _stopLoader();

    });

  }

  void deleteImage() {

    _startLoader();

    apiProvider.apiRepository.delete(url: deleteUrl!, body: deleteBody).then((response) {

      if(response.statusCode == 200) {

        if(onDeletedFile != null) onDeletedFile!(response);
        
        SnackbarUtility.showSuccessMessage(message: 'Deleted successfully!');

      }

    }).whenComplete(() {

      _stopLoader();

    });
  }

  /// Content to show based on the specified view
  Widget get content {

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isLoading 
        ? const CustomCircularProgressIndicator() 
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
              onPressed: () => Navigator.of(context).pop(),
            ),
          )

        ],
      ),
    );
  }
}