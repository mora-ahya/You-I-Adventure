import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:you_i_adventure/scenes/state_select.dart';

final Duration walkOfd = Duration(milliseconds: 2000);
final Duration climbOfd = Duration(milliseconds: 6000);
final Duration pushedOfd = Duration(milliseconds: 150);
final Duration interval = Duration(seconds: 3);

bool fail = false;
bool canClear = false;
bool lock = false;
bool showResult = false;
List<Alignment> youAlignments = [
  Alignment(-1.2, 1),
  Alignment(-0.075, 1),
  Alignment(-0.075, -0.35),
  Alignment(1.2, -0.35),
  Alignment(1.2, -0.35),
  Alignment(0, 1),
];

Duration d = Duration(microseconds: 0);

String youState = "idle";
int phase = 0;
AlignmentGeometry get youAlignment =>
    youAlignments[phase % youAlignments.length];

class Stage1 extends StatelessWidget {
  Stage1({Key key, this.title}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Goal(),
          secondFloor(context, size),
          firstFloor(context, size),
          SecondFloorGimmik(),
          SecondFloorGimmikTwo(),
          You(),
          Result(),
          //ChangeButton(),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget firstFloor(BuildContext context, Size size) {
    return Align(
      child: Container(
        color: Colors.blue,
        width: size.width,
        height: size.height / 10,
      ),
      alignment: Alignment.bottomCenter,
    );
  }

  Widget secondFloor(BuildContext context, Size size) {
    return Align(
        child: Container(
      color: Colors.blue,
      width: size.width,
      height: size.height / 10,
    ));
  }
}

class You extends StatefulWidget {
  You();

  _YouState createState() => _YouState();
}

class _YouState extends State<You> {
  Timer _timer;

  @override
  void initState() {
    super.initState();
    fail = false;
    canClear = false;
    lock = false;
    showResult = false;
    d = Duration(microseconds: 0);

    youState = "idle";
    phase = 0;
    _timer = Timer.periodic(
        Duration(milliseconds: 100), (_t) => effectByOtherWidget());
  }

  void effectByOtherWidget() {
    if (fail) {
      lock = true;
      setState(() {
        youAction();
      });
    }
  }

  void youAction() {
    if (fail) {
      switch (phase) {
        case 0:
          phase = 5;
          _timer.cancel();
          _timer = Timer.periodic(
              pushedOfd,
              (_t) => setState(() {
                    youAction();
                  }));
          youState = "pushed";
          d = pushedOfd;
          break;
        case 5:
          _timer.cancel();
          _timer = Timer.periodic(
              interval,
              (_t) => setState(() {
                    _timer.cancel();
                    showResult = true;
                  }));
          youState = "lie";
      }
    } else if (canClear) {
      if (!lock) {
        lock = true;
      }
      phase++;
      switch (phase) {
        case 1:
          _timer.cancel();
          _timer = Timer.periodic(
              walkOfd,
              (_t) => setState(() {
                    youAction();
                  }));
          youState = "walk";
          d = walkOfd;
          break;
        case 2:
          _timer.cancel();
          _timer = Timer.periodic(
              climbOfd,
              (_t) => setState(() {
                    youAction();
                  }));
          youState = "climb";
          d = climbOfd;
          break;
        case 3:
          _timer.cancel();
          _timer = Timer.periodic(
              walkOfd,
              (_t) => setState(() {
                    youAction();
                  }));
          youState = "walk";
          d = walkOfd;
          break;
        case 4:
          _timer.cancel();
          _timer = Timer.periodic(
              interval,
              (_t) => setState(() {
                    _timer.cancel();
                    showResult = true;
                  }));
          youState = "clear";
      }
    } else {
      if (youState == "waveHand") {
        youState = "waveHand2";
      } else {
        youState = "waveHand";
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AnimatedAlign(
      duration: d,
      alignment: youAlignment,
      child: SizedBox(
        width: size.width / 3,
        height: size.height / 3,
        child: FlatButton(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: FlareActor(
            "assets/humanOfStick2.flr",
            animation: youState,
            fit: BoxFit.contain,
          ),
          onPressed: () {
            if (!lock) {
              setState(() {
                youAction();
              });
            }
          },
        ),
      ),
    );
  }
}

class SecondFloorGimmik extends StatefulWidget {
  _SecondFloorGimmikState createState() => _SecondFloorGimmikState();
}

class _SecondFloorGimmikState extends State<SecondFloorGimmik> {
  _SecondFloorGimmikState();
  double h = 0;
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Align(
        alignment: Alignment(0, 0.8),
        child: SizedBox(
            width: size.width / 5,
            height: size.height / 2,
            child: Stack(children: <Widget>[
              IconButton(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                icon: Icon(Icons.menu),
                onPressed: () {
                  setState(() {
                    if (!lock) {
                      if (h == 0) {
                        h = size.height * 0.45;
                        canClear = true;
                      } else {
                        h = 0;
                      }
                    }
                  });
                },
              ),
              AnimatedContainer(
                color: Colors.white,
                duration: Duration(milliseconds: 500),
                height: h,
                child: Text("=======\n" * 30),
              ),
            ])));
  }
}

class SecondFloorGimmikTwo extends StatefulWidget {
  _SecondFloorGimmikTwoState createState() => _SecondFloorGimmikTwoState();
}

class _SecondFloorGimmikTwoState extends State<SecondFloorGimmikTwo> {
  _SecondFloorGimmikTwoState();
  double w = 0;
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Align(
        alignment: Alignment(-1, 0.8),
        child: SizedBox(
            width: size.width / 4,
            height: size.height / 2,
            child: Stack(children: <Widget>[
              IconButton(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                icon: Icon(Icons.menu),
                onPressed: () {
                  setState(() {
                    if (!lock) {
                      if (w == 0) {
                        w = size.width / 4;
                        fail = true;
                      } else {
                        w = 0;
                      }
                    }
                  });
                },
              ),
              AnimatedContainer(
                color: Colors.lightBlue,
                duration: Duration(milliseconds: 100),
                width: w,
                height: size.height * 0.45,
              ),
            ])));
  }
}

