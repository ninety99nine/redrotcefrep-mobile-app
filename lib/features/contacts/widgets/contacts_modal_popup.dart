import 'package:get/get.dart';

import '../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../features/contacts/widgets/contact_avatar.dart';
import '../../../features/contacts/widgets/contact_list.dart';
import '../../../core/shared_widgets/chips/custom_chip.dart';
import '../../../core/utils/mobile_number.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter/material.dart';
import '../enums/contact_enums.dart';
import 'contact_creation.dart';

class ContactsModalPopup extends StatefulWidget {

  final bool disabled;
  final bool enableBulkSelection;
  final void Function(List<Contact>) onSelection;
  final List<MobileNetworkName> supportedMobileNetworkNames;

  const ContactsModalPopup({
    super.key,
    this.disabled = false,
    required this.onSelection,
    this.enableBulkSelection = false,
    required this.supportedMobileNetworkNames
  });

  @override
  State<ContactsModalPopup> createState() => _ContactsModalPopupState();
}

class _ContactsModalPopupState extends State<ContactsModalPopup> {

  Contact? contact;
  bool get disabled => widget.disabled;
  bool get hasContact => contact != null;
  bool get enableBulkSelection => widget.enableBulkSelection;
  void Function(List<Contact>) get onSelection => widget.onSelection;
  List<MobileNetworkName> get supportedMobileNetworkNames => widget.supportedMobileNetworkNames;

  Widget get trigger {
    return Row(
      children: [
        if(hasContact) ContactAvatar(contact: contact!),
        if(hasContact) const SizedBox(width: 4),
        CustomChip(
          type: CustomChipType.primary,
          labelWidget: Row(
            children: [
              Icon(
                hasContact ? Icons.change_circle : Icons.person_add_alt_1_rounded,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 4),
              CustomBodyText(
                hasContact ? 'Change contact' : 'Select contact',
                color: Theme.of(context).primaryColor,  
              )
            ],
          ), 
        ),
        
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      disabled: disabled,
      /// Trigger to open the bottom modal sheet
      trigger: trigger,
      /// Content of the bottom modal sheet
      content: ModalContent(
        onSelection: onSelection,
        enableBulkSelection: enableBulkSelection,
        supportedMobileNetworkNames: supportedMobileNetworkNames

      ),
    );
  }
}

class ModalContent extends StatefulWidget {

  final bool enableBulkSelection;
  final void Function(List<Contact>) onSelection;
  final List<MobileNetworkName> supportedMobileNetworkNames;

  const ModalContent({
    super.key,
    required this.onSelection,
    required this.enableBulkSelection,
    required this.supportedMobileNetworkNames,
  });

  @override
  State<ModalContent> createState() => _ModalContentState();
}

class _ModalContentState extends State<ModalContent> {

List<Contact> contacts = [];
  bool showFloatingButton = true;
  ContactContentView contactContentView = ContactContentView.viewingList;

  int get totalContacts => contacts.length;
  bool get hasContacts => contacts.isNotEmpty;
  bool get enableBulkSelection => widget.enableBulkSelection;
  void Function(List<Contact>) get onSelection => widget.onSelection;
  bool get isViewingList => contactContentView == ContactContentView.viewingList;
  List<MobileNetworkName> get supportedMobileNetworkNames => widget.supportedMobileNetworkNames;

  String get subtitle {
    if(hasContacts) {
      return 'Select contact information';
    }else if(isViewingList) {
      return'Select your friend, family or team';
    }else{
      return'Create a new contact';
    }
  }

  Widget get content {

    if(hasContacts && enableBulkSelection == false) {

      return const Text('select the contact mobile number');

    /// If we are currently viewing the followers content
    }else if(contactContentView == ContactContentView.viewingList) {

      /// Show contact list view
      return ContactList(
        onSelection: selectContacts,
        enableBulkSelection: enableBulkSelection,
        supportedMobileNetworkNames: supportedMobileNetworkNames
      );

    }else{

      /// Show the create new contact view
      return ContactCreation(
        onCreated: onCreated
      );

    }

  }

  void onCreated(Contact newContact) {
    selectContacts([newContact]);
    notifyParentAndCloseModal();
  }

  void selectContacts(List<Contact> contacts) {
    setState(() => this.contacts = contacts);
  }

  void notifyParentAndCloseModal() {
    //// Notify parent
    onSelection(contacts);
    /// Close Modal
    Get.back();
  }

  String get floatingActionButtonLabel {
    if(hasContacts) {
      return 'Done';
    }else if(isViewingList) {
      return 'Add Contact';
    }else{
      return 'Back';
    }
  }

  IconData? get floatingActionButtonIcon {
    if(hasContacts) {
      return Icons.check_circle;
    }else if(isViewingList) {
      return Icons.add;
    }else{
      return Icons.keyboard_double_arrow_left;
    }
  }

  Widget get floatingActionButton {

    return CustomElevatedButton(
      width: 120,
      floatingActionButtonLabel,
      prefixIcon: floatingActionButtonIcon,
      onPressed: floatingActionButtonOnPressed,
    );

  }

  void floatingActionButtonOnPressed() {

    if(hasContacts) {

      //// Notify parent
      notifyParentAndCloseModal();

    /// If we are currently viewing the contact list
    }else if(contactContentView == ContactContentView.viewingList) {

      /// Change to add new contact
      changeContactContentView(ContactContentView.creatingNewContact);

    }else{

      /// Change to view contact list
      changeContactContentView(ContactContentView.viewingList);

    }

  }

  void changeContactContentView(ContactContentView contactContentView) {
    setState(() => this.contactContentView = contactContentView);
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
              
              /// Title
              const CustomTitleMediumText('Contacts', padding: EdgeInsets.only(top:20, left: 32, bottom: 8),),
              
              /// Subtitle
              CustomBodyText(subtitle, padding: const EdgeInsets.only(left: 32, bottom: 24),),
  
              /// Content
              Expanded(
                child: Container(
                  alignment: Alignment.topCenter,
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: double.infinity,
                  color: Colors.white,
                  child: content,
                ),
              )
  
            ],
          ),
  
          /// Cancel Icon
          Positioned(
            top: 8,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Get.back()
            ),
          ),
  
          /// Floating Button (show if provided)
          if(showFloatingButton) Positioned(
            top: 64,
            right: 10,
            child: floatingActionButton
          )
        ],
      ),
    );
  }
}