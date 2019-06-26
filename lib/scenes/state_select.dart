import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:you_i_adventure/scenes/gametitle.dart';

bool reloadFlag = false;

class StageSelect extends StatelessWidget {
  StageSelect({Key key, this.clearStageNum = ""}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String clearStageNum;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => DeleteDialog());
            },
          ),
        ],
        centerTitle: true,
        title: Text("Stage Select"),
      ),
      body: StageList(
        clearStageNum: this.clearStageNum,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class StageList extends StatefulWidget {
  StageList({this.clearStageNum});
  final String clearStageNum;
  _StageListState createState() =>
      _StageListState(clearStageNum: this.clearStageNum);
}

class _StageListState extends State<StageList> {
  _StageListState({this.clearStageNum});

  Timer _timer;
  final String clearStageNum;
  int clearNum;
  bool wait = true;

  void callData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    clearNum = prefs.getInt('clearNum') ?? 1;
    if (clearStageNum != "") {
      if (!(prefs.getBool(clearStageNum) ?? false)) {
        clearNum++;
        await prefs.setBool(clearStageNum, true);
      }
    }
    wait = false;
    await prefs.setInt('clearNum', clearNum);
    setState(() {});
    //await prefs.setBool("1", false);
  }

  @override
  void initState() {
    super.initState();
    wait = true;
    //_timer = Timer.periodic(Duration(milliseconds: 1), (_t) => setState(() {}));
    callData();
  }

  Widget makeButton(int number, Size size, BuildContext context) {
    bool isButtonAble = number <= clearNum ? true : false;
    return SizedBox(
        width: size.width / 6,
        height: size.width / 6,
        child: OutlineButton(
          onPressed: isButtonAble
              ? () {
                  Navigator.of(context).pushReplacementNamed(number.toString());
                }
              : null,
          child: Text(
            number.toString(),
            style:
                TextStyle(color: isButtonAble ? Colors.blue : Colors.black26),
          ),
          borderSide: BorderSide(color: Colors.blue),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        ));
  }

  @override
  void dispose() {
    //_timer.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    if (wait) {
      return SizedBox();
    } else {
      Size size = MediaQuery.of(context).size;
      return ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            elevation: 0,
            color: Color(0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  makeButton(1 + index * 5, size, context),
                  makeButton(2 + index * 5, size, context),
                  makeButton(3 + index * 5, size, context),
                  makeButton(4 + index * 5, size, context),
                  makeButton(5 + index * 5, size, context),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}

class DeleteDialog extends StatelessWidget {
  Widget build(BuildContext context) {
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
              child: Delete(),
            ),
          ),
        ),
      ),
    );
  }
}

class Delete extends StatefulWidget {
  _DeleteState createState() => _DeleteState();
}

class _DeleteState extends State<Delete> {
  _DeleteState();

  int _phase = 0;

  @override
  void initState() {
    super.initState();
    _phase = 0;
  }

  void deleteData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    reloadFlag = true;
    //await prefs.setBool("1", false);
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        Align(
            alignment: Alignment(0, -3),
            child: SizedBox(
              width: size.width / 3,
              height: size.height / 3,
              child: FlareActor(
                "assets/humanOfStick2.flr",
                animation: _phase == 0 ? "waveHand" : "oh",
                fit: BoxFit.contain,
              ),
            )),
        Align(
          alignment: Alignment(0, 0.4),
          child: _phase == 0
              ? Text(
                  "Delete clear data...",
                  textScaleFactor: 2,
                )
              : Text(
                  "Really...?",
                  textScaleFactor: 2,
                ),
        ),
        Align(
          alignment: Alignment(-0.5, 1),
          child: FlatButton(
            child: _phase == 0
                ? Text(
                    "Yes",
                    style: TextStyle(color: Colors.blueAccent),
                  )
                : Text(
                    "YesYesYes",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
            onPressed: () {
              if (_phase == 0) {
                setState(() {
                  _phase++;
                });
              } else {
                Navigator.pop(context);
                deleteData();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => GameTitle()));
              }
            },
          ),
        ),
        Align(
            alignment: Alignment(0.5, 1),
            child: FlatButton(
              child: _phase == 0
                  ? Text(
                      "No",
                      style: TextStyle(color: Colors.blueAccent),
                    )
                  : Text(
                      "NoNoNo",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
              onPressed: () {
                Navigator.pop(context);
              },
            ))
      ],
    );
  }
}
