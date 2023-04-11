import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../core/shared_models/user_and_store_association.dart';
import '../../../../core/utils/snackbar.dart';
import '../../providers/store_provider.dart';
import '../../models/shoppable_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class FollowStoreButton extends StatefulWidget {
  
  final Alignment alignment;
  final ShoppableStore store;

  const FollowStoreButton({
    super.key,
    required this.store,
    this.alignment = Alignment.center
  });

  @override
  State<FollowStoreButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowStoreButton> {

  bool isLoading = false;

  ShoppableStore get store => widget.store;
  Alignment get alignment => widget.alignment;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get isFollowing => userAndStoreAssociation.followerStatus.toLowerCase() == 'following';
  UserAndStoreAssociation get userAndStoreAssociation => store.attributes.userAndStoreAssociation!;

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);

  _requestUpdateFollowing() {

    _startLoader();

    storeProvider.setStore(store).storeRepository.updateFollowing().then((response) async {

      if(response.statusCode == 200) {

        final responseBody = jsonDecode(response.body);

        SnackbarUtility.showSuccessMessage(message: responseBody['message']);

        setState(() {
          
          store.attributes.userAndStoreAssociation!.followerStatus = responseBody['followerStatus'];

        });

      }

    }).catchError((error) {

      SnackbarUtility.showErrorMessage(message: 'Can\'t ${isFollowing ? 'unfollow' : 'follow'}');

    }).whenComplete((){

      _stopLoader();

    });

  }

  @override
  Widget build(BuildContext context) {

    return CustomElevatedButton(
      isFollowing ? 'Unfollow' : 'Follow',
      onPressed: _requestUpdateFollowing,
      padding: EdgeInsets.zero,
      isLoading: isLoading,
      alignment: alignment,
    );

  }
}