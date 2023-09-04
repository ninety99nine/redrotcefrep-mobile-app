import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'dart:convert';

class ApiRepository {

  String? bearerToken;
  late Future<String?> bearerTokenFuture;

  Map<String, String> get apiHeaders => {
    'Authorization': 'Bearer $bearerToken',
    'Content-Type': 'application/json'
  };

  ApiRepository() {

    /// Automatically acquire the bearer token stored on the device
    bearerTokenFuture = ApiService.getBearerTokenFromDeviceStorage().then((bearerToken) {

      setBearerToken(bearerToken);

    });

  }

  /// Set the bearer token
  ApiRepository setBearerToken(String? bearerToken) {
    this.bearerToken = bearerToken;
    return this;
  }

  setQueryParamsOnUrl({ required String url, Map<String, String>? queryParams, int? page }) {

    //  Set the query params
    queryParams = queryParams ?? {};

    //  Add the page as a query param (if provided)
    if(page != null) queryParams.addAll({ 'page': page.toString() });

    if(queryParams.isNotEmpty) {

      final encodedQueryParams = queryParams.entries.map((entry) {

        final key = Uri.encodeQueryComponent(entry.key);
        final value = Uri.encodeQueryComponent(entry.value);
        return '$key=$value';

      }).join('&');

      final separator = url.contains('?') ? '&' : '?';

      url = '$url$separator$encodedQueryParams';

      return url;

    }else{
      
      return url;

    }

  }

  /// Make GET Request
  Future<http.Response> get({ required String url, Map<String, String>? queryParams, int? page, handleRequestFailure = true }) async {
    
    await Future.delayed(const Duration(seconds: 0));

    //  Set the query params on the request url
    url = setQueryParamsOnUrl(url: url, page: page, queryParams: queryParams);

    print('get url $url');
    print('_bearerToken: $bearerToken');

    return http.get(
      Uri.parse(url),
      headers: apiHeaders,
    ).then((response) {

      if(handleRequestFailure) ApiService.handleRequestFailure(response: response);
      return response;
      
    }).catchError((error) {
      print(error);
      ApiService.handleApplicationFailure(error);
      throw(error);
      
    });
  }

  /// Make POST Request
  Future<http.Response> post({ required String url, body = const {}, Map<String, String>? queryParams, int? page, handleRequestFailure = true }) async {
    
    await Future.delayed(const Duration(seconds: 0));

    //  Set the query params on the request url
    url = setQueryParamsOnUrl(url: url, page: page, queryParams: queryParams);
    
    print('post url $url');
    print('_bearerToken: $bearerToken');
    print('post body');
    print(body);

    return http.post(
      Uri.parse(url),
      headers: apiHeaders,
      body: jsonEncode(body),
    ).then((response) {

      if(handleRequestFailure) ApiService.handleRequestFailure(response: response);
      return response;
      
    }).catchError((error) {

      ApiService.handleApplicationFailure(error);
      throw(error);
      
    });
    
  }

  /// Make POST Request with uploadable files
  Future<dio.Response> postWithDio({
    required String url,
    Map<String, String>? queryParams,
    required Map<String, dynamic> body,
    void Function(int, int)? onSendProgress,
    bool handleRequestFailure = true,
  }) async {

    print('post url $url');
    print('_bearerToken: $bearerToken');
    print('post body');
    print(body);

    final dio.FormData formData = dio.FormData.fromMap(body);

    try {
      
      return await Dio().post(
        url,
        data: formData,
        options: Options(
          headers: apiHeaders
        ),
        queryParameters: queryParams,
        onSendProgress: onSendProgress,
      );
      
    } on DioException catch (exception) {

      ApiService.handleDioRequestFailure(exception: exception);
      rethrow;
      
    }

  }

  /// Make PUT Request
  Future<http.Response> put({ required String url, Map<String, String>? queryParams, body = const {}, handleRequestFailure = true }) async {
    
    await Future.delayed(const Duration(seconds: 0));

    //  Set the query params on the request url
    url = setQueryParamsOnUrl(url: url, queryParams: queryParams);
    
    print('put url $url');
    print('put body');
    print(body);

    return http.put(
      Uri.parse(url),
      headers: apiHeaders,
      body: jsonEncode(body),
    ).then((response) {
      
      if(handleRequestFailure) ApiService.handleRequestFailure(response: response);
      return response;
      
    }).catchError((error) {
      
      ApiService.handleApplicationFailure(error);
      throw(error);
      
    });
  }

  /// Make PATCH Request
  Future<http.Response> patch({ required String url, Map<String, String>? queryParams, body = const {}, handleRequestFailure = true }) async {
    
    await Future.delayed(const Duration(seconds: 0));

    //  Set the query params on the request url
    url = setQueryParamsOnUrl(url: url, queryParams: queryParams);
    
    print('patch url $url');
    print('patch body');
    print(body);

    return http.patch(
      Uri.parse(url),
      headers: apiHeaders,
      body: jsonEncode(body),
    ).then((response) {

      if(handleRequestFailure) ApiService.handleRequestFailure(response: response);
      return response;
      
    }).catchError((error) {

      ApiService.handleApplicationFailure(error);
      throw(error);
      
    });
  }

  /// Make DELETE Request
  Future<http.Response> delete({ required String url, Map<String, String>? queryParams, body = const {}, handleRequestFailure = true }) async {
    
    await Future.delayed(const Duration(seconds: 0));

    //  Set the query params on the request url
    url = setQueryParamsOnUrl(url: url, queryParams: queryParams);
    
    print('delete url $url');
    print('delete body');
    print(body);

    return http.delete(
      Uri.parse(url),
      headers: apiHeaders,
      body: jsonEncode(body),
    ).then((response) {

      if(handleRequestFailure) ApiService.handleRequestFailure(response: response);
      return response;
      
    }).catchError((error) {

      ApiService.handleApplicationFailure(error);
      throw(error);
      
    });
  }

  Map getUploadableFiles(Map body) {
    print('stage 1');
    // Create a copy of the original body
    Map bodyCopy = Map.from(body);
    print('stage 2');
    bodyCopy.removeWhere((key, value) => value.runtimeType != XFile);
    print('stage 3');
    print(bodyCopy);
    return bodyCopy;
  }

  Map excludeUploadableFiles(Map body) {
    print('stage 4');
    // Create a copy of the original body
    Map bodyCopy = Map.from(body);
    print('stage 5');
    bodyCopy.removeWhere((key, value) => value.runtimeType == XFile);
    print('stage 6');
    print(bodyCopy);
    return bodyCopy;
  }

}