import '../store_card/primary_section_content/primary_section_content.dart';
import '../../../shopping_cart/widgets/shopping_cart_content.dart';
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

  bool get hasDescription => store.description != null;
  double get logoRadius => hasDescription ? 36 : 24;

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
    
            /// Back Arrow
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
    
            /// Spacer
            const SizedBox(height: 16,),
    
            /// Store Logo, Profile, Adverts, Rating, e.t.c
            StorePrimarySectionContent(
              store: store, 
              logoRadius: logoRadius, 
              showProfileRightSide: false
            ),
    
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
        ),
      ),
    );
  }
}
