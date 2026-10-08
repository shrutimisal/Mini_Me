import 'package:flutter/material.dart';

extension MinutesOfDay on int {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: this ~/ 60, minute: this % 60);
}

extension TimeOfDayMinutes on TimeOfDay {
  int get totalMinutes => hour * 60 + minute;
}
