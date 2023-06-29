import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/core/shared_widgets/checkbox/custom_checkbox.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import '../../../../core/constants/constants.dart' as constants;
import 'package:bonako_demo/core/shared_models/user.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class AnonymousDetails extends StatefulWidget {
  const AnonymousDetails({super.key});

  @override
  State<AnonymousDetails> createState() => _AnonymousDetailsState();
}

class _AnonymousDetailsState extends State<AnonymousDetails> {
  
  ShoppableStore? store;

  User get authUser => authProvider.user!;
  bool get hasAnonymousStatus => store?.anonymous != null;
  bool get hasSelectedProducts => store == null ? false : store!.hasSelectedProducts;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the updated Shoppable Store Model
    store = Provider.of<ShoppableStore>(context, listen: false);

    /// If the anonymous status has not been set on this store
    if(hasAnonymousStatus == false) {

      Future.delayed(Duration.zero).then((_) {

        setState(() {

          /// If this store supports identified orders (Orders where the customer can be revealed publicly)
          if(store!.identifiedOrders) {

            /// Set the anonymous status based on the users default anonymous status
            store!.updateAnonymousStatus(authUser.anonymous);

          }else{

            /// Set the anonymous status to indicate that this user is anonymous
            store!.updateAnonymousStatus(true);
            
          }

        });

      });

    }

  }

  @override
  Widget build(BuildContext context) {

    /// Capture the store that was passed on ListenableProvider.value() of the StoreCard. 
    /// This store is accessible if the StoreCard is an ancestor of this 
    /// ShoppableProductCards. We can use this shoppable store instance 
    /// for shopping purposes e.g selecting this product so that we 
    /// can place an order.
    store = Provider.of<ShoppableStore>(context, listen: true);
    
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
        child: Column(
          children: hasSelectedProducts && hasAnonymousStatus ? [
            
            //  Divider
            const Divider(),

            /// Spacer
            const SizedBox(height: 8),

            /// Make me anonymous
            CustomCheckbox(
              crossAxisAlignment: CrossAxisAlignment.start,
              value: store!.anonymous!,
              text: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CustomBodyText('Make me anonymous ${constants.anonymousEmoji}', height: 1.2,),
                  SizedBox(height: 8,),
                  CustomBodyText(
                    'Your order will be seen by others but your name with not appear (Anonymous)', 
                    lightShade: true
                  ),
                ],
              ),
              onChanged: (value) {
                setState(() => store!.updateAnonymousStatus(value ?? false));
              }
            ),

            /// Spacer
            const SizedBox(height: 16),

          ] : [],
        )
      ),
    );
  }
}