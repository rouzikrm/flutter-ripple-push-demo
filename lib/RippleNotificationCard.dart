import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';

class RippleNotificationCard extends StatefulWidget {
  RippleNotificationCard(
      { String topic,
        Color color,
      double containerWidth,
      double containerHeight,
      List<Widget> cardBody,
      double ripplePower,
      String eventType})
      : this.topic =topic,
        this.color = color,
        this.containerWidth = containerWidth,
        this.containerHeight = containerHeight,
        this.cardBody = cardBody,
        this.ripplePower = ripplePower,
        this.eventType = eventType;
  final String eventType;
  final String topic;
  final Color color;
  final double containerWidth;
  final double containerHeight;
  final double ripplePower;
  final List<Widget> cardBody;
  @override
  State<StatefulWidget> createState() => _RippleNotificationCardState(
      stateTopic: topic,
      stateColor: color,
      stateContainerWidth: containerWidth,
      stateContainerHeight: containerHeight,
      stateCardBody: cardBody,
      stateRipplePower: ripplePower,
      stateEventType: eventType);
}

class _RippleNotificationCardState extends State<RippleNotificationCard>
    with TickerProviderStateMixin {
  _RippleNotificationCardState(
      {
      String stateTopic,
      Color stateColor,
      double stateContainerWidth,
      double stateContainerHeight,
      List<Widget> stateCardBody,
      double stateRipplePower,
      String stateEventType})
      : client = MqttClient('192.168.1.2', ''),
        this.stateTopic = stateTopic,
        this.stateColor = stateColor,
        this.stateContainerHeight = stateContainerHeight,
        this.stateContainerWidth = stateContainerWidth,
        this.stateCardBody = stateCardBody,
        this.stateRipplePower = stateRipplePower,
        this.stateEventType = stateEventType;

  String stateTopic;
  String stateEventType;
  AnimationController _controller;
  Color stateColor;
  double stateContainerWidth;
  double stateContainerHeight;
  double stateRipplePower;
  List<Widget> stateCardBody;
  @override
  Widget build(BuildContext context) {
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    Stack stackedView = Stack(children: <Widget>[
      Center(
          child: Dot(
        radiusMax: stateContainerWidth * stateRipplePower,
        radiusMin: 0.0,
        dotController: _controller.view,
        color: stateColor,
      )),
      Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: stateCardBody))
    ]);
    return Container(
        //width: stateContainerWidth,
        //height: stateContainerHeight,
        constraints: BoxConstraints.expand(),
        child: InkWell(
            onTap: () {
              _playAnimation();
            },
            child: stackedView));
  }

  @override
  void initState() {
    super.initState();
    connect(); 
    SmsReceiver receiver = new SmsReceiver();
    receiver.onSmsReceived.listen((SmsMessage msg){
        if (!msg.address.contains("9358544562"))
            return;
        Map commandDetails = json.decode(msg.body);
        if (stateEventType != commandDetails["type"])
            return;
        
        setState((){
           stateColor =Color(int.parse(commandDetails["color"], radix: 16));
           stateCardBody = <Widget>[Text(commandDetails["iv"])];
           Future.delayed(const Duration(milliseconds: 500),(){_playAnimation();});   
        });
        
        
      } 
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await _controller.forward().orCancel;
      _controller.reset();
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

  final MqttClient client;
//final String topic;
//final String clientId;

  Future<int> connect() async {
    /// A websocket URL must start with ws:// or wss:// or Dart will throw an exception, consult your websocket MQTT broker
    /// for details.
    /// To use websockets add the following lines -:
    /// client.useWebSocket = true;
    /// client.port = 80;  ( or whatever your WS port is)
    /// There is also an alternate websocket implementation for specialist use, see useAlternateWebSocketImplementation
    /// Note do not set the secure flag if you are using wss, the secure flags is for TCP sockets only.
    /// You can also supply your own websocket protocol list or disable this feature using the websocketProtocols
    /// setter, read the API docs for further details here, the vast majority of brokers will support the client default
    /// list so in most cases you can ignore this.

    /// Set logging on if needed, defaults to off
    client.logging(on: false);

    /// If you intend to use a keep alive value in your connect message that is not the default(60s)
    /// you must set it here
    client.keepAlivePeriod = 20;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = onDisconnected;

    /// Add the successful connection callback
    client.onConnected = onConnected;

    /// Add a subscribed callback, there is also an unsubscribed callback if you need it.
    /// You can add these before connection or change them dynamically after connection if
    /// you wish. There is also an onSubscribeFail callback for failed subscriptions, these
    /// can fail either because you have tried to subscribe to an invalid topic or the broker
    /// rejects the subscribe request.
    client.onSubscribed = onSubscribed;

    /// Set a ping received callback if needed, called whenever a ping response(pong) is received
    /// from the broker.
    client.pongCallback = pong;

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password, the default keepalive interval(60s)
    /// and clean session, an example of a specific one below.
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier('Shaboore${stateTopic}')
        .keepAliveFor(
            3600) // Must agree with the keep alive set above or not set
        //.withWillTopic('willtopic') // If you set this you must set a will message
        //.withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however eill
    /// never send malformed messages.
    try {
      await client.connect();
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      client.disconnect();
    }

    /// Check we are connected
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print(
          'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
          
      client.disconnect();
    }

    /// Ok, lets try a subscription
    print('EXAMPLE::Subscribing to the $this.topic topic');
    // const String topic = 'test/lol';Not a wildcard topic
    client.subscribe('topic/${this.stateTopic}', MqttQos.atMostOnce);

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      /// The above may seem a little convoluted for users only interested in the
      /// payload, some users however may be interested in the received publish message,
      /// lets not constrain ourselves yet until the package has been in the wild
      /// for a while.
      /// The payload is a byte buffer, this will be specific to the topic
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
          
        Map commandDetails = json.decode(pt); 
        if (stateEventType != commandDetails["type"])
            return;
        
        setState((){
           stateColor =Color(int.parse(commandDetails["color"], radix: 16));
           stateCardBody = <Widget>[Text(commandDetails["iv"])];
           Future.delayed(const Duration(milliseconds: 500),(){_playAnimation();});   
        });
      print('');
    });

    /// Ok, we will now sleep a while, in this gap you will see ping request/response
    /// messages being exchanged by the keep alive mechanism.
    print('EXAMPLE::Sleeping....');
    await MqttUtilities.asyncSleep(120);

    return 0;
  }

  Future<int> disconnect() async {
    /// Finally, unsubscribe and exit gracefully
    print('EXAMPLE::Unsubscribing');
    client.unsubscribe('topic/${this.stateTopic}');

    /// Wait for the unsubscribe message from the broker if you wish.
    await MqttUtilities.asyncSleep(2);
    print('EXAMPLE::Disconnecting');
    client.disconnect();
    return 0;
  }

  Future<int> publishTo(final String pubTopic) {
    /// If needed you can listen for published messages that have completed the publishing
    /// handshake which is Qos dependant. Any message received on this stream has completed its
    /// publishing handshake with the broker.
    client.published.listen((MqttPublishMessage message) {
      print(
          'EXAMPLE::Published notification:: topic is ${message.variableHeader.topicName}, with Qos ${message.header.qos}');
    });

    /// Lets publish to our topic
    /// Use the payload builder rather than a raw buffer
    /// Our known topic to publish to
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString('Hello from mqtt_client');

    /// Subscribe to it
    print('EXAMPLE::Subscribing to the Dart/Mqtt_client/testtopic topic');
    client.subscribe(pubTopic, MqttQos.exactlyOnce);

    /// Publish it
    print('EXAMPLE::Publishing our topic');
    client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus.returnCode == MqttConnectReturnCode.solicited) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
  }

  /// The successful connect callback
  void onConnected() {
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }

  /// Pong callback
  void pong() {
    print('EXAMPLE::Ping response client callback invoked');
  }
}

class Dot extends StatelessWidget {
  double radiusMin;
  double radiusMax;
  Color color;

  Dot({Key key, this.radiusMin, this.radiusMax, this.color, this.dotController})
      : fadeAnimation = new Tween(
          begin: 1.0,
          end: 0.0,
        ).animate(dotController),
        borderRadious = new BorderRadiusTween(
                begin: BorderRadius.circular(30.0),
                end: BorderRadius.circular(1.0))
            .animate(dotController),
        scaleAnimation = new Tween(
          begin: radiusMin,
          end: radiusMax,
        ).animate(dotController),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return new AnimatedBuilder(
      builder: _buildAnimation,
      animation: dotController,
    );
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Container(
        child: Opacity(
            opacity: fadeAnimation.value,
            child: Container(
              width: this.scaleAnimation.value,
              height: this.scaleAnimation.value,
              decoration: BoxDecoration(
                  color: this.color, borderRadius: borderRadious.value),
            )));
  }

  final Animation<BorderRadius> borderRadious;
  final Animation<double> dotController;
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;
}
