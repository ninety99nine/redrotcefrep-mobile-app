import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../core/shared_widgets/text_form_field/custom_search_text_form_field.dart';
import '../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../core/shared_widgets/checkbox/custom_checkbox.dart';
import '../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../features/contacts/widgets/contact_avatar.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../core/utils/mobile_number.dart';
import 'package:collection/collection.dart';
import '../../../core/utils/string.dart';
import 'package:flutter/material.dart';

class ContactList extends StatefulWidget {

  final bool showAddresses;
  final bool enableBulkSelection;
  final void Function(List<Contact>) onSelection;
  final List<MobileNetworkName> supportedMobileNetworkNames;

  const ContactList({
    super.key,
    this.showAddresses = true,
    required this.onSelection,
    this.enableBulkSelection = false,
    this.supportedMobileNetworkNames = const [
      MobileNetworkName.orange,
      MobileNetworkName.mascom,
      MobileNetworkName.btc,
    ]
  });

  @override
  State<ContactList> createState() => _ContactListState();
  
}

class _ContactListState extends State<ContactList> {

  late User authUser;
  bool isLoading = false;
  String searchWord = '';
  bool selectedAll = false;
  bool hasPermission = false;
  List<Contact> contacts = [];
  List<Contact> selectedContacts = [];
  List<Map<String, dynamic>> selectedPhoneIndexes = [];

  bool get showAddresses => widget.showAddresses;
  int get totalFilteredContacts => filteredContacts.length;
  int get totalSelectedContacts => selectedContacts.length;
  bool get enableBulkSelection => widget.enableBulkSelection;
  void Function(List<Contact>) get onSelection => widget.onSelection;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  List<MobileNetworkName> get supportedMobileNetworkNames => widget.supportedMobileNetworkNames;
  String get totalContactsSelectedText => '$totalSelectedContacts ${totalSelectedContacts == 1 ? 'contact' : 'contacts'} selected';

  List<Contact> get filteredContacts {

    if (searchWord.isEmpty) return contacts;

    final searchWordMobileNumber = MobileNumberUtility.simplify(searchWord);

    return contacts.where((contact) {

      // Check if the search term matches the display name
      bool matchesDisplayName = contact.displayName.toLowerCase().contains(searchWord.toLowerCase());

      // Check if the search term matches one of the addresses
      bool matchesAddress = contact.addresses.any((address) => address.address.toLowerCase().contains(searchWord.toLowerCase()));

      // Check if the search term matches one of the mobile numbers
      bool matchesMobileNumber = searchWordMobileNumber.isEmpty ? false : contact.phones.any((phone) => RegExp(searchWordMobileNumber).hasMatch(phone.number));

      return matchesDisplayName || matchesAddress || matchesMobileNumber;

    }).toList();
  }

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  
  @override
  void initState() {
    super.initState();
    requestContacts();
    authUser = authProvider.user!;
  }

  void requestContacts () async {

    _startLoader();

    /// Request contact permission
    if (await FlutterContacts.requestPermission()) {

      /// Indicate that we have permission
      setState(() => hasPermission = true);
        
      /// Get all contacts (fully fetched)
      contacts = await FlutterContacts.getContacts(
        withProperties: true, 
        withThumbnail: true,
        withPhoto: false
      );

      /// Filter contacts by supported mobile network names
      contacts = filterContactsBySupportedMobileNetworkNames(contacts);

    }else{

      /// Indicate that we don't have permission
      setState(() => hasPermission = false);

    }

    _stopLoader();

  }

