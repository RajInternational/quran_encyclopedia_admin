import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/DictionaryWordData.dart';
import 'package:quizeapp/services/DictionaryWordService.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';

class AddDictionaryWordScreen extends StatefulWidget {
  final DictionaryWordData? wordToEdit;

  const AddDictionaryWordScreen({Key? key, this.wordToEdit}) : super(key: key);

  @override
  State<AddDictionaryWordScreen> createState() => _AddDictionaryWordScreenState();
}

class _AddDictionaryWordScreenState extends State<AddDictionaryWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _arabicWordController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  final DictionaryWordService _dictionaryService = DictionaryWordService();
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.wordToEdit != null;
    if (_isEditMode) {
      _arabicWordController.text = widget.wordToEdit!.arabicWord ?? '';
      _descriptionController.text = widget.wordToEdit!.description ?? '';
      _referenceController.text = widget.wordToEdit!.reference ?? '';
    }
  }

  @override
  void dispose() {
    _arabicWordController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _saveDictionaryWord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final word = DictionaryWordData(
        id: _isEditMode ? widget.wordToEdit!.id : null,
        arabicWord: _arabicWordController.text.trim(),
        description: _descriptionController.text.trim(),
        reference: _referenceController.text.trim(),
        createdAt: _isEditMode ? widget.wordToEdit!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditMode) {
        await _dictionaryService.updateDictionaryWord(word);
        toast('Dictionary word updated successfully!');
      } else {
        await _dictionaryService.addDictionaryWord(word);
        toast('Dictionary word added successfully!');
        _clearForm();
      }
    } catch (e) {
      toast('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _arabicWordController.clear();
    _descriptionController.clear();
    _referenceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0,
        title: Text(
          _isEditMode ? 'Edit Dictionary Word' : 'Add Dictionary Word',
          style: boldTextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorPrimary, colorPrimary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorPrimary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.translate,
                      size: 48,
                      color: Colors.white,
                    ),
                    16.height,
                    Text(
                      'Arabic Dictionary Word',
                      style: boldTextStyle(size: 20, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    8.height,
                    Text(
                      _isEditMode 
                          ? 'Update the dictionary word information below'
                          : 'Add a new Arabic word to the dictionary',
                      style: secondaryTextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              24.height,

              // Arabic Word Input
              _buildInputCard(
                title: 'Arabic Word',
                subtitle: 'Enter the Arabic word',
                icon: Icons.text_fields,
                child: TextFormField(
                  controller: _arabicWordController,
                  textDirection: ui.TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'NotoNastaliq',
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اِلَّا',
                    hintStyle: TextStyle(
                      fontFamily: 'NotoNastaliq',
                      color: Colors.grey[400],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorPrimary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an Arabic word';
                    }
                    return null;
                  },
                ),
              ),
              16.height,

              // Description Input
              _buildInputCard(
                title: 'Description',
                subtitle: 'Enter the word description in Urdu',
                icon: Icons.description,
                child: TextFormField(
                  controller: _descriptionController,
                  textDirection: ui.TextDirection.rtl,
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'NotoNastaliq',
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اِلَّا: [حرف] (۱) الاّ کے معنی بطورِ حرفِ جر: علاوہ، سِوا، بِغیر، بِشمول کے آتے ہیں۔',
                    hintStyle: TextStyle(
                      fontFamily: 'NotoNastaliq',
                      color: Colors.grey[400],
                      height: 1.5,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorPrimary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
              ),
              16.height,

              // Reference Input
              _buildInputCard(
                title: 'Reference Image URL',
                subtitle: 'Enter the reference image URL (optional)',
                icon: Icons.image,
                child: TextFormField(
                  controller: _referenceController,
                  keyboardType: TextInputType.url,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'https://example.com/image.png',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorPrimary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: Icon(Icons.link, color: Colors.grey[400]),
                  ),
                ),
              ),
              32.height,

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _clearForm,
                      icon: Icon(Icons.clear),
                      label: Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.grey[700],
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  16.width,
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveDictionaryWord,
                      icon: _isLoading 
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(_isEditMode ? Icons.update : Icons.save),
                      label: Text(_isLoading 
                          ? 'Saving...' 
                          : _isEditMode ? 'Update Word' : 'Save Word'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
              24.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: colorPrimary, size: 20),
              ),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: boldTextStyle(size: 16),
                    ),
                    4.height,
                    Text(
                      subtitle,
                      style: secondaryTextStyle(size: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          16.height,
          child,
        ],
      ),
    );
  }
}
