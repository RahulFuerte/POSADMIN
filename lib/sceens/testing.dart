import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class YourWidget extends StatefulWidget {
  final String uid;

  YourWidget({required this.uid});

  @override
  _YourWidgetState createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
  late FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _firestore.collection('AllAdmin').doc(widget.uid).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data()!;

        // Assuming your document structure has 'name', 'email', and 'phone' fields
        String name = data['name'];
        String email = data['email'];
        String phone = data['phone'];

        // Now you can display the fetched data in your UI or use it as needed
        print('Name: $name');
        print('Email: $email');
        print('Phone: $phone');
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Widget'),
      ),
      body: Center(
        child: Text('Display your data here'),
      ),
    );
  }
}
