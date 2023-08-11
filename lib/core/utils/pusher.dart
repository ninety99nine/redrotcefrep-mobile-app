import 'package:bonako_demo/features/api/repositories/api_repository.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/api/providers/api_provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../../../../core/constants/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

class PusherProvider with ChangeNotifier, WidgetsBindingObserver {

  AuthProvider? authProvider;

  //  The pusher channels instance
  PusherChannelsFlutter? _pusherInstance;

  // The single instance of PusherProvider (singleton)
  static PusherProvider? _pusherProviderInstance;

  /// Pusher does not allow a user to subscribe more that once to the same private-channel.
  /// This is a limitation because sometimes we want to subscribe to the same private-channel
  /// in two or more different widgets so that once that channel receives the data, we can then
  /// respond to the updates in the different widgets of the applications. To solve this limitation,
  /// we can register once instance of a channel, but then capture all the events we want to be fired
  /// whenever that channel receives updates, and then fire every one of those events all at one time.
  Map<String, Map<String, Function(dynamic event)>> _subscribedChannelEvents = {};

  ApiRepository? get apiRepository => apiProvider?.apiRepository;
  ApiProvider? get apiProvider => authProvider?.apiProvider;

  /// Private constructor to prevent direct instantiation
  /// This ensures that we can only have one instance of
  /// this PusherProvider class that will have the same
  /// properties shared throughtout the App.
  PusherProvider._({ AuthProvider? authProvider }) {
    
    /// Register the WidgetsBindingObserver.
    /// This is used to track the App lifecycle changes so that we can use 
    /// the didChangeAppLifecycleState() to reconnect Pusher incase we 
    /// navigated to another App causing a disconnection. This can
    /// be remedied by tracking these lifecycle changes so that
    /// we can reconnect Pusher as soon as we have resumed 
    /// using the App.
    WidgetsBinding.instance.addObserver(this);
    
    /// Start connecting to Pusher
    startPusherConnection();

  }

  /// Set the AuthProvider so that you can authourize subscriptions that require
  /// an authenticated user. Its not necessary to set the AuthProvider when
  /// subscribing to public channels since they do not require any
  /// authentication.
  static void setAuthProvider(PusherProvider pusherProvider, AuthProvider newAuthProvider) {
    pusherProvider.authProvider = newAuthProvider;
  }

  /// Factory method to get the single instance of PusherProvider (singleton)
  /// Note: The AuthProvider is optional since its only required for making
  /// subscriptions to private or presence channels
  static PusherProvider getInstance({ AuthProvider? authProvider }) {
    _pusherProviderInstance ??= PusherProvider._(authProvider: authProvider);
    return _pusherProviderInstance!;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    /// Handle app lifecycle state changes here
    if (state == AppLifecycleState.resumed) {
      
      /// App is back to the foreground, reconnect to Pusher
      startPusherConnection();
    
    }else if (state == AppLifecycleState.paused) {
      
      /// App is back to the background, disconnect from Pusher
      stopPusherConnection();
    
    }

  }

  @override
  void dispose() {
    
    /// Unregister the WidgetsBindingObserver when the provider is disposed
    WidgetsBinding.instance.removeObserver(this);
    
    super.dispose();

  }

  Future<PusherChannelsFlutter> startPusherConnection() async {
    
    try {

      if(_pusherInstance == null || _pusherInstance?.connectionState == 'DISCONNECTED') {

        _pusherInstance = PusherChannelsFlutter.getInstance();

        /**
         *  Reference 1: https://pub.dev/packages/pusher_channels_flutter 
         *  Reference 2: https://pusher.com/docs/channels/getting_started/flutter/
         *  Reference 3: https://stackoverflow.com/questions/73783564/how-to-use-private-channel-of-pusher-in-flutter
         */
        await _pusherInstance!.init(
          useTLS: true,
          onAuthorizer: onAuthorizer,
          apiKey: constants.pusherKey,
          cluster: constants.pusherCluster,
        );

        await _pusherInstance!.connect();
        
      }
        
      return _pusherInstance!;
    
    } catch (e) {
       
      printError(info: "Pusher error detected on PusherProvider class located in the lib/core/utils/pusher.dart file while running startPusherConnection()");
      printError(info: "$e");
      rethrow;
    
    }

  }

