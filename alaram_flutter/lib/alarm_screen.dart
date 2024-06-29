import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({Key? key}) : super(key: key);

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  TimeOfDay? _selectedTime;
  final Set<int> _selectedDays = {};
  bool _isAlarmEnabled = false;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  void _toggleAlarm(bool value) {
    setState(() {
      _isAlarmEnabled = value;
      if (value) {
        _scheduleAlarm();
      } else {
        _cancelAlarm();
      }
    });
  }

  void _scheduleAlarm() {
    if (_selectedTime != null && _selectedDays.isNotEmpty) {
      for (int day in _selectedDays) {
        var scheduledNotificationDateTime = _nextInstanceOfDayAndTime(day, _selectedTime!);
        var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
          'alarm_notif',
          'alarm_notif',
          channelDescription: 'Channel for Alarm notification',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('alarm_sound'),
          playSound: true,
          icon: '@mipmap/ic_launcher',
        );
        var iOSPlatformChannelSpecifics = const IOSNotificationDetails(sound: 'alarm_sound.aiff');
        var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics,
        );
        flutterLocalNotificationsPlugin.zonedSchedule(
          day,
          'Alarm',
          'Time to wake up!',
          scheduledNotificationDateTime,
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    }
  }

  void _cancelAlarm() {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(int day, TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    while (scheduledDate.weekday != day || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Set Alarm Time:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text(_selectedTime != null ? _selectedTime!.format(context) : 'Select Time'),
            ),
            const SizedBox(height: 20),
            const Text('Select Days:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: List<Widget>.generate(7, (int index) {
                return FilterChip(
                  label: Text(DateFormat('EEE').format(DateTime(2022, 1, 3 + index))),
                  selected: _selectedDays.contains(index + 1),
                  onSelected: (bool selected) {
                    _toggleDay(index + 1);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Enable Alarm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Switch(
                  value: _isAlarmEnabled,
                  onChanged: _toggleAlarm,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cancelAlarm,
              child: const Text('Stop Alarm'),
            ),
          ],
        ),
      ),
    );
  }
}
