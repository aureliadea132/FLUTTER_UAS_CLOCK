import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class ClockScreen extends StatefulWidget {
  @override
  ClockScreenState createState() => ClockScreenState();
}

class ClockScreenState extends State<ClockScreen> {
  late Timer _timer;
  late DateTime _dateTime;
  List<String> _timeZones = ['UTC']; // Daftar zona waktu

  final Map<String, String> _countryTimeZones = {
    'UTC': 'UTC',
    'United States (New York)': 'GMT-5',
    'United Kingdom (London)': 'GMT',
    'Germany (Berlin)': 'GMT+1',
    'India (New Delhi)': 'GMT+5:30',
    'Japan (Tokyo)': 'GMT+9',
    'Australia (Sydney)': 'GMT+10',
    'Indonesia (Jakarta)': 'GMT+7',
    // Tambahkan lebih banyak negara dan zona waktu sesuai kebutuhan
    'China (Beijing)': 'GMT+8',
    'Brazil (Sao Paulo)': 'GMT-3',
    'Russia (Moscow)': 'GMT+3',
    'South Africa (Johannesburg)': 'GMT+2',
    'Canada (Toronto)': 'GMT-5',
    'Mexico (Mexico City)': 'GMT-6',
    'France (Paris)': 'GMT+1',
    'Italy (Rome)': 'GMT+1',
    'Spain (Madrid)': 'GMT+1',
    'South Korea (Seoul)': 'GMT+9',
    'Saudi Arabia (Riyadh)': 'GMT+3',
    'Egypt (Cairo)': 'GMT+2',
    'Argentina (Buenos Aires)': 'GMT-3',
    'Thailand (Bangkok)': 'GMT+7',
    'New Zealand (Wellington)': 'GMT+12',
    'Singapore': 'GMT+8',
  };

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _dateTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formattedTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  String _formattedDate(DateTime dateTime) {
    return DateFormat('EEEE, MMM d, y').format(dateTime);
  }

  void _addTimeZone(String timeZone) {
    setState(() {
      _timeZones.add(timeZone);
    });
  }

  DateTime _getTimeForTimeZone(String timeZone) {
    return _dateTime.toUtc().add(Duration(
      seconds: _timeZoneOffsetInSeconds(timeZone),
    ));
  }

  int _timeZoneOffsetInSeconds(String timeZone) {
    // Implementasi sederhana untuk beberapa zona waktu dasar
    switch (timeZone) {
      case 'UTC':
        return 0;
      case 'GMT':
        return 0;
      case 'GMT+1':
        return 3600;
      case 'GMT+2':
        return 7200;
      case 'GMT+3':
        return 10800;
      case 'GMT+5:30':
        return 19800;
      case 'GMT+7':
        return 25200;
      case 'GMT+8':
        return 28800;
      case 'GMT+9':
        return 32400;
      case 'GMT+10':
        return 36000;
      case 'GMT+12':
        return 43200;
      case 'GMT-3':
        return -10800;
      case 'GMT-5':
        return -18000;
      case 'GMT-6':
        return -21600;
      default:
        return 0;
    }
  }

  void _showAddTimeZoneDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedTimeZone;
        return AlertDialog(
          title: Text('Pilih Zona Waktu'),
          content: DropdownButton<String>(
            hint: Text('Pilih Negara'),
            value: selectedTimeZone,
            onChanged: (String? newValue) {
              setState(() {
                selectedTimeZone = newValue;
              });
            },
            items: _countryTimeZones.keys.map((String country) {
              return DropdownMenuItem<String>(
                value: _countryTimeZones[country],
                child: Text(country),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Tambah'),
              onPressed: () {
                if (selectedTimeZone != null) {
                  _addTimeZone(selectedTimeZone!);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime jakartaTime = _getTimeForTimeZone('GMT+7');
    return Scaffold(
      appBar: AppBar(
        title: Text('Clock'),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: FloatingActionButton(
            onPressed: _showAddTimeZoneDialog,
            backgroundColor: Colors.lightGreen[600], // Warna hijau yang lebih gelap
            child: Icon(Icons.add, color: Colors.black),
            shape: CircleBorder(), // Mengubah bentuk tombol menjadi lingkaran penuh
          ),
        ),
      ),
      body: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                _formattedTime(jakartaTime),
                style: TextStyle(
                  fontSize: 36.0,
                  color: Colors.white,
                ),
              ),
              Text(
                _formattedDate(jakartaTime),
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _timeZones.map((timeZone) {
                      if (timeZone == 'GMT+7') {
                        return Container(); // Skip Jakarta as it's already displayed
                      }
                      DateTime timeForZone = _getTimeForTimeZone(timeZone);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black, // Background color hitam penuh
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_countryTimeZones.keys.firstWhere((k) => _countryTimeZones[k] == timeZone)}',
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                _formattedTime(timeForZone),
                                style: TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _formattedDate(timeForZone),
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
