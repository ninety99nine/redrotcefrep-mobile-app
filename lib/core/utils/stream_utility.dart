import 'package:dio/dio.dart' as dio;
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

class StreamUtility {

  int? statusCode;
  dio.Response? response;
  late Function onStreamControllerChanged;
  StreamSubscription? responseStreamSubscription;
  StreamController<List<int>> streamController = StreamController<List<int>>.broadcast();

  void setResponse(dio.Response response) {

    /// Set the provided response on the local state
    this.response = response;

    /// Set the provided response status code
    statusCode = response.statusCode;

    /// Listen to the provided response stream to update our local streamController
    _listenToResponseStream();
    
  }

  Future<void> _listenToResponseStream() async {

    if(response == null) {

      throw Exception('The response is required to listen to the stream response data'); 
    
    }else{

      // If this is a streamed response
      if (response!.requestOptions.responseType == dio.ResponseType.stream) {

        // Get the stream from the response data
        final Stream<Uint8List> responseStream = (response!.data as dio.ResponseBody).stream;

        /**
         *  Listen to the stream and add data to the streamController.
         *  Since we cannot listen to the response steam more than once
         *  i.e responseStream.listen(...) can only be exeuted once, therefore
         *  other parts of our application cannot re-run responseStream.listen(...)
         *  to retrieve the same data for processing. So we can listen to this stream once 
         *  and pass the same data to our own streamController which implements the broadcast() method. 
         *  The broadcast() method allows the streamController to be listened to more than once unlike 
         *  responseStream which can only be listened to once.
         * 
         *  Essentially we are just taking the same data from "dio stream" and passing it our own "custom stream"
         *  so that we can do more with the same data by applying as many listeners as we need to.
         */
        responseStreamSubscription = responseStream.listen(
          (List<int> data) {
            streamController.add(data);
          },
          onDone: () {

            /// Dispose the old streamController
            dispose();

            /// Create a new streamController
            /// 
            /// We need to always call streamController.close(); when the responseStream is done otherwise the
            /// "await streamController.stream.transform(utf8.decoder).join();" will never resolve since it 
            /// waits for the streamController to be closed before the stream data can be transformed and 
            /// joined. The getResponseStreamData() is used to acquire the entire payload of the stream 
            /// data collected by responseStream.listen()
            streamController = StreamController<List<int>>.broadcast();

            /// Notify the parent widget of the streamController change
            onStreamControllerChanged();

          },
          // Add error to the streamController if an error occurs
          onError: (error) {
            streamController.addError(error);
          },
          // Cancel the stream subscription on error
          cancelOnError: true,
        );

      }

    }

  }

  Future getResponseStreamData() async {

    if(response == null) {

      throw Exception('The response is required to read the stream response data'); 
    
    }else{

      // Transform the stream into a string (utf8 decoding)
      final responseBody = await streamController.stream.transform(utf8.decoder).join();

      // Return the JSON response
      return json.decode(responseBody);

    }

  }

  void dispose() {
    streamController.close();
    responseStreamSubscription?.cancel();
  }

}
