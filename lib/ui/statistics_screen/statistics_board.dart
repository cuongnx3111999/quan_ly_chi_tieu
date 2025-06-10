import 'package:flutter/material.dart';
import 'package:money_grower/ui/custom_control/transaction_date_card.dart';
import 'package:money_grower/ui/custom_control/transaction_detail_card.dart';
import 'package:money_grower/ui/statistics_screen/statistics_chart.dart';
import 'package:money_grower/ui/transaction_screen/transaction_summary.dart';
import 'package:money_grower/models/transaction_model.dart';

class StatisticsBoard extends StatelessWidget {
  final List<TransactionModel> list;
  final List<List<TransactionDate>> datesOfList = [];

  StatisticsBoard(this.list) {
    for (var income in list) {
      final transactions = TransactionSummary()
          .transactionList
          .where((t) => t.name == income.name);
      final diffDates = transactions.map((t) => t.date).toSet();
      final transactionDateList = diffDates
          .map((date) => TransactionDate(
          date,
          transactions
              .where((t) => t.date == date)
              .map((t) => t.price)
              .reduce((a, b) => a + b)))
          .toList();
      datesOfList.add(transactionDateList);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return Container(
          padding: EdgeInsets.only(top: 30),
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
                  child: Text("Không có thống kê",
                      style: TextStyle(fontSize: 24, color: Colors.black45)))
            ],
          ));
    }

    return Column(
      children: <Widget>[
        Container(
            color: Colors.white,
            child: SizedBox(height: 270, child: DonutPieChart(list))),
        AbsorbPointer(
            absorbing: true,
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index0) {
                return Column(children: <Widget>[
                  TransactionDetailCard(list[index0], true),
                  Container(
                      color: Colors.white,
                      child: Divider(
                        color: Colors.black87,
                      )),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: datesOfList[index0].length,
                      itemBuilder: (BuildContext context, int index1) {
                        return TransactionDateCard(
                            datesOfList[index0][index1].date,
                            datesOfList[index0][index1].price,
                            false);
                      }),
                  SizedBox(height: 10),
                  SizedBox(height: 20),
                ]);
              },
            ))
      ],
    );
  }
}

class TransactionDate {
  final DateTime date;
  final int price;

  TransactionDate(this.date, this.price);
}

