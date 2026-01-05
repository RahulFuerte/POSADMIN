import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/sceens/addCustomerScreen.dart';
import 'package:pos_admin/screen.dart';
import 'package:pos_admin/sceens/demo.dart';
import 'package:pos_admin/widgets/utils.dart';

class AddTaxScreen extends StatefulWidget {
  final String docId;

  const AddTaxScreen({required this.docId, Key? key}) : super(key: key);

  @override
  State<AddTaxScreen> createState() => _AddTaxScreenState();
}

class _AddTaxScreenState extends State<AddTaxScreen> {
  final TextEditingController taxNameController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController cgstController = TextEditingController();
  final TextEditingController sgstController = TextEditingController();
  final TextEditingController igstController = TextEditingController();
  int selectedRadio = 1;
  bool isLoading = false;

  @override
  void dispose() {
    taxNameController.dispose();
    gstController.dispose();
    cgstController.dispose();
    sgstController.dispose();
    igstController.dispose();
    super.dispose();
  }

  void handleRadioValueChange(int? value) {
    if (value != null) {
      setState(() {
        selectedRadio = value;
      });
    }
  }

  Future<void> addTax() async {
    if (!_validateFields()) return;

    setState(() {
      isLoading = true;
    });

    try {
      CollectionReference adminCollection =
          FirebaseFirestore.instance.collection('AllAdmins');
      DocumentReference adminDocument = adminCollection.doc(widget.docId);

      await adminDocument.collection('tax').add({
        'createdAt': DateTime.now().toString(),
        'name': taxNameController.text,
        'totalGst': gstController.text,
        'cGst': cgstController.text,
        'sGst': sgstController.text,
        'iGst': igstController.text,
        'status': selectedRadio == 1 ? 'Active' : 'In-Active',
      });

      _clearControllers();
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        showSuccessSnackBar(context, 'Tax added successfully!');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        showErrorSnackBar(context, 'Error adding tax: $e');
      }
    }
  }

  bool _validateFields() {
    if (taxNameController.text.isEmpty) {
      showWarningSnackBar(context, 'Please enter tax name');
      return false;
    }
    if (gstController.text.isEmpty) {
      showWarningSnackBar(context, 'Please enter total GST percentage');
      return false;
    }
    if (cgstController.text.isEmpty) {
      showWarningSnackBar(context, 'Please enter CGST percentage');
      return false;
    }
    if (sgstController.text.isEmpty) {
      showWarningSnackBar(context, 'Please enter SGST percentage');
      return false;
    }
    if (igstController.text.isEmpty) {
      showWarningSnackBar(context, 'Please enter IGST percentage');
      return false;
    }
    return true;
  }

  void _clearControllers() {
    taxNameController.clear();
    gstController.clear();
    cgstController.clear();
    sgstController.clear();
    igstController.clear();
    selectedRadio = 1;
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
                'Add Tax',
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
              '$imagesPath/tax.gif',
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
                  'Tax Information',
                  style: TextStyle(
                    fontSize: s.scale(22),
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontFamily: 'tabfont',
                  ),
                ),
                SizedBox(height: s.scale(8)),
                Text(
                  'Fill in the tax details below',
                  style: TextStyle(
                    fontSize: s.scale(14),
                    color: Colors.grey[600],
                    fontFamily: 'fontmain',
                  ),
                ),
                SizedBox(height: s.scale(24)),

                // Tax Name Field
                MyTextField(
                  cstmLable: "Tax Name",
                  controller: taxNameController,
                  hintText: 'Enter tax name',
                  prefixIcon: Icons.receipt_long_rounded,
                ),

                SizedBox(height: s.scale(16)),

                // Total GST Field
                MyTextField(
                  cstmLable: "Total GST (%)",
                  controller: gstController,
                  hintText: 'Enter total GST percentage',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.percent_rounded,
                ),

                SizedBox(height: s.scale(16)),

                // CGST Field
                MyTextField(
                  cstmLable: "CGST (%)",
                  controller: cgstController,
                  hintText: 'Enter CGST percentage',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.percent_rounded,
                ),

                SizedBox(height: s.scale(16)),

                // SGST Field
                MyTextField(
                  cstmLable: "SGST (%)",
                  controller: sgstController,
                  hintText: 'Enter SGST percentage',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.percent_rounded,
                ),

                SizedBox(height: s.scale(16)),

                // IGST Field
                MyTextField(
                  cstmLable: "IGST (%)",
                  controller: igstController,
                  hintText: 'Enter IGST percentage',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.percent_rounded,
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
          onTap: addTax,
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
                  'Add Tax',
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

  Widget _buildWebLayout(Screen s) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: const Center(
            child: Text(
              'Add Tax Details',
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

        // Main Content
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
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
                    // Tax Image
                    Center(
                      child: Container(
                        height: 180,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'https://vakilsearch.com/blog/wp-content/uploads/2022/05/INCOME-TAX-RETURNS-3.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Form Fields - Row 1
                    Row(
                      children: [
                        Expanded(
                          child: info("Tax Name", "Enter tax name", context, taxNameController),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: info("Total GST (%)", "Enter GST percentage", context, gstController),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Form Fields - Row 2
                    Row(
                      children: [
                        Expanded(
                          child: info("CGST (%)", "Enter CGST percentage", context, cgstController),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: info("SGST (%)", "Enter SGST percentage", context, sgstController),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Form Fields - Row 3
                    Row(
                      children: [
                        Expanded(
                          child: info("IGST (%)", "Enter IGST percentage", context, igstController),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 11),
                              Row(
                                children: [
                                  _buildWebRadioOption(1, 'Active'),
                                  const SizedBox(width: 16),
                                  _buildWebRadioOption(2, 'In-Active'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                          onTap: addTax,
                          borderRadius: BorderRadius.circular(10),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline, color: Colors.white),
                                SizedBox(width: 12),
                                Text(
                                  'Add Tax',
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

  Widget _buildWebRadioOption(int value, String label) {
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<int>(
              activeColor: primaryColor,
              value: value,
              groupValue: selectedRadio,
              onChanged: handleRadioValueChange,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
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
                  'Saving tax...',
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
