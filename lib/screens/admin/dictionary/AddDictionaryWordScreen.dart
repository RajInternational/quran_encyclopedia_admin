import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/DictionaryWordData.dart';
import 'dart:ui' as ui;
import 'package:quizeapp/services/DictionaryWordService.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/main.dart';

class AddDictionaryWordScreen extends StatefulWidget {
  final DictionaryWordData? wordToEdit;

  AddDictionaryWordScreen({this.wordToEdit});

  @override
  _AddDictionaryWordScreenState createState() => _AddDictionaryWordScreenState();
}

class _AddDictionaryWordScreenState extends State<AddDictionaryWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _arabicWordController = TextEditingController();
  final _rootWordController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.wordToEdit != null) {
      _arabicWordController.text = widget.wordToEdit!.arabicWord ?? '';
      _rootWordController.text = widget.wordToEdit!.rootWord ?? '';
      _descriptionController.text = widget.wordToEdit!.description ?? '';
      _referenceController.text = widget.wordToEdit!.reference ?? '';
    }
  }

  Future<void> _saveWord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final word = DictionaryWordData(
        id: widget.wordToEdit?.id,
        arabicWord: _arabicWordController.text.trim(),
        rootWord: _rootWordController.text.trim(),
        description: _descriptionController.text.trim(),
        reference: _referenceController.text.trim(),
      );

      if (widget.wordToEdit != null) {
        await dictionaryWordService.updateDictionaryWord(word);
        toast('Word updated successfully!');
      } else {
        await dictionaryWordService.addDictionaryWord(word);
        toast('Word added successfully!');
      }

      // Emit refresh event for Dictionary Words list
      LiveStream().emit('refreshDictionaryWords', true);
      
      Navigator.pop(context, true);
    } catch (e) {
      toast('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.wordToEdit != null ? 'Edit Dictionary Word' : 'Add Dictionary Word',
          style: boldTextStyle(color: Colors.white),
        ),
        backgroundColor: colorPrimary,
        elevation: 0,
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.save, color: Colors.white),
              onPressed: _saveWord,
              tooltip: 'Save',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Arabic Word Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.text_fields,
                              color: colorPrimary,
                              size: 20,
                            ),
                          ),
                          12.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Arabic Word',
                                  style: boldTextStyle(size: 16),
                                ),
                                4.height,
                                Text(
                                  'Enter the Arabic word',
                                  style: secondaryTextStyle(size: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _arabicWordController,
                        textDirection: ui.TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'NotoNastaliq',
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'اِلَّا',
                          hintStyle: TextStyle(
                            fontSize: 18,
                            fontFamily: 'NotoNastaliq',
                            color: Colors.grey[400],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: colorPrimary, width: 2),
                          ),
                          contentPadding: EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Arabic word is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              24.height,

              // Root Word Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.text_fields,
                              color: Colors.purple,
                              size: 20,
                            ),
                          ),
                          12.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Root Word (Optional)',
                                  style: boldTextStyle(size: 16),
                                ),
                                4.height,
                                Text(
                                  'Enter the root word of the Arabic word',
                                  style: secondaryTextStyle(size: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _rootWordController,
                        textDirection: ui.TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'NotoNastaliq',
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'الّا',
                          hintStyle: TextStyle(
                            fontSize: 18,
                            fontFamily: 'NotoNastaliq',
                            color: Colors.grey[400],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.purple, width: 2),
                          ),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              24.height,

              // Description Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.description,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                          12.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description (Arabic/Urdu)',
                                  style: boldTextStyle(size: 16),
                                ),
                                4.height,
                                Text(
                                  'Enter detailed description',
                                  style: secondaryTextStyle(size: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _descriptionController,
                        textDirection: ui.TextDirection.rtl,
                        maxLines: 4,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoNastaliq',
                          height: 1.4,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'اِلَّا: [حرف] (۱) الاّ کے معنی بطورِ حرفِ جر: علاوہ، سِوا، بِغیر، بِشمول کے آتے ہیں۔',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoNastaliq',
                            color: Colors.grey[400],
                            height: 1.4,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.blue, width: 2),
                          ),
                          contentPadding: EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              24.height,

              // Reference Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.link,
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                          12.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reference URL (Optional)',
                                  style: boldTextStyle(size: 16),
                                ),
                                4.height,
                                Text(
                                  'Add reference link or image URL',
                                  style: secondaryTextStyle(size: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _referenceController,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'https://example.com/image.png',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.green, width: 2),
                          ),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _arabicWordController.dispose();
    _rootWordController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    super.dispose();
  }
}
