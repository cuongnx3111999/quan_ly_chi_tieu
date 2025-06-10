import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_grower/blocs/budget_bloc.dart';
import 'package:money_grower/blocs/transaction_bloc.dart';
import 'package:money_grower/helper/format_helper.dart';
import 'package:money_grower/models/budget_model.dart';
import 'package:money_grower/ui/custom_control/faded_transition.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../helper/current_user.dart';
import '../custom_control/category_page.dart';

class BudgetAddPopup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BudgetAddPopupState();
}

class BudgetAddPopupState extends State<BudgetAddPopup> {
  final priceTextController = TextEditingController();
  final beginTextController = TextEditingController();
  final endTextController = TextEditingController();
  final nameTextController = TextEditingController();
  bool _saving = false;

  final DateFormat _dateFormat = DateFormat("dd/MM/yyyy");

  @override
  void initState() {
    super.initState();
    priceTextController.text = '0';
    beginTextController.text = _dateFormat.format(DateTime.now());
    endTextController.text = _dateFormat.format(DateTime.now());
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
    if (parseText.isEmpty) {
      priceTextController.text = '0';
      return;
    }
    final value = int.tryParse(parseText);
    if (value == null) {
      priceTextController.text = '0';
      return;
    }
    final formattedText = FormatHelper().formatMoney(value);
    priceTextController.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  void setName(String name) {
    nameTextController.text = name;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text("Lỗi"),
        content: Text("\n$message", style: TextStyle(fontSize: 16)),
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

  Future<void> submitBudget() async {
    final priceText = priceTextController.text.replaceAll(',', '');
    final beginText = beginTextController.text;
    final endText = endTextController.text;
    final name = nameTextController.text.trim();

    if (priceText.isEmpty || priceText == '0' || beginText.isEmpty || endText.isEmpty || name.isEmpty) {
      _showErrorDialog("Số tiền phải là số dương\nThông tin không được để trống");
      return;
    }

    final username = CurrentUser.username;
    if (username == null) {
      _showErrorDialog("Bạn cần đăng nhập để thêm ngân sách");
      return;
    }

    try {
      final exists = await BudgetBloc().isBudgetNameExist(name, username);
      if (exists) {
        _showErrorDialog("Ngân sách \"$name\" đã tồn tại trong danh sách");
        return;
      }
    } catch (e) {
      _showErrorDialog("Lỗi kiểm tra tên ngân sách: $e");
      return;
    }

    int totalBudget;
    DateTime beginDate, endDate;

    try {
      totalBudget = int.parse(priceText);
    } catch (e) {
      _showErrorDialog("Số tiền không hợp lệ");
      return;
    }

    try {
      beginDate = _dateFormat.parse(beginText);
      endDate = _dateFormat.parse(endText);
    } catch (e) {
      _showErrorDialog("Ngày không hợp lệ");
      return;
    }

    if (endDate.isBefore(beginDate)) {
      _showErrorDialog("Ngày kết thúc không thể sớm hơn ngày bắt đầu");
      return;
    }

    saveSubmit();

    try {
      final totalUsed = await TransactionBloc().getPriceOfTransactionTypeInTime(name, beginDate, endDate, username);
      final budget = BudgetModel(
        id: null,
        name: name,
        beginDate: beginDate,
        endDate: endDate,
        totalBudget: totalBudget,
        totalUsed: totalUsed,
        username: username,
      );
      await BudgetBloc().insertBudget(budget);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      stopSaving();
      _showErrorDialog("Lỗi khi lưu ngân sách: $e");
    }
  }

  Future<void> _selectDate({
    required TextEditingController controller,
    required String helpText,
  }) async {
    DateTime initialDate;
    try {
      initialDate = _dateFormat.parse(controller.text);
    } catch (e) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: helpText,
    );

    if (picked != null && mounted) {
      setState(() {
        controller.text = _dateFormat.format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm ngân sách'),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Icon(Icons.playlist_add_check),
              onPressed: submitBudget,
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 30),
                TextField(
                  controller: nameTextController,
                  decoration: InputDecoration(
                    labelText: 'Loại ngân sách',
                    contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: TextStyle(fontSize: 24),
                  readOnly: true,
                  onTap: () {
                    final categoryList = [
                      "Ăn uống",
                      "Bạn bè",
                      "Chi phí",
                      "Giải trí",
                      "Di chuyển",
                      "Du lịch",
                      "Giáo dục",
                      "Gia đình",
                      "Hoá đơn",
                      "Mua sắm",
                      "Kinh doanh",
                      "Sức khoẻ",
                      "Bảo hiểm"
                    ];
                    Navigator.push(
                      context,
                      FadeRoute(
                        page: CategoryPage("Chọn loại ngân sách", categoryList, setName),
                      ),
                    );
                  },
                ),
                SizedBox(height: 30),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(controller: beginTextController, helpText: "Chọn ngày bắt đầu"),
                        child: AbsorbPointer(
                          child: TextField(
                            controller: beginTextController,
                            decoration: InputDecoration(
                              labelText: 'Bắt đầu',
                              contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(controller: endTextController, helpText: "Chọn ngày kết thúc"),
                        child: AbsorbPointer(
                          child: TextField(
                            controller: endTextController,
                            decoration: InputDecoration(
                              labelText: 'Kết thúc',
                              contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
