import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class SharedPreferencesHelper {
  static Future<void> downloadData() async {
    try {
      print("Starting data download...");

      // Fetch data from Firestore
      final subjectCollection = FirebaseFirestore.instance
          .collection("Book")
          .doc("Quran")
          .collection("SubjectCollection");

      final subjectSnapshot = await subjectCollection.get();
      print("Fetched ${subjectSnapshot.docs.length} documents.");

      List<Map<String, dynamic>> subjects = [];

      for (var doc in subjectSnapshot.docs) {
        Map<String, dynamic> subjectData = doc.data();

        // Convert Timestamp fields to ISO-8601 strings
        subjectData = subjectData.map((key, value) {
          if (value is Timestamp) {
            return MapEntry(key, value.toDate().toIso8601String());
          }
          return MapEntry(key, value);
        });

        subjectData['id'] = doc.id; // Include document ID

        // Fetch ayats sub-collection
        final ayatsSnapshot = await doc.reference.collection("ayats").get();
        print(
            "Fetched ${ayatsSnapshot.docs.length} ayats for subject ${doc.id}.");

        subjectData['ayats'] = ayatsSnapshot.docs.map((e) {
          final ayatData = e.data();

          // Convert Timestamp fields in ayats
          return ayatData.map((key, value) {
            if (value is Timestamp) {
              return MapEntry(key, value.toDate().toIso8601String());
            }
            return MapEntry(key, value);
          });
        }).toList();

        subjects.add(subjectData);
      }

      // Convert data to JSON
      String jsonData = jsonEncode(subjects);
      print("Data converted to JSON.");

      // Get file path
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/subjects.json';
      print("File path: $filePath");

      // Save JSON to file
      final file = File(filePath);
      await file.writeAsString(jsonData);
      print("Data saved locally to $filePath.");
    } catch (e) {
      print("Error in downloadData: $e");
    }
  }
}
