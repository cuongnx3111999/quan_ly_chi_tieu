import 'package:flutter/material.dart';
import 'package:money_grower/blocs/transaction_bloc.dart';
import 'package:money_grower/helper/current_user.dart';
import 'package:money_grower/helper/format_helper.dart';
import 'package:progress_indicators/progress_indicators.dart';

import '../../models/transaction_model.dart';
import 'debt_board.dart';
import 'loan_board.dart';

class DebtScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DebtScreenState();
}

class DebtScreenState extends State<DebtScreen> {
  List loanList = [];
  List debtList = [];
  num totalLoanPrice = 0;
  num totalDebtPrice = 0;
  static int curTabIndex = 1;

  late Future<void> _futureLoad;

  @override
  void initState() {
    super.initState();
    _futureLoad = loadDebtAndLoanList();
  }

  Future<void> loadDebtAndLoanList() async {
    final username = CurrentUser.username;
    if (username == null || username.isEmpty) {
      return;
    }

    final loanDebtList = await TransactionBloc().getLoanDebtList(username);

    final loans = loanDebtList['loan-list'] as List<TransactionModel>;
    final debts = loanDebtList['debt-list'] as List<TransactionModel>;

    num loanSum = 0;
    num debtSum = 0;

    loans.forEach((loan) => loanSum += loan.price);
    debts.forEach((debt) => debtSum += debt.price);

    setState(() {
      loanList = loans;
      debtList = debts;
      totalLoanPrice = loanSum;
      totalDebtPrice = debtSum;
    });
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureLoad,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Center(child: Text("Không có kết nối mạng"));
          case ConnectionState.active:
          case ConnectionState.waiting:
            return JumpingDotsProgressIndicator(fontSize: 30, color: Colors.green);
          case ConnectionState.done:
            if (snapshot.hasError)
              return Center(child: Text("Lỗi kết nối"));
            else
              return DefaultTabController(
                initialIndex: curTabIndex,
                length: 2,
                child: Scaffold(
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(kToolbarHeight),
                    child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Colors.white,
                          offset: Offset(0, 0),
                          blurRadius: 0.0,
                        )
                      ]),
                      child: AppBar(
                        elevation: 0,
                        backgroundColor: Colors.white,
                        title: TabBar(
                          indicatorColor: Colors.black26,
                          indicatorPadding: EdgeInsets.only(bottom: 5, left: 35, right: 35),
                          tabs: [
                            Tab(
                              icon: Text("CHO VAY",
                                  style: TextStyle(color: Colors.green, fontSize: 16)),
                            ),
                            Tab(
                              icon: Text("KHOẢN NỢ",
                                  style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  body: Container(
                    color: Colors.white,
                    child: TabBarView(
                      children: [
                        Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(top: 20, bottom: 10),
                              child: Center(
                                child: Text(
                                  "DANH SÁCH VAY | " + FormatHelper().formatMoney(-totalLoanPrice, 'đ'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                            Divider(color: Colors.black38),
                            LoanBoard(loanList),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(top: 20, bottom: 10),
                              child: Center(
                                child: Text(
                                  "DANH SÁCH NỢ | " + FormatHelper().formatMoney(totalDebtPrice, 'đ'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ),
                            Divider(color: Colors.black38),
                            DebtBoard(debtList),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
        }
      },
    );
  }
}
