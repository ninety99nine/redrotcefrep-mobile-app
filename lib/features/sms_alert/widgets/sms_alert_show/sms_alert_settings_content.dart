import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/shared_widgets/checkbox/custom_checkbox.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/multi_select_form_field/custom_multi_select_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/text_field_tags/custom_text_form_field.dart';
import 'package:bonako_demo/features/sms_alert/models/sms_alert_activity_association.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/sms_alert/models/sms_alert_activity.dart';
import 'package:bonako_demo/features/subscriptions/widgets/subscribe/subscribe_modal_bottom_sheet/subscribe_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/user/repositories/user_repository.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/sms_alert/models/sms_alert.dart';
import 'package:bonako_demo/features/stores/enums/store_enums.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

class SmsAlertSettingsContent extends StatefulWidget {
  
  final SmsAlert smsAlert;

  const SmsAlertSettingsContent({
    Key? key,
    required this.smsAlert
  }) : super(key: key);

  @override
  State<SmsAlertSettingsContent> createState() => ReviewsScrollableContentState();
}

class ReviewsScrollableContentState extends State<SmsAlertSettingsContent> {

  late User authUser;
  bool isLoadingStores = false;
  SmsAlert get smsAlert => widget.smsAlert;
  List<ShoppableStore> availableStores = [];
  UserRepository get userRepository => authProvider.userRepository;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  void _startStoresLoader() => setState(() => isLoadingStores = true);
  void _stopStoresLoader() => setState(() => isLoadingStores = false);

  @override
  void initState() {
    super.initState();
    requestUserStores();
    authUser = authProvider.user!;
  }

  /// Request the user stores
  void requestUserStores() {

    _startStoresLoader();

    storeProvider.storeRepository.showUserStores(
      /// Return stores were the user has joined as a team member
      userAssociation: UserAssociation.teamMemberJoined,
      user: authProvider.user!
    ).then((dio.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {
        
        setState(() {

          availableStores = (response.data['data'] as List).map((store) {
            return ShoppableStore.fromJson(store);
          }).toList();

        });

      }

    }).whenComplete(() {

      _stopStoresLoader();

    });

  }

  @override
  Widget build(BuildContext context) {
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          children: [

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                /// SMS Left Indicator
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(width: 2, color: Colors.green),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomTitleLargeText(smsAlert.smsCredits.toString()),
                      const SizedBox(height: 4,),
                      const CustomBodyText('sms left')
                    ],
                  ),
                ),

                /// Spacer
                const SizedBox(width: 16),

                /// Buy SMS button
                SubscribeModalBottomSheet(
                  triggerText: 'Buy SMS',
                  onResumed: requestUserStores,
                  header: const CustomTitleSmallText('💬 Buy SMS Alerts'),
                  generatePaymentShortcode: userRepository.generateSmsAlertPaymentShortcode()
                ),

              ],
            ),

            CustomBodyText(
              'Hey ${authUser.firstName} 👋, I will send you instant SMS alerts 💬 so that I keep you up to date with your stores 🙌. Let me know what you want to be notified about 👊',
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 20),  
            ),

            if(isLoadingStores) const CustomCircularProgressIndicator(margin: EdgeInsets.symmetric(vertical: 40),),
      
            if(!isLoadingStores) ...[

              /// No stores found desclaimer
              if(availableStores.isEmpty) const CustomBodyText(
                'Hmm... I didn\'t find any stores, make sure that you create a store first',
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 20),
                color: Colors.orange,
              ),

              ...smsAlert.relationships.smsAlertActivityAssociations.map((smsAlertActivityAssociation) {
        
                return SmsAlertActivityAssociationItem(
                  availableStores: availableStores,
                  smsAlertActivityAssociation: smsAlertActivityAssociation
                );
        
              })

            ]
          
          ],
        ),
      ),
    );

  }
}

class SmsAlertActivityAssociationItem extends StatefulWidget {

  final List<ShoppableStore> availableStores;
  final SmsAlertActivityAssociation smsAlertActivityAssociation;

  const SmsAlertActivityAssociationItem({
    super.key,
    required this.availableStores,
    required this.smsAlertActivityAssociation
  });

  @override
  State<SmsAlertActivityAssociationItem> createState() => _SmsAlertActivityAssociationItemState();
}

class _SmsAlertActivityAssociationItemState extends State<SmsAlertActivityAssociationItem> {
  
  late bool enabled;
  bool isUpdating = false;
  List<ShoppableStore> selectedStores = [];
  
  UserRepository get userRepository => authProvider.userRepository;
  List<ShoppableStore> get availableStores => widget.availableStores;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  SmsAlertActivityAssociation get smsAlertActivityAssociation => widget.smsAlertActivityAssociation;
  SmsAlertActivity get smsAlertActivity => widget.smsAlertActivityAssociation.relationships.smsAlertActivity;

  void _startLoader() => setState(() => isUpdating = true);
  void _stopLoader() => setState(() => isUpdating = false);

  @override
  void initState() {
    super.initState();
    enabled = smsAlertActivityAssociation.enabled;
    selectedStores = smsAlertActivityAssociation.relationships.stores;
  }

  /// Request the user stores
  void requestUpdateSmsAlertActivityAssociation() {

    _startLoader();

    userRepository.updateSmsAlertActivityAssociation(
      storeIds: selectedStores.map((selectedStore) => selectedStore.id).toList(),
      smsAlertActivityAssociation: smsAlertActivityAssociation,
      enabled: enabled
    ).then((dio.Response response) {

    }).whenComplete(() {

      _stopLoader();

    });

  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
      ),
      margin: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          /// Store Selector
          Row(
            children: [
          
              Checkbox(
                value: enabled,
                onChanged: (value) {
                  if(value != null) setState(() => enabled = value);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)
                ),
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1
                ),
              ),
          
              /// Spacer
              const SizedBox(height: 8,),
          
              Expanded(
                child: CustomMultiSelectFormField(
                  title: smsAlertActivity.name,
                  key: ValueKey(selectedStores.length),
                  hintText: 'Select stores to receive sms alerts',
                  initialValue: (selectedStores).map((selectedStore) => selectedStore.id).toList(),
                  dataSource: List<dynamic>.from(availableStores.map((availableStore) => {
                    'display': availableStore.name,
                    'value': availableStore.id,
                  })),
                  onSaved: (value) {
                      
                    if(value != null) {
                      
                      setState(() {
    
                        selectedStores = availableStores.where((availableStore) => (value as List).contains(availableStore.id)).toList();
                        enabled = selectedStores.isNotEmpty;
    
                        requestUpdateSmsAlertActivityAssociation();
                      
                      });
                    }
                      
                  },
                ),
              ),
          
            ],
          ),
    
        ],
      ),
    );

  }
}