import 'package:flutter/material.dart';
import 'package:money_grower/blocs/transaction_bloc.dart';
import 'package:money_grower/helper/current_user.dart';
import 'package:money_grower/models/transaction_model.dart';
import 'package:money_grower/ui/custom_control/month_striper.dart';
import 'package:money_grower/ui/statistics_screen/statistics_board.dart';
import 'package:money_grower/ui/transaction_screen/transaction_summary.dart';
import 'package:money_grower/ui/transaction_screen/transacton_summary_board.dart';
import 'package:progress_indicators/progress_indicators.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  final TransactionBloc transactionBloc = TransactionBloc();
  final String? username = CurrentUser.username;
  final TransactionSummary summary = TransactionSummary();

  List<TransactionModel> incomeList = [];
  List<TransactionModel> expenseList = [];

  // Thêm các biến để lưu trữ thông tin tổng hợp
  int totalIncome = 0;
  int totalExpense = 0;
  int remaining = 0;

  Future<TransactionSummary> loadSummaryTransaction() async {
    final DateTime date = summary.date;
    final Map response = await transactionBloc.getTransactionSummaryOfMonth(date, username!);
    summary.fromMap(response.cast<String, dynamic>());

    // Đảm bảo transactionList là List<TransactionModel>
    final List<TransactionModel> transactions = List<TransactionModel>.from(summary.transactionList);

    // Tính tổng thu nhập và chi tiêu
    totalIncome = transactions
        .where((t) => t.price > 0)
        .map((t) => t.price)
        .fold(0, (a, b) => a + b);

    totalExpense = transactions
        .where((t) => t.price < 0)
        .map((t) => t.price)
        .fold(0, (a, b) => a + b);

    // Tính số tiền còn lại (totalExpense đã âm nên cộng)
    remaining = totalIncome + totalExpense;

    // Lấy danh sách tên các khoản thu và chi (loại bỏ trùng lặp)
    final Set<String> incomes = transactions
        .where((t) => t.price > 0)
        .map((t) => t.name)
        .toSet();

    final Set<String> expenses = transactions
        .where((t) => t.price < 0)
        .map((t) => t.name)
        .toSet();

    // Tạo danh sách thu nhập đã nhóm
    incomeList = incomes.map((income) {
      final int totalPrice = transactions
          .where((t) => t.name == income)
          .map((t) => t.price)
          .fold(0, (a, b) => a + b);

      return TransactionModel(
        id: null,
        name: income,
        note: '',
        price: totalPrice,
        date: summary.date,
        username: username!,
      );
    }).toList();

    // Tạo danh sách chi tiêu đã nhóm
    expenseList = expenses.map((expense) {
      final int totalPrice = transactions
          .where((t) => t.name == expense)
          .map((t) => t.price)
          .fold(0, (a, b) => a + b);

      return TransactionModel(
        id: null,
        name: expense,
        note: '',
        price: totalPrice,
        date: summary.date,
        username: username!,
      );
    }).toList();

    return summary;
  }

  void reloadSummary(DateTime date) {
    setState(() {
      summary.date = date;
    });
  }

  // Widget hiển thị thông tin "còn lại"
  Widget buildRemainingCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
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
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                  "SỐ TIỀN CÒN LẠI:",
                  style: TextStyle(
                      fontSize: 16,
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: remaining >= 0 ? Colors.green : Colors.red
              )
          )
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TransactionSummary>(
        future: loadSummaryTransaction(),
        builder: (BuildContext context, AsyncSnapshot<TransactionSummary> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(child: Text("Không có kết nối mạng"));
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Column(
                children: <Widget>[
                  MonthStriper(summary.date, true),
                  SizedBox(height: 30),
                  JumpingDotsProgressIndicator(
                      fontSize: 20, color: Colors.green)
                ],
              );
            case ConnectionState.done:
              if (snapshot.hasError)
                return Center(child: Text("Lỗi kết nối"));
              else
                return Scaffold(
                    appBar: PreferredSize(
                        preferredSize: Size.fromHeight(280), // Tăng chiều cao để chứa thêm thông tin
                        child: Column(children: <Widget>[
                          MonthStriper(summary.date, false, reloadSummary),
                          TransactionSummaryBoard(),
                          buildSummaryOverview(), // Thêm tổng quan thu chi
                          buildRemainingCard(), // Thêm card số tiền còn lại
                        ])),
                    body: DefaultTabController(
                      initialIndex: 0,
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
                                          icon: Text("KHOẢN THU",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 16))),
                                      Tab(
                                          icon: Text("KHOẢN CHI",
                                              style: TextStyle(
                                                  color: Colors.redAccent,
                                                  fontSize: 16))),
                                    ],
                                  ),
                                ))),
                        body: TabBarView(
                          children: [
                            SingleChildScrollView(
                                child: Column(children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(top: 20),
                                    color: Colors.white,
                                    child: Center(
                                        child: Text("THỐNG KÊ KHOẢN THU",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green))),
                                  ),
                                  StatisticsBoard(incomeList)
                                ])),
                            SingleChildScrollView(
                                child: Column(children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(top: 20),
                                    color: Colors.white,
                                    child: Center(
                                        child: Text("THỐNG KÊ KHOẢN CHI",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red))),
                                  ),
                                  StatisticsBoard(expenseList)
                                ]))
                          ],
                        ),
                      ),
                    ));
          }
        });
  }
}
