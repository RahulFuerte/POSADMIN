import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_admin/screen.dart';
import 'package:pos_admin/widgets/utils.dart';

import '../constants/colors.dart';

class TransferDataScreen extends StatefulWidget {
  const TransferDataScreen({Key? key}) : super(key: key);

  @override
  State<TransferDataScreen> createState() => _TransferDataScreenState();
}

class _TransferDataScreenState extends State<TransferDataScreen> {
  String? fromAdminUid;
  String? toAdminUid;
  String? fromAdminName;
  String? toAdminName;
  List<Map<String, dynamic>> adminsList = [];
  bool isLoading = false;
  bool isTransferring = false;

  @override
  void initState() {
    super.initState();
    fetchAdmins();
  }

  Future<void> fetchAdmins() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('AllAdmins').get();

      List<Map<String, dynamic>> tempList = [];
      for (var doc in snapshot.docs) {
        tempList.add({
          'name': doc['name'],
          'uID': doc['uID'],
        });
      }

      setState(() {
        adminsList = tempList;
        isLoading = false;
      });
    } catch (e) {
      log('Error fetching admins: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        showErrorSnackBar(context, 'Error fetching admins: $e');
      }
    }
  }

  Future<void> transferData() async {
    if (fromAdminUid == null || toAdminUid == null) {
      showWarningSnackBar(context, 'Please select both admins');
      return;
    }

    if (fromAdminUid == toAdminUid) {
      showWarningSnackBar(context, 'Cannot transfer to the same admin');
      return;
    }

    setState(() {
      isTransferring = true;
    });

    try {
      QuerySnapshot foodItemsSnapshot = await FirebaseFirestore.instance
          .collection('AllAdmins')
          .doc(fromAdminUid)
          .collection('foodItems')
          .get();

      if (foodItemsSnapshot.docs.isEmpty) {
        if (mounted) {
          showWarningSnackBar(context, 'No food items found to transfer');
        }
        setState(() {
          isTransferring = false;
        });
        return;
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();
      int count = 0;

      for (var doc in foodItemsSnapshot.docs) {
        DocumentReference destRef = FirebaseFirestore.instance
            .collection('AllAdmins')
            .doc(toAdminUid)
            .collection('foodItems')
            .doc(doc.id);

        batch.set(destRef, doc.data());
        count++;

        if (count >= 500) {
          await batch.commit();
          batch = FirebaseFirestore.instance.batch();
          count = 0;
        }
      }

      if (count > 0) {
        await batch.commit();
      }

      setState(() {
        isTransferring = false;
        fromAdminUid = null;
        toAdminUid = null;
        fromAdminName = null;
        toAdminName = null;
      });

      if (mounted) {
        showSuccessSnackBar(
          context,
          'Successfully transferred ${foodItemsSnapshot.docs.length} items from $fromAdminName to $toAdminName',
        );
      }
    } catch (e) {
      log('Error transferring data: $e');
      setState(() {
        isTransferring = false;
      });
      if (mounted) {
        showErrorSnackBar(context, 'Error transferring data: $e');
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
          'Transfer Data',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            fontFamily: 'tabfont',
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(s.isMobile ? s.scale(20) : 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.swap_horiz_rounded,
                                        color: primaryColor,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Transfer Food Items',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'tabfont',
                                              color: primaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Move items between admin accounts',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: grey,
                                              fontFamily: 'fontmain',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // From Admin Section
                        _buildDropdownSection(
                          title: 'From Admin',
                          subtitle: 'Select source admin',
                          icon: Icons.person_outline,
                          value: fromAdminUid,
                          hint: 'Select source admin',
                          onChanged: (value) {
                            setState(() {
                              fromAdminUid = value;
                              fromAdminName = adminsList.firstWhere(
                                  (admin) => admin['uID'] == value)['name'];
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Arrow Icon
                        const Center(
                          child: Icon(
                            Icons.arrow_downward_rounded,
                            color: primaryColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // To Admin Section
                        _buildDropdownSection(
                          title: 'To Admin',
                          subtitle: 'Select destination admin',
                          icon: Icons.person,
                          value: toAdminUid,
                          hint: 'Select destination admin',
                          onChanged: (value) {
                            setState(() {
                              toAdminUid = value;
                              toAdminName = adminsList.firstWhere(
                                  (admin) => admin['uID'] == value)['name'];
                            });
                          },
                        ),
                        const SizedBox(height: 40),

                        // Transfer Button
                        _buildTransferButton(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required String? value,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryColor, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'tabfont',
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: grey,
                        fontFamily: 'fontmain',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  hint: Text(
                    hint,
                    style: const TextStyle(color: grey),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: primaryColor),
                  items: adminsList.map((admin) {
                    return DropdownMenuItem<String>(
                      value: admin['uID'],
                      child: Text(
                        admin['name'],
                        style: const TextStyle(
                          fontFamily: 'fontmain',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferButton() {
    return Container(
      width: double.infinity,
      height: 56,
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
          onTap: isTransferring ? null : transferData,
          child: Center(
            child: isTransferring
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swap_horiz_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Transfer Data',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
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
}
