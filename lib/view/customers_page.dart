import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siparis_takip/constants/AppStrings.dart';
import 'package:siparis_takip/view_model/customers_page_viewmodel.dart';

import '../model/Customers.dart';

final viewModelProvider =
    ChangeNotifierProvider((ref) => CustomersPageViewmodel());

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {


  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    final watch = ref.watch(viewModelProvider);
    final read = ref.read(viewModelProvider);

    ValueNotifier<String?> searchQuery = ValueNotifier<String?>(null);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5),
              //Arama butonu
              child: TextField(
                onChanged: (String value) {
                  watch.filterCustomers(value);
                },

                decoration: const InputDecoration(
                  hintText: AppStrings.find,
                  suffixIcon: Icon(Icons.search, color: Colors.green),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref.refresh(viewModelProvider).getAllCustomers();
                },
                child: FutureBuilder<List<Customers>>(
                  future: ref.watch(viewModelProvider).getAllCustomers(),
                  builder: (context,snapshot){

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Veriler yüklenirken bir yüklenme göstergesi gösteriyoruz
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      // Hata durumunda bir hata mesajı gösteriyoruz
                      print("Hata: ${snapshot.error}");
                      return Center(child: Text("Hata: ${snapshot.error}"),);
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      // Veri yoksa bir mesaj gösteriyoruz
                      return const Center(child: Text('Müşteri bulunamadı.'));
                    }else{
                      final customers = snapshot.data!;
                      return ListView.builder(
                        itemCount: customers.length,
                        itemBuilder: (BuildContext context, int index) {
                          final customer = customers[index];

                          return ListTile(
                            title: Text(customer.name),
                            subtitle: Text(customer.address ?? "Adres yok"),
                            trailing: IconButton(
                              icon: const Icon(Icons.phone, color: Colors.green),
                              onPressed: () {
                                read.makePhoneCall(customer.phone);
                              },
                            ),
                            leading: const Icon(Icons.person),
                            onLongPress: () async {
                              // İstediğin uzun basma işlemini burada yapabilirsin
                              watch.showCustomerDetailDialog(context, index, customer);
                            },
                          );
                        },

                      );


                    }
                  },
                ),
              )),

          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            read.addCustomerDialog(context);
          },
          child: const Text(AppStrings.customer_add,style: TextStyle(color: Colors.red),),
        ),
      ),
    );
  }
}
