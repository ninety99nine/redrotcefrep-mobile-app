import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';

class ApiRepository {

  String? _bearerToken;

  Map<String, String> get _apiHeaders => {
    'Authorization': 'Bearer $_bearerToken',
    'Content-Type': 'application/json'
  };

  /// Set the bearer token
  ApiRepository setBearerToken(String? bearerToken) {
    _bearerToken = bearerToken;
    return this;
  }

  setQueryParamsOnUrl({ required String url, Map<String, String>? queryParams, int? page }) {

    //  Set the query params
    queryParams = queryParams ?? {};

    //  Add the page as a query param (if provided)
    if(page != null) queryParams.addAll({ 'page': page.toString() });

    //  Set the query params on the request url (if any)
    url = queryParams.isEmpty ? url : '$url?${queryParams.map((key, value) => MapEntry(key, '$key=$value')).values.join('&')}';

    return url;

  }

  /// Make GET Request
  Future<http.Response> get({ required String url, Map<String, String>? queryParams, int? page, BuildContext? context }) async {
    
    await Future.delayed(const Duration(seconds: 0));

    //  Set the query params on the request url
    url = setQueryParamsOnUrl(url: url, page: page, queryParams: queryParams);

    print('get url $url');
    print('_bearerToken: $_bearerToken');

    return http.get(
      Uri.parse(url),
      headers: _apiHeaders,
    ).then((response) {

      ApiService.handleRequestFailure(response, context);
      return response;
      
    }).catchError((error) {

      ApiService.handleApplicationFailure(error, context);
      throw(error);
      
    });
  }

  /// Make POST Request
  Future<http.Response> post({ required String url, Map<String, String>? queryParams, body = const {}, BuildContext? context }) async {
    
    await Future.delayed(const Duration(seconds: 0));

    //  Set the query params on the request url
    url = setQueryParamsOnUrl(url: url, queryParams: queryParams);
    
    print('post url $url');
    print('post body');
    print(body);

    return http.post(
      Uri.parse(url),
      headers: _apiHeaders,
      body: jsonEncode(body),
    ).then((response) {

      ApiService.handleRequestFailure(response, context);
      return response;
      
    }).catchError((error) {

      ApiService.handleApplicationFailure(error, context);
      throw(error);
      
    });
    
  }

  /// Make PUT Request
  Future<http.Response> put({ required String url, Map<String, String>? queryParams, body = const {}, BuildContext? context }) async {
    
    await Future.delayed(const Duration(seconds: 0));

    //  Set the query params on the request url
    url = setQueryParamsOnUrl(url: url, queryParams: queryParams);
    
    print('put url $url');
    print('put body');
    print(body);
    print('_bearerToken: $_bearerToken');

    return http.put(
      Uri.parse(url),
      headers: _apiHeaders,
      body: jsonEncode(body),
    ).then((response) {

      ApiService.handleRequestFailure(response, context);
      return response;
      
    }).catchError((error) {

      ApiService.handleApplicationFailure(error, context);
      throw(error);
      
    });
  }

  /// Make PATCH Request
  Future<http.Response> patch({ required String url, Map<String, String>? queryParams, body = const {}, BuildContext? context }) async {
    
    await Future.delayed(const Duration(seconds: 0));

    //  Set the query params on the request url
    url = setQueryParamsOnUrl(url: url, queryParams: queryParams);
    
    print('patch url $url');
    print('patch body');
    print(body);

    return http.patch(
      Uri.parse(url),
      headers: _apiHeaders,
      body: jsonEncode(body),
    ).then((response) {

      ApiService.handleRequestFailure(response, context);
      return response;
      
    }).catchError((error) {

      ApiService.handleApplicationFailure(error, context);
      throw(error);
      
    });
  }

  /// Make DELETE Request
  Future<http.Response> delete({ required String url, Map<String, String>? queryParams, body = const {}, BuildContext? context }) async {
    
    await Future.delayed(const Duration(seconds: 0));

    //  Set the query params on the request url
    url = setQueryParamsOnUrl(url: url, queryParams: queryParams);
    
    print('delete url $url');
    print('delete body');
    print(body);

    return http.delete(
      Uri.parse(url),
      headers: _apiHeaders,
      body: jsonEncode(body),
    ).then((response) {

      ApiService.handleRequestFailure(response, context);
      return response;
      
    }).catchError((error) {

      ApiService.handleApplicationFailure(error, context);
      throw(error);
      
    });
  }

}