import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'dart:async';
class RippleNotificationCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RippleNotificationCardState();

}



class _RippleNotificationCardState extends State<RippleNotificationCard> with TickerProviderStateMixin {
  AnimationController _controller;
  @override
  Widget build(BuildContext context) {
    
    Card card =  Card(child:
    Stack(children: <Widget>[ Center(child:   Dot(radiusMax: 150.0,radiusMin: 0.0,dotController: _controller.view,color: Colors.red,)) ,
    Center(child:
      Column( mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center ,
        mainAxisSize: MainAxisSize.min,children: <Widget>[ 
          Text("Hello"),
          ]
       )
       )
    ] 
    )
    );
    return Container(width: 100.0,height: 100.0,  child: InkWell(onTap:(){ _playAnimation();} ,child: card));
    
  }

  @override
  void initState(){
    super.initState();
    SmsReceiver receiver = new SmsReceiver();
    receiver.onSmsReceived.listen((SmsMessage msg)=> _playAnimation() );
    _controller = AnimationController( duration: const Duration(seconds: 1), vsync: this,);
    
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await _controller.forward().orCancel;
      await _controller.reset();
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

}

class Dot extends StatelessWidget {

  final double radiusMin;
  final double radiusMax;
  final Color color;

  Dot({Key key,this.radiusMin,this.radiusMax,this.color,this.dotController})
    :fadeAnimation = new Tween(begin:1.0,end:0.0,).animate(dotController),
     borderRadious = new BorderRadiusTween(begin: BorderRadius.circular(30.0), end: BorderRadius.circular(1.0)).animate(dotController),
     scaleAnimation = new Tween(begin: radiusMin, end: radiusMax,).animate(dotController),
     super(key: key);


  @override
  Widget build(BuildContext context) {
    return new AnimatedBuilder(builder: _buildAnimation,animation: dotController,);
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return  Container( child: 
    Opacity(
      opacity:fadeAnimation.value,
       child: Container (width: this.scaleAnimation.value, height: this.scaleAnimation.value, decoration: BoxDecoration(color:this.color,
       borderRadius: borderRadious.value
       ),)) );
  }

  final Animation<BorderRadius> borderRadious;
  final Animation<double> dotController;
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;

}