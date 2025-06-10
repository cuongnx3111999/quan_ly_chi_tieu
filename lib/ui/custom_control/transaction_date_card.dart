import 'package:sprintf/sprintf.dart';
import 'package:flutter/material.dart';
import 'package:money_grower/helper/format_helper.dart';

// ignore: must_be_immutable
class TransactionDateCard extends StatelessWidget {
  DateTime date;
  int price;
  bool isBoldPrice = true;

  TransactionDateCard(this.date, this.price, this.isBoldPrice);

  @override
  Widget build(BuildContext context) {
    final dayOfWeek = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật'
    ];

    final monthOfYear = [
      'Một',
      'Hai',
      'Ba',
      'Tư',
      'Năm',
      'Sáu',
      'Bảy',
      'Tám',
      'Chín',
      'Mười',
      'Mười Một',
      'Mười Hai'
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: <Widget>[
          Text(sprintf("%02d", [date.day]),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87)),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(dayOfWeek[date.weekday - 1],
                style: TextStyle(
                  color: Colors.black54, fontWeight: FontWeight.bold)),
              SizedBox(height: 2),
              Text(
                sprintf("Tháng %s %d",
                  [monthOfYear[date.month - 1], date.year]),
                style: TextStyle(color: Colors.black54))
            ],
          ),
          Spacer(),
          Text(FormatHelper().formatMoney(price.abs(), 'đ'),
            style: TextStyle(
              fontWeight: isBoldPrice ? FontWeight.bold : FontWeight.normal,
              fontSize: 18,
              color: price < 0 ? Colors.redAccent : Colors.green))
        ],
      ));
  }
}
