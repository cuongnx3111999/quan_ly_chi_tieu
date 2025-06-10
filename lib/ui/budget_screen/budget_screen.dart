import 'package:flutter/material.dart';
import 'package:money_grower/blocs/budget_bloc.dart';
import 'package:money_grower/ui/custom_control/budget_card.dart';
import 'package:money_grower/ui/custom_control/faded_transition.dart';

import '../../helper/current_user.dart';
import 'budget_add_popup.dart';
import 'package:progress_indicators/progress_indicators.dart';

class BudgetScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BudgetScreenState();
}

class BudgetScreenState extends State<BudgetScreen> {
  late Future<List> _budgetFuture;

  @override
  void initState() {
    super.initState();
    _budgetFuture = loadBudgets();
  }

  Future<List> loadBudgets() async {
    //final username = UserModel().username ?? '';
    final username = CurrentUser.username;
    if (username!.isEmpty) {
      return [];
    }
    final budgets = await BudgetBloc().getBudgetsByUsername(username);
    print('Loaded budgets: $budgets'); // debug
    return budgets;
  }

  void _reloadBudgets() {
    setState(() {
      _budgetFuture = loadBudgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: _budgetFuture,
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Center(child: Text("Không có kết nối mạng"));
          case ConnectionState.active:
          case ConnectionState.waiting:
            return JumpingDotsProgressIndicator(fontSize: 30, color: Colors.green);
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Center(child: Text("Lỗi kết nối"));
            } else {
              final budgets = snapshot.data ?? [];
              return Scaffold(
                body: BudgetBoard(budgets, _reloadBudgets),
                floatingActionButton: FloatingActionButton(
                  heroTag: 'btn-budget',
                  child: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadeRoute(page: BudgetAddPopup()),
                    ).then((_) {
                      // reload sau khi quay về màn hình này
                      _reloadBudgets();
                    });
                  },
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              );
            }
        }
      },
    );
  }
}

class BudgetBoard extends StatelessWidget {
  final List budgetList;
  final VoidCallback reloadBudgets;

  BudgetBoard(this.budgetList, this.reloadBudgets);

  @override
  Widget build(BuildContext context) {
    if (budgetList.isEmpty) {
      return Container(
        padding: EdgeInsets.only(top: 50),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text(
                ":-(",
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black45),
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: Text("Không có ngân sách", style: TextStyle(fontSize: 24, color: Colors.black45)),
            ),
            SizedBox(height: 15),
            Center(
              child: Text("Nhấn + để thêm ngân sách", style: TextStyle(fontSize: 16, color: Colors.black45)),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: budgetList.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              BudgetCard(budgetList[index], reloadBudgets),
              Divider(color: Colors.black38),
            ],
          );
        },
      );
    }
  }
}
