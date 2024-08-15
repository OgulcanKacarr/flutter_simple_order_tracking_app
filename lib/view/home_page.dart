import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siparis_takip/view_model/home_page_viewmodel.dart';

import '../model/Customers.dart';
import '../model/Orders.dart';

final viewModelProvider = ChangeNotifierProvider((ref) => HomePageViewmodel());

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: ref.watch(viewModelProvider).getAllOrdersWithCustomer(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print("Hata: ${snapshot.error}");
                    return Center(child: Text("Hata: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Sipariş bulunamadı.'));
                  } else {
                    final ordersWithCustomer = snapshot.data!;
                    final totalOrders = ordersWithCustomer.length;

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: ordersWithCustomer.length,
                            itemBuilder: (BuildContext context, int index) {
                              final item = ordersWithCustomer[index];
                              final order = item['order'] as Orders;
                              final customer = item['customer'] as Customers;

                              return ListTile(
                                title: Text("Alıcı: ${customer.name}"), // Müşterinin adı
                                subtitle: Text("Sipariş: ${order.order_amount} KG ${order.order_type} \nSatılan fiyat: ${order.order_price} TL \nToplam Tutar: ${order.order_total_price} TL\nSipariş tarihi: ${ref.watch(viewModelProvider).formatDate(order.order_date)}"), // Sipariş tarihi
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.green),
                                  onPressed: () {
                                    // Siparişi sil
                                    ref.watch(viewModelProvider).deleteOrder(order.order_id!);
                                  },
                                ),
                                leading: const Icon(Icons.person),
                                onLongPress: () {
                                  // Uzun basma işlemi
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Toplam Sipariş: $totalOrders",style: TextStyle(color: Colors.teal),),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
