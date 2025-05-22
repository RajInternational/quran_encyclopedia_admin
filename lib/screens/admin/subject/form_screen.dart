import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';

import '../../../utils/Colors.dart';
import '../../../utils/Common.dart';
import '../AdminDashboardScreen.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({Key? key}) : super(key: key);

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();

  List<AyatInputController> _ayatControllers = [AyatInputController()];
  List<Map<String, dynamic>> _previewData = [];

  bool _isLoading = false;
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    for (var controller in _ayatControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Validates Ayat format (should be like "1.2" - surah.ayat)
  bool _isValidAyatFormat(String input) {
    if (input.trim().isEmpty) return false;
    final regex = RegExp(r'^\d+\.\d+$');
    return regex.hasMatch(input.trim());
  }

  /// Get all valid Ayat numbers from controllers
  List<String> _getValidAyatNumbers() {
    List<String> validAyats = [];
    for (var controller in _ayatControllers) {
      String text = controller.textController.text.trim();
      if (_isValidAyatFormat(text)) {
        validAyats.add(text);
      }
    }
    return validAyats;
  }

  /// Fetch Ayat data from Firestore
  Future<void> _fetchAyatData({bool saveAfterFetch = false}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> ayatNumbers = _getValidAyatNumbers();

      if (ayatNumbers.isEmpty) {
        toast('Please enter at least one valid Ayat number');
        return;
      }

      // Check for duplicates
      Set<String> uniqueAyats = ayatNumbers.toSet();
      if (uniqueAyats.length != ayatNumbers.length) {
        toast('Duplicate Ayat numbers found. Please remove duplicates.');
        return;
      }

      // Create a map to maintain original input order
      Map<String, int> originalOrder = {};
      for (int i = 0; i < ayatNumbers.length; i++) {
        originalOrder[ayatNumbers[i]] = i;
      }

      // Query Firestore
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection("Book")
              .doc("Quran")
              .collection("CompleteQuran")
              .where('no', whereIn: ayatNumbers)
              .get();

      if (snapshot.docs.isEmpty) {
        toast('No Ayats found with the provided numbers');
        return;
      }

      // Process the data while maintaining original order
      List<Map<String, dynamic>> fetchedData = [];
      Map<String, Map<String, dynamic>> dataByAyat = {};

      // First, organize data by Ayat number
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final ayatKey = data['no'].toString();
        dataByAyat[ayatKey] = data;
      }

      // Then, add data in the original input order
      for (String ayatNumber in ayatNumbers) {
        if (dataByAyat.containsKey(ayatNumber)) {
          Map<String, dynamic> ayatData = Map.from(dataByAyat[ayatNumber]!);
          ayatData['inputIndex'] = originalOrder[ayatNumber];
          ayatData['originalInput'] = ayatNumber;
          fetchedData.add(ayatData);
        } else {
          // Add placeholder for missing Ayat
          fetchedData.add({
            'inputIndex': originalOrder[ayatNumber],
            'originalInput': ayatNumber,
            'error': 'Ayat not found',
            'no': ayatNumber,
            'surahName': 'Not Found',
            'arabic': 'Ayat not found in database',
          });
        }
      }

      // Sort by input order to maintain sequence
      fetchedData.sort((a, b) => a['inputIndex'].compareTo(b['inputIndex']));

      setState(() {
        _previewData = fetchedData;
        _isPreviewMode = true;
      });

      // Check if any Ayats were not found
      List<String> notFoundAyats =
          fetchedData
              .where((data) => data.containsKey('error'))
              .map((data) => data['originalInput'].toString())
              .toList();

      if (notFoundAyats.isNotEmpty) {
        toast('Warning: Some Ayats not found: ${notFoundAyats.join(', ')}');
      }

      if (saveAfterFetch) {
        // Only save if all Ayats were found successfully
        List<Map<String, dynamic>> validData =
            fetchedData.where((data) => !data.containsKey('error')).toList();

        if (validData.isEmpty) {
          toast('No valid Ayats to save');
          return;
        }

        await _saveSubjectData(validData);
      } else {
        toast('Ayat data loaded successfully');
      }
    } on FirebaseException catch (e) {
      print('Firebase error: ${e.message}');
      toast('Database error: ${e.message ?? 'Unknown error'}');
    } catch (e, stackTrace) {
      print('Error fetching Ayat data: $e');
      print('Stack trace: $stackTrace');
      toast('Error fetching data. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Save subject data to Firestore
  Future<void> _saveSubjectData(List<Map<String, dynamic>> validData) async {
    try {
      if (validData.isEmpty) {
        toast('No valid data to save');
        return;
      }

      final subjectCollection = FirebaseFirestore.instance
          .collection("Book")
          .doc("Quran")
          .collection("SubjectCollection");

      // Get current count for proper ordering
      final countResult = await subjectCollection.count().get();
      final currentCount = countResult.count ?? 0;

      // Generate new document ID
      final newDocRef = subjectCollection.doc();
      final newDocId = newDocRef.id;

      // Prepare subject data
      final subjectData = {
        "timestamp": FieldValue.serverTimestamp(),
        "count": currentCount + 1,
        "subjectId": newDocId,
        "subjectName": _subjectController.text.trim(),
        "ayatCount": validData.length,
        "createdAt": DateTime.now().toIso8601String(),
      };

      // Use batch for atomic operations
      final batch = FirebaseFirestore.instance.batch();

      // Set subject document
      batch.set(newDocRef, subjectData);

      // Add all Ayats as subcollection
      final ayatsCollection = newDocRef.collection("ayats");
      for (int i = 0; i < validData.length; i++) {
        final ayatData = Map<String, dynamic>.from(validData[i]);

        // Clean up temporary fields
        ayatData.remove('inputIndex');
        ayatData.remove('originalInput');

        // Add metadata
        ayatData['orderInSubject'] = i + 1;
        ayatData['addedAt'] = DateTime.now().toIso8601String();

        batch.set(ayatsCollection.doc(), ayatData);
      }

      // Commit the batch
      await batch.commit();

      toast('Subject created successfully with ${validData.length} Ayats');

      // Navigate back to dashboard
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
          (route) => false,
        );
      }
    } on FirebaseException catch (e) {
      print('Firebase error during save: ${e.message}');
      toast('Error saving data: ${e.message ?? 'Unknown error'}');
    } catch (e, stackTrace) {
      print('Error saving subject: $e');
      print('Stack trace: $stackTrace');
      toast('Error saving subject. Please try again.');
    }
  }

  /// Add new Ayat input field
  void _addAyatField() {
    setState(() {
      _ayatControllers.add(AyatInputController());
    });
  }

  /// Remove Ayat input field
  void _removeAyatField(int index) {
    if (_ayatControllers.length > 1) {
      setState(() {
        _ayatControllers[index].dispose();
        _ayatControllers.removeAt(index);

        // Clear preview if we're removing fields
        if (_isPreviewMode) {
          _previewData.clear();
          _isPreviewMode = false;
        }
      });
    }
  }

  /// Clear preview data
  void _clearPreview() {
    setState(() {
      _previewData.clear();
      _isPreviewMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Subject'),
        backgroundColor: colorPrimary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject name field
              AppTextField(
                controller: _subjectController,
                textFieldType: TextFieldType.NAME,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 1,
                decoration: inputDecoration(labelText: 'Subject Name *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter subject name';
                  }
                  if (value.trim().length < 3) {
                    return 'Subject name must be at least 3 characters';
                  }
                  return null;
                },
              ),

              16.height,

              // Instructions
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    4.height,
                    Text(
                      '• Enter Ayat numbers in format: Surah.Ayat (e.g., 1.1, 2.255)',
                    ),
                    Text('• Each field should contain one Ayat number only'),
                    Text('• Use "Find Surah & Ayat" to preview before saving'),
                  ],
                ),
              ),

              16.height,

              // Preview section
              if (_isPreviewMode && _previewData.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Preview (${_previewData.length} Ayats)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          TextButton(
                            onPressed: _clearPreview,
                            child: Text('Clear Preview'),
                          ),
                        ],
                      ),
                      8.height,
                      ...List.generate(_previewData.length, (index) {
                        final data = _previewData[index];
                        final hasError = data.containsKey('error');

                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: hasError ? Colors.red.shade50 : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color:
                                  hasError
                                      ? Colors.red.shade200
                                      : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ${data['surahName'] ?? 'Unknown'} (${data['no']})',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: hasError ? Colors.red.shade700 : null,
                                ),
                              ),
                              if (!hasError && data['arabic'] != null) ...[
                                4.height,
                                Text(
                                  data['arabic'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                              if (hasError) ...[
                                4.height,
                                Text(
                                  'Error: ${data['error']}',
                                  style: TextStyle(color: Colors.red.shade600),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                16.height,
              ],

              // Add more fields button
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  color: colorPrimary,
                  onTap: _addAyatField,
                  child: Text(
                    'Add More Fields',
                    style: primaryTextStyle(color: white),
                  ),
                ),
              ),

              16.height,

              // Ayat input fields
              ...List.generate(_ayatControllers.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _ayatControllers[index].textController,
                          textFieldType: TextFieldType.OTHER,
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          decoration: inputDecoration(
                            labelText: 'Ayat ${index + 1} (e.g., 2.255) *',
                            hintText: 'Enter Surah.Ayat format',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter Ayat number';
                            }
                            if (!_isValidAyatFormat(value)) {
                              return 'Invalid format. Use Surah.Ayat (e.g., 1.1)';
                            }
                            return null;
                          },
                        ),
                      ),
                      if (index > 0) ...[
                        8.width,
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeAyatField(index),
                          tooltip: 'Remove this field',
                        ),
                      ],
                    ],
                  ),
                );
              }),

              24.height,

              // Action buttons
              if (_isLoading)
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: colorPrimary),
                      8.height,
                      Text('Processing...'),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        padding: EdgeInsets.all(16),
                        color: Colors.blue,
                        onTap: () => _fetchAyatData(saveAfterFetch: false),
                        child: Text(
                          'Find Surah & Ayat',
                          style: primaryTextStyle(color: white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: AppButton(
                        padding: EdgeInsets.all(16),
                        color: colorPrimary,
                        onTap: () => _fetchAyatData(saveAfterFetch: true),
                        child: Text(
                          'Create Subject',
                          style: primaryTextStyle(color: white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper class to manage Ayat input controllers
class AyatInputController {
  final TextEditingController textController = TextEditingController();

  void dispose() {
    textController.dispose();
  }
}
