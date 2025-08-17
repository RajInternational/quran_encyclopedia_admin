import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/DictionaryWordData.dart';
import 'dart:ui' as ui;
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/widgets/ArabicUrduKeyboard.dart';
import 'package:quizeapp/controllers/KeyboardController.dart';
import 'package:quizeapp/controllers/KeyboardCubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  
  // Keyboard Cubit for state management
  late KeyboardCubit _keyboardCubit;
  
  // Keyboard Controllers
  late KeyboardController _arabicWordKeyboardController;
  late KeyboardController _rootWordKeyboardController;
  late KeyboardController _descriptionKeyboardController;
  
  // Reference field uses regular focus node (no custom keyboard)
  final FocusNode _referenceFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    // Initialize keyboard cubit
    _keyboardCubit = KeyboardCubit();
    
    // Initialize keyboard controllers with cubit
    _arabicWordKeyboardController = KeyboardController(
      textController: _arabicWordController,
      focusNode: FocusNode(),
      fieldName: 'arabicWord',
      keyboardCubit: _keyboardCubit,
    );
    
    _rootWordKeyboardController = KeyboardController(
      textController: _rootWordController,
      focusNode: FocusNode(),
      fieldName: 'rootWord',
      keyboardCubit: _keyboardCubit,
    );
    
    _descriptionKeyboardController = KeyboardController(
      textController: _descriptionController,
      focusNode: FocusNode(),
      fieldName: 'description',
      keyboardCubit: _keyboardCubit,
    );

    // Load existing data if editing
    if (widget.wordToEdit != null) {
      _arabicWordController.text = widget.wordToEdit!.arabicWord ?? '';
      _rootWordController.text = widget.wordToEdit!.rootWord ?? '';
      _descriptionController.text = widget.wordToEdit!.description ?? '';
      _referenceController.text = widget.wordToEdit!.reference ?? '';
    }
  }

  KeyboardController _getCurrentKeyboardController() {
    final currentField = _keyboardCubit.state.currentInputField;
    print('DEBUG: Getting controller for field: $currentField');
    
    switch (currentField) {
      case 'arabicWord':
        print('DEBUG: Returning Arabic Word controller');
        return _arabicWordKeyboardController;
      case 'rootWord':
        print('DEBUG: Returning Root Word controller');
        return _rootWordKeyboardController;
      case 'description':
        print('DEBUG: Returning Description controller');
        return _descriptionKeyboardController;
      default:
        print('DEBUG: Returning default Arabic Word controller');
        return _arabicWordKeyboardController;
    }
  }

  void _onTextInsert(String text) {
    _getCurrentKeyboardController().insertText(text);
  }

  void _onBackspace() {
    _getCurrentKeyboardController().backspace();
  }

  void _onClear() {
    _getCurrentKeyboardController().clearText();
  }

  void _onPaste() {
    _getCurrentKeyboardController().pasteText();
  }

  void _onCopy() {
    _getCurrentKeyboardController().copyText();
  }

  void _onHideKeyboard() {
    _getCurrentKeyboardController().hideKeyboard();
  }

  void _onTashkeelToggle(bool value) {
    _getCurrentKeyboardController().setShowTashkeel(value);
  }

  Future<void> _saveWord() async {
    if (!_formKey.currentState!.validate()) return;

    // Hide keyboard before saving
    _keyboardCubit.hideKeyboard();

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
      
      // Navigate back after a short delay to ensure UI updates
      await Future.delayed(Duration(milliseconds: 100));
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
    return BlocProvider(
      create: (context) => _keyboardCubit,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        resizeToAvoidBottomInset: false, // Prevent screen resize when keyboard shows
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
        body: BlocBuilder<KeyboardCubit, KeyboardState>(
          builder: (context, keyboardState) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: keyboardState.showCustomKeyboard ? 16 : 16,
                    ),
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
                              focusNode: _arabicWordKeyboardController.focusNode,
                              textDirection: ui.TextDirection.rtl,
                              readOnly: true, // Prevent default keyboard
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
                              focusNode: _rootWordKeyboardController.focusNode,
                              textDirection: ui.TextDirection.rtl,
                              readOnly: true, // Prevent default keyboard
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
                              focusNode: _descriptionKeyboardController.focusNode,
                              textDirection: ui.TextDirection.rtl,
                              maxLines: 4,
                              readOnly: true, // Prevent default keyboard
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
                               focusNode: _referenceFocusNode,
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
          ),
          
          // Custom Keyboard
          if (keyboardState.showCustomKeyboard) 
            ArabicUrduKeyboard(
              onTextInsert: _onTextInsert,
              onBackspace: _onBackspace,
              onClear: _onClear,
              onPaste: _onPaste,
              onCopy: _onCopy,
              onHide: _onHideKeyboard,
              currentField: keyboardState.currentInputField,
              showTashkeel: keyboardState.showTashkeel,
              onTashkeelToggle: _onTashkeelToggle,
            ),
        ],
      );
    },
  ),
        ),
      );

  }

  @override
  void dispose() {
    _keyboardCubit.close();
    _arabicWordKeyboardController.dispose();
    _rootWordKeyboardController.dispose();
    _descriptionKeyboardController.dispose();
    _referenceFocusNode.dispose();
    super.dispose();
  }
}
