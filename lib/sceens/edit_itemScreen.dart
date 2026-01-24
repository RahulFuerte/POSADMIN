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
  TextEditingController foodNameController = TextEditingController();
  TextEditingController foodPriceController = TextEditingController();
  TextEditingController foodPrice2Controller = TextEditingController();
  TextEditingController foodPrice3Controller = TextEditingController();
  TextEditingController foodCodeController = TextEditingController();
  TextEditingController foodStockController = TextEditingController();
  TextEditingController foodDescriptionController = TextEditingController();
  TextEditingController variantQtyController = TextEditingController();
  TextEditingController variantPriceController = TextEditingController();
  TextEditingController addonNameController = TextEditingController();
  TextEditingController addonPriceController = TextEditingController();

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
  List<String> baseVarients = ['Kg', 'Liter', 'Item Per Pc'];

  String baseVarient = 'Pc';
  String selectedVariantUnit = 'Pc';
  String priceType = "Fixed";
  bool enableVariants = false;
  bool enableAddons = false;

  List<Map<String, dynamic>> variants = [];
  List<Map<String, dynamic>> addons = [];

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
    // ================= BASIC FIELDS =================
    foodNameController.text = _toStringValue(widget.foodItemData['name']);
    foodCodeController.text = _toStringValue(widget.foodItemData['foodCode']);

    foodPriceController.text = _toStringValue(widget.foodItemData['price']);
    foodPrice2Controller.text = _toStringValue(widget.foodItemData['price2']);
    foodPrice3Controller.text = _toStringValue(widget.foodItemData['price3']);

    foodStockController.text = _toStringValue(widget.foodItemData['stocks']);
    foodDescriptionController.text = _toStringValue(widget.foodItemData['description']);

    isChecked = widget.foodItemData['isHot'] ?? false;
    existingImagePath = widget.foodItemData['imagePath'];
    selectedOption1 = _toStringValue(widget.foodItemData['department']);
    selectedOption2 = _toStringValue(widget.foodItemData['tax']);
    priceType = widget.foodItemData['priceType'] ?? "Fixed";

    // ================= BASE VARIANT =================
    final rawBaseVariant = widget.foodItemData['baseVariant'];
    baseVarient = (rawBaseVariant is String && rawBaseVariant.isNotEmpty) ? rawBaseVariant : 'Pc';

    // ================= VARIANTS =================
    variants.clear();
    final variantData = widget.foodItemData['variants'];

    if (variantData is List) {
      for (final v in variantData) {
        variants.add({
          'qty': (v['qty'] as num?)?.toDouble() ?? 1,
          'unit': v['unit'] ?? 'Pc',
          'price': (v['price'] as num?)?.toDouble() ?? 0,
          'size': v['size'] ?? null,
        });
      }
    }

    enableVariants = variants.isNotEmpty;

    // Set default selected unit from first variant if exists
    if (variants.isNotEmpty) {
      selectedVariantUnit = variants.first['unit'];
    } else {
      selectedVariantUnit = 'Kg';
    }

    // ================= ADD-ONS =================
    addons.clear();
    final addonData = widget.foodItemData['addons'];

    if (addonData is List) {
      for (final a in addonData) {
        addons.add({
          'name': a['name'],
          'price': (a['price'] as num?)?.toDouble() ?? 0,
        });
      }
    }

    enableAddons = addons.isNotEmpty;

    setState(() {});
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
      CollectionReference departmentsCollection =
          _firestore.collection('AllAdmins').doc(widget.uid).collection('departments');

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
      CollectionReference taxCollection = _firestore.collection('AllAdmins').doc(widget.uid).collection('tax');
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
      CollectionReference unitCollection = _firestore.collection('AllAdmins').doc(widget.uid).collection('units');
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
    final returnImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      selectedImage = File(returnImage.path);
    });
  }

  Future pickImageFromCamera() async {
    final returnImage = await ImagePicker().pickImage(source: ImageSource.camera);
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
                                  child: CircularProgressIndicator(color: primaryColor),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.fastfood, size: 40),
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
            padding: EdgeInsets.all(18),
            child: Column(
              children: [
                AppDropdown(
                  heading: 'Select Department',
                  items: activeDepartments,
                  value: selectedOption1.isNotEmpty ? selectedOption1 : null,
                  hint: "Choose department",
                  onChanged: (val) {
                    setState(() {
                      selectedOption1 = val;
                    });
                  },
                ),

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
                AppDropdown(
                  heading: 'Item Unit',
                  items: baseVarients,
                  value: baseVarient.isEmpty ? null : baseVarient,
                  hint: "Choose department",
                  onChanged: (val) {
                    setState(() {
                      baseVarient = val;
                    });
                  },
                ),

                MyTextField(
                  keyboardType: TextInputType.number,
                  controller: foodPriceController,
                  hintText: 'Enter item price here',
                  cstmLable: "Item Price",
                ),

                MyTextField(
                  keyboardType: TextInputType.number,
                  controller: foodPrice2Controller,
                  hintText: 'Enter item price 2 here',
                  cstmLable: "Item Price 2",
                ),
                MyTextField(
                  keyboardType: TextInputType.number,
                  controller: foodPrice3Controller,
                  hintText: 'Enter item price 3 here',
                  cstmLable: "Item Price 3",
                ),

                /// ================= VARIANT SECTION =================
                const SizedBox(height: 10),

                Row(
                  children: [
                    const Text(
                      "Price Type",
                      style: TextStyle(
                        letterSpacing: 1.3,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    ChoiceChip(
                      selectedColor: primaryColor,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      label: const Text("Fixed"),
                      labelStyle: TextStyle(
                        color: priceType == "Fixed" ? Colors.white : primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      selected: priceType == "Fixed",
                      onSelected: (v) {
                        setState(() {
                          priceType = "Fixed";
                          foodPriceController.clear();
                          foodPrice2Controller.clear();
                          foodPrice3Controller.clear();
                        });
                      },
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    ChoiceChip(
                      selectedColor: primaryColor,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      label: const Text("Open"),
                      labelStyle: TextStyle(
                        color: priceType == "Open" ? Colors.white : primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      selected: priceType == "Open",
                      onSelected: (v) {
                        setState(() {
                          priceType = "Open";
                          foodPriceController.text = "0";
                          foodPrice2Controller.text = "0";
                          foodPrice3Controller.text = "0";
                        });
                      },
                    ),
                  ],
                ),

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    "Add Variants",
                    style: TextStyle(
                      letterSpacing: 1.3,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  value: enableVariants,
                  onChanged: (v) {
                    setState(() {
                      enableVariants = v!;
                    });
                  },
                ),

                const SizedBox(height: 10),
                if (enableVariants) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        // ===== Variant Unit Dropdown =====
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Unit',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: selectedVariantUnit,
                                  items: ['Kg', 'Gm', 'Liter', 'Ml', 'Pc', 'Size']
                                      .map((e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setState(() {
                                      selectedVariantUnit = v;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // ===== Variant Quantity Input =====
                        Expanded(
                          child: MyTextField(
                            controller: variantQtyController,
                            keyboardType: TextInputType.number,
                            hintText: 'Qty',
                            cstmLable: 'Quantity',
                            // ⚡ No auto-calculation of price here
                            //  <-- REMOVE THIS
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== Variant Price Input =====
                  MyTextField(
                    controller: variantPriceController,
                    keyboardType: TextInputType.number,
                    hintText: 'Enter variant price manually',
                    cstmLable: 'Variant Price',
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        if (variantQtyController.text.isEmpty || variantPriceController.text.isEmpty) return;

                        setState(() {
                          variants.add({
                            'qty': double.parse(variantQtyController.text),
                            'unit': selectedVariantUnit,
                            'price': double.parse(variantPriceController.text),
                          });
                        });

                        variantQtyController.clear();
                        variantPriceController.clear();
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: primaryColor,
                        ),
                        child: const Text(
                          'ADD VARIANT',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "tabfont",
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// ================= VARIANT LIST =================
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: variants.length,
                    itemBuilder: (context, index) {
                      final v = variants[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            "${v['qty']} ${v['unit']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            "Price: ₹${v['price']}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                variants.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    "Add-Ons",
                    style: TextStyle(
                      letterSpacing: 1.3,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  value: enableAddons,
                  onChanged: (v) {
                    setState(() {
                      enableAddons = v!;
                      if (!enableAddons) addons.clear();
                    });
                  },
                ),
                if (enableAddons) ...[
                  Column(
                    children: [
                      MyTextField(
                        controller: addonNameController,
                        hintText: 'Add On Name',
                        cstmLable: 'Add Ons',
                        // ⚡ No auto-calculation of price here
                        //  <-- REMOVE THIS
                      ),
                      MyTextField(
                        controller: addonPriceController,
                        keyboardType: TextInputType.number,
                        hintText: 'Add On Price',
                        cstmLable: 'Add On Price',
                        // ⚡ No auto-calculation of price here
                        //  <-- REMOVE THIS
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                              onTap: () {
                                if (addonNameController.text.isEmpty || addonPriceController.text.isEmpty) return;

                                setState(() {
                                  addons.add({
                                    "name": addonNameController.text,
                                    "price": double.parse(addonPriceController.text),
                                  });
                                });

                                addonNameController.clear();
                                addonPriceController.clear();
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 15),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: primaryColor,
                                ),
                                child: const Text(
                                  'ADD ADDON',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "tabfont",
                                  ),
                                ),
                              ))),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: addons.length,
                    itemBuilder: (context, i) {
                      final a = addons[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            a['name'],
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Text(
                            "Price: ₹ ${a['price']}",
                            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() => addons.removeAt(i));
                            },
                          ),
                        ),
                      );
                    },
                  )
                ],

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
              ],
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
          width: MediaQuery.of(context).size.width - MediaQuery.of(context).size.width / 6,
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
                                        child: CircularProgressIndicator(color: primaryColor),
                                      ),
                                      errorWidget: (context, url, error) => const Icon(Icons.fastfood, size: 60),
                                    ),
                                  )
                                : const Icon(Icons.image, size: 60, color: Colors.grey))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(webImage, fit: BoxFit.cover),
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
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: primaryColor,
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.upload, color: Colors.white, size: 18),
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
                        info("Item Name", "Enter name here", context, foodNameController),
                        const SizedBox(width: 19),
                        info("Item code", "enter code here", context, foodCodeController),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 41),
                    child: Row(
                      children: [
                        info("Item Price", "Enter price here", context, foodPriceController),
                        const SizedBox(width: 19),
                        info("Description", "enter description here", context, foodDescriptionController),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 41),
                    child: Row(
                      children: [
                        info("Stock", "Enter stock here", context, foodStockController),
                        const SizedBox(width: 19),
                        info("units", "enter units here", context, foodNameController),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 47, vertical: 25),
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
                                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
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
    final String foodName = foodNameController.text.trim();
    final String foodCode = foodCodeController.text.trim();
    final String foodPrice = foodPriceController.text.trim();
    final String foodPrice2 = foodPrice2Controller.text.trim();
    final String foodPrice3 = foodPrice3Controller.text.trim();
    final String stocks = foodStockController.text.trim();
    final String description = foodDescriptionController.text.trim();
    final bool isHot = isChecked;

    if (foodName.isEmpty || foodCode.isEmpty || foodPrice.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please provide all required details',
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

      // 📸 Upload new image (mobile)
      if (selectedImage != null) {
        imagePath = await uploadImageToStorage(selectedImage);
      }
      // 🌐 Upload new image (web)
      else if (selectfile.isNotEmpty && webImage.isNotEmpty) {
        imagePath = await uploadWebImageToStorage(webImage, selectfile);
      }

      // 🔹 Format variants safely
      final List<Map<String, dynamic>> formattedVariants = variants.map((v) {
        return {
          'qty': v['qty'],
          'unit': v['unit'],
          'price': v['price'],
        };
      }).toList();

      // 🔥 UPDATE FIRESTORE
      await _firestore.collection('AllAdmins').doc(widget.uid).collection('foodItems').doc(widget.foodItemId).update({
        'name': foodName,
        'foodCode': foodCode,
        'price': foodPrice,
        'price2': priceType == "Open" ? 0 : double.parse(foodPrice2),
        'price3': priceType == "Open" ? 0 : double.parse(foodPrice3),
        'stocks': stocks,
        'description': description,
        'department': selectedOption1,
        'tax': selectedOption2,
        'imagePath': imagePath,
        'isHot': isHot,
        'priceType': priceType,
        'baseVariant': baseVarient,
        'variants': formattedVariants,
        'addons': addons,
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

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('❌ Error updating item: $e');

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

      final Reference storageReference =
          FirebaseStorage.instance.ref().child('food_images/${DateTime.now().millisecondsSinceEpoch}');

      await storageReference.putFile(image);
      String downloadURL = await storageReference.getDownloadURL();
      log('Image uploaded successfully. Download URL: $downloadURL');

      return downloadURL;
    } catch (e) {
      log('Error uploading image to storage: $e');
      return '';
    }
  }

  Future<String> uploadWebImageToStorage(Uint8List imageData, String fileName) async {
    try {
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('food_images/${DateTime.now().millisecondsSinceEpoch}_$fileName');

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
Widget info(String label, String hint, BuildContext context, TextEditingController controller) {
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
