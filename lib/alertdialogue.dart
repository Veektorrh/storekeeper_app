import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'models/database_model.dart';
import 'models/item_model.dart';


class AddItemDialog extends StatefulWidget {
  //final VoidCallback onPressed;
  const AddItemDialog({super.key, });

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
   final dbHelper = DatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _imagePath;
  List<Item> items = [];

  Future<void> _refreshStock() async {
    final data = await dbHelper.getItems();
    setState(() {
      items = data.map((e) => Item.fromMap(e)).toList();
    });
  }

  // ✅ Capture image using camera
  Future<void> _captureImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _imagePath = photo.path;
        });
      }
    }

  Future<void> _addItem() async {
    // if (_nameController.text.isEmpty ||
    //     _qtyController.text.isEmpty ||
    //     _priceController.text.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please fill all fields')));
    //   return; }
    final item = Item(
        name: _nameController.text,
        quantity: int.parse(_qtyController.text),
        price: double.parse(_priceController.text),
        imagePath: _imagePath
    );
    await dbHelper.insertItem(item.toMap());
    _nameController.clear();
    _qtyController.clear();
    _priceController.clear();
    Navigator.pop(context);
    _refreshStock();
  }

  // void _saveItem() {
  //   if (_nameController.text.isEmpty ||
  //       _qtyController.text.isEmpty ||
  //       _priceController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please fill all fields')),
  //     );
  //     return;
  //   }
  //
  //   Navigator.of(context).pop({
  //     'name': _nameController.text,
  //     'quantity': int.tryParse(_qtyController.text) ?? 0,
  //     'price': double.tryParse(_priceController.text) ?? 0.0,
  //     'imagePath': _imagePath,
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🖼 Camera image preview + capture button
            GestureDetector(
              onTap: _captureImage,
              child: _imagePath == null
                  ? Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt, size: 50, color: Colors.grey),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(_imagePath!),
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 📝 Input fields
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Item name'),
            ),
            TextField(
              controller: _qtyController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () {
          _nameController.clear();
          _qtyController.clear();
          _priceController.clear();
          _imagePath = null;
          Navigator.pop(context);
        }, child: Text('Cancel')),
        ElevatedButton(
          onPressed: (){
            Navigator.pop(context);
            _addItem();},
          child: const Text('Add Item'),
        )


        // TextButton(
        //   onPressed: () => Navigator.pop(context),
        //   child: const Text('Cancel'),
        // ),
        // ElevatedButton(
        //   onPressed: _saveItem,
        //   child: const Text('Add'),
        // ),
      ],
    );
  }
}
