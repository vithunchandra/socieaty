import 'package:flutter/material.dart';

bool isNowBetween(TimeOfDay? openTime, TimeOfDay? closeTime) {
  final now = TimeOfDay.now();
  if (openTime != null && closeTime != null) {
    int closeTimeInMinutes = closeTime.hour * 60 + closeTime.minute;
    int openTimeInMinutes = openTime.hour * 60 + openTime.minute;
    int nowInMinutes = now.hour * 60 + now.minute;
    if (closeTimeInMinutes < openTimeInMinutes) {
      closeTimeInMinutes += 24 * 60;
      nowInMinutes += 24 * 60;
    }
    return nowInMinutes >= openTimeInMinutes && nowInMinutes <= closeTimeInMinutes;
  }
  return false;
}
