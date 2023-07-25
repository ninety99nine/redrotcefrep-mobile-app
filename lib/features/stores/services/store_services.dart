import 'package:bonako_demo/core/shared_models/user_store_association.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/products/models/product.dart';
import '../widgets/store_page/store_page.dart';
import '../models/shoppable_store.dart';
import 'package:get/get.dart';
import 'dart:convert';

class StoreServices {

  /// Navigate to the show store page
  static void navigateToStorePage(ShoppableStore store) async {

    /// Navigate to the page 
    await Get.toNamed(
      StorePage.routeName,
      arguments: store
    );

  }

  /// Refresh the products of the specified store
  static void refreshProducts(ShoppableStore store, StoreProvider storeProvider) {

    storeProvider.setStore(store).storeRepository.showProducts(
      filter: 'Visible'
    ).then((response) {

      final responseBody = jsonDecode(response.body);
      final List<Product> products = List<Product>.from(responseBody['data'].map((product) => Product.fromJson(product)));
      store.setProducts(products);

    });

  }

  /// Check if the user is a follower to the specified store
  static bool isFollower(ShoppableStore store) {
    return getUserStoreAssociation(store)?.isFollower ?? false;
  }
  /// Check if the user has joined the specified store as a team member
  static bool isTeamMemberWhoHasJoined(ShoppableStore store) {
    return getUserStoreAssociation(store)?.isTeamMemberWhoHasJoined ?? false;
  }

  /// Check if the user has the permission to manage orders on the store
  static bool canManageProducts(ShoppableStore store) {
    return getUserStoreAssociation(store)?.canManageProducts ?? false;
  }

  /// Check if the user has the permission to manage team members on the store
  static bool canManageTeamMembers(ShoppableStore store) {
    return getUserStoreAssociation(store)?.canManageTeamMembers ?? false;
  }

  /// Check if the user is a team member as a creator on the store
  static bool isTeamMemberAsCreator(ShoppableStore store) {
    return getUserStoreAssociation(store)?.isTeamMemberAsCreator ?? false;
  }

  /// Check if the user is a team member as a creator or admin on the store
  static bool isTeamMemberAsCreatorOrAdmin(ShoppableStore store) {
    return getUserStoreAssociation(store)?.isTeamMemberAsCreatorOrAdmin ?? false;
  }

  static UserStoreAssociation? getUserStoreAssociation(ShoppableStore store) {
    /**
     *  The userStoreAssociation will only be available if the user has an association with the store,
     *  but in some cases the userStoreAssociation will be null e.g when showing a brand store or an
     *  influencer store. The user might not necessarily have any relationship with that store e.g
     *  as a team member, follower or recent visitor. In such cases the userStoreAssociation does
     *  not yet exist.
     */
    return store.attributes.userStoreAssociation;
  }

  /// Check if the user has access to the specified store as a shopper
  /// This means that the specified store is open to this user so that
  /// the user can shop
  static bool canAccessAsShopper(ShoppableStore store) {
    return store.attributes.shopperAccess!.status;
  }

  /// Check if the user has access to the specified store as a team member
  /// This means that the user has an active subscription to access this
  /// specified store
  static bool canAccessAsTeamMember(ShoppableStore store) {
    return store.attributes.teamMemberAccess!.status;
  }

}