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
import 'package:get/get.dart';

class ContactsModalPopup extends StatefulWidget {

  final bool disabled;
  final String? subtitle;
  final bool showAddresses;
  final bool enableBulkSelection;
  final Widget Function(Function)? trigger;
  final void Function(List<Contact>)? onDone;
  final void Function(List<Contact>)? onSelection;
  final List<MobileNetworkName> supportedMobileNetworkNames;

  const ContactsModalPopup({
    super.key,
    this.onDone,
    this.trigger,
    this.subtitle,
    this.onSelection,
    this.disabled = false,
    this.showAddresses = true,
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
  String? get subtitle => widget.subtitle;
  bool get showAddresses => widget.showAddresses;
  Widget Function(Function)? get trigger => widget.trigger;
  void Function(List<Contact>)? get onDone => widget.onDone;
  bool get enableBulkSelection => widget.enableBulkSelection;
  void Function(List<Contact>)? get onSelection => widget.onSelection;
  List<MobileNetworkName> get supportedMobileNetworkNames => widget.supportedMobileNetworkNames;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    Widget defaultTrigger = Row(
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

    return trigger == null ? defaultTrigger : trigger!(openBottomModalSheet);

  }

  /// Open the bottom modal sheet
  void openBottomModalSheet() {
    if(_customBottomModalSheetState.currentState != null) {
      _customBottomModalSheetState.currentState!.showBottomSheet(context);
    } 
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      /// Trigger to open the bottom modal sheet
      trigger: _trigger,
      disabled: disabled,
      key: _customBottomModalSheetState,
      /// Content of the bottom modal sheet
      content: ModalContent(
        onDone: onDone,
        subtitle: subtitle,
        onSelection: onSelection,
        showAddresses: showAddresses,
        enableBulkSelection: enableBulkSelection,
        supportedMobileNetworkNames: supportedMobileNetworkNames

      ),
    );
  }
}

class ModalContent extends StatefulWidget {
  
  final String? subtitle;
  final bool showAddresses;
  final bool enableBulkSelection;
  final void Function(List<Contact>)? onDone;
  final void Function(List<Contact>)? onSelection;
  final List<MobileNetworkName> supportedMobileNetworkNames;

  const ModalContent({
    super.key,
    this.onDone,
    this.subtitle,
    this.showAddresses = true,
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

  String? get subtitle => widget.subtitle;
  int get totalContacts => contacts.length;
  bool get hasContacts => contacts.isNotEmpty;
  bool get showAddresses => widget.showAddresses;
  void Function(List<Contact>)? get onDone => widget.onDone;
  bool get enableBulkSelection => widget.enableBulkSelection;
  void Function(List<Contact>)? get onSelection => widget.onSelection;
  bool get isViewingList => contactContentView == ContactContentView.viewingList;
  List<MobileNetworkName> get supportedMobileNetworkNames => widget.supportedMobileNetworkNames;

  String get _subtitle {
    if(subtitle == null) {

      if(isViewingList) {
        return'Select your friend, family or team';
      }else{
        return'Create a new contact';
      }

    }else{
      
      return subtitle!;

    }
  }

  Widget get content {

    /// If we are currently viewing the followers content
    if(contactContentView == ContactContentView.viewingList) {

      /// Show contact list view
      return ContactList(
        onSelection: _onSelection,
        showAddresses: showAddresses,
        enableBulkSelection: enableBulkSelection,
        supportedMobileNetworkNames: supportedMobileNetworkNames
      );

    }else{

      /// Show the create new contact view
      return ContactCreation(
        onCreated: _onCreated
      );

    }

  }

  void _onSelection(List<Contact> contacts) {
    
    /// Set the selected contacts
    setContacts(contacts);

    /// Notify parent
    if(onSelection != null) onSelection!(contacts);

    /// If we don't allow bulk selection
    if(enableBulkSelection == false) {

      /// Close Modal
      Get.back();

    }
  
  }

  void _onCreated(Contact newContact) {
    
    /// Set the created contact
    setContacts([newContact]);
    
    /// Notify parent
    if(onSelection != null) onSelection!(contacts);

    /// Close Modal
    Get.back();
  }

  void _onDone() {

    /// Notify parent
    if(onDone != null) onDone!(contacts);

    /// Close Modal
    Get.back();

  }
  
  void setContacts(List<Contact> contacts) {
    setState(() => this.contacts = contacts);
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

      /// On Done
      _onDone();

    /// If we are currently viewing the contact list
    }else if(contactContentView == ContactContentView.viewingList) {

      /// Change to add new contact
      _changeContactContentView(ContactContentView.creatingNewContact);

    }else{

      /// Change to view contact list
      _changeContactContentView(ContactContentView.viewingList);

    }

  }

  void _changeContactContentView(ContactContentView contactContentView) {
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
              CustomBodyText(_subtitle, padding: const EdgeInsets.only(left: 32, bottom: 24),),
  
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