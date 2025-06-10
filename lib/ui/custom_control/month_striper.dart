import 'package:flutter/material.dart';
import 'month_strip.dart';

class MonthStriper extends StatelessWidget {
  final DateTime date;
  final bool isDisable;
  final ValueChanged<DateTime>? callback; // hoặc VoidCallback? nếu không cần truyền DateTime

  const MonthStriper(
      this.date,
      this.isDisable, [
        this.callback,
      ]);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isDisable,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 1.0, color: Colors.black26)),
          color: Colors.white,
        ),
        child: MonthStrip(
          format: 'MM/yyyy',
          from: DateTime(1900, 4),
          to: DateTime(2100, 5),
          initialMonth: date,
          viewportFraction: 0.33,
          onMonthChanged: (newMonth) {
            callback?.call(newMonth); // cách viết gọn thay vì if
          },
          normalTextStyle: const TextStyle(fontSize: 18, color: Colors.black26),
          selectedTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}
