// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:excel/excel.dart' hide Border;
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:pos_admin/constants/colors.dart';

// class BulkUploadScreen extends StatefulWidget {
//   final String uid;
//   final List<String> activeDepartments;
//   final VoidCallback onUploadComplete;

//   const BulkUploadScreen({
//     Key? key,
//     required this.uid,
//     required this.activeDepartments,
//     required this.onUploadComplete,
//   }) : super(key: key);

//   @override
//   State<BulkUploadScreen> createState() => _BulkUploadScreenState();
// }

// class _BulkUploadScreenState extends State<BulkUploadScreen> {
//   String? _selectedFileName;
//   List<List<dynamic>>? _excelData;
//   Map<String, List<List<dynamic>>>? _excelSheets;
//   bool _isUploading = false;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> _pickExcelFile() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['xlsx', 'xls'],
//       );

//       if (result != null) {
//         var bytes = result.files.first.bytes;
//         final String? pickedPath = result.files.first.path;

//         if (bytes == null) {
//           if (pickedPath != null) {
//             bytes = await File(pickedPath).readAsBytes();
//           } else {
//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Unable to read selected file')),
//               );
//             }
//             return;
//           }
//         }

//         if (bytes != null) {
//           var excel = Excel.decodeBytes(bytes);
//           // store all sheets for later processing
//           final Map<String, List<List<dynamic>>> sheets = {};
//           for (var table in excel.tables.keys) {
//             sheets[table] = excel.tables[table]?.rows ?? [];
//           }
//           setState(() {
//             _selectedFileName = result.files.first.name;
//             _excelSheets = sheets;
//             // default to the first sheet as items if present
//             if (sheets.isNotEmpty) {
//               _excelData = sheets.entries.first.value;
//             } else {
//               _excelData = null;
//             }
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('Error picking Excel file: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error reading Excel file: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _uploadBulkData() async {
//     if (_excelData == null || _excelData!.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select an Excel file first')),
//       );
//       return;
//     }

//     setState(() {
//       _isUploading = true;
//     });

//     try {
//       CollectionReference itemsCollection = _firestore.collection('AllAdmins').doc(widget.uid).collection('foodItems');

//       int successCount = 0;
//       int errorCount = 0;
//       int duplicateCount = 0;

//       String _cellToString(List<dynamic> row, int index) {
//         if (index >= row.length) return '';
//         final cell = row[index];
//         if (cell == null) return '';
//         try {
//           // many cells are Data objects from excel package with a `value` field
//           final val = (cell as dynamic).value ?? cell;
//           return val?.toString().trim() ?? '';
//         } catch (e) {
//           return cell.toString().trim();
//         }
//       }

//       // Ensure a department document exists for a given department name.
//       Future<String?> _ensureDepartmentExists(String deptName) async {
//         final String name = deptName.trim();
//         if (name.isEmpty) return null;
//         try {
//           final depCol = _firestore.collection('AllAdmins').doc(widget.uid).collection('departments');
//           final q = await depCol.where('name', isEqualTo: name).limit(1).get();
//           if (q.docs.isNotEmpty) {
//             return q.docs.first.id;
//           } else {
//             final ref = await depCol.add({
//               'adminUid': widget.uid,
//               'createdAt': Timestamp.now(),
//               'imageUrl': '',
//               'name': name,
//               'status': 'In-Active',
//             });
//             return ref.id;
//           }
//         } catch (e) {
//           debugPrint('Error ensuring department exists: $e');
//           return null;
//         }
//       }

//       // If there's a departments sheet, import departments first
//       if (_excelSheets != null && _excelSheets!.isNotEmpty) {
//         String? deptKey;
//         for (var k in _excelSheets!.keys) {
//           if (k.toLowerCase().contains('department')) {
//             deptKey = k;
//             break;
//           }
//         }

//         if (deptKey != null) {
//           final deptRows = _excelSheets![deptKey]!;
//           for (int r = 1; r < deptRows.length; r++) {
//             try {
//               final row = deptRows[r];
//               String name = '';
//               String imageUrl = '';
//               String status = 'Active';
//               try {
//                 final cell0 = row.isNotEmpty ? (row[0] as dynamic) : null;
//                 name = (cell0 != null ? ((cell0.value ?? cell0).toString().trim()) : '');
//               } catch (_) {}
//               try {
//                 final cell1 = row.length > 1 ? (row[1] as dynamic) : null;
//                 imageUrl = (cell1 != null ? ((cell1.value ?? cell1).toString().trim()) : '');
//               } catch (_) {}
//               try {
//                 final cell2 = row.length > 2 ? (row[2] as dynamic) : null;
//                 status = (cell2 != null ? ((cell2.value ?? cell2).toString().trim()) : 'Active');
//               } catch (_) {}

//               if (name.isEmpty) continue;

//               // create if not exists
//               final depCol = _firestore.collection('AllAdmins').doc(widget.uid).collection('departments');
//               final q = await depCol.where('name', isEqualTo: name).limit(1).get();
//               if (q.docs.isEmpty) {
//                 await depCol.add({
//                   'adminUid': widget.uid,
//                   'createdAt': Timestamp.now(),
//                   'imageUrl': imageUrl,
//                   'name': name,
//                   'status': status.isEmpty ? 'Active' : status,
//                 });
//               }
//             } catch (e) {
//               debugPrint('Error importing department row: $e');
//             }
//           }
//         }
//       }

//       // For testing, only process up to 5 items (skip header at index 0)
//       const int maxTestItems = 5;
//       final int available = _excelData!.length - 1; // exclude header
//       final int toProcess = available < maxTestItems ? available : maxTestItems;
//       for (int i = 1; i <= toProcess; i++) {
//         try {
//           var row = _excelData![i];
//           if (row.isEmpty ||
//               row.every((cell) {
//                 try {
//                   final v = (cell as dynamic)?.value ?? cell;
//                   return v == null || v.toString().trim().isEmpty;
//                 } catch (e) {
//                   return cell == null || cell.toString().trim().isEmpty;
//                 }
//               })) {
//             continue;
//           }

//           String itemName = _cellToString(row, 0);
//           String itemCode = _cellToString(row, 1);
//           String itemPrice = _cellToString(row, 2);
//           String itemStock = _cellToString(row, 3);
//           String description = _cellToString(row, 4);
//           String department = _cellToString(row, 5);

//           if (itemName.isEmpty || itemCode.isEmpty || itemPrice.isEmpty) {
//             errorCount++;
//             continue;
//           }

//           // Check duplicates by foodCode first, then by name
//           bool isDuplicate = false;
//           try {
//             if (itemCode.isNotEmpty) {
//               final q = await itemsCollection.where('foodCode', isEqualTo: itemCode).limit(1).get();
//               if (q.docs.isNotEmpty) isDuplicate = true;
//             }
//             if (!isDuplicate) {
//               final q2 = await itemsCollection.where('name', isEqualTo: itemName).limit(1).get();
//               if (q2.docs.isNotEmpty) isDuplicate = true;
//             }
//           } catch (e) {
//             debugPrint('Error checking duplicates: $e');
//           }

//           if (isDuplicate) {
//             duplicateCount++;
//             continue;
//           }

//           // Determine department to use (fall back to first active department)
//           final String deptToUse = department.isEmpty ? (widget.activeDepartments.isNotEmpty ? widget.activeDepartments[0] : '') : department;

//           // Ensure department document exists and get its ID
//           final String? deptId = await _ensureDepartmentExists(deptToUse);

//           await itemsCollection.add({
//             'name': itemName,
//             'foodCode': itemCode,
//             'price': itemPrice,
//             'uid': widget.uid,
//             'imagePath': '',
//             'department': deptToUse,
//             'departmentId': deptId ?? '',
//             'stocks': itemStock,
//             'description': description,
//             'createdAt': Timestamp.now(),
//             'isHot': false,
//           });

//           successCount++;
//         } catch (e) {
//           errorCount++;
//         }
//       }

//       setState(() {
//         _isUploading = false;
//       });

//       if (mounted) {
//         widget.onUploadComplete();
//         String message = 'Upload complete! Success: $successCount, Failed: $errorCount';
//         if (duplicateCount > 0) message += ', Duplicates: $duplicateCount';
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(message),
//             backgroundColor: successColor,
//           ),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       setState(() {
//         _isUploading = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error uploading data: $e'),
//             backgroundColor: errorColor,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Bulk Upload'),
//         backgroundColor: white,
//         iconTheme: const IconThemeData(color: black),
//         elevation: 1,
//       ),
//       backgroundColor: backgroundColor,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 8),
//             const Text(
//               'Excel File Format:',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: white,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Required columns:', style: TextStyle(fontWeight: FontWeight.w600)),
//                   SizedBox(height: 8),
//                   Text('1. Item Name'),
//                   Text('2. Item Code'),
//                   Text('3. Item Price'),
//                   Text('4. Item Stock'),
//                   Text('5. Description'),
//                   Text('6. Department'),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: warningColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: warningColor.withOpacity(0.3)),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(Icons.info_outline, color: warningColor, size: 20),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Make sure your Excel file header matches the format above.',
//                       style: TextStyle(fontSize: 12),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Center(
//               child: ElevatedButton.icon(
//                 onPressed: _isUploading ? null : _pickExcelFile,
//                 icon: const Icon(Icons.file_upload),
//                 label: const Text('Select Excel File'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryColor,
//                   foregroundColor: white,
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),
//             if (_selectedFileName != null) ...[
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: successColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.check_circle, color: successColor),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'Selected: $_selectedFileName',
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Found ${(_excelData?.length ?? 1) - 1} items to upload',
//                 style: const TextStyle(fontSize: 12, color: grey),
//               ),
//             ],
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: _isUploading ? null : () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: _isUploading ? null : _uploadBulkData,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     foregroundColor: white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: _isUploading
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(white),
//                           ),
//                         )
//                       : const Text('Upload'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//====================================================================================================================================

// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:excel/excel.dart' hide Border;
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:pos_admin/constants/colors.dart';

// class BulkUploadScreen extends StatefulWidget {
//   final String uid;
//   final List<String> activeDepartments;
//   final VoidCallback onUploadComplete;

//   const BulkUploadScreen({
//     Key? key,
//     required this.uid,
//     required this.activeDepartments,
//     required this.onUploadComplete,
//   }) : super(key: key);

//   @override
//   State<BulkUploadScreen> createState() => _BulkUploadScreenState();
// }

// class _BulkUploadScreenState extends State<BulkUploadScreen> {
//   String? _selectedFileName;
//   List<List<dynamic>>? _excelData;
//   Map<String, List<List<dynamic>>>? _excelSheets;
//   bool _isUploading = false;
//   String? _uploadStatus;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Cache for department IDs to avoid redundant queries
//   final Map<String, String?> _departmentCache = {};

//   Future<void> _pickExcelFile() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['xlsx', 'xls'],
//       );

//       if (result != null) {
//         var bytes = result.files.first.bytes;
//         final String? pickedPath = result.files.first.path;

//         if (bytes == null) {
//           if (pickedPath != null) {
//             bytes = await File(pickedPath).readAsBytes();
//           } else {
//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Unable to read selected file')),
//               );
//             }
//             return;
//           }
//         }

