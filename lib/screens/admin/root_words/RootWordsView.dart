import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/RootWordModel.dart';
import 'package:quizeapp/services/RootWordsService.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import '../../../main.dart';

class RootWordsView extends StatefulWidget {
  const RootWordsView({Key? key}) : super(key: key);

  @override
  State<RootWordsView> createState() => _RootWordsViewState();
}

class _RootWordsViewState extends State<RootWordsView> {
  final RootWordsService _rootWordsService = RootWordsService();
  final TextEditingController _rootWordController = TextEditingController();
  final TextEditingController _triliteralRootWordController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _urduShortMeaningController = TextEditingController();
  final TextEditingController _englishShortMeaningController = TextEditingController();
  final TextEditingController _urduLongMeaningController = TextEditingController();
  final TextEditingController _englishLongMeaningController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  RootWordModel? _editingWord;
  bool _isLoading = false;
  bool _showForm = false;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _rootWordController.dispose();
    _descriptionController.dispose();
    _triliteralRootWordController.dispose();
    _urduShortMeaningController.dispose();
    _englishShortMeaningController.dispose();
    _urduLongMeaningController.dispose();
    _englishLongMeaningController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _clearForm({bool hideForm = true}) {
    _rootWordController.clear();
    _descriptionController.clear();
    _triliteralRootWordController.clear();
    _urduShortMeaningController.clear();
    _englishShortMeaningController.clear();
    _urduLongMeaningController.clear();
    _englishLongMeaningController.clear();

    _editingWord = null;
    if (hideForm) {
      _showForm = false;
    }
  }

  void _editWord(RootWordModel word) {
    setState(() {
      _editingWord = word;
      _rootWordController.text = word.rootWord ?? '';
      _descriptionController.text = word.description ?? '';
      _triliteralRootWordController.text = word.triLiteralWord ?? '';
      _urduShortMeaningController.text = word.urduShortMeaning ?? '';
      _englishShortMeaningController.text = word.englishShortMeaning ?? '';
      _urduLongMeaningController.text = word.urduLongMeaning ?? '';
      _englishLongMeaningController.text = word.englishLongMeaning ?? '';
      _showForm = true;
    });
  }

  Future<void> _saveRootWord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final rootWord = RootWordModel(
        id: _editingWord?.id,
        rootWord: _rootWordController.text.trim(),
        description: _descriptionController.text.trim(),
        triLiteralWord: _triliteralRootWordController.text.trim(),
        urduShortMeaning: _urduShortMeaningController.text.trim(),
        englishShortMeaning: _englishShortMeaningController.text.trim(),
        urduLongMeaning: _urduLongMeaningController.text.trim(),
        englishLongMeaning: _englishLongMeaningController.text.trim(),

      );

      if (_editingWord == null) {
        await _rootWordsService.addRootWord(rootWord);
        toast('Root word added successfully');
      } else {
        await _rootWordsService.updateRootWord(rootWord);
        toast('Root word updated successfully');
      }

