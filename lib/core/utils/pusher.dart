import 'package:bonako_demo/features/api/providers/api_provider.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../../../../core/constants/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

class PusherProvider with ChangeNotifier, WidgetsBindingObserver {

  bool _initialized = false;
  final AuthProvider authProvider;

  /// Pusher does not allow a user to subscribe more that once to the same private-channel.
  /// This is a limitation because sometimes we want to subscribe to the same private-channel
  /// in two or more different widgets so that once that channel receives the data, we can then
  /// respond to the updates in the different widgets of the applications. To solve this limitation,
  /// we can register once instance of a channel, but then capture all the events we want to be fired
  /// whenever that channel receives updates, and then fire every one of those events all at one time.
  Map<String, Map<String, Function(dynamic event)>> _subscribedChannelEvents = {};

  ApiProvider get apiProvider => authProvider.apiProvider;

  PusherProvider({ required this.authProvider }) {
    
    /// Register the WidgetsBindingObserver
    WidgetsBinding.instance.addObserver(this);

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    print('AppLifecycleState: $state');

    /// Handle app lifecycle state changes here
    if (state == AppLifecycleState.resumed) {
      
      /// App is back to the foreground, reconnect to Pusher
      reconnectToPusher();
    
    }

  }

  @override
  void dispose() {
    
    /// Unregister the WidgetsBindingObserver when the provider is disposed
    WidgetsBinding.instance.removeObserver(this);
    
    super.dispose();

  }

  void reconnectToPusher() async {

    final PusherChannelsFlutter pusherInstance = await getInstance();

    print('reconnectToPusher');

    print('pusherInstance.connectionState before: ${pusherInstance.connectionState}');
    
    if (pusherInstance.connectionState == 'DISCONNECTED') {

      /// Reset
      _initialized = false;
      
      /// Reconnect
      await pusherInstance.connect();

      final PusherChannelsFlutter pusherInstance2 = await getInstance();

      print('pusherInstance.connectionState after: ${pusherInstance2.connectionState}');
   
    }

  }

  Future<PusherChannelsFlutter> getInstance({ AuthProvider? authProvider }) async {
    
    try {

      print('*************** _initialized: $_initialized');
      
      PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

      /**
       *  Reference 1: https://pub.dev/packages/pusher_channels_flutter 
       *  Reference 2: https://pusher.com/docs/channels/getting_started/flutter/
       *  Reference 3: https://stackoverflow.com/questions/73783564/how-to-use-private-channel-of-pusher-in-flutter
       */
      if(_initialized == false) {

        /**
         *  Do not place the _initialized = true; after the pusher.init(),
         *  because the await implementation would delay the updating of
         *  the _initialized variable which would be an issue since this
         *  would cause multiple pusher.init() calls if this Provider
         *  is initialized in multiple places of the App at the same 
         *  time. This would cause conflictions when onAuthorizer()
         *  is called multiple times creating multiple pusher auth
         *  tokens, there by invalidating the other tokens.
         */
        _initialized = true;
      
        await pusher.init(
          useTLS: true,
          onAuthorizer: onAuthorizer,
          apiKey: constants.pusherKey,
          cluster: constants.pusherCluster,
        );

        await pusher.connect();

        print('pusher connectionState: ${pusher.connectionState}');

      }

      return pusher;
    
    } catch (e) {
       
      printError(info: "Pusher error detected on PusherProvider class located in the lib/core/utils/pusher.dart file");
      printError(info: "$e");
      rethrow;
    
    }

  }

  /// Your remaining Pusher utility code...

  /// Authenticate the Private Pusher Channels
  /// Reference 1: https://laravel.com/docs/10.x/broadcasting#customizing-the-authorization-request
  /// Reference 2: https://stackoverflow.com/questions/73783564/how-to-use-private-channel-of-pusher-in-flutter
  dynamic onAuthorizer(String channelName, String socketId, dynamic options) async {
    try {

      var pusherAuthHostName = constants.pusherAuthHostName;

      Map body = {
        'socket_id': socketId,
        'channel_name': channelName
      };

      var response = await apiProvider.apiRepository.post(
          handleRequestFailure: false,
          url: pusherAuthHostName,
          body: body
      );

      Map json = jsonDecode(response.body);

      print('*************** onAuthorizer()');
      print(json);

      if (json.containsKey('auth')) {
        return json;
      } else {
        return {"auth": ""};
      }
    } catch (e) {
      print("ERROR 2: $e");
    }
  }

