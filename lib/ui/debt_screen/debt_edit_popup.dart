import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_grower/blocs/transaction_bloc.dart';
import 'package:money_grower/helper/format_helper.dart';
import 'package:money_grower/models/transaction_model.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class DebtEditPopup extends StatefulWidget {
  final TransactionModel transaction;
  final String username;

  const DebtEditPopup({Key? key, required this.transaction, required this.username}) : super(key: key);

  @override
  State<DebtEditPopup> createState() => DebtEditPopupState();
}

class DebtEditPopupState extends State<DebtEditPopup> {
  bool _saving = false;

  void saveSubmit() {
    setState(() {
      _saving = true;
    });
  }

  void deleteLoan() {
    final transaction = widget.transaction;
    final username = widget.username;

    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Xác nhận xoá giao dịch"),
        content: const Text(
          "\nGiao dịch này sẽ không được lưu",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text(
              "Xác nhận",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              saveSubmit();
              await TransactionBloc().updateTransaction(transaction, username);
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Huỷ bỏ"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void payLoan() {
    final transaction = widget.transaction;
    final username = widget.username;
    final isLoan = transaction.price < 0;

    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(isLoan ? "Xác nhận thu tiền vay" : "Xác nhận trả nợ?"),
        content: Text(
          isLoan
              ? "\nGiao dịch thu tiền sẽ tự động thêm vào danh sách giao dịch"
              : "\nGiao dịch trả nợ sẽ tự động thêm vào danh sách giao dịch",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text(
              "Xác nhận",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              saveSubmit();

              final now = DateTime.now();
              final payTransaction = TransactionModel(
                id: null,
                name: isLoan ? 'Thu nợ' : 'Trả nợ',
                note: isLoan ? 'Thu tiền vay' : 'Trả nợ',
                price: isLoan ? transaction.price.abs() : -transaction.price,
                date: DateTime(now.year, now.month, now.day),
                username: username,  // Gán username cho giao dịch mới
              );

              await TransactionBloc().updateTransaction(transaction, username);
              await TransactionBloc().insertTransaction(payTransaction, username);
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Huỷ bỏ"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cho vay'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteLoan,
          ),
          Container(
            margin: const EdgeInsets.only(right: 25),
            child: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: payLoan,
            ),
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: FormatHelper().formatMoney(transaction.price.abs()),
                  readOnly: true,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(fontSize: 24),
                  decoration: InputDecoration(
                    labelText: 'Số tiền',
                    contentPadding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  initialValue: DateFormat("dd/MM/yyyy").format(transaction.date),
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: transaction.note,
                    labelText: 'Ngày cho vay',
                    contentPadding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  initialValue: transaction.price < 0 ? "Cho vay" : "Đi vay",
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Loại giao dịch',
                    contentPadding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  initialValue: transaction.note.isEmpty ? "Không có ghi chú" : transaction.note,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: transaction.note,
                    labelText: 'Ghi chú',
                    contentPadding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
