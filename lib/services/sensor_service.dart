import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  Stream<UserAccelerometerEvent>? _accelerometerStream;
  String _currentActivity = 'unknown';
  // 可能唔整
  void startActivityTracking(void Function(String) onActivityChanged) {
    _accelerometerStream = userAccelerometerEvents;
    _accelerometerStream!.listen((event) {
      double totalAccel = event.x.abs() + event.y.abs() + event.z.abs();

      String newActivity;
      if (totalAccel > 20) {
        newActivity = 'running'; // 跑
      } else if (totalAccel > 5) {
        newActivity = 'walking'; // 行
      } else {
        newActivity = 'still'; // 企
      }

      if (newActivity != _currentActivity) {
        _currentActivity = newActivity;
        onActivityChanged(newActivity);
      }
    });
  }

  String get currentActivity => _currentActivity;

  void dispose() {
  }
}