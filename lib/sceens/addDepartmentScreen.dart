import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/sceens/addCustomerScreen.dart';
import 'package:pos_admin/screen.dart';
import 'package:pos_admin/sceens/demo.dart';
import 'package:pos_admin/widgets/utils.dart';

class AddDepartmentScreen extends StatefulWidget {
  final String docId;

  const AddDepartmentScreen({required this.docId, Key? key}) : super(key: key);

  @override
  State<AddDepartmentScreen> createState() => _AddDepartmentState();
}

class _AddDepartmentState extends State<AddDepartmentScreen> {
  Uint8List webImage = Uint8List(8);
  String selectfile = '';
  File? selectedImage;
  final TextEditingController departmentNameController =
      TextEditingController();
  int selectedRadio = 1;
  bool isLoading = false;

  @override
  void dispose() {
    departmentNameController.dispose();
    super.dispose();
  }

  void handleRadioValueChange(int? value) {
    if (value != null) {
      setState(() {
        selectedRadio = value;
      });
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

  Future uploadFile() async {
    if (selectfile.isEmpty) {
      showWarningSnackBar(context, 'Please select an image');
      return;
    }

    if (departmentNameController.text.isEmpty) {
      showWarningSnackBar(context, 'Please enter department name');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      CollectionReference adminCollection =
          FirebaseFirestore.instance.collection('AllAdmins');

      DocumentReference adminDocument = adminCollection.doc(widget.docId);
      Reference ref =
          FirebaseStorage.instance.ref().child('Banks/${DateTime.now()}.png');
      UploadTask uploadTask = ref.putData(
        webImage,
        SettableMetadata(contentType: 'image/png'),
      );
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => log('done'));
      String url = await taskSnapshot.ref.getDownloadURL();

      await adminDocument.collection('departments').add({
        'createdAt': DateTime.now().toString(),
        'name': departmentNameController.text,
        'status': selectedRadio == 1 ? 'Active' : 'In-Active',
        'adminUid': widget.docId,
        'imageUrl': url.toString(),
      });

      setState(() {
        departmentNameController.clear();
        selectfile = '';
        webImage = Uint8List(8);
        selectedRadio = 1;
        isLoading = false;
      });

      if (mounted) {
        showSuccessSnackBar(context, 'Department added successfully!');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        showErrorSnackBar(context, 'Error adding department: $e');
      }
    }
  }

  Future<void> addDepartment() async {
    if (selectedImage == null) {
      showWarningSnackBar(context, 'Please select an image');
      return;
    }

    if (departmentNameController.text.isEmpty) {
      showWarningSnackBar(context, 'Please enter department name');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      CollectionReference adminCollection =
          FirebaseFirestore.instance.collection('AllAdmins');

      DocumentReference adminDocument = adminCollection.doc(widget.docId);
      String imageUrl = await uploadImageToStorage(selectedImage);

      await adminDocument.collection('departments').add({
        'createdAt': DateTime.now().toString(),
        'name': departmentNameController.text,
        'status': selectedRadio == 1 ? 'Active' : 'In-Active',
        'adminUid': widget.docId,
        'imageUrl': imageUrl,
      });

      setState(() {
        departmentNameController.clear();
        selectedImage = null;
        selectedRadio = 1;
        isLoading = false;
      });

      if (mounted) {
        showSuccessSnackBar(context, 'Department added successfully!');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        showErrorSnackBar(context, 'Error adding department: $e');
      }
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

  Future<String> uploadImageToStorage(File? image) async {
    try {
      if (image == null) {
        return '';
      }

      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('department_images/${DateTime.now().millisecondsSinceEpoch}');

      await storageReference.putFile(image);

      String downloadURL = await storageReference.getDownloadURL();
      log('Image uploaded successfully. Download URL: $downloadURL');

      return downloadURL;
    } catch (e) {
      log('Error uploading image to storage: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Screen s = Screen(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: s.isMobile
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: primaryColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Add Department',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  fontFamily: 'tabfont',
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: Stack(
        children: [
          s.isMobile ? _buildMobileLayout(s) : _buildWebLayout(s),
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(Screen s) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Image Preview Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(height: s.scale(20)),
                // Image Preview
                Container(
                  height: s.scale(150),
                  width: s.scale(200),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: selectedImage != null
                        ? Image.file(selectedImage!, fit: BoxFit.cover)
                        : Lottie.asset(
                            "$lottiePath/food2.json",
                            fit: BoxFit.contain,
                            frameRate: FrameRate(90),
                          ),
                  ),
                ),
                SizedBox(height: s.scale(20)),
                // Image Picker Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildImagePickerButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: pickImageFromGallery,
                      screen: s,
                    ),
                    SizedBox(width: s.scale(16)),
                    _buildImagePickerButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: pickImageFromCamera,
                      screen: s,
                    ),
                  ],
                ),
                SizedBox(height: s.scale(20)),
              ],
            ),
          ),

          SizedBox(height: s.scale(24)),

