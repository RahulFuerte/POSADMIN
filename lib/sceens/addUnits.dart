import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/screen.dart';
import 'package:pos_admin/sceens/demo.dart';
import 'package:pos_admin/widgets/utils.dart';

class AddUnitScreen extends StatefulWidget {
  final String docId;

  const AddUnitScreen({required this.docId, Key? key}) : super(key: key);

  @override
  State<AddUnitScreen> createState() => _AddUnitScreenState();
}

class _AddUnitScreenState extends State<AddUnitScreen> {
  final TextEditingController unitNameController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  int selectedRadio = 1;
  bool isLoading = false;

  @override
  void dispose() {
    unitNameController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  void handleRadioValueChange(int? value) {
    if (value != null) {
      setState(() {
        selectedRadio = value;
      });
    }
  }

  Future<void> addUnits() async {
    if (unitNameController.text.isEmpty) {
      showWarningSnackBar(context, 'Please enter unit name');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      CollectionReference adminCollection =
          FirebaseFirestore.instance.collection('AllAdmins');
      DocumentReference adminDocument = adminCollection.doc(widget.docId);

      await adminDocument.collection('units').add({
        'createdAt': DateTime.now().toString(),
        'name': unitNameController.text,
        'remark': remarkController.text,
        'status': selectedRadio == 1 ? 'Active' : 'In-Active',
      });

      unitNameController.clear();
      remarkController.clear();
      setState(() {
        selectedRadio = 1;
        isLoading = false;
      });

      if (mounted) {
        showSuccessSnackBar(context, 'Unit added successfully!');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        showErrorSnackBar(context, 'Error adding unit: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Screen s = Screen(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Unit',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            fontFamily: 'tabfont',
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Header Image
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    '$imagesPath/unit.gif',
                    height: s.scale(150),
                    fit: BoxFit.contain,
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
                        'Unit Information',
                        style: TextStyle(
                          fontSize: s.scale(22),
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontFamily: 'tabfont',
                        ),
                      ),
                      SizedBox(height: s.scale(8)),
                      Text(
                        'Fill in the unit details below',
                        style: TextStyle(
                          fontSize: s.scale(14),
                          color: Colors.grey[600],
                          fontFamily: 'fontmain',
                        ),
                      ),
                      SizedBox(height: s.scale(24)),

                      // Unit Name Field
                      MyTextField(
                        cstmLable: "Unit Name",
                        controller: unitNameController,
                        hintText: 'Enter unit name (e.g., kg, pcs, ltr)',
                        prefixIcon: Icons.straighten_rounded,
                      ),

                      SizedBox(height: s.scale(16)),

                      // Remark Field
                      MyTextField(
                        cstmLable: "Remark",
                        controller: remarkController,
                        hintText: 'Enter remark (optional)',
                        prefixIcon: Icons.note_alt_outlined,
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
          ),
          if (isLoading) _buildLoadingOverlay(),
        ],
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
          onTap: addUnits,
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
                  'Add Unit',
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
                  'Saving unit...',
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
