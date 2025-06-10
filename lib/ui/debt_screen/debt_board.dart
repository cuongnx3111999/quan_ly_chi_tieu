import 'package:flutter/material.dart';
import 'package:money_grower/ui/custom_control/transaction_loan_card.dart';

import 'debt_screen.dart';

class DebtBoard extends StatelessWidget {
  final debtList;

  DebtBoard(this.debtList);

  @override
  Widget build(BuildContext context) {
    DebtScreenState.curTabIndex = 1;
    if (debtList.isEmpty) {
      return Container(
        padding: EdgeInsets.only(top: 20),
        color: Colors.white,
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text(":-)",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45))),
            SizedBox(height: 15),
            Center(
              child: Text("Không có khoản nợ",
                style: TextStyle(fontSize: 24, color: Colors.black45)))
          ],
        ));
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: debtList.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(children: <Widget>[
            TransactionLoanCard(
              transaction: debtList[index],
              isBoldPrice: true,
            ),
            Divider(color: Colors.black38),
        ]);
      });
  }
}