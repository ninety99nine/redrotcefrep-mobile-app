import 'package:bonako_demo/features/reviews/enums/review_enums.dart';
import '../../../../stores/providers/store_provider.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../reviews_content.dart';
import 'package:get/get.dart';

class ReviewsPage extends StatefulWidget {

  static const routeName = 'ReviewsPage';

  const ReviewsPage({
    super.key,
  });

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {

  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  late UserReviewAssociation userReviewAssociation;
  bool canShowFloatingActionButton = true;
  ShoppableStore? store;

  @override
  void initState() {
    
    super.initState();

    /// Get the route arguments
    final arguments = Get.arguments;

    /// Set the "store" (if provided)
    store = arguments['store'] as ShoppableStore;

    /// Get the "userReviewAssociation"
    userReviewAssociation = arguments['userReviewAssociation'] as UserReviewAssociation;

    /// Get the "canShowFloatingActionButton" (if provided)
    if(arguments.containsKey('canShowFloatingActionButton')) canShowFloatingActionButton = arguments['canShowFloatingActionButton'] as bool;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Content of the page
      body: ReviewsContent(
        store: store,
        showingFullPage: true,
        userReviewAssociation: userReviewAssociation,
        //  canShowFloatingActionButton: canShowFloatingActionButton
      ),
    );
  }
}