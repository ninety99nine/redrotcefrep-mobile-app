import '../../../../core/shared_models/permission.dart';
import '../widgets/store_page/store_page.dart';
import '../models/shoppable_store.dart';
import 'package:get/get.dart';

class StoreServices {

  /// Navigate to the show store page
  static void navigateToStorePage(ShoppableStore store) async {

    /// Get the store 
    final ShoppingCartCurrentView shoppingCartCurrentView = store.shoppingCartCurrentView!;
    
    /// The current view is the current view of the shopping cart
    store.changeShoppingCartCurrentView(ShoppingCartCurrentView.storePage, canNotifyListeners: true);
    
    /// Navigate to the page 
    await Get.toNamed(
      StorePage.routeName,
      arguments: store,
    );

    /// Revert back to the previous current view that was in use
    store.changeShoppingCartCurrentView(shoppingCartCurrentView, canNotifyListeners: true);
    
  }

  /// Get the team members permissions on the specified store
  static List<Permission> teamMemberPermissions(ShoppableStore store) {
    if(store.attributes.userAssociationAsTeamMember == null) return [];
    return store.attributes.userAssociationAsTeamMember!.permissions;
  }

  /// Check if the user has the permission to manage 
  /// orders based on the permissions specified
  static bool hasPermissionsToManageOrders(ShoppableStore store) {
    return hasPermissionsTo(store, 'manage orders');
  }

  /// Check if the user has the permission to manage 
  /// team members based on the permissions specified
  static bool hasPermissionsToManageTeamMembers(ShoppableStore store) {
    return hasPermissionsTo(store, 'manage team members');
  }

  /// Check if the user has the permission to perform 
  /// actions based on the provided permission grant
  static bool hasPermissionsTo(ShoppableStore store, String grant) {

    /// Get my permissions
    final List<Permission> permissions = teamMemberPermissions(store);

    /**
     * List<Permission> permissions = [
     *  {
     *    "name": "Manage orders",
     *    "grant": "manage orders",
     *    "description": "Permission to manage orders"
     *  },
     *  ...
     * ]
     */
    return permissions.map((p) => p.grant).contains(grant);
  }

}