import 'package:flutter/material.dart';
import 'package:siparis_takip/constants/AppStrings.dart';
import 'package:siparis_takip/constants/ShowSnackBar.dart';
import 'package:siparis_takip/model/Customers.dart';
import 'package:siparis_takip/services/DatabaseHelper.dart';
import 'package:siparis_takip/view/profile_page.dart';
import '../constants/AppSizes.dart';
import '../model/Orders.dart';
import '../view/customers_page.dart';
import '../view/home_page.dart';

class BasePageViewmodel extends ChangeNotifier {
  DatabaseHelper databaseHelper = DatabaseHelper();
  final ValueNotifier<Customers?> _selectedCustomerNotifier =
  ValueNotifier<Customers?>(null);
  final ValueNotifier<String?> _selectedOrderNotifier =
  ValueNotifier<String?>(null);
  final ValueNotifier<double> _totalPriceNotifier = ValueNotifier<double>(0);
  final ValueNotifier<double> _weightNotifier = ValueNotifier<double>(0);
  final ValueNotifier<double> _moneyNotifier = ValueNotifier<double>(0);
  int customer_id = 0;
  int current_index = 0;

  // Sipariş oluşturma dialogu göster
  Future<void> showOrderDialog(BuildContext context) async {
    List<Customers> customersList = await databaseHelper.getCustomers();
    List<String> ordersList = ["Yağ", "Peynir"];
    Orders? newOrder;

    TextEditingController _weight_controller = TextEditingController();
    TextEditingController _money_controller = TextEditingController();

    _weight_controller.addListener(() {
      _weightNotifier.value = double.parse(_weight_controller.text) ?? 0;
      _updateTotalPrice();
    });

    _money_controller.addListener(() {
      _moneyNotifier.value = double.parse(_money_controller.text) ?? 0;
      _updateTotalPrice();
    });

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text(AppStrings.add_order)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person),
                      const Text(AppStrings.customer),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ValueListenableBuilder<Customers?>(
                          valueListenable: _selectedCustomerNotifier,
                          builder: (context, selectedCustomer, child) {
                            return DropdownButton<Customers>(
                              hint: const Text(AppStrings.select_customer),
                              value: customersList.contains(selectedCustomer) ? selectedCustomer : null,
                              items: customersList.map((Customers customer) {
                                return DropdownMenuItem<Customers>(
                                  value: customer,
                                  child: Text(customer.name),
                                );
                              }).toList(),
                              onChanged: (Customers? value) {
                                _selectedCustomerNotifier.value = value;
                                customer_id = value?.id ?? 0;
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<String?>(
                          valueListenable: _selectedOrderNotifier,
                          builder: (context, selectedOrder, child) {
                            return Row(
                              children: [
                                const Icon(Icons.shop),
                                const Text(AppStrings.order),
                                const SizedBox(width: 16),
                                DropdownButton<String>(
                                  hint: const Text(AppStrings.select_order),
                                  value: selectedOrder,
                                  items: ordersList.map((String order) {
                                    return DropdownMenuItem<String>(
                                      value: order,
                                      child: Text(order),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    _selectedOrderNotifier.value = newValue;
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.line_weight),
                      Expanded(
                        child: TextField(
                          controller: _weight_controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: AppStrings.amount,
                          ),
                        ),
                      ),
                      const Text("KG"),
                    ],
                  ),
                  const SizedBox(width: 16,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.money),
                      Expanded(
                        child: TextField(
                          controller: _money_controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: AppStrings.product_price,
                          ),
                        ),
                      ),
                      const Text("TL"),
                    ],
                  ),
                  ValueListenableBuilder<double>(
                    valueListenable: _totalPriceNotifier,
                    builder: (context, totalPrice, child) {
                      return Text("Toplam fiyat: ${totalPrice.toStringAsFixed(2)} TL");
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _totalPriceNotifier.value = 0;
                Navigator.pop(context);
              },
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () async {
                if (_selectedCustomerNotifier.value != null) {
                  // Yeni siparişi oluştur
                  // Veritabanına ekle
                  newOrder = Orders(
                      order_type: _selectedOrderNotifier.value.toString(),
                      order_amount: double.parse(_weight_controller.value.text),
                      order_date: DateTime.now(),
                      order_price: double.parse(_money_controller.value.text),
                      order_total_price: _totalPriceNotifier.value.toDouble()
                  );
                  await databaseHelper.insertOrder(newOrder!, customer_id);
                  ShowSnackBar.showSnackbar(context, "Sipariş Eklendi.");
                  _totalPriceNotifier.value = 0;
                  Navigator.pop(context);
                } else {
                  // Müşteri seçilmediğinde uyarı verebilirsiniz
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lütfen bir müşteri seçin')),
                  );
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  void _updateTotalPrice() {
    _totalPriceNotifier.value = _weightNotifier.value * _moneyNotifier.value;
  }

  List<BottomNavigationBarItem> list = [
    const BottomNavigationBarItem(
        icon: Icon(Icons.home), label: AppStrings.home),
    const BottomNavigationBarItem(
        icon: Icon(Icons.person), label: AppStrings.customers),
    const BottomNavigationBarItem(
        icon: Icon(Icons.settings), label: AppStrings.profile),
  ];

  void setCurrentIndex(int i) {
    current_index = i;
    notifyListeners();
  }

  Widget buildBody() {
    switch (current_index) {
      case 0:
        return const HomePage();
      case 1:
        return const CustomersPage();
      case 2:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }
}

