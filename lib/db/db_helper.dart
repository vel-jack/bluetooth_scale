import 'package:bluetooth_scale/model/customer.dart';
import 'package:bluetooth_scale/model/transactionx.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;
  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'bscale.db'),
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE customer(uid TEXT PRIMARY KEY, name TEXT, phone Text, aadhaar TEXT,createdAt TEXT,address TEXT);",
        );
        db.execute(
          "CREATE TABLE transactionx(tid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, customerID TEXT, customerName TEXT, weight Text, date TEXT);",
        );
        // more create statements....
      },
      version: 1,
    );
  }

  Future<void> addCustomer(Customer customer) async {
    var dbClient = await db;
    await dbClient.insert('customer', customer.toMap());
  }

  Future<void> addTransaction(TransactionX tx) async {
    var dbClient = await db;
    try {
      await dbClient.rawInsert(
          "INSERT INTO transactionx(customerID,customerName,weight,date) VALUES('${tx.customerID}','${tx.customerName}','${tx.weight}','${tx.date}')");
    } catch (_) {
      // debugPrint('InsertionError $e');
    }
  }

  Future<List<TransactionX>> getLastTen() async {
    var dbClient = await db;
    List<Map<String, dynamic>> dbMap = await dbClient
        .rawQuery("SELECT * FROM transactionx ORDER BY tid DESC LIMIT 10");
    if (dbMap.isNotEmpty) {
      return List.generate(dbMap.length, (index) {
        return TransactionX.fromMap(dbMap[index]);
      }).toList();
    } else {
      return [];
    }
  }

  Future<List<TransactionX>> getCustomerTx(String customerID) async {
    var dbClient = await db;
    List<Map<String, dynamic>> dbMap = await dbClient.rawQuery(
        "SELECT * FROM transactionx WHERE customerID = '$customerID' ORDER BY tid DESC LIMIT 10");
    if (dbMap.isNotEmpty) {
      return List.generate(dbMap.length, (index) {
        return TransactionX.fromMap(dbMap[index]);
      }).toList();
    } else {
      return [];
    }
  }

  Future<List<Customer>> getCustomers() async {
    var dbClient = await db;
    List<Map<String, dynamic>> dbMap = await dbClient.query('customer');
    if (dbMap.isNotEmpty) {
      return List.generate(dbMap.length, (index) {
        return Customer.fromMap(dbMap[index]);
      }).toList();
    } else {
      return [];
    }
  }

  Future<List<TransactionX>> getAllTx() async {
    var dbClient = await db;
    List<Map<String, dynamic>> dbMap = await dbClient.query('transactionx');
    if (dbMap.isNotEmpty) {
      return List.generate(dbMap.length, (index) {
        return TransactionX.fromMap(dbMap[index]);
      }).toList();
    } else {
      return [];
    }
  }

  Future<Customer?> getCustomerByID(String customerID) async {
    var dbClient = await db;
    List<Map<String, dynamic>> list = await dbClient
        .query('customer', where: 'uid = ?', whereArgs: [customerID]);
    if (list.isNotEmpty) {
      return Customer.fromMap(list.first);
    } else {
      return null;
    }
  }

  Future<void> deleteTransaction(int id) async {
    var dbClient = await db;
    dbClient.delete('transactionx', where: 'tid=?', whereArgs: [id]);
  }

  Future<void> updateCustomer(Customer customer) async {
    var dbClient = await db;
    await dbClient.update('customer', customer.toMap(),
        where: 'uid = ?', whereArgs: [customer.uid]);
  }

  Future<void> deleteCustomer(String uid) async {
    var dbClient = await db;
    await dbClient
        .delete('transactionx', where: 'customerID = ?', whereArgs: [uid]);
    await dbClient.delete('customer', where: 'uid = ?', whereArgs: [uid]);
  }
}
