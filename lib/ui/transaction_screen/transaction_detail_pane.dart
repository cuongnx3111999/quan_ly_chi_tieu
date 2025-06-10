import 'package:flutter/material.dart';
import 'package:money_grower/ui/custom_control/transaction_date_card.dart';
import 'package:money_grower/ui/custom_control/transaction_detail_card.dart';
import 'package:money_grower/ui/transaction_screen/transaction_summary.dart';

// ignore: must_be_immutable
class TransactionDetailPane extends StatelessWidget {
  DateTime date;

  TransactionDetailPane(this.date);

  @override
  Widget build(BuildContext context) {
    final transactionsOfDate = TransactionSummary()
        .transactionList
        .where((transaction) => transaction.date == date)
        .toList();

    final totalPrice = transactionsOfDate
        .map((transaction) => transaction.price)
        .reduce((a, b) => a + b);

    return Column(children: <Widget>[
      TransactionDateCard(date, totalPrice, true),
      Container(
          color: Colors.white,
          child: Divider(
            color: Colors.black87,
          )),
      ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactionsOfDate.length,
          itemBuilder: (BuildContext context, int index) {
            return TransactionDetailCard(transactionsOfDate[index], false);
          }),
      SizedBox(height: 15)
    ]);
  }
}