  List<Contact> filterContactsBySupportedMobileNetworkNames(List<Contact> contacts) {
    
    /// Return contacts with supported phones
    return contacts.map((contact) {

      /// Foreach of the contact phones
      /// 
      /// NOTE: We are iterating over the items (phones) in reverse order i.e
      /// 
      /// Instead of this:   for (var i = 0; i < contact.phones.length; i++) { ... }      - From first item to last item
      /// We are using this: for (int i = contact.phones.length - 1; i >= 0; i--) { ... } - From last item to first item
      /// 
      /// This code choice addresses a common issue when removing items from a list while iterating over it.
      /// When an item is removed at a specific index, the list is modified, and the indices of the remaining items shift.
      /// Iterating in reverse order is employed to mitigate this issue, ensuring that removing items doesn't impact the
      /// indices of elements that haven't been processed yet. This helps prevent out-of-bounds errors and ensures a
      /// consistent and predictable iteration over the list.

      for (int i = contact.phones.length - 1; i >= 0; i--) {

        /// Get the contact phone number
        final String number = contact.phones[i].number;

        /// Get the phone number mobible network name e.g orange, mascom or btc
        MobileNetworkName? mobileNetworkName = MobileNumberUtility.getMobileNetworkName(number);

        /// If the mobile network name is not provided
        if(mobileNetworkName == null) {

          /// Remove this phone index (This mobile network does not exist on our available mobile networks)
          contact.phones.removeAt(i);

        /// If the mobile network name is provided
        }else{

          /// Check if this is a supported mobile network name
          bool isSupportedMobileNetworkName = supportedMobileNetworkNames.map((supportedMobileNetworkName) => supportedMobileNetworkName.name).contains(mobileNetworkName.name);

          /// If this mobile network name is supported
          if(isSupportedMobileNetworkName) {

            /// Simplify the contact phone number e.g convert "+267 72882239" into "72882239"
            contact.phones[i].number = MobileNumberUtility.simplify(number);

          /// If this mobile network name is not supported
          }else{

            /// Remove this phone index (This mobile network is not supported)
            contact.phones.removeAt(i);

          }

        }

      }
      
      /// Return the contact with simplified phones or without phones
      return contact;

    }).where((contact) {

      /// If the contact does not have any phones left, then remove this contact
      return contact.phones.isNotEmpty;

    }).toList();
    
  }

  void selectContact(Contact contact, int selectedPhoneIndex) {

    /// If we do not support bulk selection, then remove the 
    /// previously selected contact if it does not match the 
    /// current contact
    if(enableBulkSelection == false && selectedContacts.isNotEmpty) {
      if(selectedContacts.first.id != contact.id) {
        unselectContact(selectedContacts.first);
      }
    }

    /// If this contact has not been selected already
    if( selectedContacts.where((selectedContact) => selectedContact.id == contact.id).isEmpty ) {

      /// Add the specific mobile number 
      selectedContacts.add(contact);   

      /// Capture the contact id and mobile number index
      /// index 0 means that we selected the first mobile number
      /// index 1 means that we selected the second mobile number e.t.c
      /// This helps us track each mobile number selected for each contact
      selectedPhoneIndexes.add({
        'id': contact.id,
        'phoneIndex': selectedPhoneIndex
      });
      
    /// If this contact has been selected already
    }else{

      /// Get the matching selected phone index
      final matchingSelectedPhoneIndexes = selectedPhoneIndexes.where((selectedPhoneIndex) => selectedPhoneIndex['id'] == contact.id);
      
      /// If we have a matching selected phone index
      if( matchingSelectedPhoneIndexes.isNotEmpty ) {

        /// Update the selected phone index
        matchingSelectedPhoneIndexes.first['phoneIndex'] = selectedPhoneIndex;

      }

    }

    selectedContacts = selectedContacts.map((selectedContact) {

      /// Get the matching selected contact
      final matchingContact = contacts.firstWhere((currentContact) => currentContact.id == selectedContact.id);
      
      /// Get the matching selected phone index
      final matchingSelectedPhoneIndex = selectedPhoneIndexes.firstWhere((selectedPhoneIndex) => selectedPhoneIndex['id'] == selectedContact.id);

      /// Copy the contact so that we can modify the phones without
      /// affecting the original contact phones
      Contact contactCopy = Contact.fromJson(matchingContact.toJson());

      /// Modify the matching contact phones to only include the selected phone (All other phones must be removed)
      contactCopy.phones = [
        
        contactCopy.phones[matchingSelectedPhoneIndex['phoneIndex']]

      ];

      return contactCopy;

    }).toList();

    /// Update whether or not we have selected all contacts
    updateIfSelectedAllContacts();

    //// Notify parent
    onSelection(selectedContacts);

  }

