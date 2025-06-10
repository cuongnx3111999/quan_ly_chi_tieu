import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_grower/blocs/budget_bloc.dart';
import 'package:money_grower/helper/format_helper.dart';
import 'package:intl/intl.dart';
import 'package:money_grower/ui/budget_screen/budget_edit_popup.dart';

import 'faded_transition.dart';

class BudgetCard extends StatefulWidget {
  final budget;
  final reloadBudgets;

  BudgetCard(this.budget, this.reloadBudgets);

  @override
  State<StatefulWidget> createState() => BudgetCardState();
}

class BudgetCardState extends State<BudgetCard> {
  final dateFormatter = DateFormat("dd/MM/yyyy");
  final moneyFormatter = FormatHelper();

  Future deleteBudget(String id) async {
    showDialog(
        context: context,
        builder: (_) =>
            CupertinoAlertDialog(
              title: Text("Xác nhận"),
              content: Text("Xác nhận xoá ngân sách?",
                  style: TextStyle(fontSize: 16)),
              actions: [
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text("Xác nhận",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent)),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await BudgetBloc().deleteBudget(id);
                      widget.reloadBudgets();
                    }),
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text("Huỷ bỏ"),
                    onPressed: () => Navigator.of(context).pop())
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final budget = widget.budget;

    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: <Widget>[
          SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Ngân sách: " + budget.name,
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text(
                    dateFormatter.format(budget.beginDate) +
                        " - " +
                        dateFormatter.format(budget.endDate),
                    style: TextStyle(fontSize: 15)),
                SizedBox(height: 6),
                Text(
                    "Ngân sách: " +
                        moneyFormatter.formatMoney(budget.totalBudget, 'đ'),
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 6),
                Text(
                    "Sử dụng: " +
                        moneyFormatter.formatMoney(budget.totalUsed, 'đ'),
                    style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent, size: 28),
                  onPressed: () => deleteBudget(budget.id)),
              IconButton(
                  icon: Icon(Icons.edit, color: Colors.green, size: 28),
                  onPressed: () =>
                      Navigator.push(
                          context, FadeRoute(page: BudgetEditPopup(budget))))
            ],
          )
        ],
      ),
    );
  }
}