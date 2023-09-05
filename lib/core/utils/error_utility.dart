import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

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
  static void setServerValidationErrors(Function setState, Map serverErrors, dio.DioException exception) {

    if(exception.response?.statusCode == 422) {

      /**
       *  errors = {
       *    name: [The name must be more than 3 characters]
       * }
       */
      setState(() {

        print('serverErrors');
        print(exception.response?.data);
        final Map<String, dynamic> validationErrors = exception.response?.data['errors'] ?? {};

        validationErrors.forEach((key, value) {
          serverErrors[key] = value[0];
        });
        
      });
      
    }

  }

  /// Set the validation errors as serverErrors
  static void showFirstServerValidationError(dio.DioException exception) {

    /// Get the response data
    final Map data = exception.response!.data;

    /// Get the first validation error
    final firstValidationErrorMessage = (data['errors'] as Map).entries.first.value[0];

    /// Show the error message
    SnackbarUtility.showErrorMessage(message: firstValidationErrorMessage);

  }

}