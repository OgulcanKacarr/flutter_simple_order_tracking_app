import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/AppSizes.dart';
import '../constants/AppStrings.dart';
import '../constants/ShowSnackBar.dart';
import '../model/Customers.dart';
import '../services/DatabaseHelper.dart';

class CustomersPageViewmodel extends ChangeNotifier {
  DatabaseHelper _databaseHelper = DatabaseHelper();
  late Customers customer;
  ValueNotifier<bool> updateStatus = ValueNotifier<bool>(false);
  List<Customers> _filteredCustomers = [];
  List<Customers> get filteredCustomers => _filteredCustomers;

  Future<void> addCustomerDialog(BuildContext context) async {
    String name = '';
    String phone = '';
    String address = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Center(child: Text(AppStrings.customer_add)),
            content: SizedBox(
              width: AppSizes.screenWidth(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //Müşteri adı
                  TextField(
                    onChanged: (value) {
                      name = value;
                    },
                    decoration: const InputDecoration(
                      hintText: AppStrings.customer_name,
                      icon: Icon(Icons.person, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 10),

                  //Müşteri Telefonu
                  TextField(
                    onChanged: (value) {
                      phone = value;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: AppStrings.customer_phone,
                      prefixIcon: Icon(Icons.phone, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 10),

                  //Müşteri adresi
                  TextField(
                    onChanged: (value) {
                      address = value;
                    },
                    decoration: const InputDecoration(
                      hintText: AppStrings.customer_address,
                      prefixIcon:
                          Icon(Icons.location_on_sharp, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),


            //Butonlar
            actions: [

              //İptal Butonu
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(AppStrings.cancel),
              ),

              //Ekle Butonu
              TextButton(
                onPressed: () async {
                  if (address.isEmpty) {
                    address = AppStrings.no;
                  }

                  if (name.isEmpty) {
                    ShowSnackBar.showSnackbar(
                        context, AppStrings.customer_name_isEmpty);
                  } else if (phone.isEmpty) {
                    ShowSnackBar.showSnackbar(
                        context, AppStrings.customer_phone_isEmpty);
                  } else {
                    //Müşteriyi database'e ekle
                    customer = Customers(name: name, phone: phone, address: address,orderDate: DateTime.now());
                    _databaseHelper.insertCustomer(customer);
                    notifyListeners();
                    ShowSnackBar.showSnackbar(
                        context, AppStrings.add_customer_success);
                    Navigator.pop(context);
                  }
                },
                child: const Text(AppStrings.add),
              )
            ],
          ),
        );
      },
    );
  }

//Müşterinin özelliklerini gösteren pencere, silme ve güncelleme işlemleri
  Future<void> showCustomerDetailDialog(
      BuildContext context, int index, Customers customer) async {
    String name = customer.name;
    String phone = customer.phone;
    String address = customer.address;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Center(child: Text(AppStrings.dos)),
            content: SizedBox(
              width: AppSizes.screenWidth(context),
              child: ValueListenableBuilder<bool>(
                valueListenable: updateStatus,
                builder: (context, value, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          // Buraya silme işlemini ekleyebilirsiniz
                          await _databaseHelper.deleteData(customer.id!);
                          ShowSnackBar.showSnackbar(context, AppStrings.delete_customer_success);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text(AppStrings.delete_customer),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          updateStatus.value = !updateStatus.value;
                        },
                        icon: const Icon(Icons.update),
                        label: const Text(AppStrings.update_customer),
                      ),
                      if (value)
                        Column(
                          children: [
                            TextField(
                              onChanged: (value) {
                                name = value;
                              },
                              controller: TextEditingController(text: name),
                              decoration: const InputDecoration(
                                hintText: AppStrings.customer_name,
                                icon: Icon(Icons.person, color: Colors.black),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              onChanged: (value) {
                                phone = value;
                              },
                              keyboardType: TextInputType.number,
                              controller: TextEditingController(text: phone),
                              decoration: const InputDecoration(
                                hintText: AppStrings.customer_phone,
                                prefixIcon: Icon(Icons.phone, color: Colors.green),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              onChanged: (value) {
                                address = value;
                              },
                              controller: TextEditingController(text: address),
                              decoration: const InputDecoration(
                                hintText: AppStrings.customer_address,
                                prefixIcon: Icon(Icons.location_on_sharp,
                                    color: Colors.green),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                _databaseHelper.updateData(customer.id!, name, phone, address);
                                ShowSnackBar.showSnackbar(context, AppStrings.update_customer_success);
                                Navigator.pop(context);
                              },
                              child: const Text(AppStrings.update_customer),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(AppStrings.cancel)),
            ],
          ),
        );
      },
    );
  }


  // Telefon numarasını başlatmak için kullanılan URL şeması
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri _phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(_phoneUri)) {
      await launchUrl(_phoneUri);
    } else {
      throw 'Telefon araması yapılamadı: $phoneNumber';
    }
  }


  Future<List<Customers>> getAllCustomers() async {
    // Eğer filtreleme yapılmamışsa, tüm müşterileri getir
    if (_filteredCustomers.isEmpty) {
      _filteredCustomers = await _databaseHelper.getCustomers();
    }
    return _filteredCustomers;
  }

  Future<void> filterCustomers(String name) async {
    _filteredCustomers = await _databaseHelper.getCustomersByName(name);
    notifyListeners();
  }

}
