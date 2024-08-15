import 'package:siparis_takip/constants/AppStrings.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/Customers.dart';
import '../model/Orders.dart';

class DatabaseHelper {
  static Database? _database;
  static final String _dbName = 'siparis.db';
  static final String _tableName = 'siparisler';

  // Veritabanını ve tabloyu oluşturma
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    // Veritabanını oluştur ve tabloyu ekle
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Müşteri tablosunu oluştur
        await db.execute('''
        CREATE TABLE $_tableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          phone TEXT,
          address TEXT,
          orders TEXT,
          orderDate TEXT
        )
      ''');

        // Sipariş tablosunu oluştur ve müşteri tablosuyla ilişkilendir
        await db.execute('''
        CREATE TABLE orders (
          order_id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_type TEXT,
          order_amount REAL,
          order_total_price REAL,
          order_price REAL,
          order_date TEXT,
          customerId INTEGER,
          FOREIGN KEY(customerId) REFERENCES $_tableName(id)
        )
      ''');
      },
    );
  }


  // Müşteriler
  // Mğşteri ekleme fonksiyonu
  Future<void> insertCustomer(Customers customer) async {
    final db = await database;
    await db.insert(
      _tableName,
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Müşteri silme fonksiyonu
  Future<void> deleteData(int id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Müşteri güncelleme fonksiyonu
  Future<void> updateData(int id, String name, String phone, String address) async {
    final db = await database;
    await db.update(
      _tableName,
      {
        'name': name,
        'phone': phone,
        'address': address,
      },
      where: 'id = ?',
      whereArgs: [id],
    );


  }

  //Müşteri çekme foknsiyonu
  Future<List<Customers>> getCustomers() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      columns: ['id', 'name', 'phone', 'address', 'orderDate'],
      orderBy: 'orderDate DESC',
    );

    return List.generate(maps.length, (i) {
      return Customers.fromMap(maps[i]);
    });
  }


// Kullanıcı adına göre müşteri verilerini alma
  Future<List<Customers>> getCustomersByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );

    return List.generate(maps.length, (i) {
      return Customers.fromMap(maps[i]);
    });
  }




  //Siparişler
  //Sipariş ekleme fonksiyonu
  Future<void> insertOrder(Orders order, int customerId) async {
    final db = await database;
    await db.insert(
      'orders',
      {
        ...order.toMap(),
        'customerId': customerId, // Siparişi ilgili müşteriyle ilişkilendir
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  //Sipariş güncelleme fonksiyonu
  Future<void> updateOrder(int id, Orders order) async {
    final db = await database;
    await db.update(
      'orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  //Sipariş silme fonksiyonu
  Future<void> deleteOrder(int orderId) async {
    final db = await database;
    await db.delete(
      'orders',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }
  //Sipariş filtreleme fonksiyonu
  Future<List<Orders>> getOrdersByCustomerId(int customerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'customerId = ?',
      whereArgs: [customerId],
    );

    return List.generate(maps.length, (i) {
      return Orders.fromMap(maps[i]);
    });
  }



}