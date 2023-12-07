import 'package:bonako_demo/core/utils/stream_utility.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'dart:convert';

class ApiRepository {

  String? bearerToken;
  late Future<String?> bearerTokenFuture;

  Map<String, String> get apiHeaders => {
    'Authorization': 'Bearer $bearerToken',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Platform': 'Mobile'
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
    stream = false,
    required String url,
    Map<String, dynamic>? body,
    StreamUtility? streamUtility,
    bool handleRequestFailure = true,
    Map<String, String>? queryParams,
    void Function(int, int)? onSendProgress,
  }) async {

    print('post url $url');
    print('_bearerToken: $bearerToken');
    print('post body');
    print(body);
      
    if(stream == true && streamUtility == null) {

      throw Exception('The StreamUtility class is required when executing a POST request using on a stream');

    }

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

        /// Get the JSON data to be sent
        final Map<String, dynamic> json = Map.fromEntries((body ?? {}).entries.where((entry) => entry.value.runtimeType != XFile));

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
      
      final response = await Dio().post(
        url,
        options: Options(
          headers: apiHeaders,
          responseType: stream ? ResponseType.stream : null
        ),
        data: formData ?? body,
        queryParameters: queryParams,
        onSendProgress: onSendProgress,
      );
      
      if(stream) {

        /// Set the stream response
        streamUtility!.setResponse(response);

      }

      return response;
      
    } on DioException catch (exception) {
      
      if(stream) {

        /// Set the stream response
        streamUtility!.setResponse(exception.response!);

      }

      ApiService.handleRequestFailure(exception: exception, streamUtility: streamUtility);
      
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