  void updateIfSelectedAllContacts() {

    /// If all contacts are selected
    if(contacts.length == selectedContacts.length) {

      /// Indicate that all contacts are selected
      setState(() => selectedAll = true);
      
    /// If not all contacts are selected
    }else{

      /// Indicate that not all contacts are selected
      setState(() => selectedAll = false);

    }

  }

  void unselectContact(Contact contact) {
    selectedContacts.removeWhere((selectedContact) => selectedContact.id == contact.id);
    selectedPhoneIndexes.removeWhere((selectedPhoneIndex) => selectedPhoneIndex['id'] == contact.id);

    /// Update whether or not we have selected all contacts
    updateIfSelectedAllContacts();

    //// Notify parent
    onSelection(selectedContacts);
  }

  Widget get searchInputField {  
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      margin: const EdgeInsets.only(top: 36),
      child: CustomSearchTextFormField(
        initialValue: searchWord,
        isLoading: isLoading,
        onChanged: (value) => setState(() => searchWord = value),
      ),
    );
  }

  Widget get selectAllCheckbox {
    return CustomCheckbox(
      text: 'Select All',
      value: selectedAll,
      onChanged: (status) {
        
        if(status == true) {

          /// Select every contact available
          for (var contact in contacts) {
            
            selectContact(contact, 0);

          }

        }else if(status == false) {

          /// Unselect every contact available
          for (var contact in contacts) {

            unselectContact(contact);

          }

        } 
      }
    );
  }

  Widget get permissionDenied {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 150,
            child: Image.asset('assets/images/padlock.png')
          ),
        ),

        /// Spacer
        const SizedBox(height: 50),
  
        /// Title
        const CustomTitleLargeText('Permission Required'),
      
        /// Spacer
        const Divider(height: 50),
  
        /// Instruction
        CustomBodyText(
          'Hey ${authUser.firstName} 👋, please allow access to your contacts',
          height: 1.6,
        ),
  
        const Divider(height: 50),

        /// Button
        CustomElevatedButton(
          'Allow Access',
          suffixIcon: Icons.refresh,
          alignment: Alignment.center,
          onPressed: requestContacts
        ),
  
      ],
    );
  }

  Widget get contactListContent {

    /**
     * SingleChildScrollView is required to show other widgets in a Column along with the
     * ListView widget. Setting the "shrinkWrap=true" forces ListView to take only the required space, 
     * and not the entire screen. Setting "physics=NeverScrollableScrollPhysics()" disables scrolling 
     * functionality of ListView, which means now we have only SingleChildScrollView who provide the 
     * scrolling functionality.
     * 
     * Reference: https://stackoverflow.com/questions/56131101/how-to-place-a-listview-inside-a-singlechildscrollview-but-prevent-them-from-scr
     */
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Permission Denied
          if(!isLoading && !hasPermission) ...[
            
            permissionDenied

          ],

          /// Permission Granted
          if(!isLoading && hasPermission) ...[

            /// Search Input Field
            searchInputField,

            if(enableBulkSelection) Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16, left: 32, right: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
        
                  /// Select All Checkbox
                  Expanded(child: selectAllCheckbox),

                  /// Total Contacts Selected
                  CustomBodyText(totalContactsSelectedText, lightShade: true,),

                ],
              ),
            ),

            const Divider(),
      
            /// Content List View
            ListView.separated(
              shrinkWrap: true,
              itemCount: totalFilteredContacts + 1,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 16, right: 16),
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              itemBuilder: (context, index) {
            
                ///  If this is not the last item
                if(index < totalFilteredContacts) {
            
                  /// Get the contact
                  Contact contact = filteredContacts[index];
      
                  /// Return the contact item
                  return ContactItem(
                    contact: contact, 
                    showAddresses: showAddresses,
                    selectContact: selectContact,
                    unselectContact: unselectContact,
                    selectedContacts: selectedContacts,
                    enableBulkSelection: enableBulkSelection,
                    selectedPhoneIndexes: selectedPhoneIndexes,
                    supportedMobileNetworkNames: supportedMobileNetworkNames
                  );
            
                ///  If this is the last item on the last page
                }else {
            
                  return CustomBodyText(
                    filteredContacts.isEmpty ? 'No contacts found' : 'No more contacts', 
                    margin: EdgeInsets.only(top: filteredContacts.isEmpty ? 100 : 20, bottom: 100),
                    textAlign: TextAlign.center, 
                  );
            
                }
            
              }
            ),

          ],
    
        ],
      ),
    );
  }

  Widget get loader {
    return const CustomCircularProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? loader : contactListContent;

  }
}

