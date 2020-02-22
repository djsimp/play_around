import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Completer<GoogleMapController> _controller = Completer();
  Position _lastPosition;
  DateTime _lastTime;
  Position _currentPosition;
  DateTime _currentTime;
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updatePosition());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  double _getSpeed() {
    if(_lastPosition == null || _lastTime == null || _currentPosition == null || _currentTime == null) {
      return 0;
    }
    return _deltaMiles()/_deltaHours();
  }

  double _deltaMiles() {
    return 0;
  }

  double _deltaHours() {
    return (convertTimeToSeconds(_currentTime) -  convertTimeToSeconds(_lastTime))/3600;
  }

  double convertTimeToSeconds(DateTime time) {
    return (((time.hour * 60 + time.minute) * 60 + time.second) * 1000 + time.millisecond) / 1000;
  }

  LatLng _getCurrentPosition() {
    if(_currentPosition == null) {
      return LatLng(0,0);
    }
    return LatLng(_currentPosition.latitude,_currentPosition.longitude);
  }

  LatLng _getPreviousPosition() {
    if(_lastPosition == null) {
      return LatLng(0,0);
    }
    return LatLng(_lastPosition.latitude,_lastPosition.longitude);
  }

  void _updatePosition() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _lastPosition = _currentPosition;
        _currentPosition = position;
        _lastTime = _currentTime;
        _currentTime = DateTime.now();
      });
    }).catchError((e) {
      print(e);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  String _latString(LatLng position) {
    return "Latitude: " + position.latitude.toString();
  }

  String _lngString(LatLng position) {
    return "Longitude: " + position.longitude.toString();
  }

  String _timeString(DateTime time) {
    return "Time: " + (time != null ? time.toString() : "null");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Maps Sample App'),
          backgroundColor: Colors.blue[700],
        ),
        body: Container(
          color: Colors.blue[100],
          child: Center(
            child: Column(
              children: [
                Text(
                    _getSpeed().toString() + " mph",
                    style: TextStyle(fontSize: 50)
                ),
                Container(
                  width: 400,
                  height: 400,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _getCurrentPosition(),
                      zoom: 11.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Text(
                        _latString(_getCurrentPosition()),
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        _lngString(_getCurrentPosition()),
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        _timeString(_currentTime),
                        style: TextStyle(fontSize: 20),
                      )
                    ]
                  )
                ),
                Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                        children: [
                          Text(
                            _latString(_getPreviousPosition()),
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            _lngString(_getPreviousPosition()),
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            _timeString(_lastTime),
                            style: TextStyle(fontSize: 20),
                          )
                        ]
                    )
                )
              ]
            )
          ),
        )
      )
    );
  }
}