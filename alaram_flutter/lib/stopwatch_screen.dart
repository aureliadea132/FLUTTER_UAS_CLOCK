import 'package:flutter/material.dart';
import 'dart:async';

class StopwatchScreen extends StatefulWidget {
  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  bool _isRunning = false;
  List<int> _lapTimes = [];
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentProgress = _stopwatch.elapsedMilliseconds / 1000 % 60 / 60;
      });
    });
  }

  void _startStopwatch() {
    setState(() {
      _isRunning = true;
      _stopwatch.start();
    });
  }

  void _stopStopwatch() {
    setState(() {
      _isRunning = false;
      _stopwatch.stop();
    });
  }

  void _resetStopwatch() {
    setState(() {
      _isRunning = false;
      _stopwatch.reset();
      _lapTimes.clear();
      _currentProgress = 0.0;
    });
  }

  void _lapStopwatch() {
    setState(() {
      _lapTimes.add(_stopwatch.elapsedMilliseconds);
    });
  }

  String _formattedTime(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final millisecondsFormatted = (duration.inMilliseconds.remainder(1000) / 100).toStringAsFixed(0).padLeft(1, '0');
    return '$minutes:$seconds.$millisecondsFormatted';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stopwatch'),
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 250.0,
                    height: 250.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 5.0),
                    ),
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.0, end: _currentProgress),
                      duration: Duration(milliseconds: 100),
                      builder: (BuildContext context, double value, Widget? child) {
                        return CircularProgressIndicator(
                          value: _isRunning ? value : 0.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
                          strokeWidth: 5.0,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    child: Text(
                      _formattedTime(_stopwatch.elapsedMilliseconds),
                      style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _lapTimes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Center(
                        child: Text('#${index + 1}: ${_formattedTime(_lapTimes[index])}',
                            style: TextStyle(color: Colors.white)),
                      ),
                      tileColor: Colors.transparent,
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _lapStopwatch,
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(), 
                      backgroundColor: Colors.lightGreen,
                      padding: EdgeInsets.all(20),
                    ),
                    child: Icon(Icons.refresh, color: Colors.white),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _isRunning ? _stopStopwatch : _startStopwatch,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      backgroundColor: Colors.red,
                    ),
                    child: Text(_isRunning ? 'Stop' : 'Start'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _resetStopwatch,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      backgroundColor: Colors.grey,
                    ),
                    child: Text('Reset'),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