class ContactItem extends StatefulWidget {

  final Contact contact;
  final bool showAddresses;
  final bool enableBulkSelection;
  final List<Contact> selectedContacts;
  final Function(Contact) unselectContact;
  final Function(Contact, int) selectContact;
  final List<Map<String, dynamic>> selectedPhoneIndexes;
  final List<MobileNetworkName> supportedMobileNetworkNames;

  const ContactItem({
    super.key, 
    required this.contact,
    required this.selectContact,
    required this.showAddresses,
    required this.unselectContact,
    required this.selectedContacts,
    required this.enableBulkSelection,
    required this.selectedPhoneIndexes,
    required this.supportedMobileNetworkNames
  });

  @override
  State<ContactItem> createState() => _ContactItemState();
}

class _ContactItemState extends State<ContactItem> {

  Contact get contact => widget.contact;
  int get totalPhones => contact.phones.length;
  bool get showAddresses => widget.showAddresses;
  bool get hasAddress => contact.addresses.isNotEmpty;
  bool get hasManyPhones => contact.phones.length > 1;
  bool get enableBulkSelection => widget.enableBulkSelection;
  List<Contact> get selectedContacts => widget.selectedContacts;
  Function(Contact) get unselectContact => widget.unselectContact;
  Function(Contact, int) get selectContact => widget.selectContact;
  List<Map<String, dynamic>> get selectedPhoneIndexes => widget.selectedPhoneIndexes;
  List<MobileNetworkName> get supportedMobileNetworkNames => widget.supportedMobileNetworkNames;
  bool get isSelected => selectedContacts.where((selectedContact) => selectedContact.id == contact.id).isNotEmpty;

  int get selectedPhoneIndex {
    
    Map<String, dynamic>? matchingSelectedPhoneIndex = selectedPhoneIndexes.firstWhereOrNull((currSelectedPhoneIndex) => currSelectedPhoneIndex['id'] == contact.id);

    // Return the specified phone index number, or 0 if not found
    return matchingSelectedPhoneIndex?['phoneIndex'] ?? 0;

  }

  String get prefferedMobileNumber {
    return contact.phones[selectedPhoneIndex].number;
  }

  @override
  void initState() {
    super.initState();
  }

  String getMobileNetworkName(String mobileNumber) {

    /// If we only support one mobile network name
    if(supportedMobileNetworkNames.length == 1) {

      /// Return this supported mobile network name
      return StringUtility.capitalize(supportedMobileNetworkNames.first.name);

    /// If we support more than one mobile network name
    }else{

      /// Return this supported mobile network name matching this mobileNumber
      final MobileNetworkName mobileNetworkName = MobileNumberUtility.getMobileNetworkName(mobileNumber)!;
      return StringUtility.capitalize(mobileNetworkName.name);

    }
    
  }

