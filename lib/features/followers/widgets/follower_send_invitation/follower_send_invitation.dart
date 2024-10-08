import 'package:perfect_order/core/shared_widgets/multiple_mobile_number_form/custom_multiple_mobile_number_form.dart';
import 'package:get/get.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../models/followers_invitations.dart';
import '../../../../core/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:convert';

class FollowerSendInvitation extends StatefulWidget {
  
  final ShoppableStore store;
  final void Function(bool) onLoading;
  final void Function(FollowersInvitations) onInviteFollowers;

  const FollowerSendInvitation({
    super.key,
    required this.store,
    required this.onLoading,
    required this.onInviteFollowers,
  });

  @override
  State<FollowerSendInvitation> createState() => _FollowerSendInvitationState();
}

class _FollowerSendInvitationState extends State<FollowerSendInvitation> {
  
  ShoppableStore get store => widget.store;
  FollowersInvitations? followersInvitations;

  void Function(bool) get onLoading => widget.onLoading;
  void Function(FollowersInvitations) get onInviteFollowers => widget.onInviteFollowers;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  
  /// Request to invite followers
  Future<dio.Response> _requestInviteFollowers(List<String> mobileNumbers) {

    return storeProvider.setStore(store).storeRepository.inviteFollowers(
      mobileNumbers: mobileNumbers,
    ).then((response) async {

      if(response.statusCode == 200) {

        SnackbarUtility.showSuccessMessage(message: response.data['message'], duration: 4);

        followersInvitations = FollowersInvitations.fromJson(response.data['invitations']);

        onInviteFollowers(followersInvitations!);

      }

      return response;


    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Failed to invite friends');

    });

  }

  @override
  Widget build(BuildContext context) {
    return CustomMultipleMobileNumberForm(
      instruction: 'you would like to invite to follow this store',
      onRequest: _requestInviteFollowers,
      onLoading: onLoading
    );
  }
}