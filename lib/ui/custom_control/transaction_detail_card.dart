import 'package:flutter/material.dart';
import 'package:money_grower/helper/format_helper.dart';
import 'package:money_grower/helper/icon_helper.dart';
import 'package:money_grower/models/transaction_model.dart';
import 'package:money_grower/ui/transaction_screen/transaction_edit_popup.dart';
import 'faded_transition.dart';

class TransactionDetailCard extends StatelessWidget {
  final TransactionModel transaction;
  final bool isBoldPrice;

  const TransactionDetailCard(
      this.transaction, [
        this.isBoldPrice = true,
      ]);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          FadeRoute(page: TransactionEditPopup(transaction)),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 20, 10),
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Icon(
              IconHelper().getIconByName(transaction.name),
              color: transaction.price < 0 ? Colors.redAccent : Colors.green,
              size: 40,
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  transaction.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                transaction.note.isNotEmpty
                    ? Text(transaction.note)
                    : const SizedBox.shrink(),
              ],
            ),
            const Spacer(),
            Text(
              FormatHelper().formatMoney(transaction.price.abs(), 'đ'),
              style: TextStyle(
                color: transaction.price < 0 ? Colors.redAccent : Colors.green,
                fontSize: 18,
                fontWeight: isBoldPrice ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
