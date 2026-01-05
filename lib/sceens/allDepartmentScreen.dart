import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_network/image_network.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/screen.dart';
import 'package:pos_admin/widgets/utils.dart';

class DepartmentListScreen extends StatefulWidget {
  final String docId;

  const DepartmentListScreen({required this.docId, Key? key}) : super(key: key);

  @override
  State<DepartmentListScreen> createState() => _DepartmentListScreenState();
}

class _DepartmentListScreenState extends State<DepartmentListScreen> {
  String selectedCategory = '';

  Future<void> _deleteDepartment(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('AllAdmins')
          .doc(widget.docId)
          .collection('departments')
          .doc(id)
          .delete();

      if (mounted) {
        showSuccessSnackBar(context, 'Department deleted successfully');
      }
    } catch (e) {
      log('Error deleting department: $e');
      if (mounted) {
        showErrorSnackBar(context, 'Error deleting department: $e');
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
                'All Departments',
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
          .collection('departments')
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
            var department = snapshot.data!.docs[index];
            var data = department.data() as Map<String, dynamic>;
            return _buildDepartmentCard(s, department.id, data);
          },
        );
      },
    );
  }

  Widget _buildDepartmentCard(Screen s, String id, Map<String, dynamic> data) {
    final String name = data['name'] ?? 'Unknown';
    final String status = data['status'] ?? 'Active';
    final String imageUrl = data['imageUrl'] ?? '';
    final bool isActive = status == 'Active';

    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: s.scale(12)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() {
            selectedCategory = name;
          });
        },
        child: Padding(
          padding: EdgeInsets.all(s.scale(12)),
          child: Row(
            children: [
              // Image
              Container(
                width: s.scale(70),
                height: s.scale(70),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.category,
                            color: primaryColor,
                            size: 30,
                          ),
                        )
                      : const Icon(
                          Icons.category,
                          color: primaryColor,
                          size: 30,
                        ),
                ),
              ),
              SizedBox(width: s.scale(12)),

              // Info
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

              // Delete Button
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
        ),
      ),
    );
  }

  Widget _buildEmptyState(Screen s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: s.scale(80),
            color: Colors.grey[300],
          ),
          SizedBox(height: s.scale(16)),
          Text(
            'No departments yet',
            style: TextStyle(
              fontSize: s.scale(18),
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: 'tabfont',
            ),
          ),
          SizedBox(height: s.scale(8)),
          Text(
            'Add your first department to get started',
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
        // Header
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Category List",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  fontFamily: 'tabfont',
                ),
              ),
              if (selectedCategory.isNotEmpty)
                Chip(
                  label: Text(
                    'Showing: $selectedCategory',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: primaryColor,
                  deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onDeleted: () {
                    setState(() {
                      selectedCategory = '';
                    });
                  },
                ),
            ],
          ),
        ),

        // Categories Horizontal List
        SizedBox(
          height: 280,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('AllAdmins')
                  .doc(widget.docId)
                  .collection('departments')
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
                  return const Center(
                    child: Text(
                      'No categories added yet',
                      style: TextStyle(
                        color: grey,
                        fontSize: 16,
                        fontFamily: 'fontmain',
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var department = snapshot.data!.docs[index];
                    var data = department.data() as Map<String, dynamic>;
                    return _buildWebCategoryCard(department.id, data);
                  },
                );
              },
            ),
          ),
        ),

        // Food Items Section
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedCategory.isEmpty ? 'All Items' : '$selectedCategory Items',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'tabfont',
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: selectedCategory.isEmpty
                        ? FirebaseFirestore.instance
                            .collection('AllAdmins')
                            .doc(widget.docId)
                            .collection('foodItems')
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection('AllAdmins')
                            .doc(widget.docId)
                            .collection('foodItems')
                            .where('department', isEqualTo: selectedCategory)
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
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 60,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No items found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontFamily: 'fontmain',
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 320,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var food = snapshot.data!.docs[index];
                          var data = food.data() as Map<String, dynamic>;
                          return _buildFoodItemCard(data);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebCategoryCard(String id, Map<String, dynamic> data) {
    final String name = data['name'] ?? 'Unknown';
    final String imageUrl = data['imageUrl'] ?? '';
    final bool isSelected = selectedCategory == name;

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedCategory = isSelected ? '' : name;
          });
        },
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 200,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(75),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(75),
                      child: imageUrl.isNotEmpty
                          ? ImageNetwork(
                              image: imageUrl,
                              imageCache: CachedNetworkImageProvider(imageUrl),
                              height: 150,
                              width: 150,
                              fitWeb: BoxFitWeb.cover,
                              onLoading: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.category,
                                size: 50,
                                color: primaryColor,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => _showDeleteConfirmationDialog(context, id),
                      child: Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: errorColor,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? primaryColor : Colors.black87,
                  fontFamily: 'tabfont',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodItemCard(Map<String, dynamic> data) {
    final String name = data['name'] ?? 'Unknown';
    final String description = data['description'] ?? '';
    final String price = data['price'] ?? '0';
    final String foodCode = data['foodCode'] ?? '';

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://img.lovepik.com/photo/50077/4812.jpg_wh860.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'fontmain',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: successColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '4.0',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.star, size: 12, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                color: grey,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹$price',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  foodCode,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
                'Delete Department',
                style: TextStyle(fontFamily: 'tabfont'),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this department? This action cannot be undone.',
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
                _deleteDepartment(id);
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