          // Form Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: s.scale(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Department Information',
                  style: TextStyle(
                    fontSize: s.scale(22),
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontFamily: 'tabfont',
                  ),
                ),
                SizedBox(height: s.scale(8)),
                Text(
                  'Fill in the details below to add a new department',
                  style: TextStyle(
                    fontSize: s.scale(14),
                    color: Colors.grey[600],
                    fontFamily: 'fontmain',
                  ),
                ),
                SizedBox(height: s.scale(24)),

                // Department Name Field
                MyTextField(
                  cstmLable: "Department Name",
                  controller: departmentNameController,
                  hintText: 'Enter department name',
                  prefixIcon: Icons.category_rounded,
                ),

                SizedBox(height: s.scale(20)),

                // Status Selection
                _buildStatusSection(s),

                SizedBox(height: s.scale(32)),

                // Submit Button
                _buildSubmitButton(s),

                SizedBox(height: s.scale(32)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Screen screen,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: themeAccent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screen.scale(20),
            vertical: screen.scale(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: screen.scale(20)),
              SizedBox(width: screen.scale(8)),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: screen.scale(16),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection(Screen s) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(s.scale(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status',
              style: TextStyle(
                fontSize: s.scale(15),
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontFamily: 'fontmain',
              ),
            ),
            SizedBox(height: s.scale(12)),
            _buildRadioOption(
              value: 1,
              label: 'Active',
              icon: Icons.check_circle_outline,
              iconColor: successColor,
              screen: s,
            ),
            _buildRadioOption(
              value: 2,
              label: 'In-Active',
              icon: Icons.cancel_outlined,
              iconColor: warningColor,
              screen: s,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required int value,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Screen screen,
  }) {
    final bool isSelected = selectedRadio == value;
    return GestureDetector(
      onTap: () => handleRadioValueChange(value),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screen.scale(8),
          horizontal: screen.scale(4),
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedItemBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<int>(
              activeColor: primaryColor,
              value: value,
              groupValue: selectedRadio,
              onChanged: handleRadioValueChange,
            ),
            Icon(icon, color: iconColor, size: screen.scale(20)),
            SizedBox(width: screen.scale(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: screen.scale(16),
                fontFamily: 'fontmain',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? primaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(Screen s) {
    return Container(
      width: double.infinity,
      height: s.scale(56),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [primaryColor, themeAccentSolid],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _handleSubmit,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: s.scale(24),
                ),
                SizedBox(width: s.scale(12)),
                Text(
                  'Add Department',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: s.scale(17),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (selectedImage == null) {
      showWarningSnackBar(context, 'Please select an image');
      return;
    }
    if (departmentNameController.text.isEmpty) {
      showWarningSnackBar(context, 'Please enter department name');
      return;
    }
    addDepartment();
  }

  Widget _buildWebLayout(Screen s) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: const Center(
            child: Text(
              'Add Category Details',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                fontFamily: 'tabfont',
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Main Content Card
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    Center(
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          height: 200,
                          width: 300,
                          padding: const EdgeInsets.all(16),
                          child: selectfile.isEmpty
                              ? Image.network(
                                  'https://st4.depositphotos.com/6557968/22851/v/1600/depositphotos_228519744-stock-illustration-laptop-upload-file-peoples-document.jpg',
                                  fit: BoxFit.contain,
                                )
                              : Image.memory(
                                  webImage,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Select Image Button
                    Center(
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: themeAccent,
                        child: InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(10),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.upload_file, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Select Image',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Category Name Field
                    info(
                      "Category Name",
                      "Enter name here",
                      context,
                      departmentNameController,
                    ),
                    const SizedBox(height: 24),
                    
                    // Status Section
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildWebRadioOption(1, 'Active', Icons.check_circle_outline, successColor),
                    _buildWebRadioOption(2, 'In-Active', Icons.cancel_outlined, warningColor),
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 51,
                      child: Card(
                        elevation: 5,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: themeAccent,
                        child: InkWell(
                          onTap: _handleWebSubmit,
                          borderRadius: BorderRadius.circular(10),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline, color: Colors.white),
                                SizedBox(width: 12),
                                Text(
                                  'Add Category',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
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
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebRadioOption(int value, String label, IconData icon, Color iconColor) {
    final bool isSelected = selectedRadio == value;
    return GestureDetector(
      onTap: () => handleRadioValueChange(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? selectedItemBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<int>(
              activeColor: primaryColor,
              value: value,
              groupValue: selectedRadio,
              onChanged: handleRadioValueChange,
            ),
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'fontmain',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? primaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleWebSubmit() {
    if (selectfile.isEmpty) {
      showWarningSnackBar(context, 'Please select an image');
      return;
    }
    if (departmentNameController.text.isEmpty) {
      showWarningSnackBar(context, 'Please enter department name');
      return;
    }
    uploadFile();
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
                SizedBox(height: 16),
                Text(
                  'Saving department...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'fontmain',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