//         if (bytes != null) {
//           var excel = Excel.decodeBytes(bytes);
//           final Map<String, List<List<dynamic>>> sheets = {};
//           for (var table in excel.tables.keys) {
//             sheets[table] = excel.tables[table]?.rows ?? [];
//           }
//           setState(() {
//             _selectedFileName = result.files.first.name;
//             _excelSheets = sheets;
//             if (sheets.isNotEmpty) {
//               _excelData = sheets.entries.first.value;
//             } else {
//               _excelData = null;
//             }
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('Error picking Excel file: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error reading Excel file: $e')),
//         );
//       }
//     }
//   }

//   /// Extract text from a cell, handling excel Data objects
//   String _cellToString(List<dynamic> row, int index) {
//     if (index >= row.length) return '';
//     final cell = row[index];
//     if (cell == null) return '';
//     try {
//       final val = (cell as dynamic).value ?? cell;
//       return val?.toString().trim() ?? '';
//     } catch (e) {
//       return cell.toString().trim();
//     }
//   }

//   /// Check if a row is completely empty
//   bool _isRowEmpty(List<dynamic> row) {
//     return row.isEmpty ||
//         row.every((cell) {
//           try {
//             final v = (cell as dynamic)?.value ?? cell;
//             return v == null || v.toString().trim().isEmpty;
//           } catch (e) {
//             return cell == null || cell.toString().trim().isEmpty;
//           }
//         });
//   }

//   /// Ensure a department exists in the correct Firebase location
//   /// Path: AllAdmins/{uid}/departments/{docId}
//   Future<String?> _ensureDepartmentExists(String deptName) async {
//     final String name = deptName.trim();
//     if (name.isEmpty) return null;

//     // Check cache first
//     if (_departmentCache.containsKey(name)) {
//       return _departmentCache[name];
//     }

//     try {
//       final depCol = _firestore.collection('AllAdmins').doc(widget.uid).collection('departments');

//       final q = await depCol.where('name', isEqualTo: name).limit(1).get();

//       String? deptId;
//       if (q.docs.isNotEmpty) {
//         deptId = q.docs.first.id;
//       } else {
//         final ref = await depCol.add({
//           'adminUid': widget.uid,
//           'createdAt': Timestamp.now(),
//           'imageUrl': '',
//           'name': name,
//           'status': 'Active',
//         });
//         deptId = ref.id;
//       }

//       // Cache the result
//       _departmentCache[name] = deptId;
//       return deptId;
//     } catch (e) {
//       debugPrint('Error ensuring department exists: $e');
//       _departmentCache[name] = null;
//       return null;
//     }
//   }

//   /// Import departments from a dedicated departments sheet
//   Future<void> _importDepartments() async {
//     if (_excelSheets == null || _excelSheets!.isEmpty) return;

//     String? deptKey;
//     for (var k in _excelSheets!.keys) {
//       if (k.toLowerCase().contains('department')) {
//         deptKey = k;
//         break;
//       }
//     }

//     if (deptKey == null) return;

//     final deptRows = _excelSheets![deptKey]!;
//     for (int r = 1; r < deptRows.length; r++) {
//       try {
//         final row = deptRows[r];
//         if (_isRowEmpty(row)) continue;

//         final String name = _cellToString(row, 0);
//         final String imageUrl = _cellToString(row, 1);
//         final String status = _cellToString(row, 2).isEmpty ? 'Active' : _cellToString(row, 2);

