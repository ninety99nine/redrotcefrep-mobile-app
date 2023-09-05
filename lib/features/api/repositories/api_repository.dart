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
      
      return await Dio().get(
        url,
        options: Options(
          headers: apiHeaders
        ),
        queryParameters: queryParams,
      );
      
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

    final FormData formData = FormData();

    // Add regular fields if available
    formData.fields.addAll((body ?? {}).entries.where((entry) => entry.value.runtimeType != XFile).map(
      (entry) => MapEntry(entry.key, entry.value.toString()),
    ));

    // Add uploadable files if available
    await Future.wait((body ?? {}).entries.where((entry) => entry.value.runtimeType == XFile).map(
      (entry) async {
        final xFile = entry.value as XFile;
        formData.files.add(MapEntry(
          entry.key,
          await MultipartFile.fromFile(xFile.path, filename: xFile.name),
        ));
      },
    ));

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

    final dio.FormData formData = dio.FormData.fromMap(body ?? {});

    try {
      
      return await Dio().put(
        url,
        data: formData,
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

    final dio.FormData formData = dio.FormData.fromMap(body ?? {});

    try {
      
      return await Dio().patch(
        url,
        data: formData,
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

    final dio.FormData formData = dio.FormData.fromMap(body ?? {});

    try {
      
      return await Dio().delete(
        url,
        data: formData,
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