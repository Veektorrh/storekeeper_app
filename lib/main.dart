import 'package:flutter/material.dart';
import 'package:inventory_app/models/database_model.dart';
import 'package:inventory_app/models/item_model.dart';
import 'package:inventory_app/product_list.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // var db = DatabaseHelper();
  //
  // await db.insertItem(Item
  //   (name: 'Vitamin c', quantity: 1, price: 300, id: 1).toMap());
  // print(await db.getItems());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

        home: ProductList()
    );
  }
}