//         if (name.isEmpty) continue;

//         // This will add department if it doesn't exist
//         await _ensureDepartmentExists(name);
//       } catch (e) {
//         debugPrint('Error importing department row: $e');
//       }
//     }
//   }

//   /// Upload food items to the correct Firebase location
//   /// Path: AllAdmins/{uid}/foodItems/{docId}
//   Future<void> _uploadBulkData() async {
//     if (_excelData == null || _excelData!.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select an Excel file first')),
//       );
//       return;
//     }

//     setState(() {
//       _isUploading = true;
//       _uploadStatus = 'Importing departments...';
//     });

//     try {
//       // First, import all departments
//       await _importDepartments();

//       setState(() {
//         _uploadStatus = 'Uploading food items...';
//       });

//       final CollectionReference itemsCollection = _firestore.collection('AllAdmins').doc(widget.uid).collection('foodItems');

//       int successCount = 0;
//       int errorCount = 0;
//       int duplicateCount = 0;

//       // Process all rows except header (starting from index 1)
//       for (int i = 1; i < _excelData!.length; i++) {
//         try {
//           var row = _excelData![i];

//           if (_isRowEmpty(row)) continue;

//           final String itemName = _cellToString(row, 0);
//           final String itemCode = _cellToString(row, 1);
//           final String itemPrice = _cellToString(row, 2);
//           final String itemStock = _cellToString(row, 3);
//           final String description = _cellToString(row, 4);
//           final String department = _cellToString(row, 5);

//           // Validate required fields
//           if (itemName.isEmpty || itemCode.isEmpty || itemPrice.isEmpty) {
//             errorCount++;
//             continue;
//           }

//           // Check for duplicates
//           bool isDuplicate = false;
//           try {
//             if (itemCode.isNotEmpty) {
//               final q = await itemsCollection.where('foodCode', isEqualTo: itemCode).limit(1).get();
//               if (q.docs.isNotEmpty) isDuplicate = true;
//             }
//             if (!isDuplicate && itemName.isNotEmpty) {
//               final q2 = await itemsCollection.where('name', isEqualTo: itemName).limit(1).get();
//               if (q2.docs.isNotEmpty) isDuplicate = true;
//             }
//           } catch (e) {
//             debugPrint('Error checking duplicates: $e');
//           }

//           if (isDuplicate) {
//             duplicateCount++;
//             continue;
//           }

//           // Determine department to use
//           final String deptToUse = department.isEmpty ? (widget.activeDepartments.isNotEmpty ? widget.activeDepartments[0] : '') : department;

//           // Ensure department exists and get its ID
//           final String? deptId = await _ensureDepartmentExists(deptToUse);

//           // Add item to foodItems collection
//           await itemsCollection.add({
//             'name': itemName,
//             'foodCode': itemCode,
//             'price': itemPrice,
//             'uid': widget.uid,
//             'imagePath': '',
//             'department': deptToUse,
//             'departmentId': deptId ?? '',
//             'stocks': itemStock,
//             'description': description,
//             'createdAt': Timestamp.now(),
//             'isHot': false,
//           });

//           successCount++;
//         } catch (e) {
//           debugPrint('Error uploading item row $i: $e');
//           errorCount++;
//         }
//       }

//       setState(() {
//         _isUploading = false;
//         _uploadStatus = null;
//       });

//       if (mounted) {
//         widget.onUploadComplete();
//         String message = 'Upload complete! Success: $successCount, Failed: $errorCount';
//         if (duplicateCount > 0) message += ', Duplicates: $duplicateCount';

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(message),
//             backgroundColor: successColor,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       debugPrint('Error uploading bulk data: $e');
//       setState(() {
//         _isUploading = false;
//         _uploadStatus = null;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error uploading data: $e'),
//             backgroundColor: errorColor,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Bulk Upload'),
//         backgroundColor: white,
//         iconTheme: const IconThemeData(color: black),
//         elevation: 1,
//       ),
//       backgroundColor: backgroundColor,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 8),
//             const Text(
//               'Excel File Format:',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: white,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Required columns:', style: TextStyle(fontWeight: FontWeight.w600)),
//                   SizedBox(height: 8),
//                   Text('1. Item Name (required)'),
//                   Text('2. Item Code (required)'),
//                   Text('3. Item Price (required)'),
//                   Text('4. Item Stock (optional)'),
//                   Text('5. Description (optional)'),
//                   Text('6. Department (optional)'),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: warningColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: warningColor.withOpacity(0.3)),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(Icons.info_outline, color: warningColor, size: 20),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Optional: Create a "Departments" sheet to import departments automatically.',
//                       style: TextStyle(fontSize: 12),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Center(
//               child: ElevatedButton.icon(
//                 onPressed: _isUploading ? null : _pickExcelFile,
//                 icon: const Icon(Icons.file_upload),
//                 label: const Text('Select Excel File'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryColor,
//                   foregroundColor: white,
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),
//             if (_selectedFileName != null) ...[
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: successColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.check_circle, color: successColor),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'Selected: $_selectedFileName',
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Found ${(_excelData?.length ?? 1) - 1} items to upload',
//                 style: const TextStyle(fontSize: 12, color: grey),
//               ),
//             ],
//             if (_uploadStatus != null) ...[
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         _uploadStatus!,
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: _isUploading ? null : () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: _isUploading ? null : _uploadBulkData,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     foregroundColor: white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: _isUploading
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(white),
//                           ),
//                         )
//                       : const Text('Upload'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ================================================================================================================================