      _clearForm(hideForm: true);
    } catch (e) {
      toast('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteWord(RootWordModel word) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Root Word'),
          content: Text('Are you sure you want to delete "${word.rootWord}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _rootWordsService.deleteRootWord(word.id!);
        toast('Root word deleted successfully');
      } catch (e) {
        toast('Error deleting root word: ${e.toString()}');
      }
    }
  }

  bool get _isWideScreen => MediaQuery.of(context).size.width > 600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Root Words Management', style: boldTextStyle(color: Colors.white)),
        backgroundColor: colorPrimary,
        elevation: 0,
        actions: [
          if (!_showForm)
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                setState(() {
                  _clearForm(hideForm: false);
                  _showForm = true;
                });
              },
              tooltip: 'Add New Root Word',
            ),
        ],
      ),
      body: Column(
        children: [
          // Form Section
          if (_showForm)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _editingWord == null ? 'Add Root Word' : 'Edit Root Word',
                                style: boldTextStyle(size: 18),
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () => setState(() => _clearForm(hideForm: true)),
                              ),
                            ],
                          ),
                          16.height,
                          AppTextField(
                            controller: _rootWordController,
                            textFieldType: TextFieldType.NAME,
                            decoration: inputDecoration(labelText: 'Root Word *'),
                            // enabled: _editingWord == null, // Can't edit root word once created
                            // Keep ONLY this field required
                            isValidationRequired: false,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Root word is required';
                              }
                              return null;
                            },
                          ),
                          16.height,
                          AppTextField(
                            controller: _descriptionController,
                            textFieldType: TextFieldType.MULTILINE,
                            maxLines: 3,
                            decoration: inputDecoration(labelText: 'Description'),
                            isValidationRequired: false,
                            validator: (_) => null,
                          ),
                          16.height,
                          AppTextField(
                            controller: _triliteralRootWordController,
                            textFieldType: TextFieldType.MULTILINE,
                            maxLines: 3,
                            decoration: inputDecoration(labelText: 'Triliteral Root'),
                            isValidationRequired: false,
                            validator: (_) => null,
                          ),
                          16.height,
                          AppTextField(
                            controller: _urduShortMeaningController,
                            textFieldType: TextFieldType.MULTILINE,
                            maxLines: 2,
                            decoration: inputDecoration(labelText: 'Urdu Short Meaning'),
                            isValidationRequired: false,
                            validator: (_) => null,
                          ),
                          16.height,
                          AppTextField(
                            controller: _englishShortMeaningController,
                            textFieldType: TextFieldType.MULTILINE,
                            maxLines: 2,
                            decoration: inputDecoration(labelText: 'English Short Meaning'),
                            isValidationRequired: false,
                            validator: (_) => null,
                          ),
                          16.height,
                          AppTextField(
                            controller: _urduLongMeaningController,
                            textFieldType: TextFieldType.MULTILINE,
                            maxLines: 3,
                            decoration: inputDecoration(labelText: 'Urdu Long Meaning'),
                            isValidationRequired: false,
                            validator: (_) => null,
                          ),
                          16.height,
                          AppTextField(
                            controller: _englishLongMeaningController,
                            textFieldType: TextFieldType.MULTILINE,
                            maxLines: 3,
                            decoration: inputDecoration(labelText: 'English Long Meaning'),
                            isValidationRequired: false,
                            validator: (_) => null,
                          ),
                          16.height,
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  text: _editingWord == null ? 'Add Root Word' : 'Update Root Word',
                                  textStyle: boldTextStyle(color: white),
                                  color: colorPrimary,
                                  onTap: _isLoading ? null : _saveRootWord,
                                ),
                              ),
                              12.width,
                              Expanded(
                                child: AppButton(
                                  text: 'Cancel',
                                  textStyle: boldTextStyle(color: colorPrimary),
                                  color: Colors.white,
                                  onTap: () => setState(() => _clearForm(hideForm: true)),
                                ),
                              ),
                            ],
                          ),
                          if (_isLoading) ...[
                            16.height,
                            Center(child: CircularProgressIndicator()),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // List Section
          if (!_showForm)
            Expanded(
              child: StreamBuilder<List<RootWordModel>>(
                stream: _rootWordsService.streamRootWords(),
                builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: colorPrimary),
                        16.height,
                        Text('Loading root words...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        16.height,
                        Text('Error loading root words'),
                        8.height,
                        Text(snapshot.error.toString(), style: secondaryTextStyle()),
                      ],
                    ),
                  );
                }

                final rootWords = snapshot.data ?? [];

                if (rootWords.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.library_books_outlined, size: 64, color: Colors.grey[400]),
                        16.height,
                        Text('No Root Words', style: boldTextStyle(size: 18, color: Colors.grey[600])),
                        8.height,
                        Text('Add your first root word to get started', style: secondaryTextStyle(color: Colors.grey[500])),
                        24.height,
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _clearForm(hideForm: false);
                              _showForm = true;
                            });
                          },
                          icon: Icon(Icons.add),
                          label: Text('Add First Root Word'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorPrimary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return _isWideScreen
                    ? _buildDataTable(rootWords)
                    : _buildListView(rootWords);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<RootWordModel> rootWords) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with count and scroll hint
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colorPrimary.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Root Words: ${rootWords.length}',
                  style: boldTextStyle(size: 14, color: colorPrimary),
                ),
                Row(
                  children: [
                    Icon(Icons.swap_horiz, size: 18, color: Colors.grey[600]),
                    8.width,
                    Text(
                      'Scroll horizontally',
                      style: secondaryTextStyle(size: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Scrollable table
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  thickness: 6,
                  radius: Radius.circular(3),
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: SingleChildScrollView(
                        controller: _verticalScrollController,
                        scrollDirection: Axis.vertical,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: DataTable(
                      headingRowColor: MaterialStateProperty.all(colorPrimary.withOpacity(0.1)),
                      columnSpacing: 20,
                      horizontalMargin: 12,
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 120,
                      columns: [
                        DataColumn(
                          label: Container(
                            constraints: BoxConstraints(minWidth: 150),
                            child: Text('Root Word', style: boldTextStyle(size: 14)),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            constraints: BoxConstraints(minWidth: 180),
                            child: Text('Trilateral Root', style: boldTextStyle(size: 14)),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            constraints: BoxConstraints(minWidth: 180),
                            child: Text('Urdu Short', style: boldTextStyle(size: 14)),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            constraints: BoxConstraints(minWidth: 180),
                            child: Text('English Short', style: boldTextStyle(size: 14)),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            constraints: BoxConstraints(minWidth: 220),
                            child: Text('Urdu Long', style: boldTextStyle(size: 14)),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            constraints: BoxConstraints(minWidth: 220),
                            child: Text('English Long', style: boldTextStyle(size: 14)),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            constraints: BoxConstraints(minWidth: 120),
                            child: Text('Actions', style: boldTextStyle(size: 14)),
                          ),
                        ),
                      ],
                      rows: rootWords.map((word) {
                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.hovered)) {
                                return colorPrimary.withOpacity(0.05);
                              }
                              return Colors.transparent;
                            },
                          ),
                          cells: [
                            DataCell(
                              Container(
                                constraints: BoxConstraints(minWidth: 150, maxWidth: 200),
                                child: Text(
                                  word.rootWord ?? '-',
                                  style: primaryTextStyle().copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorPrimary,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                constraints: BoxConstraints(minWidth: 180, maxWidth: 250),
                                child: Text(
                                  word.triLiteralWord?.isEmpty ?? true ? '-' : word.triLiteralWord!,
                                  style: secondaryTextStyle(),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                constraints: BoxConstraints(minWidth: 180, maxWidth: 250),
                                child: Text(
                                  word.urduShortMeaning?.isEmpty ?? true ? '-' : word.urduShortMeaning!,
                                  style: secondaryTextStyle(),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                constraints: BoxConstraints(minWidth: 180, maxWidth: 250),
                                child: Text(
                                  word.englishShortMeaning?.isEmpty ?? true ? '-' : word.englishShortMeaning!,
                                  style: secondaryTextStyle(),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                constraints: BoxConstraints(minWidth: 220, maxWidth: 300),
                                child: Text(
                                  word.urduLongMeaning?.isEmpty ?? true ? '-' : word.urduLongMeaning!,
                                  style: secondaryTextStyle(),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                constraints: BoxConstraints(minWidth: 220, maxWidth: 300),
                                child: Text(
                                  word.englishLongMeaning?.isEmpty ?? true ? '-' : word.englishLongMeaning!,
                                  style: secondaryTextStyle(),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                constraints: BoxConstraints(minWidth: 120),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: colorPrimary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.edit, color: colorPrimary, size: 20),
                                        onPressed: () => _editWord(word),
                                        tooltip: 'Edit',
                                        padding: EdgeInsets.all(8),
                                        constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                        onPressed: () => _deleteWord(word),
                                        tooltip: 'Delete',
                                        padding: EdgeInsets.all(8),
                                        constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<RootWordModel> rootWords) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with count
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colorPrimary.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Root Words: ${rootWords.length}',
                  style: boldTextStyle(size: 14, color: colorPrimary),
                ),
              ],
            ),
          ),
          // List items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: rootWords.length,
              itemBuilder: (context, index) {
                final word = rootWords[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          (index + 1).toString(),
                          style: boldTextStyle(size: 14, color: colorPrimary),
                        ),
                      ),
                    ),
                    title: Text(
                      word.rootWord ?? '',
                      style: boldTextStyle(size: 16, color: colorPrimary),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: colorPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.edit, color: colorPrimary, size: 20),
                            onPressed: () => _editWord(word),
                            tooltip: 'Edit',
                            padding: EdgeInsets.all(8),
                            constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _deleteWord(word),
                            tooltip: 'Delete',
                            padding: EdgeInsets.all(8),
                            constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        ),
                      ],
                    ),
                    children: [
                      if (word.triLiteralWord.validate().isNotEmpty) ...[
                        _buildInfoRow('Trilateral Root', word.triLiteralWord ?? ''),
                      ],
                      if (word.urduShortMeaning.validate().isNotEmpty) ...[
                        _buildInfoRow('Urdu Short Meaning', word.urduShortMeaning ?? ''),
                      ],
                      if (word.englishShortMeaning.validate().isNotEmpty) ...[
                        _buildInfoRow('English Short Meaning', word.englishShortMeaning ?? ''),
                      ],
                      if (word.urduLongMeaning.validate().isNotEmpty) ...[
                        _buildInfoRow('Urdu Long Meaning', word.urduLongMeaning ?? ''),
                      ],
                      if (word.englishLongMeaning.validate().isNotEmpty) ...[
                        _buildInfoRow('English Long Meaning', word.englishLongMeaning ?? ''),
                      ],
                      if (word.description.validate().isNotEmpty) ...[
                        _buildInfoRow('Description', word.description ?? ''),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: boldTextStyle(size: 12, color: Colors.grey[600]!),
          ),
          4.height,
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              value,
              style: secondaryTextStyle(),
            ),
          ),
        ],
      ),
    );
  }
}

