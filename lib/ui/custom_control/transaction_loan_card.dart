import 'package:flutter/material.dart';
import 'package:money_grower/helper/format_helper.dart';
import 'package:money_grower/models/transaction_model.dart';
import 'package:money_grower/ui/debt_screen/debt_edit_popup.dart';
import 'package:sprintf/sprintf.dart';

import 'faded_transition.dart';

class TransactionLoanCard extends StatelessWidget {
  final TransactionModel transaction;
  final bool isBoldPrice;

  const TransactionLoanCard({
    Key? key,
    required this.transaction,
    required this.isBoldPrice,
  }) : super(key: key);

  get username => null;

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

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        FadeRoute(page: DebtEditPopup(transaction: transaction, username: username,)),
      ),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Row(
          children: <Widget>[
            Text(sprintf("%02d", [transaction.date.day]),
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(dayOfWeek[transaction.date.weekday - 1],
                    style: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text(
                    sprintf("Tháng %s %d", [
                      monthOfYear[transaction.date.month - 1],
                      transaction.date.year,
                    ]),
                    style: TextStyle(color: Colors.black54)),
                SizedBox(height: 2),
                transaction.note.isEmpty
                    ? SizedBox.shrink()
                    : Text(transaction.note, style: TextStyle(color: Colors.black54))
              ],
            ),
            Spacer(),
            Text(
              FormatHelper().formatMoney(transaction.price.abs(), 'đ'),
              style: TextStyle(
                fontWeight: isBoldPrice ? FontWeight.bold : FontWeight.normal,
                fontSize: 18,
                color: transaction.price < 0 ? Colors.green : Colors.redAccent,
              ),
            )
          ],
        ),
      ),
    );
  }
}
