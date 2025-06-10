import 'package:flutter/material.dart';
import 'package:money_grower/helper/icon_helper.dart';

// ignore: must_be_immutable
class CategoryPage extends StatelessWidget {
  final categoryList;
  final setName;
  final title;

  CategoryPage(this.title, this.categoryList, this.setName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView.builder(
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
                              bottom: BorderSide(
                                  width: 1.5, color: Colors.black12)),
                          color: Colors.white),
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Icon(IconHelper().getIconByName(categoryList[index]),
                              color: Colors.green),
                          SizedBox(width: 15),
                          Text(categoryList[index],
                              style: TextStyle(fontSize: 20))
                        ],
                      )));
            }));
  }
}
