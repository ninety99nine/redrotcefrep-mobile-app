import 'package:bonako_demo/features/introduction/widgets/landing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/snackbar.dart';
import '../providers/api_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

class ApiService {

  /// Save the bearer token from the request on to the device storage
  static Future<http.Response> setBearerTokenFromResponse(http.Response response, ApiProvider apiProvider) async {

    if( response.statusCode == 200 ) {
      
      /// Get the response body
      final responseBody = jsonDecode(response.body);

      /// Get the response body token
      final token = responseBody['accessToken']['token'];

      /// Save the bearer token on to the device storage
      saveBearerTokenOnDeviceStorage(token).then((value) {
        
        /// Set the bearer token on the api provider state
        /// and then notify the api provider listeners
        apiProvider.setBearerTokenAndNotifyListeners(token);

      });

    }

    return response;

  }

  /// Save the bearer token on to the device storage
  static Future<String> saveBearerTokenOnDeviceStorage(String token) async {
    
    await SharedPreferences.getInstance().then((prefs) {

      //  Store bearer token on device storage (long-term storage)
      prefs.setString('bearerToken', token);

    });

    return token;

  }

  /// Get the bearer token that is saved on the device storage
  static Future<String?> getBearerTokenFromDeviceStorage() async {
    
    return await SharedPreferences.getInstance().then((prefs) {

      //  Return the bearer token stored on the device (long-term storage)
      return prefs.getString('bearerToken');

    });

  }

  /// Handle the request failure
  static void handleRequestFailure({ required http.Response response, bool ignoreValidationErrors = false }) {

    try {

      /// Get the response body
      final responseBody = jsonDecode(response.body);

      /// If the request status code is 400 or greater
      if(response.statusCode >= 400) {

        /// Check if this is a 401 Unauthorized Request
        if(response.statusCode == 401) {

          /// Navigate to the page 
          Get.toNamed(
            LandingPage.routeName
          );

          /// Show the unauthorized message
          SnackbarUtility.showInfoMessage(message: responseBody['message']);

        }else {

          print(responseBody);
          print(responseBody['error']);

          /// If the response body contains a message
          if(responseBody.containsKey('message')) {

            if( !(response.statusCode == 422 && ignoreValidationErrors == true) ) {

              /// Show the error message
              SnackbarUtility.showErrorMessage(message: responseBody['message']);

            }

          }else{

            /// Throw an exception since we don't have the Api Error Message to show
            /// using a snackbar. The method responsible for making this Request 
            /// can catch this Exception and show a more meaningful error.
            throw Exception('Request Failed');

          }

        }

      }

    } catch (e) {

      print(e);
      
      e.printError();
      
      /// Show the error message e.g when the jsonDecode(response.body) fails
      SnackbarUtility.showErrorMessage(message: e.toString());

    }

  }

  /// Handle the application failure
  static void handleApplicationFailure(error) {

  }

}