  void toggleSelectionWithoutPhone() async {

    /// If this contact is already selected
    if(isSelected) {

      /// Unselect this contact
      unselectContact(contact);

    }else{

      if(hasManyPhones) {

        /// Show dialog to choose a specific mobile number
        final int? dialogSelectedPhoneIndex = await chooseOneMobileNumberDialog();

        if(dialogSelectedPhoneIndex != null) {

          /// Select this contact
          selectContact(contact, dialogSelectedPhoneIndex);

        }

      }else{

        /// Select this contact
        selectContact(contact, selectedPhoneIndex);

      }

    }

  }

  Future chooseOneMobileNumberDialog() {

    return DialogUtility.showContentDialog(
      title: contact.displayName,
      context: context,
      content: ChooseOneMobileNumberDialogContent(
        runSpacing: 16,
        contact: contact, 
        selectedPhoneIndex: selectedPhoneIndex, 
        getMobileNetworkName: getMobileNetworkName
      ),
    );

  }

  void toggleSelectionWithPhone(int index, Phone phone) {

    /// If this contact is already selected
    if(isSelected) {

      /// If the mobile number has not been changed
      if(prefferedMobileNumber == phone.number) {

        /// Unselect this contact
        unselectContact(contact);

      /// If the mobile number has been changed
      }else{

        /// Re-select this contact to change the selected mobile number
        selectContact(contact, index);

      }

    /// If this contact is not already selected
    }else{

      /// Select this contact
      selectContact(contact, index);

    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey<String>(contact.id),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: isSelected ? Colors.green.shade50 : null,
        border: Border.all(color: isSelected ? Colors.green.shade300 : Colors.transparent),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        onTap: () => toggleSelectionWithoutPhone(),
        leading: ContactAvatar(contact: contact),
        title: Stack(
          children: [
            
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Display Name: Julian Tabona
                CustomTitleMediumText(contact.displayName),

                /// Single Mobile Number: 72882239
                if(!hasManyPhones) ...[
                  const SizedBox(height: 4,),
                  CustomBodyText('$prefferedMobileNumber ${getMobileNetworkName(prefferedMobileNumber)}', color: Colors.grey,),
                ],

                /// Multiple Mobile Numbers: 2 mobiles
                if(!isSelected && hasManyPhones) ...[
                  const SizedBox(height: 4,),
                  CustomBodyText('$totalPhones mobiles', color: Colors.grey,),
                ],

                /// Address
                if(showAddresses && hasAddress) ...[
                  const SizedBox(height: 4,),
                  CustomBodyText(StringUtility.removeLineBreaks(contact.addresses.first.address)),
                ],

                /// Multiple Phone Number Selectors
                if(isSelected && hasManyPhones) ...[

                  /// Spacer
                  const SizedBox(height: 4,),

                  /// Phone Choices
                  PhoneChoices(
                    contact: contact,
                    selectedPhoneIndex: selectedPhoneIndex,
                    getMobileNetworkName: getMobileNetworkName, 
                    toggleSelectionWithPhone: toggleSelectionWithPhone
                  )

                ]
              
              ]
            ),

            /// Cancel Icon
            if(isSelected) Positioned(
              top: -5,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.cancel, size: 20, color: Colors.green.shade500,),
                onPressed: () => unselectContact(contact),
              ),
            ),
        
          ],
        ),
      ),
    );
  }
}

class ChooseOneMobileNumberDialogContent extends StatefulWidget {
  
  final Contact contact;
  final double? runSpacing;
  final int selectedPhoneIndex;
  final Function getMobileNetworkName;

  const ChooseOneMobileNumberDialogContent({
    super.key,
    this.runSpacing,
    required this.contact,
    required this.selectedPhoneIndex,
    required this.getMobileNetworkName
  });

  @override
  State<ChooseOneMobileNumberDialogContent> createState() => _ChooseOneMobileNumberDialogContentState();
}

