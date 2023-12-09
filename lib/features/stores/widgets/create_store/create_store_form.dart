
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_mobile_number_text_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/Loader/custom_circular_progress_indicator.dart';
import '../../../../core/shared_widgets/text_form_field/custom_text_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:bonako_demo/core/utils/error_utility.dart';
import 'package:bonako_demo/core/utils/mobile_number.dart';
import '../store_emoji_picker/store_emoji_picker.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import '../../repositories/store_repository.dart';
import '../../../../core/utils/snackbar.dart';
import '../../providers/store_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class CreateStoreForm extends StatefulWidget {

  final Function(ShoppableStore)? onCreatedStore;

  const CreateStoreForm({
    super.key,
    this.onCreatedStore
  });

  @override
  State<CreateStoreForm> createState() => _CreateStoreFormState();
}

class _CreateStoreFormState extends State<CreateStoreForm> {
  
  String name = '';
  Emoji? selectedEmoji;
  Map serverErrors = {};
  String description = '';
  late String mobileNumber;
  bool isSubmitting = false;
  String callToAction = 'Buy';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emojiTextEditingController = TextEditingController();

  bool get doesNotHaveName => name.isEmpty;
  bool get hasEmoji => selectedEmoji != null;
  bool get doesNotHaveEmoji => selectedEmoji == null;
  bool get hasIncompleteMobileNumber => mobileNumber.length != 8;
  Function(ShoppableStore)? get onCreatedStore => widget.onCreatedStore;
  StoreRepository get storeRepository => friendGroupProvider.storeRepository;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get friendGroupProvider => Provider.of<StoreProvider>(context, listen: false);
  String? get nameErrorText => serverErrors.containsKey('name') ? serverErrors['name'] : null;
  String get mobileNumberWithExtension => MobileNumberUtility.addMobileNumberExtension(mobileNumber);
  String? get descriptionErrorText => serverErrors.containsKey('description') ? serverErrors['description'] : null;
  String? get mobileNumberErrorText => serverErrors.containsKey('mobileNumber') ? serverErrors['mobileNumber'] : null;

  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  @override
  void initState() {
    super.initState();
    mobileNumber = authProvider.user!.mobileNumber!.withoutExtension;
  }

  void _requestCreateStore() {

    if(isSubmitting) return;

    _resetServerErrors().then((value) {

      if(_formKey.currentState!.validate()) {

        _startSubmittionLoader();

        storeRepository.createStore(
          name: name,
          description: description,
          callToAction: callToAction,
          emoji: selectedEmoji!.emoji,
          mobileNumber: mobileNumberWithExtension
        ).then((response) async {

          if(response.statusCode == 201) {

            _resetForm();

            ShoppableStore createdStore = ShoppableStore.fromJson(response.data);

            if(onCreatedStore != null) onCreatedStore!(createdStore);

            SnackbarUtility.showSuccessMessage(message: 'Store created');

          }

        }).onError((dio.DioException exception, stackTrace) {

          ErrorUtility.setServerValidationErrors(setState, serverErrors, exception);

        }).catchError((error) {

          printError(info: error.toString());

          SnackbarUtility.showErrorMessage(message: 'Can\'t create store');

        }).whenComplete(() {

          _stopSubmittionLoader();

        });

      }else{

        SnackbarUtility.showErrorMessage(message: 'We found some mistakes');

      }

    });

  }

  /// Reset the server errors
  void _resetForm() {
    setState(() {
      name = '';

      Future.delayed(const Duration(milliseconds: 100)).then((value) {

        if(_formKey.currentState != null) {
          
          _formKey.currentState!.reset();

        }
      
      });
    });
  }

  /// Reset the server errors
  Future _resetServerErrors() {

    setState(() => serverErrors = {});

    /**
     *  We need to allow the setState() method to update the Widget Form Fields
     *  so that we can give the application a chance to update the inputs 
     *  before we validate them.
     */
    return Future.delayed(const Duration(milliseconds: 100));
    
  }

  Widget emojiPicker() {

    Color primaryColor = Theme.of(context).primaryColor;

    Widget emojiPicker = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Title
        const CustomTitleSmallText('Pick Your Store Emoji', padding: EdgeInsets.all(16.0),),

        /// Emoji Picker
        Expanded(
          child: EmojiPicker(
              onEmojiSelected: (Category? category, Emoji emoji) {
                setState(() {
                  selectedEmoji = emoji;
                  Get.back();
                });
              },
              textEditingController: emojiTextEditingController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
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
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: () {
        
        DialogUtility.showInfiniteScrollContentDialog(
          heightRatio: 0.8,
          context: context,
          content: emojiPicker,
        );
        
      },
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
      
            /// Instruction
            const CustomBodyText(
              'Add your shop emoji',
              textAlign: TextAlign.left,
              lightShade: true, 
            ),
      
            /// Spacer
            const SizedBox(height: 16,),
      
            Container(
              width: 80,
              height: 80,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey.shade700),
                borderRadius: BorderRadius.circular(80)
              ),
              child: hasEmoji 
                ? Text(
                    selectedEmoji!.emoji, 
                    style: const TextStyle(fontSize: 60,), 
                    textAlign: TextAlign.center
                  )
                : const Icon(Icons.add, size: 40)
            ),
      
          ],
        ),
      ),
    );
    
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Store Name
            CustomTextFormField(
              hintText: 'Baby Cakes 🧁',
              errorText: nameErrorText,
              enabled: !isSubmitting,
              borderRadiusAmount: 16,
              initialValue: name,
              labelText: 'Name',
              maxLength: 25,
              onChanged: (value) {
                setState(() => name = value); 
              },
            ),
              
            /// Spacer
            const SizedBox(height: 16),

            /// Description
            CustomTextFormField(
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              hintText: 'The sweetest cakes in the world 🍰',
              errorText: descriptionErrorText,
              initialValue: description,
              labelText: 'Description (Optional)',
              enabled: !isSubmitting,
              borderRadiusAmount: 16,
              maxLength: 120,
              minLines: 2,
              onChanged: (value) {
                setState(() => description = value); 
              }
            ),
              
            /// Spacer
            const SizedBox(height: 16),

            /// Instruction
            const CustomBodyText(
              'Mobile number for customers to call', 
              textAlign: TextAlign.left,
              lightShade: true, 
            ),
              
            /// Spacer
            const SizedBox(height: 16),
          
            //// Mobile Number Field
            CustomMobileNumberTextFormField(
              supportedMobileNetworkNames: const [
                MobileNetworkName.orange,
                MobileNetworkName.mascom,
                MobileNetworkName.btc,
              ],
              errorText: mobileNumberErrorText,
              initialValue: mobileNumber,
              enabled: !isSubmitting,
              onChanged: (value) {
                setState(() => mobileNumber = value);
              }
            ),

            /// Spacer
            const SizedBox(height: 16,),

            /// Stpre Emoji Picker
            StoreEmojiPicker(
              emoji: selectedEmoji,
              onEmojiSelected: (Category? category, Emoji emoji) {
                setState(() => selectedEmoji = emoji);
              },
            ),

            /// Spacer
            const SizedBox(height: 16,),

            /// Add Button
            CustomElevatedButton(
              width: 120,
              'Create Store',
              isLoading: isSubmitting,
              alignment: Alignment.center,
              onPressed: _requestCreateStore,
              disabled: doesNotHaveName || doesNotHaveEmoji || hasIncompleteMobileNumber ,
            )

          ]
        )
    );
  }
}