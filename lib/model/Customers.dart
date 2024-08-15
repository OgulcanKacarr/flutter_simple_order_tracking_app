import 'package:siparis_takip/model/Orders.dart';

class Customers {
  final int? id; // Müşteri ID'si, veritabanı tarafından otomatik artırılacak
  final String name; // Müşteri adı
  final String phone; // Müşteri telefonu
  final String address; // Müşteri adresi
    List<Orders>? orders; // Müşteriye ait siparişler
  final DateTime orderDate; // Müşteri ile ilişkili tarih

  // Constructor
  Customers({
    this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.orders,
    required this.orderDate,
  });

  // Nesneyi Map formatına dönüştüren yöntem
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'orders': orders != null && orders!.isNotEmpty
          ? orders!.map((order) => order.toMap()).toList()
          : [], // Siparişler boşsa boş liste döndür
      'orderDate': orderDate.toIso8601String(), // Tarihi ISO 8601 formatında saklayın
    };
  }

  // Map formatındaki veriyi nesneye dönüştüren factory
  factory Customers.fromMap(Map<String, dynamic> map) {
    return Customers(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      orders: map['orders'] != null
          ? List<Orders>.from(map['orders'].map((orderMap) => Orders.fromMap(orderMap)))
          : [], // Siparişler null ise boş liste
      orderDate: DateTime.parse(map['orderDate']), // Tarihi DateTime'a dönüştür
    );
  }

  void addOrder(Orders newOrder) {
    if (orders != null) {
      orders!.add(newOrder);
    } else {
      orders = [newOrder];
    }
  }

}
