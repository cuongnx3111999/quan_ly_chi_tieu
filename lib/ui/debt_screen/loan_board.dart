import 'package:flutter/material.dart';
import 'package:money_grower/ui/custom_control/transaction_loan_card.dart';

import 'debt_screen.dart';

class LoanBoard extends StatelessWidget {
  final loanList;

  LoanBoard(this.loanList);

  @override
  Widget build(BuildContext context) {
    DebtScreenState.curTabIndex = 0;
    if (loanList.isEmpty) {
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
                  child: Text("Không có khoản vay",
                      style: TextStyle(fontSize: 24, color: Colors.black45)))
            ],
          ));
    }
    return ListView.builder(
        shrinkWrap: true,
        itemCount: loanList.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(children: <Widget>[
            TransactionLoanCard(
              transaction: loanList[index],
              isBoldPrice: true,
            ),
            Divider(color: Colors.black38),
          ]);
        });
  }
}