import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:xml/xml.dart';

class BulkUploadScreen extends StatefulWidget {
  final String uid;
  final List<String> activeDepartments;
  final VoidCallback onUploadComplete;

  const BulkUploadScreen({
    Key? key,
    required this.uid,
    required this.activeDepartments,
    required this.onUploadComplete,
  }) : super(key: key);

  @override
  State<BulkUploadScreen> createState() => _BulkUploadScreenState();
}

class _BulkUploadScreenState extends State<BulkUploadScreen> {
  String adminNo = '+919327350149';
  String? _selectedFileName;
  List<List<dynamic>>? _excelData;
  Map<String, List<List<dynamic>>>? _excelSheets;
  bool _isUploading = false;
  String? _uploadStatus;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, String?> _departmentCache = {};

  Future<void> _pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null) {
        debugPrint('File picker returned null - user cancelled');
        return;
      }

      if (result.files.isEmpty) {
        debugPrint('File picker returned empty files list');
        return;
      }

      // Safely get the first file
      final pickedFile = result.files.first;
      if (pickedFile == null) {
        debugPrint('First file is null');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid file selection')),
          );
        }
        return;
      }

      debugPrint('File selected: ${pickedFile.name}');
      
      // Get bytes from file
      Uint8List? bytes = pickedFile.bytes;
      final String? pickedPath = pickedFile.path;

      // Try to read from disk if bytes are not available
      if (bytes == null && pickedPath != null && pickedPath.isNotEmpty) {
        try {
          debugPrint('Reading bytes from path: $pickedPath');
          bytes = await File(pickedPath).readAsBytes();
        } catch (fileReadError) {
          debugPrint('Error reading file from path: $fileReadError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to read file: $fileReadError')),
            );
          }
          return;
        }
      }

      // Final check for bytes
      if (bytes == null || bytes.isEmpty) {
        debugPrint('No bytes available from file');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to read selected file - file may be empty')),
          );
        }
        return;
      }

      debugPrint('Bytes loaded: ${bytes.length} bytes');

      // Validate file signature for Excel
      if (bytes.length < 4) {
        debugPrint('File too small to be a valid Excel file');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File is too small to be a valid Excel file')),
          );
        }
        return;
      }

      // Check for PK signature (ZIP format for xlsx)
      bool isValidZip = bytes[0] == 0x50 && bytes[1] == 0x4B && bytes[2] == 0x03 && bytes[3] == 0x04;
      debugPrint('File signature check - Valid ZIP/XLSX: $isValidZip');

      // Decode Excel file with detailed error handling
      Excel? excel;
      try {
        debugPrint('Attempting to decode Excel file...');
        
        // Try decoding with different parameters
        excel = Excel.decodeBytes(bytes);
        
        if (excel == null) {
          debugPrint('First decode attempt returned null, trying alternative...');
          excel = Excel.decodeBytes(bytes);
        }
        
        if (excel == null) {
          throw Exception('Excel.decodeBytes returned null');
        }
        
        if (excel.tables.isEmpty) {
          throw Exception('No sheets found in Excel file');
        }
        
        debugPrint('Excel file decoded successfully with ${excel.tables.length} sheet(s)');
      } catch (decodeError) {
        debugPrint('Error decoding Excel file: $decodeError');
        debugPrint('Error type: ${decodeError.runtimeType}');
        debugPrint('Stack trace: ${StackTrace.current}');
        
        // Try with csv parsing as fallback
        debugPrint('Attempting fallback: converting to CSV parsing...');
        
        // Provide helpful error message
        String userMessage = 'Failed to decode Excel file. The file might be corrupted or in an unsupported format.';
        if (decodeError.toString().contains('Null check')) {
          userMessage = 'Excel parsing error detected. Please try:\n'
            '1. Re-save your Excel file in latest format\n'
            '2. Try exporting as CSV instead\n'
            '3. Ensure no special characters in headers';
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userMessage),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Parse sheets with null safety
      final Map<String, List<List<dynamic>>> sheets = {};
      try {
        if (excel != null && excel.tables.isNotEmpty) {
          for (var table in excel.tables.keys) {
            try {
              final sheet = excel.tables[table];
              if (sheet != null && sheet.rows != null) {
                // Convert to list and filter out null rows
                final rowsList = <List<dynamic>>[];
                for (var row in sheet.rows!) {
                  if (row != null) {
                    // Convert cell objects to values
                    final processedRow = <dynamic>[];
                    for (var cell in row) {
                      try {
                        if (cell != null) {
                          final value = (cell as dynamic).value ?? cell;
                          processedRow.add(value);
                        } else {
                          processedRow.add(null);
                        }
                      } catch (e) {
                        processedRow.add(cell);
                      }
                    }
                    rowsList.add(processedRow);
                  }
                }
                sheets[table] = rowsList;
                debugPrint('Sheet "$table" loaded with ${rowsList.length} rows');
              } else {
                debugPrint('Sheet "$table" is null or has no rows');
              }
            } catch (sheetError) {
              debugPrint('Error processing sheet "$table": $sheetError');
            }
          }
          
          if (sheets.isEmpty) {
            throw Exception('No valid sheets found in Excel file');
          }
        } else {
          throw Exception('Excel file is null or contains no sheets');
        }
      } catch (parseError) {
        debugPrint('Error parsing Excel sheets: $parseError');
        
        // Try manual extraction from XLSX
        debugPrint('Attempting manual XLSX extraction...');
        try {
          final extractedSheets = await _extractSheetsFromXLSX(bytes);
          if (extractedSheets.isNotEmpty) {
            sheets.addAll(extractedSheets);
            debugPrint('Successfully extracted sheets manually');
          } else {
            throw Exception('Manual extraction found no sheets');
          }
        } catch (extractError) {
          debugPrint('Manual extraction also failed: $extractError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Cannot parse this Excel file. Try saving as CSV and uploading that instead.',
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return;
        }
      }

      if (mounted) {
        setState(() {
          _selectedFileName = pickedFile.name?.isNotEmpty == true 
            ? pickedFile.name! 
            : 'Unknown File';
          _excelSheets = sheets;
          if (sheets.isNotEmpty) {
            _excelData = sheets.entries.first.value;
            debugPrint('Using first sheet: ${sheets.entries.first.key}');
          } else {
            _excelData = null;
            debugPrint('No sheets found in Excel file');
          }
        });
      }
    } catch (e) {
      debugPrint('Unexpected error in _pickExcelFile: $e');
      debugPrintStack(label: 'Stack trace for Excel file error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reading Excel file: $e')),
        );
      }
    }
  }

  /// Manual extraction of sheets from XLSX file format
  /// XLSX is a ZIP file containing XML sheets
  Future<Map<String, List<List<dynamic>>>> _extractSheetsFromXLSX(Uint8List bytes) async {
    final Map<String, List<List<dynamic>>> sheets = {};
    try {
      // Decode ZIP archive
      final archive = ZipDecoder().decodeBytes(bytes);
      
      debugPrint('Archive contains ${archive.length} files');
      
      // Find sheet files (xl/worksheets/sheet1.xml, sheet2.xml, etc)
      final sheetFiles = <String, ArchiveFile>{};
      for (var file in archive) {
        if (file.name.contains('xl/worksheets/sheet') && file.name.endsWith('.xml')) {
          sheetFiles[file.name] = file;
          debugPrint('Found sheet file: ${file.name}');
        }
      }
      
      // Extract workbook.xml to get sheet names
      ArchiveFile? workbookFile;
      for (var file in archive) {
        if (file.name == 'xl/workbook.xml') {
          workbookFile = file;
          break;
        }
      }
      
      // Parse sheets
      int sheetIndex = 1;
      for (var entry in sheetFiles.entries) {
        try {
          final xmlString = String.fromCharCodes(entry.value.content as List<int>);
          final document = XmlDocument.parse(xmlString);
          
          // Get sheet name from workbook or use default
          String sheetName = 'Sheet$sheetIndex';
          
          // Extract cell values from XML
          final rows = <List<dynamic>>[];
          final sheetDataElements = document.findAllElements('sheetData');
          
          for (var sheetData in sheetDataElements) {
            final rowElements = sheetData.findAllElements('row');
            for (var rowElem in rowElements) {
              final cells = <dynamic>[];
              final cellElements = rowElem.findAllElements('c');
              
              for (var cellElem in cellElements) {
                String cellValue = '';
                try {
                  final valueElem = cellElem.getElement('v');
                  if (valueElem != null) {
                    cellValue = valueElem.innerText;
                  } else {
                    final textElem = cellElem.getElement('t');
                    if (textElem != null) {
                      cellValue = textElem.innerText;
                    }
                  }
                } catch (e) {
                  debugPrint('Error extracting cell: $e');
                }
                cells.add(cellValue);
              }
              
              if (cells.isNotEmpty) {
                rows.add(cells);
              }
            }
          }
          
          if (rows.isNotEmpty) {
            sheets[sheetName] = rows;
            debugPrint('Extracted $sheetName with ${rows.length} rows');
          }
          
          sheetIndex++;
        } catch (e) {
          debugPrint('Error parsing sheet file ${entry.key}: $e');
        }
      }
      
      return sheets;
    } catch (e) {
      debugPrint('Error in manual XLSX extraction: $e');
      return {};
    }
  }

  String _cellToString(List<dynamic> row, int index) {
    if (index >= row.length) return '';
    final cell = row[index];
    if (cell == null) return '';
    try {
      final val = (cell as dynamic).value ?? cell;
      return val?.toString().trim() ?? '';
    } catch (e) {
      return cell.toString().trim();
    }
  }

  bool _isRowEmpty(List<dynamic> row) {
    if (row.isEmpty) return true;
    return row.every((cell) {
      try {
        final v = (cell as dynamic)?.value ?? cell;
        return v == null || v.toString().trim().isEmpty;
      } catch (e) {
        return cell == null || cell.toString().trim().isEmpty;
      }
    });
  }

  Future<String?> _ensureDepartmentExists(String deptName) async {
    final String name = deptName.trim();
    if (name.isEmpty) return null;

    if (_departmentCache.containsKey(name)) {
      return _departmentCache[name];
    }

    try {
      final depCol = _firestore.collection('AllAdmins').doc(adminNo).collection('departments');

      final q = await depCol.where('name', isEqualTo: name).limit(1).get();

      String? deptId;
      if (q.docs.isNotEmpty) {
        deptId = q.docs.first.id;
      } else {
        final ref = await depCol.add({
          'adminUid': adminNo,
          'createdAt': Timestamp.now(),
          'imageUrl': '',
          'name': name,
          'status': 'Active',
        });
        deptId = ref.id;
      }

      _departmentCache[name] = deptId;
      return deptId;
    } catch (e) {
      debugPrint('Error ensuring department exists: $e');
      _departmentCache[name] = null;
      return null;
    }
  }

  Future<void> _importDepartments() async {
    if (_excelSheets == null || _excelSheets!.isEmpty) return;

    String? deptKey;
    for (var k in _excelSheets!.keys) {
      if (k.toLowerCase().contains('department')) {
        deptKey = k;
        break;
      }
    }

    if (deptKey == null) return;

    final deptRows = _excelSheets![deptKey]!;
    for (int r = 1; r < deptRows.length; r++) {
      try {
        final row = deptRows[r];
        if (_isRowEmpty(row)) continue;

        final String name = _cellToString(row, 0);
        final String imageUrl = _cellToString(row, 1);
        final String status = _cellToString(row, 2).isEmpty ? 'Active' : _cellToString(row, 2);

        if (name.isEmpty) continue;

        debugPrint('Department Row $r - Name: $name, Status: $status');
        await _ensureDepartmentExists(name);
      } catch (e) {
        debugPrint('Error importing department row: $e');
      }
    }
  }

  Future<void> _uploadBulkData() async {
    if (_excelData == null || _excelData!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an Excel file first')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Importing departments...';
    });

    try {
      // First, import all departments
      await _importDepartments();

      setState(() {
        _uploadStatus = 'Uploading food items...';
      });

      final CollectionReference itemsCollection = _firestore.collection('AllAdmins').doc(adminNo).collection('foodItems');

      int successCount = 0;
      int errorCount = 0;
      int duplicateCount = 0;

      // Process up to 10 items for testing
      int? maxTestItems = 0;
      final int totalRows = _excelData!.length;
      final int available = totalRows - 1; // exclude header
      final int toProcess = available;
      // < maxTestItems || maxTestItems == null || maxTestItems > 0 ? available : maxTestItems;

      debugPrint('\n========== BULK UPLOAD TEST ==========');
      debugPrint('Total rows in Excel: $totalRows');
      debugPrint('Available items (excluding header): $available');
      debugPrint('Items to process (test limit): $toProcess');
      debugPrint('=======================================\n');

      for (int i = 1; i <= toProcess; i++) {
        try {
          var row = _excelData![i];

          if (_isRowEmpty(row)) {
            debugPrint('Row $i: EMPTY - skipping');
            continue;
          }

          final String itemName = _cellToString(row, 0);
          final String itemCode = _cellToString(row, 1);
          final String itemPrice = _cellToString(row, 2);
          final String itemStock = _cellToString(row, 3);
          final String description = _cellToString(row, 4);
          final String department = _cellToString(row, 5);

          debugPrint('\n--- Row $i Data ---');
          debugPrint('Name: $itemName');
          debugPrint('Code: $itemCode');
          debugPrint('Price: $itemPrice');
          debugPrint('Stock: $itemStock');
          debugPrint('Department: $department');

          // Validate required fields
          if (itemName.isEmpty || itemCode.isEmpty || itemPrice.isEmpty) {
            errorCount++;
            debugPrint('Status: ❌ VALIDATION FAILED (missing required fields)');
            continue;
          }
          debugPrint('Validation: ✓ PASSED');

          // Check for duplicates
          bool isDuplicate = false;
          try {
            if (itemCode.isNotEmpty) {
              final q = await itemsCollection.where('foodCode', isEqualTo: itemCode).limit(1).get();
              if (q.docs.isNotEmpty) isDuplicate = true;
            }
            if (!isDuplicate && itemName.isNotEmpty) {
              final q2 = await itemsCollection.where('name', isEqualTo: itemName).limit(1).get();
              if (q2.docs.isNotEmpty) isDuplicate = true;
            }
          } catch (e) {
            debugPrint('Error checking duplicates: $e');
          }

          if (isDuplicate) {
            duplicateCount++;
            debugPrint('Status: ⚠️  DUPLICATE FOUND');
            continue;
          }
          debugPrint('Duplicate Check: ✓ PASSED');

          // Determine department to use
          final String deptToUse = department.isEmpty ? (widget.activeDepartments.isNotEmpty ? widget.activeDepartments[0] : '') : department;

          // Ensure department exists and get its ID
          final String? deptId = await _ensureDepartmentExists(deptToUse);
          debugPrint('Department Used: $deptToUse (ID: $deptId)');

          // Add item to foodItems collection
          final docRef = await itemsCollection.add({
            'name': itemName,
            'foodCode': itemCode,
            'price': itemPrice,
            'uid': adminNo,
            'imagePath': '',
            'department': deptToUse,
            'departmentId': deptId ?? '',
            'stocks': itemStock,
            'description': description,
            'createdAt': Timestamp.now(),
            'isHot': false,
            'tax':'',
          });

          debugPrint('Firestore Path: AllAdmins/$adminNo/foodItems/${docRef.id}');
          debugPrint('Status: ✅ UPLOADED SUCCESSFULLY');
          successCount++;
        } catch (e) {
          debugPrint('Status: ❌ UPLOAD FAILED');
          debugPrint('Error: $e');
          errorCount++;
        }
      }

      setState(() {
        _isUploading = false;
        _uploadStatus = null;
      });

      debugPrint('\n========== UPLOAD SUMMARY ==========');
      debugPrint('✅ Successfully Uploaded: $successCount');
      debugPrint('❌ Failed: $errorCount');
      debugPrint('⚠️  Duplicates Skipped: $duplicateCount');
      debugPrint('=====================================\n');

      if (mounted) {
        widget.onUploadComplete();
        String message = 'Upload complete! Success: $successCount, Failed: $errorCount';
        if (duplicateCount > 0) message += ', Duplicates: $duplicateCount';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: successColor,
            duration: const Duration(seconds: 4),
          ),
        );

        _showUploadReport(successCount, errorCount, duplicateCount);
      }
    } catch (e) {
      debugPrint('Error uploading bulk data: $e');
      setState(() {
        _isUploading = false;
        _uploadStatus = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading data: $e'),
            backgroundColor: errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showUploadReport(int success, int failed, int duplicates, {int? maxTestItems}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upload Report'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReportItem(
                icon: Icons.check_circle,
                label: 'Successfully Uploaded',
                value: success.toString(),
                color: successColor,
              ),
              const SizedBox(height: 16),
              _buildReportItem(
                icon: Icons.error_outline,
                label: 'Failed',
                value: failed.toString(),
                color: errorColor,
              ),
              const SizedBox(height: 16),
              _buildReportItem(
                icon: Icons.warning_amber_outlined,
                label: 'Duplicates Skipped',
                value: duplicates.toString(),
                color: warningColor,
              ),
              const SizedBox(height: 20),
              if (maxTestItems != null && maxTestItems > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ Testing Mode - First 10 Items Only',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Check the console logs (Flutter DevTools) for detailed verification:\n\n'
                        '1. Verify all data is correct\n'
                        '2. Check Firebase paths\n'
                        '3. If everything is OK, remove test limit\n'
                        '4. If errors found, delete collections and fix data',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: white,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Upload'),
        backgroundColor: white,
        iconTheme: const IconThemeData(color: black),
        elevation: 1,
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Excel File Format:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Required columns:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text('1. Item Name (required)'),
                  Text('2. Item Code (required)'),
                  Text('3. Item Price (required)'),
                  Text('4. Item Stock (optional)'),
                  Text('5. Description (optional)'),
                  Text('6. Department (optional)'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: warningColor.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: warningColor, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Optional: Create a "Departments" sheet to import departments automatically.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickExcelFile,
                icon: const Icon(Icons.file_upload),
                label: const Text('Select Excel File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (_selectedFileName != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: successColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Selected: $_selectedFileName',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Found ${(_excelData?.length ?? 1) - 1} items in file',
                style: const TextStyle(fontSize: 12, color: grey),
              ),
            ],
            if (_uploadStatus != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _uploadStatus!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isUploading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isUploading ? null : _uploadBulkData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(white),
                          ),
                        )
                      : const Text('Upload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
