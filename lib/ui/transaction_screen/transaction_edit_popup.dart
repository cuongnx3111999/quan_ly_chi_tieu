import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:money_grower/blocs/transaction_bloc.dart';
import 'package:money_grower/helper/format_helper.dart';
import 'package:money_grower/models/transaction_model.dart';
import 'package:money_grower/ui/custom_control/faded_transition.dart';
import 'package:money_grower/ui/transaction_screen/transaction_category_page.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../helper/current_user.dart';

// ignore: must_be_immutable
class TransactionEditPopup extends StatefulWidget {
  TransactionModel transaction;

  TransactionEditPopup(this.transaction);

  @override
  State<StatefulWidget> createState() => TransactionEditPopupState();
}

class TransactionEditPopupState extends State<TransactionEditPopup> {
  final priceTextController = TextEditingController();
  final dateTextController = TextEditingController();
  final nameTextController = TextEditingController();
  final noteTextController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    priceTextController.text = FormatHelper().formatMoney(transaction.price.abs());
    dateTextController.text = DateFormat("dd/MM/yyyy").format(transaction.date);
    nameTextController.text = transaction.name;
    noteTextController.text = transaction.note;
  }

  void setPrice(String price) {
    if (price.isEmpty) return;
    final parseText = price.replaceAll(',', '');
    if (int.tryParse(parseText) == null) return;
    final formattedText = FormatHelper().formatMoney(int.parse(parseText));
    priceTextController.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  void setName(String name) {
    nameTextController.text = name;
  }

  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _saving = loading;
      });
    }
  }

  Future<void> deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text("Xác nhận"),
        content: Text("Xác nhận xoá giao dịch?", style: TextStyle(fontSize: 16)),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Xác nhận", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Huỷ bỏ"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setLoading(true);
    try {
      await TransactionBloc().deleteTransaction(widget.transaction, widget.transaction.username);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setLoading(false);
        showDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: Text("Lỗi"),
            content: Text("Không thể xoá giao dịch: $e"),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text("Đóng"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> updateTransaction() async {
    final priceText = priceTextController.text.replaceAll(',', '');
    final dateText = dateTextController.text;
    final name = nameTextController.text;
    final note = noteTextController.text.trim();

    if (priceText.isEmpty || priceText == '0' || dateText.isEmpty || name.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text("Lỗi"),
          content: Text(
            "Số tiền phải là số dương\nNgày giao dịch và loại giao dịch không được để trống.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("Đóng"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    //final username = UserModel().username ?? '';
    final username = CurrentUser.username;
    if (username!.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text("Lỗi"),
          content: Text("Bạn chưa đăng nhập!"),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("Đóng"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    final isIncomeTransaction = [
      "Thưởng",
      "Lương",
      "Tiền lãi",
      "Bán đồ",
      "Được tặng",
      "Vay tiền",
      "Thu nợ"
    ].contains(name);

    final price = int.parse(priceText);
    final date = DateFormat("dd/MM/yyyy").parse(dateText);

    dynamic transaction;

    if (['Cho vay', 'Vay tiền'].contains(name)) {
      transaction = DebtTransactionModel(
        id: widget.transaction.id,
        name: name,
        note: note,
        price: isIncomeTransaction ? price : -price,
        date: date,
        username: username,
        done: (widget.transaction is DebtTransactionModel) ? (widget.transaction as DebtTransactionModel).done : false,
      );
    } else {
      transaction = TransactionModel(
        id: widget.transaction.id,
        name: name,
        note: note,
        price: isIncomeTransaction ? price : -price,
        date: date,
        username: username,
      );
    }

    setLoading(true);
    try {
      await TransactionBloc().updateTransaction(transaction, username);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setLoading(false);
        showDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: Text("Lỗi"),
            content: Text("Không thể cập nhật giao dịch: $e"),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text("Đóng"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết giao dịch'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: deleteTransaction,
          ),
          Container(
            margin: EdgeInsets.only(right: 25),
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: updateTransaction,
            ),
          )
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 40),
            child: Column(
              children: <Widget>[
                TextField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15),
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: priceTextController,
                  onChanged: setPrice,
                  style: TextStyle(fontSize: 24),
                  decoration: InputDecoration(
                    labelText: 'Số tiền',
                    contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: dateTextController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Thời gian',
                    contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  style: TextStyle(fontSize: 22),
                  onTap: () async {
                    DateTime initialDate;
                    if (dateTextController.text.isNotEmpty) {
                      try {
                        initialDate = DateFormat("dd/MM/yyyy")
                            .parse(dateTextController.text);
                      } catch (_) {
                        initialDate = DateTime.now();
                      }
                    } else {
                      initialDate = DateTime.now();
                    }

                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      dateTextController.text =
                          DateFormat("dd/MM/yyyy").format(pickedDate);
                    }
                  },
                ),
                SizedBox(height: 30),
                TextField(
                  controller: nameTextController,
                  decoration: InputDecoration(
                    labelText: 'Loại giao dịch',
                    contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  style: TextStyle(fontSize: 24),
                  readOnly: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      FadeRoute(page: TransactionCategoryPage(setName)),
                    );
                  },
                ),
                SizedBox(height: 30),
                TextField(
                  controller: noteTextController,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(30),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Ghi chú',
                    contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
