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

  final bool enableBulkSelection;
  final void Function(List<Contact>) onSelection;
  final List<MobileNetworkName> supportedMobileNetworkNames;

  const ContactList({
    super.key,
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

  bool isLoading = false;
  String searchWord = '';
  bool selectedAll = false;
  List<Contact> contacts = [];
  List<Contact> selectedContacts = [];
  List<Map<String, dynamic>> selectedPhoneIndexes = [];

  int get totalFilteredContacts => filteredContacts.length;
  int get totalSelectedContacts => selectedContacts.length;
  bool get enableBulkSelection => widget.enableBulkSelection;
  void Function(List<Contact>) get onSelection => widget.onSelection;
  String get totalContactsSelectedText => '$totalSelectedContacts ${totalSelectedContacts == 1 ? 'contact' : 'contacts'} selected';

  List<Contact> get filteredContacts {
    return contacts.where((contact) {

      /// Check if the search term matches the display name
      final bool matchesDisplayName = contact.displayName.toLowerCase().contains(RegExp(searchWord.toLowerCase()));
      
      /// Check if the search term matches one of the mobile numbers
      final bool matchesMobileNumber = contact.phones.where((phone) {
        final searchWordMobileNumber  = MobileNumberUtility.simplify(searchWord);
        if(searchWordMobileNumber.isNotEmpty) {
          return MobileNumberUtility.simplify(phone.number).contains(RegExp(searchWordMobileNumber));
        }else{
          return false;
        }
      }).isNotEmpty;
      
      /// Check if the search term matches one of the address
      final bool matchesAddress = contact.addresses.where((address) {
          return address.address.toLowerCase().contains(searchWord.toLowerCase());
      }).isNotEmpty;

      return matchesDisplayName || matchesMobileNumber || matchesAddress;
    }).toList();
  }

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  
  @override
  void initState() {
    super.initState();
    requestContacts();
  }

  void requestContacts () async {

    _startLoader();

    /// Request contact permission
    if (await FlutterContacts.requestPermission()) {
        
      /// Get all contacts (fully fetched)
      contacts = await FlutterContacts.getContacts(
        withProperties: true, 
        withThumbnail: false,
        withPhoto: false
      );

      /// Filter contacts by supported mobile network names
      contacts = filterContactsBySupportedMobileNetworkNames(contacts);

    }

    _stopLoader();

  }

  List<Contact> filterContactsBySupportedMobileNetworkNames(List<Contact> contacts) {
    
    /// Return contacts with supported phones
    return contacts.where((contact) {

      /// Remove unsupported phones from each contact
      contact.phones.removeWhere((phone) {

        MobileNetworkName? mobileNetworkName = MobileNumberUtility.getMobileNetworkName(phone.number);
        
        /// Remove the phone if does not match any mobile network name
        if(mobileNetworkName == null) return true;
        
        /// Remove the phone if its not supported at the moment 
        /// Check if this current phone isn't in the list of 
        /// the supported mobile network names
        return widget.supportedMobileNetworkNames.map((supportedMobileNetworkName) => supportedMobileNetworkName.name).contains(mobileNetworkName.name) == false;
      
      });

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

    /// Make sure that this contact has not been selected already
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

      /// Get the matching selected contact. We need to get the orignial copy
      /// because the order of the phones does not change with the original
      /// contacts, but the order of the phones keeps changing with the
      /// selectedContacts. So we need to consider whether or not to
      /// re-arrange phones based on the original contacts otherwise
      /// if we use the selectedContacts we will keep rotating the
      /// numbers each time we select another number since the 
      /// arrangement keeps changing.
      final matchingContact = contacts.firstWhere((currentContact) => currentContact.id == selectedContact.id);
      
      /// Get the matching selected phone index
      final matchingSelectedPhoneIndex = selectedPhoneIndexes.firstWhere((selectedPhoneIndex) => selectedPhoneIndex['id'] == selectedContact.id);
      
      /// Return a copy of the selected contact with the phones rearranged
      /// by placing the preffered phone at the top of the stack
      final Contact modifiedContact = rearrangeContactPhones(matchingContact, matchingSelectedPhoneIndex['phoneIndex']);

      return modifiedContact;

    }).toList();

    /// Update whether or not we have selected all contacts
    updateIfSelectedAllContacts();

    //// Notify parent
    onSelection(selectedContacts);

  }

  Contact rearrangeContactPhones(Contact contact, int selectedPhoneIndex) {

    /// If the selected phone is not at the top of the list 
    if (selectedPhoneIndex >= 0) {
      
      /// Copy the contact so that we can rearrange the phone without
      /// affecting the original contact phones otherwise this will
      /// change the phone arrangement on the contact list UI, but
      /// we want the UI to remain the same while pushing the
      /// contact to the parent with the preffered mobile
      /// number at the top of the list.
      Contact contactCopy = Contact.fromJson(contact.toJson());

      /// Get the selected phone
      Phone selectedPhone = contactCopy.phones[selectedPhoneIndex];

      /// Remove the selected phone from its current position
      contactCopy.phones.removeAt(selectedPhoneIndex);

      /// Place the selected phone to the top of the list
      contactCopy.phones.insert(0, selectedPhone);

      /// Return the modified conpy
      return contactCopy;

    } else {
      
      /// Return the original copy, no changes are required
      return contact;

    }

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
            
          /// Search Input Field
          searchInputField,

          if(enableBulkSelection) Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16, left: 20, right: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
      
                /// Select All Checkbox
                selectAllCheckbox,

                /// Total Contacts Selected
                CustomBodyText(totalContactsSelectedText),

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
                  selectContact: selectContact,
                  unselectContact: unselectContact,
                  selectedContacts: selectedContacts,
                  enableBulkSelection: enableBulkSelection,
                  selectedPhoneIndexes: selectedPhoneIndexes,
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
  final Function selectContact;
  final Function unselectContact;
  final bool enableBulkSelection;
  final List<Contact> selectedContacts;
  final List<Map<String, dynamic>> selectedPhoneIndexes;

  const ContactItem({
    super.key, 
    required this.contact,
    required this.selectContact,
    required this.unselectContact,
    required this.selectedContacts,
    required this.enableBulkSelection,
    required this.selectedPhoneIndexes
  });

  @override
  State<ContactItem> createState() => _ContactItemState();
}

class _ContactItemState extends State<ContactItem> {

  Contact get contact => widget.contact;
  bool get hasPhone => contact.phones.isNotEmpty;
  Function get selectContact => widget.selectContact;
  bool get hasAddress => contact.addresses.isNotEmpty;
  bool get hasManyPhones => contact.phones.length > 1;
  Function get unselectContact => widget.unselectContact;
  bool get enableBulkSelection => widget.enableBulkSelection;
  List<Contact> get selectedContacts => widget.selectedContacts;
  List<Map<String, dynamic>> get selectedPhoneIndexes => widget.selectedPhoneIndexes;
  bool get isSelected => selectedContacts.where((selectedContact) => selectedContact.id == contact.id).isNotEmpty;

  int get selectedPhoneIndex {
  
    List<Map> matchingSelectedPhoneIndexes = selectedPhoneIndexes.where((currSelectedPhoneIndex) => currSelectedPhoneIndex['id'] == contact.id).toList();

    if(matchingSelectedPhoneIndexes.isNotEmpty) {
      return matchingSelectedPhoneIndexes.first['phoneIndex'];
    }else{

      /// Try to acquire the index number of the first Orange Mobile Number
      final int index = contact.phones.indexWhere((phone) => MobileNumberUtility.getMobileNetworkName(phone.number) == MobileNetworkName.orange);
      
      /// Check if we have an Orange Number that we can select
      if(index > 0) {
        return index;
      }else{
        return 0;
      }

    }

  }

  String get prefferedMobileNumber {
    return MobileNumberUtility.simplify(contact.phones[selectedPhoneIndex].number);
  }

  @override
  void initState() {
    super.initState();
  }

  String getMobileNetworkName(String mobileNumber) {
    final MobileNetworkName? mobileNetworkName = MobileNumberUtility.getMobileNetworkName(mobileNumber);
    return mobileNetworkName == null ? '' : StringUtility.capitalize(mobileNetworkName.name);
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
        onTap: () => selectContact(contact, selectedPhoneIndex),
        leading: ContactAvatar(contact: contact),
        title: Stack(
          children: [
        
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTitleMediumText(contact.displayName),
                          if(hasPhone && !(isSelected && hasManyPhones)) const SizedBox(height: 4,),
                          if(hasPhone && !(isSelected && hasManyPhones)) CustomBodyText('$prefferedMobileNumber ${getMobileNetworkName(prefferedMobileNumber)}', color: Colors.grey,),
                          if(hasAddress) const SizedBox(height: 4,),
                          if(hasAddress) CustomBodyText(StringUtility.removeLineBreaks(contact.addresses.first.address)),
                        ],
                      ),
                    ),
          
                    const SizedBox(width: 16,),
          
                    if(!enableBulkSelection) GestureDetector(
                      onTap: () => selectContact(contact, selectedPhoneIndex),
                      child: Icon(Icons.arrow_forward, size: 20, color: Colors.grey.shade400),
                    )
                  ],
                ),
        
                if(isSelected && hasManyPhones) Column(
                  children: [
                    const SizedBox(height: 4,),
                    ...contact.phones.mapIndexed((index, phone) {
                      final bool isSelectedPhone = selectedPhoneIndex == index;
                      return GestureDetector(
                        onTap: () => selectContact(contact, index),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(isSelectedPhone ? Icons.radio_button_checked : Icons.radio_button_unchecked_sharp, color: Colors.green,),
                            const SizedBox(width: 4,),
                            CustomBodyText('${phone.number} ${getMobileNetworkName(phone.number)}'),
                          ],
                        ),
                      );
                    }).toList()
                  ],
                ),
              ],
            ),
        
            /// Cancel Icon
            if(enableBulkSelection && isSelected) Positioned(
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