class Goal extends StatefulWidget {
  _GoalState createState() => _GoalState();
}

class _GoalState extends State<Goal> {
  _GoalState();

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Align(
        alignment: Alignment(0.9, -0.3),
        child: SizedBox(
            width: size.width / 5,
            height: size.height / 10,
            child: Stack(
              children: <Widget>[
                Icon(
                  Icons.outlined_flag,
                  size: size.width / 3.7,
                ),
                Align(
                    alignment: Alignment(0.8, 0.5),
                    child: Text(
                      "Goal!",
                    )),
              ],
            )));
  }
}

class Result extends StatefulWidget {
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {
  _ResultState();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 1), (_t) => check());
  }

  Widget build(BuildContext context) {
    return Container();
  }

  Widget resultDesigned() {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          height: size.height / 2,
          width: size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
            color: Colors.blue,
          ),
          child: Center(
            child: Container(
              height: size.height / 2.5,
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  Align(
                      alignment: Alignment(0, -3),
                      child: SizedBox(
                        width: size.width / 3,
                        height: size.height / 3,
                        child: FlareActor(
                          "assets/humanOfStick2.flr",
                          animation: !fail ? "waveHand" : "oh",
                          fit: BoxFit.contain,
                        ),
                      )),
                  Align(
                    alignment: Alignment(0, 0.4),
                    child: !fail
                        ? Text(
                            "Clear!!",
                            textScaleFactor: 2,
                          )
                        : Text(
                            "Failed...",
                            textScaleFactor: 2,
                          ),
                  ),
                  Align(
                    alignment: Alignment(-1, 1),
                    child: FlatButton(
                      child: !fail
                          ? Text(
                              "Go next stage!!",
                              style: TextStyle(color: Colors.blueAccent),
                            )
                          : Text(
                              "Retry!!",
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushReplacementNamed("1");
                      },
                    ),
                  ),
                  Align(
                      alignment: Alignment(1, 1),
                      child: FlatButton(
                        child: Text(
                          "Return to stage select",
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StageSelect(
                                        clearStageNum: !fail ? "1" : "",
                                      )));
                        },
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void check() {
    if (showResult) {
      _timer.cancel();
      setState(() {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => resultDesigned());
      });
    }
  }
}
