import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/screen.dart';
import 'package:pos_admin/widgets/utils.dart';

class AllCustomerScreen extends StatefulWidget {
  final String adminUid;

  const AllCustomerScreen({required this.adminUid, Key? key}) : super(key: key);

  @override
  State<AllCustomerScreen> createState() => _AllCustomerScreenState();
}

class _AllCustomerScreenState extends State<AllCustomerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                'All Customers',
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
    return Column(
      children: [
        // Search Bar
        Container(
          padding: EdgeInsets.all(s.scale(16)),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              cursorColor: primaryColor,
              style: TextStyle(fontSize: s.scale(16)),
              decoration: InputDecoration(
                hintText: 'Search customers...',
                hintStyle: const TextStyle(color: grey),
                prefixIcon: const Icon(Icons.search, color: primaryColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: s.scale(16),
                  vertical: s.scale(14),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),

        // Customer List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('AllAdmins')
                .doc(widget.adminUid)
                .collection('customer')
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

              var customers = snapshot.data!.docs.where((doc) {
                if (_searchQuery.isEmpty) return true;
                var data = doc.data() as Map<String, dynamic>;
                var name = (data['name'] ?? '').toString().toLowerCase();
                var phone = (data['phoneNumber'] ?? '').toString().toLowerCase();
                var code = (data['customerCode'] ?? '').toString().toLowerCase();
                return name.contains(_searchQuery) ||
                    phone.contains(_searchQuery) ||
                    code.contains(_searchQuery);
              }).toList();

              if (customers.isEmpty) {
                return _buildNoResultsState(s);
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(s.scale(16)),
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  var customer = customers[index];
                  var data = customer.data() as Map<String, dynamic>;
                  return _buildCustomerCard(s, customer.id, data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerCard(Screen s, String customerId, Map<String, dynamic> data) {
    final String name = data['name'] ?? 'Unknown';
    final String phone = data['phoneNumber'] ?? '';
    final String code = data['customerCode'] ?? '';
    final String email = data['email'] ?? '';

    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: s.scale(12)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          // View customer details
        },
        child: Padding(
          padding: EdgeInsets.all(s.scale(12)),
          child: Row(
            children: [
              // Avatar
              Container(
                width: s.scale(60),
                height: s.scale(60),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    '$imagesPath/account.gif',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: s.scale(12)),

              // Customer Info
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
                    Row(
                      children: [
                        Icon(Icons.badge_outlined, size: s.scale(14), color: grey),
                        SizedBox(width: s.scale(4)),
                        Text(
                          'Code: $code',
                          style: TextStyle(
                            fontSize: s.scale(13),
                            fontFamily: 'fontmain',
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: s.scale(2)),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: s.scale(14), color: grey),
                        SizedBox(width: s.scale(4)),
                        Text(
                          phone,
                          style: TextStyle(
                            fontSize: s.scale(13),
                            fontFamily: 'fontmain',
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    if (email.isNotEmpty) ...[
                      SizedBox(height: s.scale(2)),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, size: s.scale(14), color: grey),
                          SizedBox(width: s.scale(4)),
                          Expanded(
                            child: Text(
                              email,
                              style: TextStyle(
                                fontSize: s.scale(13),
                                fontFamily: 'fontmain',
                                color: Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
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
                onPressed: () => _showDeleteConfirmationDialog(context, customerId),
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
            Icons.people_outline,
            size: s.scale(80),
            color: Colors.grey[300],
          ),
          SizedBox(height: s.scale(16)),
          Text(
            'No customers yet',
            style: TextStyle(
              fontSize: s.scale(18),
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: 'tabfont',
            ),
          ),
          SizedBox(height: s.scale(8)),
          Text(
            'Add your first customer to get started',
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

  Widget _buildNoResultsState(Screen s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: s.scale(80),
            color: Colors.grey[300],
          ),
          SizedBox(height: s.scale(16)),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: s.scale(18),
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: 'tabfont',
            ),
          ),
          SizedBox(height: s.scale(8)),
          Text(
            'Try a different search term',
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
                "Customer's List",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  fontFamily: 'tabfont',
                ),
              ),
              // Search Bar
              SizedBox(
                width: 300,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    cursorColor: primaryColor,
                    decoration: const InputDecoration(
                      hintText: 'Search customers...',
                      hintStyle: TextStyle(color: grey),
                      prefixIcon: Icon(Icons.search, color: primaryColor),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Table Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                SizedBox(width: 16),
                SizedBox(
                  width: 50,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Phone Number',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Joining Date',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Actions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(width: 16),
              ],
            ),
          ),
        ),

        // Table Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('AllAdmins')
                  .doc(widget.adminUid)
                  .collection('customer')
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

                var customers = snapshot.data!.docs.where((doc) {
                  if (_searchQuery.isEmpty) return true;
                  var data = doc.data() as Map<String, dynamic>;
                  var name = (data['name'] ?? '').toString().toLowerCase();
                  var phone = (data['phoneNumber'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) || phone.contains(_searchQuery);
                }).toList();

                if (customers.isEmpty) {
                  return _buildNoResultsState(s);
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    var customer = customers[index];
                    var data = customer.data() as Map<String, dynamic>;
                    return _buildWebCustomerRow(customer.id, data);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebCustomerRow(String customerId, Map<String, dynamic> data) {
    final String name = data['name'] ?? 'Unknown';
    final String phone = data['phoneNumber'] ?? '';
    final String email = data['email'] ?? '';
    final String createdAt = data['createdAt'] ?? '';

    return Container(
      height: 55,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                fontFamily: 'fontmain',
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              phone,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              email,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(createdAt),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: errorColor),
                onPressed: () => _showDeleteConfirmationDialog(context, customerId),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr.length > 10 ? dateStr.substring(0, 10) : dateStr;
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String customerId) {
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
                'Delete Customer',
                style: TextStyle(fontFamily: 'tabfont'),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this customer? This action cannot be undone.',
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
                _deleteCustomer(customerId);
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

  Future<void> _deleteCustomer(String customerId) async {
    try {
      await _firestore
          .collection('AllAdmins')
          .doc(widget.adminUid)
          .collection('customer')
          .doc(customerId)
          .delete();

      if (mounted) {
        showSuccessSnackBar(context, 'Customer deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Error deleting customer: $e');
      }
    }
  }
}
