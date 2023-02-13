import '../../../../core/constants/constants.dart' as constants;
import '../repositories/api_repository.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/api_home.dart';
import 'dart:convert';

/// The ApiProvider is strictly responsible for maintaining the
/// state of the _apiHome and _apiRepository. These states can
/// then be shared with the rest of the application. Requests 
/// are managed by the ApiRepository which is responsible for 
/// establishing communication with the REST API.
class ApiProvider with ChangeNotifier {

  ApiHome? _apiHome;
  final ApiRepository _apiRepository = ApiRepository();

  ApiHome? get apiHome => _apiHome;
  ApiRepository get apiRepository => _apiRepository;

  /// Make the Api Call to the Api Home route to acquire the initial payload 
  /// containing guest routes and and the authenticated user provided that
  /// the Bearer Token is valid
  Future<http.Response> setApiHome({ required BuildContext context }) async {
    
    /**
     *  Get the bearer token stored on the device. This usually takes some time, which is why this method 
     *  returns a Future / Promise, so that we can wait for the  process to resolve before we can
     *  continue. As soon as we have set the stored bearer token, we can use it to make a 
     *  GET Request to the API Home endpoint.
     */
    return await ApiService.getBearerTokenFromDeviceStorage().then((String? bearerToken) async {
      /** 
       *  Make an API Call to the API Home endpoint. This endpoint will provide us with the essential 
       *  routes to execute Login, Registation and Logout calls. Since we also set the bearer token 
       *  using the setBearerTokenFromDeviceStorage() method, we can also derive if the user is 
       *  still logged in since this is made available by the "_apiHome.authenticated" property.
       */
      return await setBearerToken(bearerToken).get(url: constants.apiHomeUrl, context: context)
        .then((response) {

          if( response.statusCode == 200 ) {
            
            /// Get the response body
            final responseBody = jsonDecode(response.body);

            /// Parse the response body
            _apiHome = ApiHome.fromJson(responseBody);
            
          }

          return response;

        });
    });

  }

  /// Set the bearer token on the application state by setting 
  /// it on the apiRepository which is part of the apiProvider 
  /// state. This will allow us to make requests while making
  /// use of the bearer token set on the apiRepository.
  ApiRepository setBearerToken(String? bearerToken) {

    /// Set the bearer token on the Api Repository instance
    return _apiRepository.setBearerToken(bearerToken);

  }

  /// Set the bearer token on the application state by setting 
  /// it on the apiRepository which is part of the apiProvider 
  /// state. This will allow us to make requests while making
  /// use of the bearer token set on the apiRepository. Then
  /// notify listeners to trigger the process of rebuilding 
  /// widgets after the bearer token has been set.
  void setBearerTokenAndNotifyListeners(String? bearerToken) {
    setBearerToken(bearerToken);
    notifyListeners();
  }
}