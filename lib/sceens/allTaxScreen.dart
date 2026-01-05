import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/screen.dart';
import 'package:pos_admin/widgets/utils.dart';

class TaxListScreen extends StatefulWidget {
  final String docId;

  const TaxListScreen({required this.docId, Key? key}) : super(key: key);

  @override
  State<TaxListScreen> createState() => _TaxListScreenState();
}

class _TaxListScreenState extends State<TaxListScreen> {
  Future<void> _deleteTax(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('AllAdmins')
          .doc(widget.docId)
          .collection('tax')
          .doc(id)
          .delete();

      if (mounted) {
        showSuccessSnackBar(context, 'Tax deleted successfully');
      }
    } catch (e) {
      log('Error deleting tax: $e');
      if (mounted) {
        showErrorSnackBar(context, 'Error deleting tax: $e');
      }
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
                'All Taxes',
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
      body: s.isMobile ? _buildMobileLayout(s) : _buildWebLayout(s),
    );
  }

  Widget _buildMobileLayout(Screen s) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('AllAdmins')
          .doc(widget.docId)
          .collection('tax')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(s);
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(s.scale(16)),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var tax = snapshot.data!.docs[index];
            var data = tax.data() as Map<String, dynamic>;
            return _buildTaxCard(s, tax.id, data);
          },
        );
      },
    );
  }

  Widget _buildTaxCard(Screen s, String id, Map<String, dynamic> data) {
    final String name = data['name'] ?? 'Unknown';
    final String status = data['status'] ?? 'Active';
    final String totalGst = data['totalGst'] ?? '0';
    final String cgst = data['cGst'] ?? '0';
    final String sgst = data['sGst'] ?? '0';
    final bool isActive = status == 'Active';

    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: s.scale(12)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(s.scale(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: s.scale(50),
                  height: s.scale(50),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: s.scale(28),
                  ),
                ),
                SizedBox(width: s.scale(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: s.scale(17),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'tabfont',
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: s.scale(4)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: s.scale(8),
                          vertical: s.scale(4),
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? successColor.withOpacity(0.1)
                              : warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive ? successColor : warningColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: s.scale(12),
                            fontWeight: FontWeight.w500,
                            color: isActive ? successColor : warningColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: errorColor,
                    size: s.scale(24),
                  ),
                  onPressed: () => _showDeleteConfirmationDialog(context, id),
                ),
              ],
            ),
            SizedBox(height: s.scale(16)),
            Container(
              padding: EdgeInsets.all(s.scale(12)),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTaxDetail(s, 'Total GST', '$totalGst%'),
                  _buildTaxDetail(s, 'CGST', '$cgst%'),
                  _buildTaxDetail(s, 'SGST', '$sgst%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxDetail(Screen s, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: s.scale(12),
            color: grey,
            fontFamily: 'fontmain',
          ),
        ),
        SizedBox(height: s.scale(4)),
        Text(
          value,
          style: TextStyle(
            fontSize: s.scale(16),
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Screen s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: s.scale(80),
            color: Colors.grey[300],
          ),
          SizedBox(height: s.scale(16)),
          Text(
            'No taxes added yet',
            style: TextStyle(
              fontSize: s.scale(18),
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: 'tabfont',
            ),
          ),
          SizedBox(height: s.scale(8)),
          Text(
            'Add your first tax configuration',
            style: TextStyle(
              fontSize: s.scale(14),
              color: Colors.grey[500],
              fontFamily: 'fontmain',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout(Screen s) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: const Row(
            children: [
              Text(
                "All Tax List",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  fontFamily: 'tabfont',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('AllAdmins')
                  .doc(widget.docId)
                  .collection('tax')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(s);
                }

                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 350,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var tax = snapshot.data!.docs[index];
                    var data = tax.data() as Map<String, dynamic>;
                    return _buildWebTaxCard(tax.id, data);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebTaxCard(String id, Map<String, dynamic> data) {
    final String name = data['name'] ?? 'Unknown';
    final String status = data['status'] ?? 'Active';
    final String totalGst = data['totalGst'] ?? '0';
    final String cgst = data['cGst'] ?? '0';
    final String sgst = data['sGst'] ?? '0';
    final bool isActive = status == 'Active';

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://premiatnc.com/vn/wp-content/uploads/2022/08/income-tax-in-Vietnam-for-foreigners-.jpeg',
                ),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'tabfont',
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? successColor : warningColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildWebTaxDetail('GST', '$totalGst%'),
                      _buildWebTaxDetail('CGST', '$cgst%'),
                      _buildWebTaxDetail('SGST', '$sgst%'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _showDeleteConfirmationDialog(context, id),
                    icon: const Icon(Icons.delete_outline, color: errorColor),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: errorColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebTaxDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: grey,
            fontFamily: 'fontmain',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: warningColor),
              SizedBox(width: 8),
              Text(
                'Delete Tax',
                style: TextStyle(fontFamily: 'tabfont'),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this tax? This action cannot be undone.',
            style: TextStyle(fontFamily: 'fontmain'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: errorColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTax(id);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
