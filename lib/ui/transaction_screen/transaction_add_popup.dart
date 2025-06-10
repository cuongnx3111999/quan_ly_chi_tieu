import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:money_grower/blocs/transaction_bloc.dart';
import 'package:money_grower/helper/format_helper.dart';
import 'package:money_grower/models/transaction_model.dart';
import 'package:money_grower/ui/custom_control/faded_transition.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:money_grower/ui/transaction_screen/transaction_category_page.dart';

import '../../helper/current_user.dart';

class TransactionAddPopup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TransactionAddPopupState();
}

class TransactionAddPopupState extends State<TransactionAddPopup> {
  final TextEditingController priceTextController = TextEditingController();
  final TextEditingController dateTextController = TextEditingController();
  final TextEditingController nameTextController = TextEditingController();
  final TextEditingController noteTextController = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    priceTextController.text = '0';
    dateTextController.text = DateFormat("dd/MM/yyyy").format(DateTime.now());
  }

  void setPrice(String price) {
    final parseText = price.replaceAll(',', '');
    if (parseText.isEmpty) return;
    try {
      final int parsed = int.parse(parseText);
      final formattedText = FormatHelper().formatMoney(parsed);
      priceTextController.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    } catch (e) {
      // ignore parse error
    }
  }

  void setName(String name) {
    nameTextController.text = name;
  }

  void submitTransaction() async {
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
            )
          ],
        ),
      );
      return;
    }

    //final username = UserModel().username ?? '';
    final username = CurrentUser.username;

    if (username!.isEmpty) {
      // Thông báo hoặc xử lý user chưa đăng nhập
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
            )
          ],
        ),
      );
      return;
    }

    final incomeTransactionTypes = [
      "Thưởng",
      "Lương",
      "Tiền lãi",
      "Bán đồ",
      "Được tặng",
      "Vay tiền",
      "Thu nợ"
    ];
    final isIncomeTransaction = incomeTransactionTypes.contains(name);

    final price = int.parse(priceText);
    final date = DateFormat("dd/MM/yyyy").parse(dateText);

    final transaction = (name == 'Cho vay' || name == 'Vay tiền')
        ? DebtTransactionModel(
      id: null,
      name: name,
      note: note,
      price: isIncomeTransaction ? price : -price,
      date: date,
      username: username,
      done: false,
    )
        : TransactionModel(
      id: null,
      name: name,
      note: note,
      price: isIncomeTransaction ? price : -price,
      date: date,
      username: username,
    );

    setState(() {
      _saving = true;
    });

    try {
      await TransactionBloc().insertTransaction(transaction, username);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      showDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text("Lỗi"),
          content: Text("Không thể thêm giao dịch: $e"),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("Đóng"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm giao dịch'),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Icon(Icons.playlist_add_check),
              onPressed: submitTransaction,
            ),
          ),
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
                  onChanged: setPrice,
                  style: TextStyle(fontSize: 24),
                  decoration: InputDecoration(
                    labelText: 'Số tiền',
                    contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: dateTextController,
                  readOnly: true,
                  style: TextStyle(fontSize: 22),
                  decoration: InputDecoration(
                    labelText: 'Thời gian',
                    contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: DateFormat("dd/MM/yyyy").parse(dateTextController.text),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      dateTextController.text = DateFormat("dd/MM/yyyy").format(date);
                    }
                  },
                ),
                SizedBox(height: 30),
                TextField(
                  controller: nameTextController,
                  readOnly: true,
                  style: TextStyle(fontSize: 24),
                  decoration: InputDecoration(
                    labelText: 'Loại giao dịch',
                    contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    FadeRoute(page: TransactionCategoryPage(setName)),
                  ),
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
                      borderRadius: BorderRadius.circular(10),
                    ),
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