  Future<PusherChannelsFlutter> stopPusherConnection() async {
    
    try {

      if(_pusherInstance != null && _pusherInstance?.connectionState == 'CONNECTED') {

        await _pusherInstance!.disconnect();
        
      }
        
      return _pusherInstance!;
    
    } catch (e) {
       
      printError(info: "Pusher error detected on PusherProvider class located in the lib/core/utils/pusher.dart file while running stopPusherConnection()");
      printError(info: "$e");
      rethrow;
    
    }

  }

  /// Authenticate the Private Pusher Channels
  /// The onAuthorizer() is called when attempting to subscribe to private or presence channels.
  /// This method is not called when attempting to subscribe to public channels. In order to
  /// authorize these subscriptions, a valid bearer token must be set. This is accomplished
  /// by using the bearer token provided by the ApiRepository.
  /// 
  /// Reference 1: https://laravel.com/docs/10.x/broadcasting#customizing-the-authorization-request
  /// Reference 2: https://stackoverflow.com/questions/73783564/how-to-use-private-channel-of-pusher-in-flutter
  dynamic onAuthorizer(String channelName, String socketId, dynamic options) async {
    try {

      var pusherAuthHostName = constants.pusherAuthHostName;

      Map body = {
        'socket_id': socketId,
        'channel_name': channelName
      };

      var response = await apiProvider!.apiRepository.post(
          handleRequestFailure: false,
          url: pusherAuthHostName,
          body: body
      );

      Map json = jsonDecode(response.body);

      if (json.containsKey('auth')) {
      
        return json;
      
      } else {
        
        return {"auth": ""};

      }

    } catch (e) {
       
      printError(info: "Pusher Authourization error detected on PusherProvider class located in the lib/core/utils/pusher.dart file");
      printError(info: "$e");

    }
  }

  /// Subscribe for auth login alerts
  void subscribeToAuthLogin({ required String identifier, required dynamic onEvent }) async {
    if(authProvider == null) throw Exception("Pusher subscription error detected on PusherProvider class located in the lib/core/utils/pusher.dart file: The authProvider has not been provided");
    subscribe(channelName: 'private-login.${authProvider!.userId}', identifier: identifier, onEvent: onEvent);
  }

  /// Unsubscribe for auth login alerts
  void unsubscribeToAuthLogin({ required String identifier }) async {
    if(authProvider == null) throw Exception("Pusher unsubscribe error detected on PusherProvider class located in the lib/core/utils/pusher.dart file: The authProvider has not been provided");
    unsubscribe(channelName: 'private-login.${authProvider!.userId}', identifier: identifier);
  }

  /// Subscribe for auth notification alerts
  void subscribeToAuthNotifications({ required String identifier, required dynamic onEvent }) async {
    if(authProvider == null) throw Exception("Pusher subscription error detected on PusherProvider class located in the lib/core/utils/pusher.dart file: The authProvider has not been provided");
    subscribe(channelName: 'private-user.notifications.${authProvider!.userId}', identifier: identifier, onEvent: onEvent);
  }

  /// Unsubscribe for auth notification alerts
  void unsubscribeToAuthNotifications({ required String identifier }) async {
    if(authProvider == null) throw Exception("Pusher unsubscribe error detected on PusherProvider class located in the lib/core/utils/pusher.dart file: The authProvider has not been provided");
    unsubscribe(channelName: 'private-user.notifications.${authProvider!.userId}', identifier: identifier);
  }

