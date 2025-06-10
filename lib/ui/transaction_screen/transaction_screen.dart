import 'package:flutter/material.dart';
import 'package:money_grower/blocs/transaction_bloc.dart';
import 'package:money_grower/ui/custom_control/faded_transition.dart';
import 'package:money_grower/ui/transaction_screen/transaction_add_popup.dart';
import 'package:money_grower/ui/transaction_screen/transaction_detail_board.dart';
import 'package:money_grower/ui/transaction_screen/transaction_summary.dart';
import 'package:money_grower/ui/transaction_screen/transacton_summary_board.dart';
import 'package:money_grower/ui/custom_control/month_striper.dart';
import 'package:progress_indicators/progress_indicators.dart';

import '../../helper/current_user.dart';

class TransactionScreen extends StatefulWidget {
  @override
  State<TransactionScreen> createState() => TransactionScreenState();
}

class TransactionScreenState extends State<TransactionScreen> {
  final summary = TransactionSummary();
  final transactionBloc = TransactionBloc();
  final username = CurrentUser.username;

  // Thêm các biến để lưu trữ thông tin tổng hợp
  int totalIncome = 0;
  int totalExpense = 0;
  int remaining = 0;

  Future<void> loadSummaryTransaction() async {
    final date = summary.date;
    final response = await transactionBloc.getTransactionSummaryOfMonth(date, username!);
    summary.fromMap(response);

    // Tính toán các giá trị tổng hợp
    totalIncome = summary.totalIncome;
    totalExpense = summary.totalExpense;
    remaining = summary.remaining;
  }

  void reloadSummary(DateTime date) {
    setState(() {
      summary.date = date;
    });
  }

  // Widget hiển thị tổng quan thu chi
  Widget buildSummaryOverview() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Card tổng thu
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up, color: Colors.green, size: 20),
                  SizedBox(height: 4),
                  Text(
                      "TỔNG THU",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700]
                      )
                  ),
                  SizedBox(height: 4),
                  Text(
                      "${totalIncome.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},'
                      )} đ",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green
                      )
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          // Card tổng chi
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_down, color: Colors.red, size: 20),
                  SizedBox(height: 4),
                  Text(
                      "TỔNG CHI",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700]
                      )
                  ),
                  SizedBox(height: 4),
                  Text(
                      "${totalExpense.abs().toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},'
                      )} đ",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red
                      )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị số tiền còn lại
  Widget buildRemainingCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: remaining >= 0 ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: remaining >= 0 ? Colors.green : Colors.red,
            width: 2
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                remaining >= 0 ? Icons.account_balance_wallet : Icons.warning,
                color: remaining >= 0 ? Colors.green : Colors.red,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                  "SỐ TIỀN CÒN LẠI:",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87
                  )
              ),
            ],
          ),
          Text(
              "${remaining.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},'
              )} đ",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: remaining >= 0 ? Colors.green : Colors.red
              )
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: loadSummaryTransaction(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          return Column(
            children: [
              MonthStriper(summary.date, true),
              SizedBox(height: 30),
              JumpingDotsProgressIndicator(fontSize: 20, color: Colors.green),
            ],
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi kết nối"));
          }
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(200),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MonthStriper(summary.date, false, reloadSummary),
                    TransactionSummaryBoard(),
                    buildSummaryOverview(), // Thêm tổng quan thu chi
                    buildRemainingCard(), // Thêm card số tiền còn lại
                  ],
                ),
              ),
            ),
            body: TransactionDetailBoard(),
            floatingActionButton: FloatingActionButton(
              heroTag: 'btn-transaction',
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(context, FadeRoute(page: TransactionAddPopup()));
              },
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          );
        } else if (snapshot.connectionState == ConnectionState.none) {
          return Center(child: Text("Không có kết nối mạng"));
        }
        return SizedBox.shrink(); // fallback widget
      },
    );
  }
}
