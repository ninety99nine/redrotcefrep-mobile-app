import '../../../../core/shared_models/permission.dart';
import '../widgets/store_page/store_page.dart';
import '../models/shoppable_store.dart';
import 'package:get/get.dart';

class StoreServices {

  /// Navigate to the show store page
  static void navigateToStorePage(ShoppableStore store) async {

    /// Navigate to the page 
    await Get.toNamed(
      StorePage.routeName,
      arguments: store
    );

  }

  /// Get the team members permissions on the specified store
  static List<Permission> teamMemberPermissions(ShoppableStore store) {
    if(store.attributes.userAndStoreAssociation == null) return [];
    return store.attributes.userAndStoreAssociation!.teamMemberPermissions;
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

  /// Check if the user has joined the team on the specified store
  static bool hasJoinedStoreTeam(ShoppableStore store) {
    return store.attributes.userAndStoreAssociation?.teamMemberStatus.toLowerCase() == 'joined';
  }

  /// Check if the user is associated as a creator on the specified store
  static bool isAssociatedAsCreator(ShoppableStore store) {
    return store.attributes.userAndStoreAssociation?.teamMemberRole?.toLowerCase() == 'creator';
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