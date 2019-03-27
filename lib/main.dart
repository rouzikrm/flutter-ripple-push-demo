import 'package:flutter/material.dart';
import 'package:simple_ripple_animation/RippleNotificationCard.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reactive Montioring Dashboard',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Reactive Monitoring Dashboard'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        child: _buildContent(),
      ),
      
    );
  }

  Widget _buildContent(){
    return _centeredLayout(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _buildBox(points: 1,eventType:"aa", color: Colors.white),
                _buildBox(points: 1,eventType:"ab", color: Colors.white),
                _buildBox(points: 1,eventType:"ac", color: Colors.white),
                _buildBox(points: 1,eventType:"ad", color: Colors.white),
                _buildBox(points: 1,eventType:"ae", color: Colors.white),
                
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _buildBox(points: 1,eventType:"ba", color: Colors.white),
                _buildBox(points: 1,eventType:"bb", color: Colors.white),
                _buildBox(points: 1,eventType:"bc", color: Colors.white),
                _buildBox(points: 1,eventType:"bd", color: Colors.white),
                _buildBox(points: 1,eventType:"be", color: Colors.white),
                
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _buildBox(points: 1,eventType:"ca", color: Colors.white),
                _buildBox(points: 1,eventType:"cb", color: Colors.white),
                _buildBox(points: 1,eventType:"cc", color: Colors.white),
                _buildBox(points: 1,eventType:"cd", color: Colors.white),
                _buildBox(points: 1,eventType:"ce", color: Colors.white),
                
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _buildBox(points: 1,eventType:"da", color: Colors.white),
                _buildBox(points: 1,eventType:"db", color: Colors.white),
                _buildBox(points: 1,eventType:"dc", color: Colors.white),
                _buildBox(points: 1,eventType:"dd", color: Colors.white),
                _buildBox(points: 1,eventType:"de", color: Colors.white),
                
              ],
            ),
          ),
                    Expanded(
            flex: 2,
            child: Row(
              children: [
                _buildBox(points: 1,eventType:"ea", color: Colors.white),
                _buildBox(points: 1,eventType:"eb", color: Colors.white),
                _buildBox(points: 1,eventType:"ec", color: Colors.white),
                _buildBox(points: 1,eventType:"ed", color: Colors.white),
                _buildBox(points: 1,eventType:"ee", color: Colors.white),
                
              ],
            ),
          ),
        ],
      )
    );
  }


  Widget _buildBox({int points, Color color,String eventType, Color textColor = Colors.white}) {
    return Expanded(
      flex: points,
      child: Container(
        constraints: BoxConstraints.expand(),

        child: Center( child:
              RippleNotificationCard(
                sticky:false,topic:eventType,color:color,containerWidth:points * 100.0, containerHeight:100.0,
                cardBody:<Widget>[
                  Spacer()
                ],
                ripplePower: 3.0,eventType: eventType,)
            )
          ,
        ),
    ); 
  }

  Size _goldenRatio(BoxConstraints constraints) {
    double ratio = 13.0 / 8.0;
    if (constraints.maxHeight / constraints.maxWidth > ratio) {
      double height = constraints.maxWidth * ratio;
      return Size(constraints.maxWidth, height);
    } else {
      double width = constraints.maxHeight / ratio;
      return Size(width, constraints.maxHeight);
    }
  }

  Widget _centeredLayout({Widget child}) {
    return LayoutBuilder(builder: (content, constraints) {
      Size size = _goldenRatio(constraints);
      return Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: size.width,
            maxHeight: size.height,
          ),
          child: child,
        ),
      );
    });
  }

  /*
     Card(child:
              RippleNotificationCard(
                color:Colors.amber,containerWidth:100.0, containerHeight:100.0,
                cardBody:<Widget>[
                  Spacer()
                ],
                ripplePower: 3.0,eventType: "o",)
            )
   */
}
