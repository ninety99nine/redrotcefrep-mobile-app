import 'package:get/get.dart';

import '../../../../core/shared_widgets/multiple_mobile_number_form/custom_multiple_mobile_number_form.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../../../core/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:convert';

class FriendCreate extends StatefulWidget {
  
  final void Function(bool) onLoading;
  final void Function() onCreatedFriends;

  const FriendCreate({
    super.key,
    required this.onLoading,
    required this.onCreatedFriends,
  });

  @override
  State<FriendCreate> createState() => _FriendCreateState();
}

class _FriendCreateState extends State<FriendCreate> {
  
  void Function(bool) get onLoading => widget.onLoading;
  void Function() get onCreatedFriends => widget.onCreatedFriends;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  
  /// Request to add friends
  Future<dio.Response> _requestCreateFriends(List<String> mobileNumbers) {

    return authProvider.authRepository.createFriends(
      mobileNumbers: mobileNumbers
    ).then((response) async {

      if(response.statusCode == 200) {

        SnackbarUtility.showSuccessMessage(message: response.data['message'], duration: 4);

        onCreatedFriends();

      }

      return response;

    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Failed to add friends');

    });

  }

  @override
  Widget build(BuildContext context) {
    return CustomMultipleMobileNumberForm(
      instruction: 'you would like to share this order with',
      onRequest: _requestCreateFriends,
      onLoading: onLoading
    );
  }
}