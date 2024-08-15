import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../model/Customers.dart';
import '../model/Orders.dart';
import '../services/DatabaseHelper.dart';

class HomePageViewmodel extends ChangeNotifier {
  DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> getAllOrdersWithCustomer() async {
    List<Map<String, dynamic>> ordersWithCustomer = [];

    // Tüm müşterileri al
    List<Customers> customers = await _databaseHelper.getCustomers();

    // Her müşteri için siparişleri al
    for (var customer in customers) {
      List<Orders> orders = await _databaseHelper.getOrdersByCustomerId(customer.id!);
      for (var order in orders) {
        ordersWithCustomer.add({
          'order': order,
          'customer': customer,
        });
      }
    }

    return ordersWithCustomer;
  }

  Future<void> deleteOrder(int id) async {
    await _databaseHelper.deleteOrder(id);
    notifyListeners();
  }

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd MMMM yyyy, HH:mm'); // Gün Ay Yıl, Saat:Dakika formatı
    return formatter.format(date);
  }

}
