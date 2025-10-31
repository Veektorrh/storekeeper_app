import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_app/product_list.dart';

import 'models/database_model.dart';
import 'models/item_model.dart';

class EditItem extends StatefulWidget {
  final  item;
  const EditItem({super.key, required this.item});

  @override
  State<EditItem> createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  final dbHelper = DatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _imagePath;

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


  @override
  Widget build(BuildContext context) {
    _nameController.text = widget.item.name;
    _qtyController.text = widget.item.quantity.toString();
    _priceController.text = widget.item.price.toString();
    _imagePath = widget.item.imagePath;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Item'),
        centerTitle: true,
      ),
      body: Container(
        // color: Colors.grey.shade800,
        height: Get.height,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
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
              const SizedBox(height: 16),
              TextField(
                controller: _qtyController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      style: ButtonStyle(
                          fixedSize: WidgetStatePropertyAll(Size.fromWidth(Get.width * 0.3)),
                          side: WidgetStatePropertyAll(BorderSide(width: 1, style: BorderStyle.none))
                      ),
                      onPressed: () {
                        Get.back();
                      }, child: Text('Cancel')),
                  ElevatedButton(
                    onPressed:

                      () async {
                        final updatedItem = Item(
                          id: widget.item.id,
                          name: _nameController.text,
                          quantity: int.parse(_qtyController.text),
                          price: double.parse(_priceController.text),
                          imagePath: _imagePath,
                        );
                        await dbHelper.updateItem(updatedItem.toMap());

                        //Navigator.pop(context);
                        _nameController.clear();
                        _qtyController.clear();
                        _priceController.clear();
                        _imagePath = null;
                        Get.to(()=>ProductList());


                       // _refreshStock();
                      },


                    child: const Text('Save'),
                  ),
                ],
              )
            ],
          ),
        ),

      ),
    );;
  }
}
