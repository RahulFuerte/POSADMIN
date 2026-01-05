import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/sceens/addCustomerScreen.dart';
import 'package:pos_admin/sceens/addDepartmentScreen.dart';
import 'package:pos_admin/sceens/addItemScreen.dart';
import 'package:pos_admin/sceens/addTaxScreen.dart';
import 'package:pos_admin/sceens/allCustomerScreen.dart';
import 'package:pos_admin/sceens/allDepartmentScreen.dart';
import 'package:pos_admin/sceens/allFoodScreen.dart';
import 'package:pos_admin/sceens/allTaxScreen.dart';
import 'package:pos_admin/sceens/inception.dart';
import 'package:pos_admin/sceens/overallbill.dart';
import 'package:pos_admin/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  final String Uid;
  const AdminDashboard({required this.Uid, Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool showMasterSublist = false;
  late FirebaseFirestore _firestore;
  bool isFetched = true;
  String name = '';
  String email = '';
  String phone = '';
  bool dashboard = true;
  bool allcustomers = false;
  bool allcategory = false;
  bool alltaxes = false;
  bool allitems = false;
  bool addcustomer = false;
  bool additems = false;
  bool addtax = false;
  bool addcategory = false;
  bool allreport = false;

  @override
  void initState() {
    super.initState();
    print(widget.Uid);
    _firestore = FirebaseFirestore.instance;
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _firestore.collection('AllAdmins').doc(widget.Uid).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data()!;

        // Assuming your document structure has 'name', 'email', and 'phone' fields
        name = data['name'];
        email = data['email'];
        phone = data['phone'];

        // Now you can display the fetched data in your UI or use it as needed
        print('Name: $name');
        print('Email: $email');
        print('Phone: $phone');
        setState(() {
          isFetched = false;
        });
      } else {
        setState(() {
          isFetched = false;
        });
        print('Document does not exist');
      }
    } catch (e) {
      setState(() {
        isFetched = false;
      });
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Screen s = Screen(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: s.isMobile
          ? AppBar(
              elevation: 0,
              backgroundColor: secondaryColor,
              centerTitle: false,
              title: const Text(
                'POS',
                style: TextStyle(
                  color: black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: errorColor,
                      size: 22,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: errorColor
                                          .withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.logout_rounded,
                                      color: errorColor,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Logout Confirmation",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Are you sure you want to logout?",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                            side: const BorderSide(
                                                color: Color(0xFFE5E7EB)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(
                                              color: Color(0xFF6B7280),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                            backgroundColor:
                                                errorColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            "Logout",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          onPressed: () async {
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            await prefs.setBool(
                                                'isLogged', false);
                                            FirebaseAuth.instance.signOut();
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const Inception(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
              iconTheme: const IconThemeData(color: black),
            )
          : null,
      drawer: Drawer(
        child: Container(
          color: secondaryColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 60, left: 20, bottom: 20),
                decoration: const BoxDecoration(
                  color: primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        color: primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name.isNotEmpty ? name.toUpperCase() : 'Shop Name',
                      style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'tabfont',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone.isNotEmpty ? phone : '',
                      style: TextStyle(
                        color: secondaryColor.withOpacity(0.9),
                        fontSize: 14,
                        fontFamily: 'fontmain',
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(
                icon: Icons.dashboard_rounded,
                title: 'Dashboard',
                isSelected: dashboard,
                onTap: () {
                  Navigator.pop(context);
                  // Dashboard is the default screen, just pop to return
                },
              ),
              _buildDrawerItem(
                icon: Icons.inventory_2_rounded,
                title: 'Master',
                onTap: () {
                  setState(() {
                    showMasterSublist = !showMasterSublist;
                  });
                },
                trailing: Icon(
                  showMasterSublist ? Icons.expand_less : Icons.expand_more,
                  color: grey,
                ),
              ),
              if (showMasterSublist) ...[
                _buildSubDrawerItem(
                  title: 'Customer List',
                  isSelected: allcustomers,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AllCustomerScreen(adminUid: widget.Uid),
                      ),
                    );
                  },
                ),
                _buildSubDrawerItem(
                  title: 'Department List',
                  isSelected: allcategory,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DepartmentListScreen(docId: widget.Uid),
                      ),
                    );
                  },
                ),
                _buildSubDrawerItem(
                  title: 'Tax List',
                  isSelected: alltaxes,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaxListScreen(docId: widget.Uid),
                      ),
                    );
                  },
                ),
              ],
              _buildDrawerItem(
                icon: Icons.assessment_rounded,
                title: 'Reports',
                isSelected: allreport,
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    counter = 6;
                    allcategory = false;
                    dashboard = false;
                    alltaxes = false;
                    allcustomers = false;
                    allitems = false;
                    addcustomer = false;
                    additems = false;
                    addtax = false;
                    addcategory = false;
                    allreport = true;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Requirement 10.2: Use 600px breakpoint consistently
          if (constraints.maxWidth < responsiveBreakpoint) {
            return isFetched
                ? const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  )
                : allcustomers
                    ? AllCustomerScreen(adminUid: widget.Uid)
                    : allcategory
                        ? DepartmentListScreen(docId: widget.Uid)
                        : alltaxes
                            ? TaxListScreen(docId: widget.Uid)
                            : allitems
                                ? AllFoodsScreen(documentId: widget.Uid)
                                : addcustomer
                                    ? AddCustomerScreen(uid: widget.Uid)
                                    : additems
                                        ? AddItemScreen(uid: widget.Uid)
                                        : addtax
                                            ? AddTaxScreen(docId: widget.Uid)
                                            : addcategory
                                                ? AddDepartmentScreen(
                                                    docId: widget.Uid)
                                                : allreport
                                                    ? OverAllReport()
                                                    : _buildDashboardContent(s);
          } else {
            return Container(); // Desktop view remains unchanged
          }
        },
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? primaryColor : const Color(0xFF6B7280),
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                isSelected ? primaryColor : const Color(0xFF1A1A1A),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSubDrawerItem({
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 12, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color:
                isSelected ? primaryColor : const Color(0xFF6B7280),
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                isSelected ? primaryColor : const Color(0xFF1A1A1A),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Builds the dashboard content with responsive scaling.
  /// Requirement 10.3: Scale text and padding using customWidth multiplier.
  Widget _buildDashboardContent(Screen s) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            margin: EdgeInsets.all(s.scale(20)),
            padding: EdgeInsets.all(s.scale(24)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryColor, Color.fromARGB(255, 46, 139, 49)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(s.scale(12)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.waving_hand_rounded,
                    color: Colors.white,
                    size: s.scale(32),
                  ),
                ),
                SizedBox(width: s.scale(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: s.scale(14),
                        ),
                      ),
                      SizedBox(height: s.scale(4)),
                      Text(
                        name.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: s.scale(22),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Quick Actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: s.scale(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: s.scale(20),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: s.scale(16)),
                _buildActionCard(
                  icon: Icons.person_add_rounded,
                  title: 'Add Customer',
                  subtitle: 'Create new customer profile',
                  color: const Color(0xFF10B981),
                  screen: s,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddCustomerScreen(uid: widget.Uid),
                      ),
                    );
                  },
                ),
                SizedBox(height: s.scale(12)),
                _buildActionCard(
                  icon: Icons.shopping_bag_rounded,
                  title: 'Add Item',
                  subtitle: 'Add new product to inventory',
                  color: primaryColor,
                  screen: s,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddItemScreen(uid: widget.Uid),
                      ),
                    );
                  },
                ),
                SizedBox(height: s.scale(12)),
                _buildActionCard(
                  icon: Icons.category_rounded,
                  title: 'Add Category',
                  subtitle: 'Create new department',
                  color: const Color(0xFF3B82F6),
                  screen: s,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddDepartmentScreen(docId: widget.Uid),
                      ),
                    );
                  },
                ),
                SizedBox(height: s.scale(12)),
                _buildActionCard(
                  icon: Icons.edit_rounded,
                  title: 'Edit Items',
                  subtitle: 'Manage your inventory',
                  color: const Color(0xFF8B5CF6),
                  screen: s,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AllFoodsScreen(documentId: widget.Uid),
                      ),
                    );
                  },
                ),
                SizedBox(height: s.scale(12)),
                // _buildActionCard(
                //   icon: Icons.receipt_long_rounded,
                //   title: 'Add Tax',
                //   subtitle: 'Configure tax settings',
                //   color: const Color(0xFFF59E0B),
                //   screen: s,
                //   onTap: () {
                //     setState(() {
                //       counter = 10;
                //       dashboard = false;
                //       allcategory = false;
                //       allcustomers = false;
                //       alltaxes = false;
                //       allitems = false;
                //       addcustomer = false;
                //       additems = false;
                //       addtax = true;
                //       addcategory = false;
                //     });
                //   },
                // ),
              ],
            ),
          ),

          SizedBox(height: s.scale(32)),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required Screen screen,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(screen.scale(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(screen.scale(12)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: screen.scale(24)),
            ),
            SizedBox(width: screen.scale(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screen.scale(16),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: screen.scale(2)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: screen.scale(13),
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: screen.scale(18),
            ),
          ],
        ),
      ),
    );
  }

  int counter = 1;
  dashboardicon(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: MaterialButton(
        onPressed: () {
          index == 1
              ? setState(() {
                  counter = index;
                  allcategory = false;
                  dashboard = true;
                  alltaxes = false;
                  allcustomers = false;
                  allitems = false;
                  addcustomer = false;
                  additems = false;
                  addtax = false;
                  addcategory = false;
                  allreport = false;
                })
              : index == 2
                  ? setState(() {
                      counter = index;
                      alltaxes = false;
                      dashboard = false;
                      allcategory = false;
                      allcustomers = true;
                      allitems = false;
                      addcustomer = false;
                      additems = false;
                      addtax = false;
                      addcategory = false;
                      allreport = false;
                    })
                  : index == 3
                      ? setState(() {
                          counter = index;
                          dashboard = false;
                          allcategory = true;
                          allcustomers = false;
                          alltaxes = false;
                          allitems = false;
                          addcustomer = false;
                          additems = false;
                          addtax = false;
                          addcategory = false;
                          allreport = false;
                        })
                      : index == 4
                          ? setState(() {
                              counter = index;
                              dashboard = false;
                              allcategory = false;
                              allcustomers = false;
                              alltaxes = true;
                              allitems = false;
                              addcustomer = false;
                              additems = false;
                              addtax = false;
                              addcategory = false;
                              allreport = false;
                            })
                          : index == 5
                              ? setState(() {
                                  counter = index;
                                  dashboard = false;
                                  allcategory = false;
                                  allcustomers = false;
                                  alltaxes = false;
                                  allitems = true;
                                  addcustomer = false;
                                  additems = false;
                                  addtax = false;
                                  addcategory = false;
                                  allreport = false;
                                })
                              : setState(() {
                                  counter = index;
                                  dashboard = false;
                                  allcategory = false;
                                  allcustomers = false;
                                  alltaxes = false;
                                  allitems = false;
                                  addcustomer = false;
                                  additems = false;
                                  addtax = false;
                                  addcategory = false;
                                  allreport = true;
                                });
        },
        color: counter == index
            ? primaryColor
            : primaryColor,
        hoverColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: MediaQuery.of(context).size.width < 1000
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    index == 1
                        ? const Icon(
                            Icons.dashboard,
                            color: Colors.white,
                            size: 16,
                          )
                        : index == 2
                            ? const Icon(
                                Icons.verified_user_sharp,
                                color: Colors.white,
                                size: 16,
                              )
                            : index == 3
                                ? const Icon(
                                    Icons.category,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : index == 4
                                    ? const Icon(
                                        Icons.currency_bitcoin,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : index == 5
                                        ? const Icon(
                                            Icons.production_quantity_limits,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        : const Icon(
                                            Icons.list,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                    Text(
                      index == 1
                          ? 'Dashboard'
                          : index == 2
                              ? 'Customer List'
                              : index == 3
                                  ? 'Category List'
                                  : index == 4
                                      ? 'Tax List'
                                      : index == 5
                                          ? 'All-Items'
                                          : 'All Repoprts',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    index == 1
                        ? const Icon(
                            Icons.dashboard,
                            color: Colors.white,
                          )
                        : index == 2
                            ? const Icon(
                                Icons.verified_user_sharp,
                                color: Colors.white,
                              )
                            : index == 3
                                ? const Icon(
                                    Icons.category,
                                    color: Colors.white,
                                  )
                                : index == 4
                                    ? const Icon(
                                        Icons.currency_bitcoin,
                                        color: Colors.white,
                                      )
                                    : index == 5
                                        ? const Icon(
                                            Icons.production_quantity_limits,
                                            color: Colors.white,
                                          )
                                        : const Icon(
                                            Icons.list,
                                            color: Colors.white,
                                          ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        index == 1
                            ? 'Dashboard'
                            : index == 2
                                ? 'Customer List'
                                : index == 3
                                    ? 'Category List'
                                    : index == 4
                                        ? 'Tax List'
                                        : index == 5
                                            ? 'All-Items'
                                            : 'All Repoprts',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
