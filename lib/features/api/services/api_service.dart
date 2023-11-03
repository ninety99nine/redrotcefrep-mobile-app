import 'package:bonako_demo/features/introduction/widgets/landing_page.dart';
import 'package:bonako_demo/core/utils/stream_utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bonako_demo/core/utils/error_utility.dart';
import '../../../core/utils/snackbar.dart';
import '../providers/api_provider.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class ApiService {

  /// Save the bearer token from the request on to the device storage
  static Future<dio.Response> setBearerTokenFromResponse(dio.Response response, ApiProvider apiProvider) async {

    if( response.statusCode == 200 || response.statusCode == 201 ) {

      /// Get the response body token
      final token = response.data['accessToken'];

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
  static void handleRequestFailure({ required dio.DioException exception, StreamUtility? streamUtility, bool ignoreValidationErrors = false }) {

    try {
      
      /// Print the external exception error (API error)
      exception.printError();

      /// The request was made and the server responded with a status code
      /// that falls out of the range of 2xx and is also not a 304.
      /// Reference: https://pub.dev/packages/dio#handling-errors
      if (exception.response != null) {

        final int statusCode = exception.response!.statusCode!;

        if(statusCode == 401 || statusCode == 403 || statusCode == 422) {

          /// Check if this is a 401 Unauthorized Request
          if(statusCode == 401) {

            /// Navigate to the page 
            Get.offAndToNamed(LandingPage.routeName);

            final String message = exception.response!.data['message'];

            /// Show the unauthenticated message
            SnackbarUtility.showInfoMessage(message: message);

          }else if(exception.response!.statusCode == 403) {

            final String message = exception.response!.data['message'];
            
            /// Show the unauthorized message
            SnackbarUtility.showErrorMessage(message: message);

          }else if(statusCode == 422 && ignoreValidationErrors == false) {
            
            ErrorUtility.showFirstServerValidationError(exception, streamUtility: streamUtility);

          }

        }

      }

    } catch (e) {
      
      /// Print the internal exception error (Application error)
      e.printError();
      
      /// Show the error message e.g when the handleRequestFailure() logic fails
      SnackbarUtility.showErrorMessage(message: e.toString());

    }

  }

  /// Handle the application failure
  static void handleApplicationFailure(error) {

  }

}