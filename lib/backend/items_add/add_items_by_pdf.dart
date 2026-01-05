import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';

class SheetalDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String adminUid = "+919974797080";

  // Complete menu data structure with all actual items from PDF
  final Map<String, Map<String, dynamic>> menuData = {
    "Ice Cream Cup - Natural Cup": {
      "category": "Ice Cream Cup",
      "items": [
        {"name": "Tender Coconut", "price": "40", "vol": "80 ml", "code": "1"},
        {"name": "Alphonso Mango", "price": "30", "vol": "80 ml", "code": "2"},
        {"name": "Mixed Fruits", "price": "30", "vol": "80 ml", "code": "3"},
        {"name": "Guava", "price": "30", "vol": "80 ml", "code": "4"},
        {"name": "Jamun", "price": "30", "vol": "80 ml", "code": "5"},
        {"name": "Custard Apple", "price": "30", "vol": "80 ml", "code": "6"},
      ]
    },
    "Ice Cream Cup - Jumbo Cup": {
      "category": "Ice Cream Cup",
      "items": [
        {"name": "Almond Carnival", "price": "40", "vol": "120 ml", "code": "7"},
        {"name": "Chocolate Chips", "price": "30", "vol": "120 ml", "code": "8"},
        {"name": "American Nuts", "price": "30", "vol": "120 ml", "code": "9"},
        {"name": "Creamy Vanilla", "price": "20", "vol": "80 ml", "code": "10"},
      ]
    },
    "Ice Cream Cup - Big Cup": {
      "category": "Ice Cream Cup",
      "items": [
        {"name": "Authentic Kulfi", "price": "50", "vol": "100 ml", "code": "11"},
        {"name": "Creamy Bastani", "price": "40", "vol": "100 ml", "code": "12"},
        {"name": "Triple Chocolate", "price": "40", "vol": "100 ml", "code": "13"},
        {"name": "Sugar Free Kesar Pista", "price": "40", "vol": "100 ml", "code": "14"},
        {"name": "Kaju Draksh", "price": "20", "vol": "80 ml", "code": "15"},
        {"name": "Butterscotch", "price": "20", "vol": "80 ml", "code": "16"},
        {"name": "American Dry Fruits", "price": "20", "vol": "80 ml", "code": "17"},
        {"name": "Sugar Free Vanilla", "price": "30", "vol": "100 ml", "code": "18"},
        {"name": "Kesar Pista", "price": "40", "vol": "100 ml", "code": "19"},
        {"name": "Rajbhog", "price": "40", "vol": "80 ml", "code": "20"},
        {"name": "Mawa Badam", "price": "30", "vol": "80 ml", "code": "21"},
        {"name": "Cookies N Cream", "price": "20", "vol": "80 ml", "code": "22"},
        {"name": "Vanilla", "price": "10", "vol": "50 ml", "code": "23"},
        {"name": "Strawberry", "price": "10", "vol": "50 ml", "code": "24"},
      ]
    },
    "Ice Cream Cup - Ripple": {
      "category": "Ice Cream Cup",
      "items": [
        {"name": "Ripple Funday", "price": "15", "vol": "65 ml", "code": "25"},
        {"name": "Chocolate Cyclone", "price": "20", "vol": "100 ml", "code": "26"},
        {"name": "Fruit Rocking", "price": "20", "vol": "100 ml", "code": "27"},
      ]
    },
    "Kulfi - Stick Kulfi": {
      "category": "Kulfi",
      "items": [
        {"name": "Shahi Kulfi", "price": "50", "vol": "70 ml", "code": "28"},
        {"name": "Anjeer Kulfi", "price": "40", "vol": "60 ml", "code": "29"},
        {"name": "Traditional Kulfi", "price": "30", "vol": "60 ml", "code": "30"},
        {"name": "Sugar Free Kulfi", "price": "30", "vol": "60 ml", "code": "31"},
        {"name": "Kadai Kulfi", "price": "30", "vol": "50 ml", "code": "32"},
        {"name": "Punjabi Di Kulfi", "price": "20", "vol": "50 ml", "code": "33"},
      ]
    },
    "Kulfi - Premium Kulfi": {
      "category": "Kulfi",
      "items": [
        {"name": "Jamun Kulfi", "price": "30", "vol": "60 ml", "code": "34"},
        {"name": "Royal Rabdi Kulfi", "price": "30", "vol": "60 ml", "code": "35"},
        {"name": "Malai Kulfi", "price": "20", "vol": "45 ml", "code": "36"},
        {"name": "Shahi Pista Kulfi", "price": "20", "vol": "45 ml", "code": "37"},
        {"name": "Bombay Chowpati", "price": "30", "vol": "60 ml", "code": "38"},
        {"name": "Masti Chowpati", "price": "20", "vol": "60 ml", "code": "39"},
      ]
    },
    "Candy - Premium Gloria": {
      "category": "Candy",
      "items": [
        {"name": "Almond Truffle", "price": "80", "vol": "70 ml", "code": "40"},
        {"name": "Almond", "price": "70", "vol": "70 ml", "code": "41"},
        {"name": "Frostick", "price": "40", "vol": "70 ml", "code": "42"},
        {"name": "Rajbhog Candy", "price": "40", "vol": "60 ml", "code": "43"},
        {"name": "Almond Chocobar", "price": "30", "vol": "60 ml", "code": "44"},
      ]
    },
    "Candy - Regular": {
      "category": "Candy",
      "items": [
        {"name": "Alphonso Mango", "price": "20", "vol": "50 ml", "code": "45"},
        {"name": "Mini Mega Bite", "price": "20", "vol": "40 ml", "code": "46"},
        {"name": "Choco Sparkle", "price": "20", "vol": "65 ml", "code": "47"},
        {"name": "Classic Chocobar", "price": "20", "vol": "60 ml", "code": "48"},
        {"name": "Premium Mawa Malai", "price": "20", "vol": "55 ml", "code": "49"},
        {"name": "Junior Chocobar", "price": "15", "vol": "35 ml", "code": "50"},
      ]
    },
    "Candy - Kids": {
      "category": "Candy",
      "items": [
        {"name": "Chiku Candy", "price": "10", "vol": "50 ml", "code": "51"},
        {"name": "Crunchy Chocobar", "price": "10", "vol": "35 ml", "code": "52"},
        {"name": "Kid's Chocobar", "price": "10", "vol": "25 ml", "code": "53"},
        {"name": "Chatpati Imli", "price": "10", "vol": "60 ml", "code": "54"},
        {"name": "Kachi Keri", "price": "10", "vol": "50 ml", "code": "55"},
        {"name": "Kala Katta", "price": "10", "vol": "50 ml", "code": "56"},
        {"name": "Lemon Chew", "price": "10", "vol": "50 ml", "code": "57"},
      ]
    },
    "Cone - Premium": {
      "category": "Cone",
      "items": [
        {"name": "Unicone", "price": "70", "vol": "150 ml", "code": "58"},
        {"name": "Boltop", "price": "60", "vol": "135 ml", "code": "59"},
        {"name": "American Nuts", "price": "60", "vol": "135 ml", "code": "60"},
        {"name": "Dark Choco Fantasy", "price": "60", "vol": "135 ml", "code": "61"},
      ]
    },
    "Cone - Disc Cone": {
      "category": "Cone",
      "items": [
        {"name": "Kesar Pista", "price": "40", "vol": "110 ml", "code": "62"},
        {"name": "Cappuccino", "price": "30", "vol": "100 ml", "code": "63"},
      ]
    },
    "Cone - Classic": {
      "category": "Cone",
      "items": [
        {"name": "Nutty Butterscotch", "price": "30", "vol": "110 ml", "code": "64"},
        {"name": "Kaju Draksh", "price": "25", "vol": "100 ml", "code": "65"},
        {"name": "Kesar", "price": "20", "vol": "100 ml", "code": "66"},
        {"name": "2 in One", "price": "20", "vol": "100 ml", "code": "67"},
      ]
    },
    "Cone - Junior": {
      "category": "Cone",
      "items": [
        {"name": "Choco Daddy", "price": "20", "vol": "100 ml", "code": "68"},
        {"name": "Butter Caramel", "price": "15", "vol": "90 ml", "code": "69"},
        {"name": "Junior Chocolate", "price": "10", "vol": "50 ml", "code": "70"},
      ]
    },
    "Novelty - Sundae": {
      "category": "Novelty",
      "items": [
        {"name": "Triple Sundae", "price": "60", "vol": "120 ml", "code": "71"},
        {"name": "Single Sundae", "price": "50", "vol": "100 ml", "code": "72"},
      ]
    },
    "Novelty - Matka": {
      "category": "Novelty",
      "items": [
        {"name": "Matka Kulfi", "price": "50", "vol": "80 ml", "code": "73"},
        {"name": "Rajasthani Matka", "price": "60", "vol": "100 ml", "code": "74"},
        {"name": "Ras Malai Matka", "price": "60", "vol": "100 ml", "code": "75"},
        {"name": "Pista Malai Matka", "price": "70", "vol": "100 ml", "code": "76"},
      ]
    },
    "Novelty - Cassata": {
      "category": "Novelty",
      "items": [
        {"name": "Slice Cassata", "price": "40", "vol": "100 ml", "code": "77"},
        {"name": "Classic Cassata", "price": "50", "vol": "120 ml", "code": "78"},
        {"name": "Traditional Cassata", "price": "70", "vol": "120 ml", "code": "79"},
      ]
    },
    "Novelty - Roll Cut": {
      "category": "Novelty",
      "items": [
        {"name": "Nutty Roll Cut", "price": "40", "vol": "80 ml", "code": "80"},
      ]
    },
    "Novelty - Sandwich": {
      "category": "Novelty",
      "items": [
        {"name": "Cookies Sandwich", "price": "40", "vol": "125 ml", "code": "81"},
        {"name": "Sandwich", "price": "30", "vol": "100 ml", "code": "82"},
      ]
    },
    "Cake - Ice Cream Cake": {
      "category": "Cake",
      "items": [
        {"name": "Golden Fantasy Cake", "price": "550", "vol": "1 Ltr", "code": "83"},
        {"name": "Black Forest Cake", "price": "530", "vol": "1 Ltr", "code": "84"},
        {"name": "Chocolate Cake", "price": "250", "vol": "400 g", "code": "85"},
        {"name": "Red Velvet Cake", "price": "280", "vol": "500 g", "code": "86"},
        {"name": "Cookie Chocolate Cake", "price": "280", "vol": "500 g", "code": "87"},
      ]
    },
    "Cake - Pastry": {
      "category": "Cake",
      "items": [
        {"name": "Golden Fantasy Pastry", "price": "50", "vol": "100 ml", "code": "88"},
        {"name": "Black Forest Pastry", "price": "40", "vol": "100 ml", "code": "89"},
      ]
    },
    "Home Pack - 1 Ltr Tub": {
      "category": "Home Pack",
      "items": [
        {"name": "Tender Coconut", "price": "400", "vol": "1 Ltr", "code": "90"},
        {"name": "Classical Kulfi", "price": "400", "vol": "1 Ltr", "code": "91"},
        {"name": "Rajbhog", "price": "360", "vol": "1 Ltr", "code": "92"},
        {"name": "Kesar Kaju Katli", "price": "360", "vol": "1 Ltr", "code": "93"},
        {"name": "Almond Carnival", "price": "360", "vol": "1 Ltr", "code": "94"},
        {"name": "Alphonso Mango", "price": "300", "vol": "1 Ltr", "code": "95"},
        {"name": "Malai Kulfi", "price": "300", "vol": "1 Ltr", "code": "96"},
        {"name": "Sitafal", "price": "300", "vol": "1 Ltr", "code": "97"},
      ]
    },
    "Home Pack - 750 ml": {
      "category": "Home Pack",
      "items": [
        {"name": "Kesar Pista", "price": "230", "vol": "750 ml", "code": "98"},
        {"name": "Badam Rabdi", "price": "220", "vol": "750 ml", "code": "99"},
        {"name": "Butterscotch", "price": "200", "vol": "750 ml", "code": "100"},
      ]
    },
    "Ready To Eat - Paratha": {
      "category": "Ready To Eat",
      "items": [
        {"name": "Laccha Paratha", "price": "0", "vol": "Pack", "code": "101"},
        {"name": "Mix Veg Paratha", "price": "0", "vol": "Pack", "code": "102"},
        {"name": "Aloo Paratha", "price": "0", "vol": "Pack", "code": "103"},
        {"name": "Malabar Paratha", "price": "0", "vol": "Pack", "code": "104"},
        {"name": "Onion Paratha", "price": "0", "vol": "Pack", "code": "105"},
        {"name": "Methi Paratha", "price": "0", "vol": "Pack", "code": "106"},
        {"name": "Palak Paneer Paratha", "price": "0", "vol": "Pack", "code": "107"},
        {"name": "Cheese Chilli Paratha", "price": "0", "vol": "Pack", "code": "108"},
      ]
    },
    "Ready To Eat - Chapati & Snacks": {
      "category": "Ready To Eat",
      "items": [
        {"name": "Chapati", "price": "0", "vol": "Pack", "code": "109"},
        {"name": "Pizza", "price": "0", "vol": "Pack", "code": "110"},
        {"name": "Punjabi Samosa", "price": "0", "vol": "Pack", "code": "111"},
        {"name": "French Fries", "price": "0", "vol": "Pack", "code": "112"},
        {"name": "Burger Patty", "price": "0", "vol": "Pack", "code": "113"},
        {"name": "Vada Pav Tikki", "price": "0", "vol": "Pack", "code": "114"},
      ]
    },
    "Dairy - Paneer & Milk": {
      "category": "Dairy",
      "items": [
        {"name": "Malai Paneer", "price": "0", "vol": "200 g", "code": "115"},
        {"name": "Chocolate Milk", "price": "0", "vol": "200 ml", "code": "116"},
        {"name": "Kulfi Milk", "price": "0", "vol": "200 ml", "code": "117"},
        {"name": "Elaichi Milk", "price": "0", "vol": "200 ml", "code": "118"},
        {"name": "Kesar Milk", "price": "0", "vol": "200 ml", "code": "119"},
      ]
    },
    "Dairy - Shrikhand": {
      "category": "Dairy",
      "items": [
        {"name": "Elaichi Shrikhand", "price": "0", "vol": "Pack", "code": "120"},
        {"name": "Mango Shrikhand", "price": "0", "vol": "Pack", "code": "121"},
        {"name": "Mixed Fruits Shrikhand", "price": "0", "vol": "Pack", "code": "122"},
        {"name": "Rajbhog Shrikhand", "price": "0", "vol": "Pack", "code": "123"},
      ]
    },
    "Chocolate - Bar": {
      "category": "Chocolate",
      "items": [
        {"name": "Fruit & Nut Bar", "price": "0", "vol": "Bar", "code": "124"},
        {"name": "Roasted Almond Bar", "price": "0", "vol": "Bar", "code": "125"},
        {"name": "Milk Chocolate Bar", "price": "0", "vol": "Bar", "code": "126"},
      ]
    },
    "Chocolate - Compound": {
      "category": "Chocolate",
      "items": [
        {"name": "Milk Chocolate Compound", "price": "0", "vol": "Bar", "code": "127"},
        {"name": "Dark Compound", "price": "0", "vol": "Bar", "code": "128"},
      ]
    },
  };

  /// Main function to process PDF and upload menu data
  Future<void> processAndUploadMenu(File pdfFile) async {
    PdfDocument? document;

    try {
      // Validate file exists
      if (!await pdfFile.exists()) {
        throw Exception("PDF file does not exist");
      }

      // Read and load PDF
      final Uint8List bytes = await pdfFile.readAsBytes();
      document = PdfDocument(inputBytes: bytes);

      final String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS').format(DateTime.now());

      int totalItems = menuData.values.fold(0, (sum, dept) => sum + (dept['items'] as List).length);

      print("═══════════════════════════════════════════════════");
      print("🚀 Starting Sheetal Menu Upload Process");
      print("═══════════════════════════════════════════════════");
      print("📄 Total pages in PDF: ${document.pages.count}");
      print("📦 Total departments: ${menuData.length}");
      print("🍦 Total items: $totalItems");
      print("═══════════════════════════════════════════════════\n");

      // Extract all images from all pages first
      // Map<int, List<Uint8List>> allPageImages = {};
      // for (int i = 0; i < document.pages.count; i++) {
      //   try {
      //     PdfPage page = document.pages[i];
      //     List<Uint8List> pageImages = _extractImagesFromPage(page);
      //     allPageImages[i] = pageImages;
      //     print("📸 Page ${i + 1}: Extracted ${pageImages.length} images");
      //   } catch (e) {
      //     print("⚠️  Page ${i + 1}: Could not extract images - $e");
      //     allPageImages[i] = [];
      //   }
      // }

      print("\n");

      // Process each department
      int departmentIndex = 0;
      int totalItemsProcessed = 0;

      for (var entry in menuData.entries) {
        String deptName = entry.key;
        String category = entry.value['category'];
        List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(entry.value['items']);

        print("┌─────────────────────────────────────────────────");
        print("│ 📂 Department: $deptName");
        print("│ 📁 Category: $category");
        print("│ 🍦 Items: ${items.length}");
        print("└─────────────────────────────────────────────────");

        // Get images for this department
        List<Uint8List> deptImages = [];
        // if (departmentIndex < allPageImages.length) {
        //   deptImages = allPageImages[departmentIndex] ?? [];
        // }

        // Create department
        await _createDepartment(deptName, deptImages.isNotEmpty ? deptImages[0] : null, timestamp);

        // Create food items for this department
        await _createFoodItems(deptName, items, deptImages, timestamp);

        totalItemsProcessed += items.length;
        departmentIndex++;
        print("");
      }

      print("═══════════════════════════════════════════════════");
      print("✅ UPLOAD COMPLETE!");
      print("═══════════════════════════════════════════════════");
      print("📦 Departments created: ${menuData.length}");
      print("🍦 Items created: $totalItemsProcessed");
      print("═══════════════════════════════════════════════════\n");
    } catch (e, stackTrace) {
      print("\n═══════════════════════════════════════════════════");
      print("❌ ERROR OCCURRED");
      print("═══════════════════════════════════════════════════");
      print("Error: $e");
      print("Stack trace: $stackTrace");
      print("═══════════════════════════════════════════════════\n");
      rethrow;
    } finally {
      document?.dispose();
    }
  }

  /// Extract images from a PDF page
  /// Extract images from a PDF page
  // List<Uint8List> _extractImagesFromPage(PdfPage page) {
  //   List<Uint8List> images = [];
  //   try {
  //     // Syncfusion PDF supports extracting images through page contents
  //     // We'll iterate through all objects in the page

  //     if (page.contents != null) {
  //       try {
  //         // Get images from page contents
  //         final pageImages = _extractImagesFromContent(page.contents!);
  //         if (pageImages.isNotEmpty) {
  //           images.addAll(pageImages);
  //         }
  //       } catch (e) {
  //         print("    ⚠️  Could not extract from contents: $e");
  //       }
  //     }

  //     // If no images found, create a placeholder
  //     if (images.isEmpty) {
  //       print("    ℹ️  No images found in page, using placeholder");
  //       // Create a dummy image as placeholder (1x1 transparent PNG)
  //       images.add(_createPlaceholderImage());
  //     }

  //     return images;
  //   } catch (e) {
  //     print("  ⚠️  Could not extract images from page: $e");
  //     // Return placeholder on error
  //     return [_createPlaceholderImage()];
  //   }
  // }

  /// Create a department in Firestore
  Future<void> _createDepartment(
    String deptName,
    Uint8List? imageBytes,
    String timestamp,
  ) async {
    try {
      // Check if department already exists
      final existingDept = await _firestore.collection('AllAdmins').doc(adminUid).collection('departments').where('name', isEqualTo: deptName).limit(1).get();

      if (existingDept.docs.isNotEmpty) {
        print("  ℹ️  Department already exists, skipping...");
        return;
      }

      DocumentReference deptRef = _firestore.collection('AllAdmins').doc(adminUid).collection('departments').doc();

      String? deptImageUrl;
      if (imageBytes != null && imageBytes.isNotEmpty) {
        deptImageUrl = await _uploadImage(
          imageBytes,
          "departments/dept_${deptName.replaceAll(' ', '_').replaceAll('-', '_')}_${deptRef.id}",
        );
      }

      await deptRef.set({
        "createdAt": timestamp,
        "imageUrl": deptImageUrl ?? "",
        "name": deptName,
        "status": "Active",
      });

      print("  ✅ Department created successfully");
    } catch (e) {
      print("  ❌ Error creating department: $e");
      rethrow;
    }
  }

  /// Create food items in Firestore
  Future<void> _createFoodItems(
    String deptName,
    List<Map<String, dynamic>> items,
    List<Uint8List> images,
    String timestamp,
  ) async {
    int successCount = 0;
    int failCount = 0;

    for (int i = 0; i < items.length; i++) {
      var item = items[i];

      try {
        DocumentReference itemRef = _firestore.collection('AllAdmins').doc(adminUid).collection('foodItems').doc();

        // Upload image if available (skip first image as it's used for department)
        String? itemImageUrl;
        int imageIndex = i + 1; // Skip first image
        if (imageIndex < images.length && images[imageIndex].isNotEmpty) {
          itemImageUrl = await _uploadImage(
            images[imageIndex],
            "items/${deptName.replaceAll(' ', '_').replaceAll('-', '_')}/${item['name'].replaceAll(' ', '_')}_${itemRef.id}",
          );
        }

        // Parse price safely
        int priceValue = 0;
        try {
          priceValue = int.parse(item['price'].toString());
        } catch (e) {
          print("  ⚠️  Could not parse price for ${item['name']}: ${item['price']}");
        }

        await itemRef.set({
          "createdAt": timestamp,
          "department": deptName,
          "description": "${item['name']} - ${item['vol']}",
          "foodCode": item['code'],
          "imagePath": itemImageUrl ?? "",
          "isHot": false,
          "name": item['name'],
          "price": priceValue,
          "stocks": "",
          "tax": "GST",
          "uid": adminUid,
          "updatedAt": timestamp,
        });

        successCount++;
        String priceDisplay = priceValue == 0 ? "Price TBD" : "₹$priceValue";
        print("  ✓ [${item['code']}] ${item['name']} - $priceDisplay (${item['vol']})");
      } catch (e) {
        failCount++;
        print("  ✗ [${item['code']}] ${item['name']} - Error: $e");
      }
    }

    print("  ────────────────────────────────────────────────");
    print("  📊 Success: $successCount | Failed: $failCount");
  }

  /// Upload image bytes to Firebase Storage
  Future<String> _uploadImage(Uint8List bytes, String path) async {
    try {
      // Validate image data
      if (bytes.isEmpty) {
        print("    ⚠️  Image data is empty");
        return "";
      }

      Reference ref = _storage.ref().child('sheetal_menu/$path.png');

      UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/png'),
      );

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print("    ⚠️  Image upload failed: $e");
      return "";
    }
  }

  /// Delete all existing menu data before uploading
  Future<void> clearExistingMenuData() async {
    try {
      print("🗑️  Clearing existing menu data...\n");

      // Delete departments
      final deptSnapshot = await _firestore.collection('AllAdmins').doc(adminUid).collection('departments').get();

      int deptCount = 0;
      for (var doc in deptSnapshot.docs) {
        await doc.reference.delete();
        deptCount++;
      }

      // Delete food items
      final itemsSnapshot = await _firestore.collection('AllAdmins').doc(adminUid).collection('foodItems').get();

      int itemCount = 0;
      for (var doc in itemsSnapshot.docs) {
        await doc.reference.delete();
        itemCount++;
      }

      print("✅ Cleared $deptCount departments and $itemCount items\n");
    } catch (e) {
      print("❌ Error clearing data: $e\n");
      rethrow;
    }
  }

  /// Get summary of menu data
  void printMenuSummary() {
    print("\n═══════════════════════════════════════════════════");
    print("📋 SHEETAL MENU SUMMARY");
    print("═══════════════════════════════════════════════════");

    Map<String, int> categoryCount = {};
    int totalItems = 0;

    for (var entry in menuData.entries) {
      String deptName = entry.key;
      String category = entry.value['category'];
      List items = entry.value['items'];

      categoryCount[category] = (categoryCount[category] ?? 0) + items.length;
      totalItems += items.length;

      print("$deptName: ${items.length} items");
    }

    print("\n───────────────────────────────────────────────────");
    print("📦 By Category:");
    categoryCount.forEach((category, count) {
      print("  $category: $count items");
    });

    print("───────────────────────────────────────────────────");
    print("🍦 Total Items: $totalItems");
    print("═══════════════════════════════════════════════════\n");
  }

  /// Get menu item by code
  Map<String, dynamic>? getItemByCode(String code) {
    for (var entry in menuData.entries) {
      List<Map<String, dynamic>> items = entry.value['items'];
      for (var item in items) {
        if (item['code'] == code) {
          return item;
        }
      }
    }
    return null;
  }

  /// Get all items for a specific category
  List<Map<String, dynamic>> getItemsByCategory(String category) {
    List<Map<String, dynamic>> result = [];
    for (var entry in menuData.entries) {
      if (entry.value['category'] == category) {
        result.addAll(List<Map<String, dynamic>>.from(entry.value['items']));
      }
    }
    return result;
  }

  /// Get all department names
  List<String> getAllDepartments() {
    return menuData.keys.toList();
  }

  /// Validate menu data structure
  bool validateMenuData() {
    try {
      for (var entry in menuData.entries) {
        String deptName = entry.key;
        Map<String, dynamic> deptData = entry.value;

        // Check required fields
        if (!deptData.containsKey('category')) {
          print("❌ Department '$deptName' missing 'category'");
          return false;
        }
        if (!deptData.containsKey('items')) {
          print("❌ Department '$deptName' missing 'items'");
          return false;
        }

        List items = deptData['items'];
        for (int i = 0; i < items.length; i++) {
          Map<String, dynamic> item = items[i];

          if (!item.containsKey('name')) {
            print("❌ Item #$i in '$deptName' missing 'name'");
            return false;
          }
          if (!item.containsKey('price')) {
            print("❌ Item #$i in '$deptName' missing 'price'");
            return false;
          }
          if (!item.containsKey('vol')) {
            print("❌ Item #$i in '$deptName' missing 'vol'");
            return false;
          }
          if (!item.containsKey('code')) {
            print("❌ Item #$i in '$deptName' missing 'code'");
            return false;
          }
        }
      }

      print("✅ Menu data validation passed!");
      return true;
    } catch (e) {
      print("❌ Validation error: $e");
      return false;
    }
  }
}
