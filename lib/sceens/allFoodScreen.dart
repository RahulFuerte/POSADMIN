import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/sceens/edit_itemScreen.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AllFoodsScreen extends StatefulWidget {
  final String documentId;

  AllFoodsScreen({required this.documentId});

  @override
  State<AllFoodsScreen> createState() => _AllFoodsScreenState();
}

class _AllFoodsScreenState extends State<AllFoodsScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String searchQuery = '';

  // Helper method to safely convert values to String
  String _toStringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  Future<void> _deleteItem(String itemId) async {
    try {
      await FirebaseFirestore.instance.collection('AllAdmins').doc(widget.documentId).collection('foodItems').doc(itemId).delete();

      Fluttertoast.showToast(
        msg: 'Item deleted successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print('Error deleting item: $e');
      Fluttertoast.showToast(
        msg: 'Error deleting item. Please try again!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _navigateToEditScreen(DocumentSnapshot foodItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemScreen(
          uid: widget.documentId,
          foodItemId: foodItem.id,
          foodItemData: foodItem.data() as Map<String, dynamic>,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: MediaQuery.of(context).size.width < 600 ? _buildMobileView() : _buildWebView(),
    );
  }

  Widget _buildMobileView() {
    return Column(
      children: [
        // Enhanced Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
              )
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 25),
              const Text(
                "All Products",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search, color: primaryColor),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('AllAdmins').doc(widget.documentId).collection('foodItems').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                var documents = snapshot.data!.docs;

                // Filter documents based on search query
                if (searchQuery.isNotEmpty) {
                  documents = documents.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String name = _toStringValue(data['name']).toLowerCase();
                    String code = _toStringValue(data['foodCode']).toLowerCase();
                    return name.contains(searchQuery) || code.contains(searchQuery);
                  }).toList();
                }

                if (documents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty ? 'No products found.' : 'No matching products.',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    var data = documents[index].data() as Map<String, dynamic>;
                    return EnhancedFoodItemWidget(
                      imagePath: _toStringValue(data['imagePath']),
                      name: _toStringValue(data['name']),
                      foodCode: _toStringValue(data['foodCode']),
                      price: _toStringValue(data['price']),
                      department: _toStringValue(data['department']),
                      description: _toStringValue(data['description']),
                      stocks: _toStringValue(data['stocks']),
                      onDelete: () {
                        _deleteItem(documents[index].id);
                      },
                      onEdit: () {
                        _navigateToEditScreen(documents[index]);
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWebView() {
    return Column(
      children: [
        // Enhanced Header for Web
        Container(
          width: MediaQuery.of(context).size.width - MediaQuery.of(context).size.width / 6,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "All Product's Inventory",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Container(
                width: 350,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name or code...',
                    prefixIcon: const Icon(Icons.search, color: primaryColor),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 41),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('AllAdmins').doc(widget.documentId).collection('foodItems').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var documents = snapshot.data!.docs;

                // Filter documents based on search query
                if (searchQuery.isNotEmpty) {
                  documents = documents.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String name = _toStringValue(data['name']).toLowerCase();
                    String code = _toStringValue(data['foodCode']).toLowerCase();
                    return name.contains(searchQuery) || code.contains(searchQuery);
                  }).toList();
                }

                if (documents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey),
                        const SizedBox(height: 20),
                        Text(
                          searchQuery.isEmpty ? 'No products available.' : 'No matching products found.',
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ResponsiveGridList(
                  horizontalGridSpacing: 30,
                  horizontalGridMargin: 10,
                  verticalGridSpacing: 30,
                  minItemWidth: 320,
                  minItemsPerRow: 1,
                  maxItemsPerRow: 3,
                  listViewBuilderOptions: ListViewBuilderOptions(),
                  children: List.generate(documents.length, (index) {
                    final DocumentSnapshot food = documents[index];
                    var data = food.data() as Map<String, dynamic>;

                    return EnhancedWebFoodCard(
                      food: food,
                      data: data,
                      onDelete: () {
                        _deleteItem(food.id);
                      },
                      onEdit: () {
                        _navigateToEditScreen(food);
                      },
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Enhanced Mobile Food Item Widget
class EnhancedFoodItemWidget extends StatelessWidget {
  final String imagePath;
  final String name;
  final String foodCode;
  final String price;
  final String department;
  final String description;
  final String stocks;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const EnhancedFoodItemWidget({
    required this.imagePath,
    required this.name,
    required this.foodCode,
    required this.price,
    required this.department,
    required this.description,
    required this.stocks,
    required this.onDelete,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        height: 140,
        child: Row(
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
              child: Container(
                width: 120,
                child: CachedNetworkImage(
                  imageUrl: imagePath,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
            // Details Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: "tabfont",
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Code: $foodCode',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontFamily: "fontmain",
                          ),
                        ),
                        Text(
                          'Price: Rs $price',
                          style: const TextStyle(
                            fontSize: 14,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontFamily: "fontmain",
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            department,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          'Stock: $stocks',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Action Buttons
            Container(
              width: 60,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(.25),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 22),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                  Divider(color: Colors.grey[300], thickness: 1),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                    onPressed: () => _showDeleteDialog(context),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 10),
              Text("Delete Item"),
            ],
          ),
          content: Text("Are you sure you want to delete '$name'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onDelete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}

// Enhanced Web Food Card
class EnhancedWebFoodCard extends StatelessWidget {
  final DocumentSnapshot food;
  final Map<String, dynamic> data;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const EnhancedWebFoodCard({
    required this.food,
    required this.data,
    required this.onDelete,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  // Helper method to safely convert values to String
  String _toStringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        height: 380,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section with Action Buttons
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Container(
                    height: 220,
                    child: CachedNetworkImage(
                      imageUrl: _toStringValue(data['imagePath']),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fastfood, size: 60, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('No Image', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Action Buttons Overlay
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                            )
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: primaryColor, size: 20),
                          onPressed: onEdit,
                          tooltip: 'Edit Item',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                            )
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _showDeleteDialog(context),
                          tooltip: 'Delete Item',
                        ),
                      ),
                    ],
                  ),
                ),
                // Stock Badge
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Stock: ${_toStringValue(data['stocks'])}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Details Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _toStringValue(data['name']),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 31, 120, 34),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    '4.0',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(Icons.star, size: 12, color: Colors.white),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _toStringValue(data['description']),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _toStringValue(data['department']),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              'Rs ${_toStringValue(data['price'])}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Code: ${_toStringValue(data['foodCode'])}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Text("Delete Item"),
            ],
          ),
          content: Text(
            "Are you sure you want to delete '${data['name']}'? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onDelete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
