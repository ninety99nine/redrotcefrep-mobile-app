import 'package:dio/dio.dart' as dio;
import 'dart:async';

class ApiConflictResolverUtility {

  int _totalRequests = 0;
  int _totalResponses = 0;
  bool get _requestsHaveCompleted => _totalRequests == _totalResponses;
  
  ///  Imagine that we have two requests. "Request First" was the first request, while "Request Last" 
  ///  was the last request. Obviously we want "Request Last" to be the request that updates the data 
  ///  since this is the last request that was implemented as an Http Request. However its possible
  ///  that "Request First" can take a long time to resolve e.g If it returns more data or than 
  ///  "Request Last", then they might be a delay in processing and returning this data in 
  ///  the request cycle. Another reason might be the result a poor network connection. In 
  ///  any case the "Request Last" will return data before "Request First" and won't be 
  ///  allowed to make an update because we need both requests to be resolved before we 
  ///  can update the data. 
  /// 
  ///  The problem is that once "Request First" resolves, its data will be used to update the "data",
  ///  but this is incorrect data since the data we need is of "Request Last", but "Request Last" 
  ///  resolved sooner than "Request First" and was rejected from updating the data until 
  ///  "Request First" resolved, in which case the result of "Request First" was preferred 
  ///  over the result of "Request Last" since the "Request First" completed "last" 
  ///  instead of completing "first".
  /// 
  ///  To resolve this possible mixup, we need to have a local state of the _totalRequests saved on each 
  ///  Request call. This way we can know to update only if the local state of the "_totalRequests", 
  ///  which we will call "currentTotalRequests" matches with the global _totalRequests. We know for 
  ///  instance that on "Request First" the "currentTotalRequests = 1", but on "Request Last" the 
  ///  "currentTotalRequests = 2". So we can check if the "_totalRequests" and the 
  ///  "currentTotalRequests" match so that we can continue with the update of 
  ///  the data, otherwise we prevent any data changes.
  /// 
  ///  Now we can update the correct data of "Request Last" by implementing 
  ///  the following logic after a successful request.
  /// 
  ///  if( currentResponse == _totalRequests) {
  ///    
  ///     Update the scrollable data using the payload of the "Request Last"
  ///  
  ///  }
  Future<dio.Response> addRequest({ 
    required Future<dio.Response> Function() onRequest, 
    required Function(dio.Response) onCompleted,
    required Function() onStartLoader, 
    required Function() onStopLoader
  }) {

    /// Increment since we are making a new request
    _totalRequests++;

    /// Notify that the loader can be displayed
    onStartLoader();

    final currentTotalRequests = _totalRequests;

    /// Run the Api Request
    return onRequest().then((response) {

      /// Increment since we are done executing the request
      _totalResponses++;

      /// If the current total requests is the same as the total requests
      /// This resolves the conflict of capturing data from the wrong
      /// request and then consuming this data.
      if( currentTotalRequests == _totalRequests) {

        //  Pass this reponse as the completed response to update our data
        onCompleted(response);

      }
      
      return response;

    }).whenComplete(() {

      /**
       *  When we make multiple requests, we need to make sure that the loader stays loading until 
       *  the last request has completed. Suppose that we make 2 requests. The first request will 
       *  start the loader, then the second request will start the loader as well, but no 
       *  difference will be seen as far as the UI is concerned. If the first request
       *  finishes before the second request, then the first request will stop the 
       *  loader, therefore showing content, meanwhile the second request will 
       *  still be pending although the loader is not showing. 
       * 
       *  Once the second request completes it will update the data, therefore content will then 
       *  suddenly change. The second request will stop the loader as well, but no difference
       *  will be seen as far as the UI is concerned. We want to start the loader on the
       *  first request, but we don't want to stop the loader as long as the second
       *  request is pending. We use the _totalRequests and _totalResponses to track
       *  if the total number of requests and responses are the same before we can
       *  stop the loader. If the total requests and responses are the same, then 
       *  the _requestsHaveCompleted will return true, otherwise false.
       */
      if(_requestsHaveCompleted) onStopLoader();

    });

  }

}