  /// Subscribe
  /// Use the identifier to differentiate between events if you decide to
  /// call this subscribe method multiple times on the same channel name.
  void subscribe({required String channelName, required String identifier, required dynamic onEvent}) async {
    
    if(_pusherInstance == null) throw Exception("Pusher subscription error detected on PusherProvider class located in the lib/core/utils/pusher.dart file: The pusher instance has not been provided. Please run getInstance() before attempting to subscribe");
    
    /**
     *  The identifier is used to make sure that we can never have duplicate events on the same subscribed channel e.g
     *  Suppose that we subscribe to an channel such as subscribe('private-example.1', onEventLogicOne). The event
     *  called "onEventLogicOne" will be saved on the _subscribedChannelEvents so that it can be later called
     *  whenever updates are received. The problem is that we might leave the widget and then come back
     *  to the same widget without unsubscribing from the channel to clear the "onEventLogicOne" event.
     *  This can become a problem since we would re-run this subscribe() method, and although we won't 
     *  be running the (await getInstance()).subscribe() method below, we would still add this event 
     *  to the _subscribedChannelEvents creating duplicate entries of the exact same event logic. 
     *  To allow us to utilise this subscribe() method without the conflict of ending up with 
     *  duplicate events of the same logic, we can use identifiers.
     * 
     *  _subscribedChannelEvents: {
     *    'private-example.1': {          <--- The "1" would represent the user's ID
     *      'identifier2': () { ... },    <--- You can specify a name for your other events so that we never saved it twice
     *      'identifier2': () { ... },    <--- You can specify a name for your other events so that we never saved it twice
     *      ...
     *    },
     *    private-example2.1: {
     *      ....
     *    }
     *    ...
     *  }
     * 
     *  Here is an simple use case. Suppose you have 2 widgets in 2 separate files that need to all listen to the
     *  private notifications channel on "private-notification.1". On each of these files you can subscribe and
     *  pass the identifier and onEvent callback. Since this is a Provider, the events set on the
     *  _subscribedChannelEvents will be saved even if the user can navigate elsewhere. However
     *  by navigating elsewhere and returning back and calling the subscribe() method, we can
     *  make sure that by using an identifier, we can know which events have already been set
     *  and which have not. This way we can always avoid duplicate event entries for any
     *  channel that we have subscribed to.
     * 
     *  In widget 1: subscribe(channelName: 'private-notification.1', identifier: 'notifications-page', onEvent: () { ... }})
     *  In widget 2: subscribe(channelName: 'private-notification.1', identifier: 'home-page', onEvent: () { ... }})
     * 
     *  This custom code was implemented because Pusher does not allow an authenticated user to subscribe
     *  more that once to the same channel name. We had to rewrite the "subscribe" and "unsubscribe" to
     *  extend this limitation and allow us to be able to subcribe to the same channel but also call
     *  the different events necessary to be called in different widgets.
     */

    /// If we have already subscribed to this channel
    if (_subscribedChannelEvents.containsKey(channelName)) {

      /// If we have not added this event to the list of subscribed channel events
      if (!_subscribedChannelEvents[channelName]!.containsKey(identifier)) {
          
        /// Add this event to the list of subscribed channel events
        _subscribedChannelEvents[channelName]![identifier] = onEvent;

      }else{

        printError(info: 'The pusher identifier "$identifier" already exists. You can only have one unique event identifier per channel subscription');

      }

    /// If we have never subscribed to this channel
    } else {

      /// Add this first event to the empty list of subscribed channel events
      _subscribedChannelEvents[channelName] = {
        identifier: onEvent
      };

       _pusherInstance!.subscribe(
        channelName: channelName,
        onMemberAdded: (_) {},
        onMemberRemoved: (_) {},
        onSubscriptionCount: (_) {},
        onSubscriptionError: (_) {},
        onSubscriptionSucceeded: (_) {},
        onEvent: (event) {

          ///  Foreach of this channel events
          for (var subscriptionEvent in _subscribedChannelEvents[channelName]!.values) {

            /// Fire this event
            subscriptionEvent(event);

          }

        },
      );

    }
  }

  /// Unsubscribe
  void unsubscribe({ required String channelName, required String identifier }) async {
    
    if(_pusherInstance == null) throw Exception("Pusher unsubscribe error detected on PusherProvider class located in the lib/core/utils/pusher.dart file: The pusher instance has not been provided. Please run getInstance() before attempting to unsubscribe");

    /// If we have already subscribed to this channel
    if (_subscribedChannelEvents.containsKey(channelName)) {

      /// If we have already subscribed to this channel with the specified identifier
      if (!_subscribedChannelEvents[channelName]!.containsKey(identifier)) {
          
        /// Remove this identifier and its associated event from this subscribed channel
        _subscribedChannelEvents[channelName]!.remove(identifier);

        /// If this subscribed channel does not have any identifiers and their associated events
        if (_subscribedChannelEvents[channelName]!.isEmpty) {

          /// Remove the channel name reference
          _subscribedChannelEvents.remove(channelName);

          /// Unsubscribe from this channel
           _pusherInstance!.unsubscribe(channelName: channelName);

        }

      }

    } 

  }

  /// Unsubscribe from everything
  void unsubscribeFromEverything() async {
    
    if(_pusherInstance == null) throw Exception("Pusher unsubscribe from everything error detected on PusherProvider class located in the lib/core/utils/pusher.dart file: The pusher instance has not been provided. Please run getInstance() before attempting to unsubscribe from everything");

    /// Foreach subscribed channel
    _subscribedChannelEvents.forEach((channelName, events) async {

      /// Unsubscribe from this channel
      _pusherInstance!.unsubscribe(channelName: channelName);
      
    });

    /// Reset the _subscribedChannelEvents
    _subscribedChannelEvents = {};

  }

}
