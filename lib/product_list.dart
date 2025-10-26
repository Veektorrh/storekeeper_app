import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'models/database_model.dart';
import 'models/item_model.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final dbHelper = DatabaseHelper();
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  String? _imagePath;

  List<Item> items = [];

  @override
  void initState() {
    super.initState();
    _refreshStock();
  }

  Future<void> _refreshStock() async {
    final data = await dbHelper.getItems();
    setState(() {
      items = data.map((e) => Item.fromMap(e)).toList();
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _addItem() async {
    final item = Item(

      name: _nameController.text,
      quantity: int.parse(_qtyController.text),
      price: double.parse(_priceController.text),
    );
    await dbHelper.insertItem(item.toMap());
    _nameController.clear();
    _qtyController.clear();
    _priceController.clear();
    Navigator.pop(context);
    _refreshStock();
  }

  Future<void> _editItem(Item item) async {
    _nameController.text = item.name;
    _qtyController.text = item.quantity.toString();
    _priceController.text = item.price.toString();
    _imagePath = item.imagePath;

    await showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text('Edit Item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: _imagePath == null
                        ? const Icon(Icons.image, size: 80, color: Colors.grey)
                        : Image.file(File(_imagePath!), height: 80,
                        width: 80,
                        fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: 'Item name')),
                  TextField(controller: _qtyController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number),
                  TextField(controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _nameController.clear();
                  _qtyController.clear();
                  _priceController.clear();
                  _imagePath = null;
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final updatedItem = Item(
                    id: item.id,
                    name: _nameController.text,
                    quantity: int.parse(_qtyController.text),
                    price: double.parse(_priceController.text),
                    imagePath: _imagePath,
                  );
                  await dbHelper.updateItem(updatedItem.toMap());
                  Navigator.pop(context);
                  _nameController.clear();
                  _qtyController.clear();
                  _priceController.clear();
                  _imagePath = null;
                  _refreshStock();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }


  Future<void> _deleteItem(int id) async {
    await dbHelper.deleteItem(id);
    _refreshStock();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: const Text('Inventory App')),
      body:
      Container(
        child:

          // Padding(
          //   padding: const EdgeInsets.all(8),
          //   child: Column(
          //     children: [
          //       GestureDetector(
          //         onTap: _pickImage,
          //         child: _imagePath == null
          //             ? const Icon(Icons.image, size: 80, color: Colors.grey)
          //             : Image.file(File(_imagePath!), height: 80,
          //             width: 80,
          //             fit: BoxFit.cover),
          //       ),
          //       const SizedBox(height: 10),
          //       TextField(controller: _nameController,
          //           decoration: const InputDecoration(labelText: 'Item name')),
          //       TextField(controller: _qtyController,
          //           decoration: const InputDecoration(labelText: 'Quantity'),
          //           keyboardType: TextInputType.number),
          //       TextField(controller: _priceController,
          //           decoration: const InputDecoration(labelText: 'Price'),
          //           keyboardType: TextInputType.number),
          //       const SizedBox(height: 10),
          //       ElevatedButton(
          //         onPressed: _addItem,
          //         child: const Text('Add Item'),
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: item.imagePath != null
                        ? Image.file(File(item.imagePath!), width: 50,
                        height: 50,
                        fit: BoxFit.cover)
                        : const Icon(
                        Icons.image_not_supported, color: Colors.grey),
                    title: Text('${item.name} (${item.quantity})'),
                    subtitle: Text('₦${item.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(
                            Icons.edit, color: Colors.blue), onPressed: () =>
                            _editItem(item)),
                        IconButton(icon: const Icon(
                            Icons.delete, color: Colors.red), onPressed: () =>
                            _deleteItem(item.id!)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            showDialog(context: context,
                builder: (_) => AlertDialog(
                  title: Center(child: Text('Add New Item')),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      GestureDetector(
                              onTap: _pickImage,
                              child: _imagePath == null
                                  ? const Icon(Icons.image, size: 80, color: Colors.grey)
                                  : Image.file(File(_imagePath!), height: 80,
                                  width: 80,
                                  fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 10),
                            TextField(controller: _nameController,
                                decoration: const InputDecoration(labelText: 'Item name')),
                            TextField(controller: _qtyController,
                                decoration: const InputDecoration(labelText: 'Quantity'),
                                keyboardType: TextInputType.number),
                            TextField(controller: _priceController,
                                decoration: const InputDecoration(labelText: 'Price'),
                                keyboardType: TextInputType.number),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _addItem,
                              child: const Text('Add Item'),
                            ),
                      ],
                    ),
                  ),
                ));
          },

      child: Text('Add Item'),),
    );
  }
}