class _ChooseOneMobileNumberDialogContentState extends State<ChooseOneMobileNumberDialogContent> {
  
  late int selectedPhoneIndex;
  Contact get contact => widget.contact;
  double? get runSpacing => widget.runSpacing;
  Function get getMobileNetworkName => widget.getMobileNetworkName;

  @override
  void initState() {
    super.initState();
    selectedPhoneIndex = widget.selectedPhoneIndex;
  }

  void toggleSelectionWithPhone(int index, Phone phone) {

    /// Capture the selected phone index
    setState(() => selectedPhoneIndex = index);

  }

  void onDone() {

    /// Close the dialog while returning the selected phone index
    Get.back(result: selectedPhoneIndex);

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Phone Number
        const CustomBodyText('Choose a specific mobile number'),
        
        /// Divider
        const Divider(),
        
        /// Spacer
        const SizedBox(height: 16,),

        /// Phone Choices
        PhoneChoices(
          contact: contact,
          runSpacing: runSpacing,
          selectedPhoneIndex: selectedPhoneIndex,
          getMobileNetworkName: getMobileNetworkName,
          toggleSelectionWithPhone: toggleSelectionWithPhone,
        ),
        
        /// Spacer
        const SizedBox(height: 16,),

        CustomElevatedButton(
          'Done',
          onPressed: onDone,
        )

      ],
    );
  }
}

class PhoneChoices extends StatefulWidget {
  
  final Contact contact;
  final double? runSpacing;
  final int selectedPhoneIndex;
  final Function getMobileNetworkName;
  final Function(int, Phone) toggleSelectionWithPhone;

  const PhoneChoices({
    super.key,
    this.runSpacing,
    required this.contact,
    required this.selectedPhoneIndex,
    required this.getMobileNetworkName,
    required this.toggleSelectionWithPhone
  });

  @override
  State<PhoneChoices> createState() => _PhoneChoicesState();
}

class _PhoneChoicesState extends State<PhoneChoices> {

  double? get runSpacing => widget.runSpacing;
  int get selectedPhoneIndex => widget.selectedPhoneIndex;
  Function(int, Phone) get toggleSelectionWithPhone => widget.toggleSelectionWithPhone;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: runSpacing ?? 0,
      children: [
        
        ...widget.contact.phones.mapIndexed((index, phone) {

          final bool isSelectedPhone = selectedPhoneIndex == index;
          final String mobileNetworkName = widget.getMobileNetworkName(phone.number);
        
          return PhoneChoice(
            phone: phone,
            isSelectedPhone: isSelectedPhone,
            mobileNetworkName: mobileNetworkName,
            toggleSelectionWithPhone: () => toggleSelectionWithPhone(index, phone),
          );

        }).toList()

      ],
    );
  }
}

class PhoneChoice extends StatefulWidget {

  final Phone phone;
  final bool isSelectedPhone;
  final String mobileNetworkName;
  final Function toggleSelectionWithPhone;

  const PhoneChoice({
    super.key,
    required this.phone,
    required this.isSelectedPhone,
    required this.mobileNetworkName,
    required this.toggleSelectionWithPhone
  });

  @override
  State<PhoneChoice> createState() => _PhoneChoiceState();
}

class _PhoneChoiceState extends State<PhoneChoice> {

  Phone get phone => widget.phone;
  bool get isSelectedPhone => widget.isSelectedPhone;
  String get mobileNetworkName => widget.mobileNetworkName;
  Function get toggleSelectionWithPhone => widget.toggleSelectionWithPhone;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => toggleSelectionWithPhone(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          /// Radio Button Icon
          Icon(isSelectedPhone ? Icons.radio_button_checked : Icons.radio_button_unchecked_sharp, color: Colors.green,),
          
          /// Spacer
          const SizedBox(width: 4,),

          /// Phone Number
          CustomBodyText('${phone.number} $mobileNetworkName')

        ],
      ),
    );
  }
}