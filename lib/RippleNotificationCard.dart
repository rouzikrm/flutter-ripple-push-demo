import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'dart:async';
import 'dart:convert';
class RippleNotificationCard extends StatefulWidget {
  RippleNotificationCard( {Color color, double containerWidth, double containerHeight, List<Widget> cardBody,double ripplePower}):
   this.color=color,this.containerWidth=containerWidth,this.containerHeight=containerHeight,this.cardBody=cardBody,this.ripplePower=ripplePower;
  final Color color;
  final double containerWidth;
  final double containerHeight;
  final double ripplePower;
  final List<Widget> cardBody;
  @override
  State<StatefulWidget> createState() => _RippleNotificationCardState(stateColor:color,stateContainerWidth:containerWidth,stateContainerHeight:containerHeight,stateCardBody:cardBody,stateRipplePower: ripplePower);

}



class _RippleNotificationCardState extends State<RippleNotificationCard> with TickerProviderStateMixin {
  _RippleNotificationCardState( {Color stateColor, double stateContainerWidth,  double stateContainerHeight, List<Widget>stateCardBody,double stateRipplePower}):
    this.stateColor =stateColor,this.stateContainerHeight =stateContainerHeight, this.stateContainerWidth=stateContainerWidth,this.stateCardBody=stateCardBody,this.stateRipplePower=stateRipplePower;
    
  AnimationController _controller;
  Color stateColor;
  double stateContainerWidth;
  double stateContainerHeight;
  double stateRipplePower;
  List<Widget> stateCardBody;
  @override
  Widget build(BuildContext context) {
    
    
    _controller = AnimationController( duration: const Duration(seconds: 1), vsync: this,);
    Stack stackedView = Stack(children: <Widget>[ 
      Center(child:   Dot(radiusMax: stateContainerWidth*stateRipplePower,radiusMin: 0.0,dotController: _controller.view,color: stateColor,)) ,
      Center(child:
        Column( mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center ,
          mainAxisSize: MainAxisSize.min,children: stateCardBody
       )
       )
    ] 
    );
    return Container(width: stateContainerWidth,height: stateContainerHeight,  child: InkWell(onTap:(){ _playAnimation();} ,child: stackedView));
    
  }

  @override
  void initState(){
    super.initState();
    SmsReceiver receiver = new SmsReceiver();
    receiver.onSmsReceived.listen((SmsMessage msg){
        Map commandDetails = json.decode(msg.body);
        
        setState((){
           stateColor =Color(int.parse(commandDetails["color"], radix: 16));
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

}

class Dot extends StatelessWidget {
  

  double radiusMin;
  double radiusMax;
  Color color;

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

