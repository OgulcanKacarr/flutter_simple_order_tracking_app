class Orders{
  int? order_id;
  String order_type; //yağ ya da peynir
  double order_amount; //miktar
  double order_price; //fiyat
  double order_total_price; //fiyat
  DateTime order_date;

  // Constructor
  Orders({
    this.order_id,
    required this.order_type,
    required this.order_amount,
    required this.order_date,
    required this.order_price,
    required this.order_total_price,
  });

  // Nesneyi Map formatına dönüştüren yöntem
  Map<String, dynamic> toMap() {
    return {
      'order_id': order_id,
      'order_type': order_type,
      'order_amount': order_amount,
      'order_total_price': order_total_price,
      'order_price': order_price,
      'order_date': order_date.toIso8601String(),
    };
  }

  // Map formatındaki veriyi nesneye dönüştüren factory
  factory Orders.fromMap(Map<String, dynamic> map) {
    return Orders(
      order_id: map['order_id'],
      order_type: map['order_type'],
      order_amount: map['order_amount'],
      order_total_price: map['order_total_price'],
      order_price: map['order_price'],
      order_date: DateTime.parse(map['order_date']),
    );
  }

}