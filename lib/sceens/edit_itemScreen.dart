import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/sceens/demo.dart';

class EditItemScreen extends StatefulWidget {
  final String uid;
  final String foodItemId;
  final Map<String, dynamic> foodItemData;

  const EditItemScreen({
    required this.uid,
    required this.foodItemId,
    required this.foodItemData,
    super.key,
  });

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final TextEditingController foodNameController = TextEditingController();
  final TextEditingController foodPriceController = TextEditingController();
  final TextEditingController foodCodeController = TextEditingController();
  final TextEditingController foodStockController = TextEditingController();
  final TextEditingController foodDescriptionController =
      TextEditingController();

  bool isChecked = false;
  bool isLoading = true;
  bool isUploading = false;
  String selectedOption1 = '';
  String selectedOption2 = '';
  String selectedOption3 = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? selectedImage;
  String? existingImagePath;
  List<String> activeDepartments = [];

  Uint8List webImage = Uint8List(8);
  String selectfile = '';

  // Helper method to safely convert values to String
  String _toStringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    initializeValues();
  }

  void _loadExistingData() {
    // Load existing food item data into controllers with type safety
    foodNameController.text = _toStringValue(widget.foodItemData['name']);
    foodCodeController.text = _toStringValue(widget.foodItemData['foodCode']);
    foodPriceController.text = _toStringValue(widget.foodItemData['price']);
    foodStockController.text = _toStringValue(widget.foodItemData['stocks']);
    foodDescriptionController.text =
        _toStringValue(widget.foodItemData['description']);
    isChecked = widget.foodItemData['isHot'] ?? false;
    existingImagePath = widget.foodItemData['imagePath'];
    selectedOption1 = _toStringValue(widget.foodItemData['department']);
    selectedOption2 = _toStringValue(widget.foodItemData['tax']);
  }

  void initializeValues() async {
    await fetchActiveDepartments();
    await fetchActiveTax();
    await fetchActiveUnit();

    setState(() {
      // Only set default if no existing department
      if (selectedOption1.isEmpty && activeDepartments.isNotEmpty) {
        selectedOption1 = activeDepartments[0];
      }
      isLoading = false;
    });
  }

  Future<void> fetchActiveDepartments() async {
    try {
      CollectionReference departmentsCollection = _firestore
          .collection('AllAdmins')
          .doc(widget.uid)
          .collection('departments');

      QuerySnapshot querySnapshot = await departmentsCollection.get();
      activeDepartments.clear();

      for (var doc in querySnapshot.docs) {
        var department = doc.data() as Map<String, dynamic>;
        if (department['status'] == 'Active') {
          activeDepartments.add(department['name']);
        }
      }
    } catch (e) {
      log('Error fetching active departments: $e');
    }
  }

  Future<void> fetchActiveTax() async {
    try {
      CollectionReference taxCollection =
          _firestore.collection('AllAdmins').doc(widget.uid).collection('tax');
      QuerySnapshot querySnapshot = await taxCollection.get();
      for (var doc in querySnapshot.docs) {
        var department = doc.data() as Map<String, dynamic>;
        if (department['status'] == 'Active') {}
      }
    } catch (e) {
      log('Error fetching active Tax: $e');
    }
  }

  Future<void> fetchActiveUnit() async {
    try {
      CollectionReference unitCollection = _firestore
          .collection('AllAdmins')
          .doc(widget.uid)
          .collection('units');
      QuerySnapshot querySnapshot = await unitCollection.get();
      for (var doc in querySnapshot.docs) {
        var department = doc.data() as Map<String, dynamic>;
        if (department['status'] == 'Active') {}
      }
    } catch (e) {
      log('Error fetching active units: $e');
    }
  }

  Future _pickImage() async {
    FilePickerResult? fileResult = await FilePicker.platform.pickFiles();
    if (fileResult != null) {
      setState(() {
        selectfile = fileResult.files.first.name;
        webImage = fileResult.files.first.bytes!;
      });
    }
  }

  Future pickImageFromGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      selectedImage = File(returnImage.path);
    });
  }

  Future pickImageFromCamera() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      selectedImage = File(returnImage.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Edit Product',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : MediaQuery.of(context).size.width < 600
              ? _buildMobileView()
              : _buildWebView(),

              
    );
  }

  Widget _buildMobileView() {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50)),
            color: black,
          ),
          width: double.infinity,
          height: MediaQuery.of(context).size.height / 4,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * .14,
                  width: MediaQuery.of(context).size.width * .6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(selectedImage!, fit: BoxFit.cover),
                        )
                      : existingImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                imageUrl: existingImagePath!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                      color: primaryColor),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.fastfood, size: 40),
                              ),
                            )
                          : const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: pickImageFromGallery,
                      icon: const Icon(Icons.photo_library, size: 18),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: pickImageFromCamera,
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  MyTextField(
                    controller: foodNameController,
                    hintText: 'Enter item name here',
                    cstmLable: 'Item Name',
                  ),
                  MyTextField(
                    controller: foodCodeController,
                    hintText: 'Enter item code here',
                    cstmLable: 'Item Code',
                    keyboardType: TextInputType.number,
                  ),
                  MyTextField(
                    keyboardType: TextInputType.number,
                    controller: foodPriceController,
                    hintText: 'Enter item price here',
                    cstmLable: "Item Price",
                  ),
                  MyTextField(
                    keyboardType: TextInputType.number,
                    controller: foodStockController,
                    hintText: "Enter item stocks here",
                    cstmLable: 'Item Stock',
                  ),
                  MyTextField(
                    controller: foodDescriptionController,
                    hintText: 'Enter item description',
                    cstmLable: 'Item Description',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Department',
                          style: TextStyle(
                            letterSpacing: 1.3,
                            fontSize: 14,
                            fontFamily: 'fontmain',
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: MediaQuery.of(context).size.width * .9,
                          height: MediaQuery.of(context).size.height / 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: selectedOption1.isNotEmpty
                                ? selectedOption1
                                : null,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedOption1 = newValue!;
                              });
                            },
                            items:
                                activeDepartments.map<DropdownMenuItem<String>>(
                              (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: isUploading ? null : _updateItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: isUploading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'UPDATE ITEM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebView() {
    return ListView(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width -
              MediaQuery.of(context).size.width / 6,
          height: 55,
          child: const Center(
            child: Text(
              'Edit Item Details',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 23,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              color: const Color(0XFFeeeeee),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 40),
                      Container(
                        height: 200,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: selectfile.isEmpty
                            ? (existingImagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: existingImagePath!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator(
                                            color: primaryColor),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.fastfood, size: 60),
                                    ),
                                  )
                                : const Icon(Icons.image,
                                    size: 60, color: Colors.grey))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child:
                                    Image.memory(webImage, fit: BoxFit.cover),
                              ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 19),
                    child: Row(
                      children: [
                        const SizedBox(width: 41),
                        InkWell(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: primaryColor,
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.upload,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Change Image',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 41),
                    child: Row(
                      children: [
                        info("Item Name", "Enter name here", context,
                            foodNameController),
                        const SizedBox(width: 19),
                        info("Item code", "enter code here", context,
                            foodCodeController),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 41),
                    child: Row(
                      children: [
                        info("Item Price", "Enter price here", context,
                            foodPriceController),
                        const SizedBox(width: 19),
                        info("Description", "enter description here", context,
                            foodDescriptionController),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 41),
                    child: Row(
                      children: [
                        info("Stock", "Enter stock here", context,
                            foodStockController),
                        const SizedBox(width: 19),
                        info("units", "enter units here", context,
                            foodNameController),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 47, vertical: 25),
                        child: Container(
                          height: 52,
                          width: MediaQuery.of(context).size.width / 3.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: primaryColor,
                          ),
                          child: MaterialButton(
                            onPressed: isUploading ? null : _updateItem,
                            height: 38,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: isUploading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.update, color: Colors.white),
                                        SizedBox(width: 10),
                                        Text(
                                          'Update Item',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Future<void> _updateItem() async {
    final String foodName = foodNameController.text;
    final String foodCode = foodCodeController.text;
    final String foodPrice = foodPriceController.text;
    final String stocks = foodStockController.text;
    final String description = foodDescriptionController.text;
    final bool isHot = isChecked;

    if (foodName.isEmpty || foodCode.isEmpty || foodPrice.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please provide all details',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      String imagePath = existingImagePath ?? '';

      // Upload new image if selected (mobile)
      if (selectedImage != null) {
        imagePath = await uploadImageToStorage(selectedImage);
      }
      // Upload new image if selected (web)
      else if (selectfile.isNotEmpty && webImage.isNotEmpty) {
        imagePath = await uploadWebImageToStorage(webImage, selectfile);
      }

      // Update the food item in Firestore
      await _firestore
          .collection('AllAdmins')
          .doc(widget.uid)
          .collection('foodItems')
          .doc(widget.foodItemId)
          .update({
        'name': foodName,
        'foodCode': foodCode,
        'price': foodPrice,
        'stocks': stocks,
        'description': description,
        'department': selectedOption1,
        'tax': selectedOption2,
        'imagePath': imagePath,
        'isHot': isHot,
        'updatedAt': DateTime.now().toString(),
      });

      Fluttertoast.showToast(
        msg: 'Item updated successfully!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      setState(() {
        isUploading = false;
      });

      // Navigate back
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      log('Error updating item: $e');
      Fluttertoast.showToast(
        msg: 'Error updating item. Please try again!',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<String> uploadImageToStorage(File? image) async {
    try {
      if (image == null) {
        return '';
      }

      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('food_images/${DateTime.now().millisecondsSinceEpoch}');

      await storageReference.putFile(image);
      String downloadURL = await storageReference.getDownloadURL();
      log('Image uploaded successfully. Download URL: $downloadURL');

      return downloadURL;
    } catch (e) {
      log('Error uploading image to storage: $e');
      return '';
    }
  }

  Future<String> uploadWebImageToStorage(
      Uint8List imageData, String fileName) async {
    try {
      final Reference storageReference = FirebaseStorage.instance.ref().child(
          'food_images/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      await storageReference.putData(imageData);
      String downloadURL = await storageReference.getDownloadURL();
      log('Web image uploaded successfully. Download URL: $downloadURL');

      return downloadURL;
    } catch (e) {
      log('Error uploading web image to storage: $e');
      return '';
    }
  }

  @override
  void dispose() {
    foodNameController.dispose();
    foodPriceController.dispose();
    foodCodeController.dispose();
    foodStockController.dispose();
    foodDescriptionController.dispose();
    super.dispose();
  }
}

// Helper widget for web form fields
Widget info(String label, String hint, BuildContext context,
    TextEditingController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: MediaQuery.of(context).size.width / 4.5,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      const SizedBox(height: 15),
    ],
  );
}
