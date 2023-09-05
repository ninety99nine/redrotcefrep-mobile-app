import '../../../../core/constants/constants.dart' as constants;
import '../repositories/api_repository.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
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
  Future<dio.Response> setApiHome() async {
    
     /// Make an API Call to the API Home endpoint. This endpoint will provide us with the essential routes
     /// to execute Login, Registation and Logout calls. Since the Bearer token is automatically set on the 
     /// ApiRepository as soon as it is initialized (see ApiRepository constructor), we can also derive if 
     /// the user is still logged in since this is made available by the "_apiHome.authenticated" property.
     /// Note: apiRepository.bearerTokenFuture simply makes sure that we wait until the bearer token has
     /// been provided by the device storage before we attempt to make the Api Home API Call.
      return await apiRepository.bearerTokenFuture.then((bearerToken) {
        return apiRepository.get(url: constants.apiHomeUrl)
          .then((response) {

            if( response.statusCode == 200 ) {

              /// Parse the response body
              _apiHome = ApiHome.fromJson(response.data);
              
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