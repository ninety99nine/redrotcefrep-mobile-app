import '../subscribe_to_store/subscribe_to_store_modal_bottom_sheet/subscribe_to_store_modal_bottom_sheet.dart';
import '../store_menu/store_menu_modal_bottom_sheet/store_menu_modal_bottom_sheet.dart';
import '../store_cards/store_card/primary_section_content/primary_section_content.dart';
import '../../../../core/shared_widgets/message_alerts/custom_message_alert.dart';
import '../../../shopping_cart/widgets/shopping_cart_content.dart';
import '../add_store_to_group/add_to_group_button.dart';
import '../follow_store/follow_store_button.dart';
import '../../services/store_services.dart';
import '../../models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class StorePage extends StatefulWidget {

  static const routeName = 'StorePage';

  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
  
}

class _StorePageState extends State<StorePage> {

  @override
  Widget build(BuildContext context) {

    final ShoppableStore store = ModalRoute.of(context)!.settings.arguments as ShoppableStore;

    return Scaffold(
      body: SafeArea(
        child: StorePageContent(store: store),
      ),
    );
  }
}

class StorePageContent extends StatelessWidget {

  final ShoppableStore store;
  
  const StorePageContent({required this.store, Key? key}) : super(key: key);

  double get logoRadius => isOpen && hasDescription  ? 36 : 24;
  bool get hasDescription => store.description != null;

  bool get isOpen => StoreServices.isOpen(store);
  bool get hasJoinedStoreTeam => StoreServices.hasJoinedStoreTeam(store);
  bool get isClosedButNotTeamMember => StoreServices.isClosedButNotTeamMember(store);

  Widget _trigger(void Function()? openBottomModalSheet) {

    return IconButton(
      onPressed: openBottomModalSheet,
      padding: const EdgeInsets.all(4.0),
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.more_vert_rounded, size: 24, color: Colors.grey,)
    );

  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
    
                /// Back Arrow
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),

                /// Menu Modal Bottom Sheet
                StoreMenuModalBottomSheet(
                  store: store,
                  trigger: _trigger,
                ),

              ],
            ),
    
            /// Spacer
            const SizedBox(height: 16,),
    
            /// Store Logo, Profile, Adverts, Rating, e.t.c
            StorePrimarySectionContent(
              store: store,
              logoRadius: logoRadius, 
              showProfileRightSide: false,
            ),

            if(!isOpen && hasJoinedStoreTeam) ...[

              /// Spacer
              const SizedBox(height: 20,),

              /// Subscribe Message Alert
              const CustomMessageAlert('You cannot access this store until you subscribe'),

              /// Divider
              const Divider(height: 40,),

              /// Subscribe Modal Bottom Sheet
              SubscribeToStoreModalBottomSheet(
                store: store,
                subscribeButtonAlignment: Alignment.center,
              )
            
            ],

            if(isOpen || isClosedButNotTeamMember) Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                
                /// Add Store To Group Button
                AddStoreToGroupButton(store: store),
    
                /// Spacer
                const SizedBox(width: 8,),

                /// Follow / Unfollow Button
                FollowStoreButton(store: store, alignment: Alignment.centerRight),

              ],
            ),

            if(!isOpen && !hasJoinedStoreTeam) ...[

              /// Spacer
              const SizedBox(height: 20,),

              /// Cannot Place Orders Message Alert
              const CustomMessageAlert('You cannot place orders because the store managers are not available to take orders'),
            
            ],

            if(isOpen) ... [
    
              /// Spacer
              const SizedBox(height: 16,),
              
              // Shopping Cart
              ListenableProvider.value(
                value: store,
                child: const ShoppingCartContent(
                  shoppingCartCurrentView: ShoppingCartCurrentView.storePage,
                )
              ),
          
              //  Spacer
              const SizedBox(height: 100),

            ],
    
          ],
        ),
      ),
    );
  }
}
