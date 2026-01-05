import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:pos_admin/sceens/demo.dart';
import 'package:pos_admin/sceens/upload/bulkUploadScreen.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/screen.dart';

import '../backend/items_add/add_items_by_pdf.dart';

class AddItemScreen extends StatefulWidget {
  final String uid;
  const AddItemScreen({required this.uid, super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool isLoading = true;
  bool isUploading = false;
  String selectedDepartment = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? selectedImage;
  File? pdfFile;
  List<String> activeDepartments = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _codeController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _fetchActiveDepartments();
    if (mounted) {
      setState(() {
        selectedDepartment = activeDepartments.isNotEmpty ? activeDepartments[0] : '';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchActiveDepartments() async {
    try {
      final snapshot = await _firestore.collection('AllAdmins').doc(widget.uid).collection('departments').get();

      activeDepartments.clear();
      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data['status'] == 'Active') {
          activeDepartments.add(data['name']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching departments: $e');
    }
  }

  Future<void> updateAllFoodItemsUid() async {
    final firestore = FirebaseFirestore.instance;

    // Path to the subcollection
    final collectionRef = firestore.collection('AllAdmins').doc('+919265280309').collection('foodItems');

    try {
      // 1. Get all documents in that subcollection
      QuerySnapshot querySnapshot = await collectionRef.get();

      // 2. Initialize a batch
      WriteBatch batch = firestore.batch();

      // 3. Loop through documents and add them to the batch
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'uid': '+919265280309'});
      }

      // 4. Commit the batch
      await batch.commit();
      print("Successfully updated ${querySnapshot.docs.length} items.");
    } catch (e) {
      print("Error performing batch update: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Screen s = Screen(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: black),
          onPressed: () {
            _clearControllers();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Add Item',
          style: TextStyle(
            color: black,
            fontFamily: 'tabfont',
            fontSize: 19,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BulkUploadScreen(
                    uid: widget.uid,
                    activeDepartments: activeDepartments,
                    onUploadComplete: () {
                      _fetchActiveDepartments().then((_) {
                        if (mounted) {
                          setState(() {
                            selectedDepartment = activeDepartments.isNotEmpty ? activeDepartments[0] : '';
                          });
                        }
                      });
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.update, color: black),
            onPressed: () async {
              // If no PDF selected, open picker first
              final service = SheetalDataService();
              if (pdfFile == null) {
                await _pickPdfFile();
                return;
              }

              // Try to print and clear menu (best-effort)
              try {
                service.printMenuSummary();
              } catch (_) {}
              try {
                await service.clearExistingMenuData();
              } catch (_) {}

              // Upload the selected PDF
              try {
                await service.processAndUploadMenu(pdfFile!);
                _showSnackBar('PDF uploaded successfully');
                setState(() {
                  pdfFile = null;
                });
              } catch (e) {
                _showSnackBar('Error uploading PDF: $e');
              }
            },
          ),
        ],
        centerTitle: true,
      ),
      body: PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          if (didPop) _clearControllers();
        },
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(s.scale(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image picker section
                    _buildImagePicker(s),

                    SizedBox(height: s.scale(24)),

                    // Form fields
                    _buildFormSection(s),

                    SizedBox(height: s.scale(32)),

                    // Submit button
                    // _buildSubmitButton(s),

                    SizedBox(height: s.scale(24)),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 0.0).copyWith(bottom: s.scale(10.0)),
        child: _buildSubmitButton(s),
      ),
    );
  }

  Widget _buildImagePicker(Screen s) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(s.scale(20)),
        child: Column(
          children: [
            // Image preview
            Container(
              height: s.scale(150),
              width: s.scale(150),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fastfood_rounded,
                          size: s.scale(60),
                          color: primaryColor.withOpacity(0.5),
                        ),
                        SizedBox(height: s.scale(8)),
                        Text(
                          'Add Image',
                          style: TextStyle(
                            color: grey,
                            fontSize: s.scale(12),
                          ),
                        ),
                      ],
                    ),
            ),

            SizedBox(height: s.scale(16)),

            // Image picker buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImageButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: _pickImageFromGallery,
                  s: s,
                ),
                SizedBox(width: s.scale(16)),
                _buildImageButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: _pickImageFromCamera,
                  s: s,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Screen s,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: s.scale(20),
          vertical: s.scale(12),
        ),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: s.scale(20)),
            SizedBox(width: s.scale(8)),
            Text(
              label,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: s.scale(14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(Screen s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item Details',
          style: TextStyle(
            fontSize: s.scale(20),
            fontWeight: FontWeight.bold,
            color: black,
          ),
        ),
        SizedBox(height: s.scale(16)),

        MyTextField(
          controller: _nameController,
          hintText: 'Enter item name',
          cstmLable: 'Item Name',
          prefixIcon: Icons.shopping_bag_outlined,
        ),

        MyTextField(
          controller: _codeController,
          hintText: 'Enter item code',
          cstmLable: 'Item Code',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.qr_code_rounded,
        ),

        MyTextField(
          controller: _priceController,
          hintText: 'Enter item price',
          cstmLable: 'Item Price (₹)',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.currency_rupee_rounded,
        ),

        MyTextField(
          controller: _stockController,
          hintText: 'Enter stock quantity',
          cstmLable: 'Stock Quantity',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.inventory_2_outlined,
        ),

        MyTextField(
          controller: _descriptionController,
          hintText: 'Enter item description',
          cstmLable: 'Description',
          prefixIcon: Icons.description_outlined,
        ),

        SizedBox(height: s.scale(8)),

        // Department dropdown
        _buildDepartmentDropdown(s),
      ],
    );
  }

  Widget _buildDepartmentDropdown(Screen s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          SizedBox(height: s.scale(8)),
          Card(
            elevation: 5,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  // Ensure value is null when not present in items to avoid Dropdown assertion
                  value: (selectedDepartment.isEmpty || !activeDepartments.contains(selectedDepartment)) ? null : selectedDepartment,
                  isExpanded: true,
                  hint: const Text(
                    'Select department',
                    style: TextStyle(color: grey),
                  ),
                  items: activeDepartments.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedDepartment = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(Screen s) {
    return SizedBox(
      width: double.infinity,
      height: s.scale(56),
      child: ElevatedButton(
        onPressed: isUploading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isUploading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: s.scale(22)),
                  SizedBox(width: s.scale(12)),
                  Text(
                    'Add Item',
                    style: TextStyle(
                      fontSize: s.scale(17),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _clearControllers() {
    _nameController.clear();
    _priceController.clear();
    _codeController.clear();
    _stockController.clear();
    _descriptionController.clear();
  }

  Future<void> _pickImageFromGallery() async {
    final returnImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage != null) {
      setState(() {
        selectedImage = File(returnImage.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final returnImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage != null) {
      setState(() {
        selectedImage = File(returnImage.path);
      });
    }
  }

  Future<void> _pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          pdfFile = File(result.files.single.path!);
        });
        _showSnackBar('Selected PDF: ${result.files.single.name}');
      } else {
        _showSnackBar('No PDF selected');
      }
    } catch (e) {
      _showSnackBar('Error picking PDF: $e');
    }
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim();
    final price = _priceController.text.trim();
    final stock = _stockController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || code.isEmpty || price.isEmpty || stock.isEmpty) {
      _showSnackBar('Please fill all required fields');
      return;
    }

    setState(() {
      isUploading = true;
    });

    _createItem(name, code, price, stock, description).then((_) {
      setState(() {
        isUploading = false;
      });
    });
  }

  Future<void> _createItem(
    String name,
    String code,
    String price,
    String stock,
    String description,
  ) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        _showSnackBar('User not authenticated');
        return;
      }

      String imagePath = await _uploadImageToStorage(selectedImage);

      await _firestore.collection('AllAdmins').doc(widget.uid).collection('foodItems').add({
        'name': name,
        'foodCode': code,
        'price': price,
        'uid': widget.uid,
        'imagePath': imagePath,
        'department': selectedDepartment,
        'stocks': stock,
        'description': description,
        'createdAt': DateTime.now().toString(),
        'isHot': false,
      });

      _showSnackBar('Item added successfully!');
      _clearControllers();
      setState(() {
        selectedImage = null;
      });
    } catch (e) {
      _showSnackBar('Error adding item: $e');
    }
  }

  Future<String> _uploadImageToStorage(File? image) async {
    if (image == null) return '';

    try {
      final ref = FirebaseStorage.instance.ref().child('food_images/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return '';
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}

// Bulk upload is now implemented in a full screen widget: see bulkUploadScreen.dart
