import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:money_grower/blocs/budget_bloc.dart';
import 'package:money_grower/blocs/transaction_bloc.dart';
import 'package:money_grower/helper/format_helper.dart';
import 'package:money_grower/models/budget_model.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../helper/current_user.dart';

class BudgetEditPopup extends StatefulWidget {
  final BudgetModel budget;

  BudgetEditPopup(this.budget);

  @override
  State<StatefulWidget> createState() => BudgetEditPopupState();
}

class BudgetEditPopupState extends State<BudgetEditPopup> {
  bool _saving = false;
  final priceTextController = TextEditingController();
  final beginTextController = TextEditingController();
  final endTextController = TextEditingController();
  final nameTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final budget = widget.budget;

    priceTextController.text = FormatHelper().formatMoney(budget.totalBudget);
    nameTextController.text = budget.name;
    beginTextController.text = DateFormat("dd/MM/yyyy").format(budget.beginDate);
    endTextController.text = DateFormat("dd/MM/yyyy").format(budget.endDate);
  }

  @override
  void dispose() {
    priceTextController.dispose();
    beginTextController.dispose();
    endTextController.dispose();
    nameTextController.dispose();
    super.dispose();
  }

  void saveSubmit() {
    setState(() {
      _saving = true;
    });
  }

  void stopSaving() {
    setState(() {
      _saving = false;
    });
  }

  void setPrice(String price) {
    final parseText = price.replaceAll(',', '');
    if (parseText.isEmpty) return;
    final value = int.tryParse(parseText);
    if (value == null) return;

    final formattedText = FormatHelper().formatMoney(value);
    priceTextController.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  void setName(String name) {
    nameTextController.text = name;
  }

  Future<void> submitBudget() async {
    final priceText = priceTextController.text.replaceAll(',', '');
    final beginText = beginTextController.text;
    final endText = endTextController.text;
    final name = nameTextController.text.trim();

    if (priceText.isEmpty || priceText == '0' || beginText.isEmpty || endText.isEmpty || name.isEmpty) {
      await showDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text("Lỗi"),
          content: Text("\nSố tiền phải là số dương\nThông tin không được để trống", style: TextStyle(fontSize: 16)),
          actions: [
            CupertinoDialogAction(
                isDefaultAction: true,
                child: Text("Đóng"),
                onPressed: () => Navigator.of(context).pop())
          ],
        ),
      );
      return;
    }

    int totalBudget;
    DateTime beginDate, endDate;

    try {
      totalBudget = int.parse(priceText);
    } catch (_) {
      await _showErrorDialog("Số tiền không hợp lệ");
      return;
    }

    try {
      beginDate = DateFormat("dd/MM/yyyy").parse(beginText);
      endDate = DateFormat("dd/MM/yyyy").parse(endText);
    } catch (_) {
      await _showErrorDialog("Ngày không hợp lệ");
      return;
    }

    if (endDate.isBefore(beginDate)) {
      await _showErrorDialog("Ngày kết thúc không thể sớm hơn ngày bắt đầu");
      return;
    }

    final username = CurrentUser.username;
    if (username == null || username.isEmpty) {
      await _showErrorDialog("Bạn cần đăng nhập để chỉnh sửa ngân sách");
      return;
    }

    saveSubmit();

    try {
      final totalUsed = await TransactionBloc().getPriceOfTransactionTypeInTime(name, beginDate, endDate, username);
      final budget = BudgetModel(
        id: widget.budget.id,
        name: name,
        beginDate: beginDate,
        endDate: endDate,
        totalBudget: totalBudget,
        totalUsed: totalUsed,
        username: username,
      );
      await BudgetBloc().updateBudget(budget);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      stopSaving();
      await _showErrorDialog("Lỗi khi cập nhật ngân sách: $e");
    }
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text("Lỗi"),
        content: Text("\n$message", style: TextStyle(fontSize: 16)),
        actions: [
          CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("Đóng"),
              onPressed: () => Navigator.of(context).pop())
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    try {
      initialDate = DateFormat("dd/MM/yyyy").parse(controller.text);
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      initialDate: initialDate,
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        controller.text = DateFormat("dd/MM/yyyy").format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa ngân sách'),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => submitBudget(),
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
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  controller: priceTextController,
                  onChanged: (text) => setPrice(text),
                  style: TextStyle(fontSize: 24),
                  decoration: InputDecoration(
                    labelText: 'Số tiền',
                    contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 30),
                TextField(
                  controller: nameTextController,
                  decoration: InputDecoration(
                    labelText: 'Loại ngân sách',
                    contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  style: TextStyle(fontSize: 24),
                  readOnly: true,
                ),
                SizedBox(height: 30),
                TextField(
                  controller: beginTextController,
                  decoration: InputDecoration(
                    labelText: 'Ngày bắt đầu',
                    contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  style: TextStyle(fontSize: 22),
                  onTap: () => _selectDate(context, beginTextController),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: endTextController,
                  decoration: InputDecoration(
                    labelText: 'Ngày kết thúc',
                    contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  style: TextStyle(fontSize: 22),
                  onTap: () => _selectDate(context, endTextController),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
