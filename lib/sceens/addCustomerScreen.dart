import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/screen.dart';
import 'package:pos_admin/widgets/utils.dart';

class AddCustomerScreen extends StatefulWidget {
  final String uid;
  const AddCustomerScreen({required this.uid, super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerCodeController = TextEditingController();
  final TextEditingController customerPhoneController = TextEditingController();
  final TextEditingController customerEmailController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    customerNameController.dispose();
    customerCodeController.dispose();
    customerPhoneController.dispose();
    customerEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Screen s = Screen(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: s.isMobile
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: primaryColor),
                onPressed: () {
                  _clearControllers();
                  Navigator.of(context).pop();
                },
              ),
              title: const Text(
                'Add Customer',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          if (didPop) {
            _clearControllers();
          }
        },
        child: s.isMobile
            ? _buildMobileLayout(s)
            : _buildDesktopLayout(s),
      ),
    );
  }

  /// Builds the mobile layout with responsive scaling.
  /// Requirement 10.3: Scale text and padding using customWidth multiplier.
  Widget _buildMobileLayout(Screen s) {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
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
                  "$imagesPath/customer.gif",
                  height: s.scale(180),
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
                      'Customer Information',
                      style: TextStyle(
                        fontSize: s.scale(22),
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: s.scale(8)),
                    Text(
                      'Fill in the details below to add a new customer',
                      style: TextStyle(
                        fontSize: s.scale(14),
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: s.scale(24)),

                    // Customer Code Field
                    _buildModernTextField(
                      controller: customerCodeController,
                      label: 'Customer Code',
                      hint: 'Enter 5-digit code',
                      icon: Icons.qr_code_rounded,
                      maxLength: 5,
                      keyboardType: TextInputType.number,
                      screen: s,
                    ),

                    SizedBox(height: s.scale(20)),

                    // Customer Name Field
                    _buildModernTextField(
                      controller: customerNameController,
                      label: 'Customer Name',
                      hint: 'Enter full name',
                      icon: Icons.person_outline_rounded,
                      screen: s,
                    ),

                    SizedBox(height: s.scale(20)),

                    // Phone Number Field
                    _buildModernTextField(
                      controller: customerPhoneController,
                      label: 'Mobile Number',
                      hint: 'Enter 10-digit number',
                      icon: Icons.phone_outlined,
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
                      prefix: '+91 ',
                      screen: s,
                    ),

                    SizedBox(height: s.scale(20)),

                    // Email Field
                    _buildModernTextField(
                      controller: customerEmailController,
                      label: 'Email Address',
                      hint: 'Enter email address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      screen: s,
                    ),
                    SizedBox(height: s.scale(32)),
                    _buildSubmitButton(s),

                    SizedBox(height: s.scale(32)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Loading Overlay
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Screen screen,
    int? maxLength,
    TextInputType? keyboardType,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screen.scale(15),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: screen.scale(8)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLength: maxLength,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: screen.scale(16),
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: primaryColor,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.grey[400],
              ),
              prefixIcon: Icon(icon, color: primaryColor, size: screen.scale(22)),
              prefixText: prefix,
              prefixStyle: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: screen.scale(16),
              ),
              counterText: '',
              contentPadding: EdgeInsets.symmetric(
                horizontal: screen.scale(16),
                vertical: screen.scale(16),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(Screen s) {
    return Container(
      width: double.infinity,
      height: s.scale(56),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
          onTap: _handleSubmit,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: s.scale(24),
                ),
                SizedBox(width: s.scale(12)),
                Text(
                  'Add Customer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: s.scale(18),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(Screen s) {
    return ListView(
      children: [
        Container(
          width: MediaQuery.of(context).size.width -
              MediaQuery.of(context).size.width / 6,
          height: 55,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: const Center(
            child: Text(
              'Add Customer Details here',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 23,
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 120,
              width: MediaQuery.of(context).size.width / 3.1,
              color: Colors.grey.withOpacity(0.2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  info("Customer code", "Enter code here", context,
                      customerCodeController),
                  info("Customer name", "enter customer name here", context,
                      customerNameController),
                  info("Mobile number", "Enter mobile number", context,
                      customerPhoneController),
                  info("Email", "enter email here", context,
                      customerEmailController),
                  Container(
                    height: 51,
                    width: MediaQuery.of(context).size.width / 3.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: primaryColor,
                    ),
                    child: MaterialButton(
                      onPressed: _handleSubmit,
                      height: 50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Add customer',
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
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleSubmit() {
    final String customerName = customerNameController.text.trim();
    final String customerCode = customerCodeController.text.trim();
    final String customerPhone = customerPhoneController.text.trim();
    final String customerEmail = customerEmailController.text.trim();

    if (customerName.isEmpty ||
        customerCode.isEmpty ||
        customerPhone.isEmpty ||
        customerEmail.isEmpty) {
      showSnackBar(context, "Please fill all fields");
      return;
    }

    if (customerPhone.length != 10) {
      showSnackBar(context, "Please enter a valid 10-digit phone number");
      return;
    }

    if (customerCode.length != 5) {
      showSnackBar(context, "Customer code must be 5 digits");
      return;
    }

    if (!customerEmail.contains('@') || !customerEmail.contains('.')) {
      showSnackBar(context, "Please enter a valid email address");
      return;
    }

    addCustomer(customerName, customerPhone, customerCode, customerEmail);
  }

  void _clearControllers() {
    customerNameController.clear();
    customerCodeController.clear();
    customerPhoneController.clear();
    customerEmailController.clear();
  }

  Future<void> addCustomer(
      String name, String phoneNumber, String code, String email) async {
    setState(() {
      isLoading = true;
    });

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? adminUser = auth.currentUser;

    if (adminUser != null) {
      final CollectionReference adminsCollection =
          FirebaseFirestore.instance.collection('AllAdmins');

      try {
        final DocumentReference adminDoc = adminsCollection.doc(widget.uid);

        final CollectionReference vendorsCollection =
            FirebaseFirestore.instance.collection('AllCustomer');

        final DocumentReference vendorDoc =
            vendorsCollection.doc('+91$phoneNumber');

        final vendorData = {
          'createdAt': DateTime.now().toString(),
          'name': name,
          'phoneNumber': '+91$phoneNumber',
          'adminUid': widget.uid,
          'customerCode': code,
          'email': email,
        };

        await vendorDoc.set(vendorData);

        final vendorId = vendorDoc.id;

        final vendorSubcollection = adminDoc.collection('customer');
        await vendorSubcollection.doc(vendorId).set(vendorData);

        setState(() {
          isLoading = false;
        });

        if (mounted) {
          showSnackBar(context, "Customer added successfully!");
          _clearControllers();
          Navigator.of(context).pop();
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          showSnackBar(context, "Error adding customer: $e");
        }
      }
    } else {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        showSnackBar(context, "Admin user not authenticated");
      }
    }
  }
}

Widget info(String name, String name2, BuildContext context, control) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17.0,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 11),
        SizedBox(
          height: 50,
          width: MediaQuery.of(context).size.width / 3.5,
          child: Card(
            elevation: 5,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: TextField(
                controller: control,
                cursorColor: Colors.black,
                style: const TextStyle(
                  fontSize: 18.2,
                  letterSpacing: 1,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
