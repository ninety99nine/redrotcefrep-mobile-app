import 'package:bonako_demo/core/utils/stream_utility.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:async';

class ErrorUtility {

  static Future<bool> validateForm(GlobalKey<FormState> formKey) {

    /**
     *  We need to allow the setState() method to update the Widget Form Fields
     *  so that we can give the application a chance to update the inputs 
     *  before we validate them.
     * 
     *  This is usually useful after runningsetState on resetting serverErrors:
     * 
     *  setState(() => serverErrors = {});
     */
    return Future.delayed(const Duration(milliseconds: 100)).then((value) {
      return formKey.currentState!.validate() == true;
    });
    
  }

  /// Set the validation errors as serverErrors
  static void setServerValidationErrors(Function setState, Map serverErrors, dio.DioException exception, { StreamUtility? streamUtility }) async {

    /// Get the response data
    getServerValidationErrors(exception, streamUtility: streamUtility).then((validationErrors) {

      if(validationErrors != null) {

        setState(() {
          
          validationErrors.forEach((key, value) {
            serverErrors[key] = value[0];
          });
      
        });

      }

    });

  }

  /// Set the validation errors as serverErrors
  static void showFirstServerValidationError(dio.DioException exception, { StreamUtility? streamUtility }) {

    /// Get the response data
    getServerValidationErrors(exception, streamUtility: streamUtility).then((validationErrors) {

      /// Get the first validation error
      final firstValidationErrorMessage = validationErrors!.entries.first.value[0];

      /// Show the error message
      SnackbarUtility.showErrorMessage(message: firstValidationErrorMessage);

    });

  }

  /// Set the validation errors as serverErrors
  static Future<Map?> getServerValidationErrors(dio.DioException exception, { StreamUtility? streamUtility }) async {
    
    // Check if the response status code is 422 (Unprocessable Entity), indicating validation errors
    if (exception.response?.statusCode == 422) {

      // If this is a streamed response
      if (exception.requestOptions.responseType == dio.ResponseType.stream) {

        // Get the response stream data
        final parsedResponse = await streamUtility!.getResponseStreamData();

        /**
         *  errors = {
         *    userContent: [The user content must be more than 3 characters]
         * }
         */
        return parsedResponse?['errors'];

      } else {

        /**
         *  Handle the case when the response is not streamed
         * 
         *  errors = {
         *    name: [The name must be more than 3 characters]
         * }
         */
        return exception.response?.data['errors'] ?? {};

      }

    }

    return null;
    
  }

}