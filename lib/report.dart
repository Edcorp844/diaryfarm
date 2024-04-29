import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm/main.dart';
import 'package:farm/services/authservice.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  Future<DocumentSnapshot<Map<String, dynamic>>> _getAllData() async {
    // Call the StorageService method to retrieve all data
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(AuthService().currentUser?.uid)
        .get();
  }

  Future<File> generateAndSavePDF() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(AuthService().currentUser?.uid)
        .get();

    final expensesQuery = await FirebaseFirestore.instance
        .collection('users')
        .doc(AuthService().currentUser?.uid)
        .collection('Expenses')
        .get();

    final milkQuery = await FirebaseFirestore.instance
        .collection('users')
        .doc(AuthService().currentUser?.uid)
        .collection('Milk')
        .get();

    final document = pw.Document();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      final expensesData = expensesQuery.docs.map((doc) => doc.data()).toList();
      final milkData = milkQuery.docs.map((doc) => doc.data()).toList();
      print(userData);
      print(expensesData);
      print(milkData);

      document.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(children: [
              pw.Text(
                'Report',
                style: pw.TextStyle(color: PdfColors.green, fontSize: 30),
              ),
              pw.Table(
                border: const pw.TableBorder(
                  horizontalInside: pw.BorderSide(
                    color: PdfColors.black,
                  ),
                  verticalInside: pw.BorderSide(
                    color: PdfColors.black,
                  ),
                  bottom: pw.BorderSide(
                    color: PdfColors.black,
                  ),
                  top: pw.BorderSide(
                    color: PdfColors.black,
                  ),
                  left: pw.BorderSide(
                    color: PdfColors.black,
                  ),
                  right: pw.BorderSide(
                    color: PdfColors.black,
                  ),
                ),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Farm Name'),
                      pw.Text('User Name'),
                      pw.Text('Email'),
                      pw.Text('Type'),
                      pw.Text('Id'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text('${userData['farmName']}'),
                      pw.Text('${userData['UserName']}'),
                      pw.Text('${userData['userEmail']}'),
                      pw.Text('${userData['userType']}'),
                      pw.Text('${userData['userId']}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20), // Add some space between tables
              pw.Text(
                'Expenses',
                style: pw.TextStyle(color: PdfColors.blue, fontSize: 20),
              ),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Date'),
                      pw.Text('Name'),
                      pw.Text('Notes'),
                      pw.Text('Payment Method'),
                      pw.Text('Cost'),
                    ],
                  ),
                  for (var expense in expensesData)
                    pw.TableRow(
                      children: [
                        pw.Text('${expense['date']}'),
                        pw.Text('${expense['name']}'),
                        pw.Text('${expense['notes']}'),
                        pw.Text('${expense['paymentMethod']}'),
                        pw.Text('${expense['cost']}'),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 20), // Add some space between tables
              pw.Text(
                'Milk Data',
                style: pw.TextStyle(color: PdfColors.blue, fontSize: 20),
              ),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Date'),
                      pw.Text('Quantity'),
                      pw.Text('Time'),
                    ],
                  ),
                  for (var milk in milkData)
                    pw.TableRow(
                      children: [
                        pw.Text('${milk['date']}'),
                        pw.Text('${milk['quantity']}'),
                        pw.Text('${milk['time']}'),
                      ],
                    ),
                ],
              ),
            ]);
          }));
    } else {}
    final bytes = await document.save();

    // Save the bytes to a file
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    print(path);
    final file = File('$path/report.pdf');
    await file.writeAsBytes(bytes);

    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Color.fromARGB(47, 100, 128, 153),
        title: Text(
          'Report',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [],
      ),
      body: FutureBuilder<File>(
        future: generateAndSavePDF(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a circular progress indicator while the report is being generated
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show an error message if there's an error generating the report
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Show the PDF viewer to preview the generated report
            return SfPdfViewer.file(snapshot.data!);
          }
        },
      ),
    );
  }
}

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(
             'Admin', // Use null check and provide a default value
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.logout,
            color: Colors.white,
          ),
          onPressed: () {
            AuthService().signOut();
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MyHomePage()));
          },
        ),
      ],
    ));
  }
}
