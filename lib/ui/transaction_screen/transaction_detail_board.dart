import 'package:flutter/material.dart';
import 'package:money_grower/ui/transaction_screen/transaction_detail_pane.dart';
import 'package:money_grower/ui/transaction_screen/transaction_summary.dart';

class TransactionDetailBoard extends StatelessWidget {
  final dateList = TransactionSummary()
      .transactionList
      .map((transaction) => transaction.date)
      .toSet()
      .toList()
        ..sort((b, a) => a.compareTo(b));

  @override
  Widget build(BuildContext context) {
    if (dateList.isNotEmpty) {
      return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: dateList.length,
        itemBuilder: (BuildContext context, int index) {
          return new TransactionDetailPane(dateList[index]);
        },
      );
    } else {
      return Container(
          padding: EdgeInsets.only(top: 30),
          color: Colors.white,
          child: Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                SizedBox(height: 10),
                Text(":-)",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 48,
                        color: Colors.black45)),
                SizedBox(height: 15),
                Text("Không có giao dịch",
                    style: TextStyle(fontSize: 24, color: Colors.black45)),
                SizedBox(height: 15),
                Center(
                    child: Text("Nhấn + để thêm giao dịch",
                        style: TextStyle(fontSize: 16, color: Colors.black45)))
              ])));
    }
  }
}
