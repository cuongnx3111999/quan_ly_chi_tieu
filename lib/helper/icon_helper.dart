import 'package:flutter/material.dart';

class IconHelper {
  IconData getIconByName(String name) {
    switch (name) {
      case "Ăn uống": return Icons.free_breakfast;
      case "Giải trí": return Icons.videogame_asset;
      case "Thưởng": return Icons.attach_money;
      case "Tiền lãi": return Icons.monetization_on;
      case "Lương": return Icons.credit_card;
      case "Được tặng": return Icons.card_giftcard;
      case "Bán đồ": return Icons.work;
      case "Bạn bè": return Icons.people;
      case "Chi phí": return Icons.account_balance_wallet;
      case "Di chuyển": return Icons.directions_bus;
      case "Du lịch": return Icons.airplanemode_active;
      case "Gia đình": return Icons.people;
      case "Giáo dục": return Icons.school;
      case "Hoá đơn": return Icons.receipt;
      case "Mua sắm": return Icons.shopping_cart;
      case "Kinh doanh": return Icons.card_travel;
      case "Quà tặng": return Icons.card_giftcard;
      case "Sức khoẻ": return Icons.favorite;
      case "Bảo hiểm": return Icons.healing;
      case "Cho vay": return Icons.money_off;
      case "Trả nợ": return Icons.money_off;
      case "Vay tiền": return Icons.attach_money;
      case "Thu nợ": return Icons.attach_money;
      default: return Icons.monetization_on;
    }
  }
}