  /// Subscribe for auth login alerts
  void subscribeToAuthLogin({ String? identifier, required dynamic onEvent }) async {
    subscribe(channelName: 'private-login.${authProvider.userId}', identifier: identifier, onEvent: onEvent);
  }

  /// Unsubscribe for auth login alerts
  void unsubscribeToAuthLogin({ String? identifier }) async {
    unsubscribe(channelName: 'private-login.${authProvider.userId}', identifier: identifier);
  }

  /// Subscribe for auth notification alerts
  void subscribeToAuthNotifications({ String? identifier, required dynamic onEvent }) async {
    subscribe(channelName: 'private-user.notifications.${authProvider.userId}', identifier: identifier, onEvent: onEvent);
  }

  /// Unsubscribe for auth notification alerts
  void unsubscribeToAuthNotifications({ String? identifier }) async {
    unsubscribe(channelName: 'private-user.notifications.${authProvider.userId}', identifier: identifier);
  }

  /// Subscribe
  /// Use the identifier to differentiate between events if you decide to
  /// call this subscribe method multiple times on the same channel name.
  void subscribe({required String channelName, required String? identifier, required dynamic onEvent}) async {

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
     *      'default': () { ... },        <--- The default identifier for the first event (can be changed e.g identifier1)
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
    identifier ??= "default";

    /// If we have already subscribed to this channel
    if (_subscribedChannelEvents.containsKey(channelName)) {

      /// If we have not added this event to the list of subscribed channel events
      if (!_subscribedChannelEvents[channelName]!.containsKey(identifier)) {
          
        /// Add this event to the list of subscribed channel events
        _subscribedChannelEvents[channelName]![identifier] = onEvent;

      }

    /// If we have never subscribed to this channel
    } else {

      /// Add this first event to the empty list of subscribed channel events
      _subscribedChannelEvents[channelName] = {
        identifier: onEvent
      };

      (await getInstance()).subscribe(
        channelName: channelName,
        onEvent: (event) {

          print('^^^^ FIRE EVENTS ^^^^');
          print(_subscribedChannelEvents[channelName]);

          ///  Foreach of this channel events
          for (var capturedOnEvent in _subscribedChannelEvents[channelName]!.values) {
            
            print(capturedOnEvent);

            /// Fire each event using a new function that captures the onEvent callback
            // Create a new function with a new context that captures the onEvent callback
            newCallback() => capturedOnEvent(event);
            
            // Call the new function
            newCallback();

          }

        },
      );

    }
  }

  /// Unsubscribe
  void unsubscribe({ required String channelName, required String? identifier }) async {
      
    print('@@ removeEvent - stage 1');

    /// If we have already subscribed to this channel
    if (_subscribedChannelEvents.containsKey(channelName)) {
      
      print('@@ removeEvent - stage 2');

      identifier ??= "default";

      /// If we have already subscribed to this channel with the default or specified identifier
      if (!_subscribedChannelEvents[channelName]!.containsKey(identifier)) {
      
        print('@@ removeEvent - stage 3');
          
        /// Remove this identifier and its associated event from this subscribed channel
        _subscribedChannelEvents[channelName]!.remove(identifier);

        /// If this subscribed channel does not have any identifiers and their associated events
        if (_subscribedChannelEvents[channelName]!.isEmpty) {
      
        print('@@ removeEvent - stage 4');

          /// Remove the channel name reference
          _subscribedChannelEvents.remove(channelName);

          /// Unsubscribe from this channel
          (await getInstance()).unsubscribe(channelName: channelName);

        }

      }

    } 

  }

}
