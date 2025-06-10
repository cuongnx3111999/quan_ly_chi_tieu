import 'package:flutter/material.dart';
import 'package:money_grower/helper/icon_helper.dart';

// ignore: must_be_immutable
class TransactionCategoryPage extends StatelessWidget {
  final incomeList = ["Thưởng", "Lương", "Tiền lãi", "Bán đồ", "Được tặng"];
  final deptList = ["Cho vay", "Vay tiền", "Trả nợ", "Thu nợ"];
  final expenseList = [
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

  Function setName;

  TransactionCategoryPage(this.setName);

// ignore: must_be_immutable, non_constant_identifier_names
  Widget TransactionCategoryList(List categoryList) {
    return ListView.builder(
      itemCount: categoryList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setName(categoryList[index]);
            Navigator.of(context).pop();
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom:
                BorderSide(width: 1.5, color: Colors.black12)),
              color: Colors.white),
            padding: EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                Icon(IconHelper().getIconByName(categoryList[index]),
                  color: Colors.green),
                SizedBox(width: 15),
                Text(categoryList[index], style: TextStyle(fontSize: 20))
              ],
            )));
      });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Text("VAY/TRẢ NỢ", style: TextStyle(fontSize: 14))),
              Tab(icon: Text("TIỀN RA", style: TextStyle(fontSize: 14))),
              Tab(icon: Text("TIỀN VÀO", style: TextStyle(fontSize: 14)))
            ],
          ),
          title: Text('Chọn loại giao dịch'),
        ),
        body: TabBarView(
          children: [
            TransactionCategoryList(deptList),
            TransactionCategoryList(expenseList),
            TransactionCategoryList(incomeList),
          ],
        ),
      ),
    );
  }
}
