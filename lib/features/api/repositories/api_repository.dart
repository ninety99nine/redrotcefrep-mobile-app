import 'dart:convert';

import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';

class ApiRepository {

  String? bearerToken;
  late Future<String?> bearerTokenFuture;

  Map<String, String> get apiHeaders => {
    'Authorization': 'Bearer $bearerToken',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  ApiRepository() {

    /// Automatically acquire the bearer token stored on the device
    bearerTokenFuture = ApiService.getBearerTokenFromDeviceStorage().then((bearerToken) {

      setBearerToken(bearerToken);
      return bearerToken;

    });

  }

  /// Set the bearer token
  ApiRepository setBearerToken(String? bearerToken) {
    this.bearerToken = bearerToken;
    return this;
  }

  /// Make GET Request
  Future<dio.Response> get({
    required String url,
    bool handleRequestFailure = true,
    Map<String, String>? queryParams,
    void Function(int, int)? onSendProgress,
  }) async {

    print('get url $url');
    print('_bearerToken: $bearerToken');

    try {
      
      dio.Response response = await Dio().get(
        url,
        options: Options(
          headers: apiHeaders
        ),
        queryParameters: queryParams,
      );

      return response;
      
    } on DioException catch (exception) {

      ApiService.handleRequestFailure(exception: exception);
      rethrow;
      
    }

  }

  /// Make POST Request
  Future<dio.Response> post({
    required String url,
    Map<String, dynamic>? body,
    bool handleRequestFailure = true,
    Map<String, String>? queryParams,
    void Function(int, int)? onSendProgress,
  }) async {

    print('post url $url');
    print('_bearerToken: $bearerToken');
    print('post body');
    print(body);

    FormData? formData;

    /// Check if this data has files
    final hasFiles = (body ?? {}).entries.where((entry) => entry.value.runtimeType == XFile).isNotEmpty;

    /// If this data has files
    if(hasFiles) {

      /// Set the FormData object
      formData = FormData();

      /// Check if this data has fields
      final hasFields = (body ?? {}).entries.where((entry) => entry.value.runtimeType != XFile).isNotEmpty;

      /// Add regular fields if available
      /// Convert non-string values to strings
      /// formData.fields.addAll((body ?? {}).entries.where((entry) => entry.value.runtimeType != XFile).map(
      ///   (entry) => MapEntry(entry.key, entry.value.toString()),
      /// ));
    
      if(hasFields) {

        print('stage 1');

        /// Get the JSON data to be sent
        final Map<String, dynamic> json = Map.fromEntries((body ?? {}).entries.where((entry) => entry.value.runtimeType != XFile));

        print('stage 2');

        /// Since FormData requires that data is sent as String values,
        /// we need to JSON encode the data so that we can send it as
        /// a string while preserving the data types when recevied by
        /// the API server e.g Integers, Booleans and Arrays can be
        /// properly transmitted over our API with the assurance
        /// that this data will be reconverted from JSON string
        /// to its respective data types. The API server
        /// requires that the data is encapsulated using
        /// a property called "json" so that the server
        /// can know that these information must be
        /// JSON decoded before processing
        formData.fields.add(MapEntry('json', jsonEncode(json)));

        print('stage 3');

      }

      // Add uploadable files if available
      await Future.wait((body ?? {}).entries.where((entry) => entry.value.runtimeType == XFile).map(
        (entry) async {
          final xFile = entry.value as XFile;
          formData!.files.add(MapEntry(
            entry.key,
            await MultipartFile.fromFile(xFile.path, filename: xFile.name),
          ));
        },
      ));

    }

    try {
      
      return await Dio().post(
        url,
        options: Options(
          headers: apiHeaders
        ),
        data: formData ?? body,
        queryParameters: queryParams,
        onSendProgress: onSendProgress,
      );
      
    } on DioException catch (exception) {

      ApiService.handleRequestFailure(exception: exception);
      rethrow;
      
    }

  }

  /// Make PUT Request
  Future<dio.Response> put({
    required String url,
    Map<String, dynamic>? body,
    bool handleRequestFailure = true,
    Map<String, String>? queryParams,
    void Function(int, int)? onSendProgress,
  }) async {

    print('put url $url');
    print('_bearerToken: $bearerToken');
    print('put body');
    print(body);

    try {
      
      return await Dio().put(
        url,
        data: body,
        options: Options(
          headers: apiHeaders
        ),
        queryParameters: queryParams,
        onSendProgress: onSendProgress,
      );
      
    } on DioException catch (exception) {

      ApiService.handleRequestFailure(exception: exception);
      rethrow;
      
    }

  }

  /// Make PATCH Request
  Future<dio.Response> patch({
    required String url,
    Map<String, dynamic>? body,
    bool handleRequestFailure = true,
    Map<String, String>? queryParams,
    void Function(int, int)? onSendProgress,
  }) async {

    print('patch url $url');
    print('_bearerToken: $bearerToken');
    print('patch body');
    print(body);

    try {
      
      return await Dio().patch(
        url,
        data: body,
        options: Options(
          headers: apiHeaders
        ),
        queryParameters: queryParams,
        onSendProgress: onSendProgress,
      );
      
    } on DioException catch (exception) {

      ApiService.handleRequestFailure(exception: exception);
      rethrow;
      
    }

  }

  /// Make DELETE Request
  Future<dio.Response> delete({
    required String url,
    Map<String, dynamic>? body,
    bool handleRequestFailure = true,
    Map<String, String>? queryParams,
    void Function(int, int)? onSendProgress,
  }) async {

    print('delete url $url');
    print('_bearerToken: $bearerToken');
    print('delete body');
    print(body);

    try {
      
      return await Dio().delete(
        url,
        data: body,
        options: Options(
          headers: apiHeaders
        ),
        queryParameters: queryParams
      );
      
    } on DioException catch (exception) {

      ApiService.handleRequestFailure(exception: exception);
      rethrow;
      
    }

  }

}