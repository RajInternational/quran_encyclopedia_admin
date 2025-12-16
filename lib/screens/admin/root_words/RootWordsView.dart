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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  RootWordModel? _editingWord;
  bool _isLoading = false;
  bool _showForm = false;

  @override
  void dispose() {
    _rootWordController.dispose();
    _descriptionController.dispose();
    _triliteralRootWordController.dispose();
    super.dispose();
  }

  void _clearForm({bool hideForm = true}) {
    _rootWordController.clear();
    _descriptionController.clear();
    _triliteralRootWordController.clear();

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
      _triliteralRootWordController.text=word.triLiteralWord ?? '' ;
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
            Container(
              padding: EdgeInsets.all(16),
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
                    ),
                    16.height,
                    AppTextField(
                      controller: _triliteralRootWordController,
                      textFieldType: TextFieldType.MULTILINE,
                      maxLines: 3,
                      decoration: inputDecoration(labelText: 'Triliteral Root'),
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

          // List Section
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(colorPrimary.withOpacity(0.1)),
          columns: [
            DataColumn(label: Text('Root Word', style: boldTextStyle())),
            DataColumn(label: Text('Description', style: boldTextStyle())),
            DataColumn(label: Text('Triliteral Root', style: boldTextStyle())),
            // DataColumn(label: Text('Created At', style: boldTextStyle())),
            DataColumn(label: Text('Actions', style: boldTextStyle())),
          ],
          rows: rootWords.map((word) {
            return DataRow(
              cells: [
                DataCell(Text(word.rootWord ?? '', style: primaryTextStyle())),
                DataCell(
                  Container(
                    constraints: BoxConstraints(maxWidth: 300),
                    child: Text(
                      word.description ?? '',
                      style: secondaryTextStyle(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    constraints: BoxConstraints(maxWidth: 300),
                    child: Text(
                      word.triLiteralWord ?? '',
                      style: secondaryTextStyle(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // DataCell(Text(
                //   word.createdAt != null
                //       ? DateFormat('yyyy-MM-dd HH:mm').format(word.createdAt!)
                //       : 'N/A',
                //   style: secondaryTextStyle(size: 12),
                // )),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: colorPrimary, size: 20),
                        onPressed: () => _editWord(word),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => _deleteWord(word),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildListView(List<RootWordModel> rootWords) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: rootWords.length,
      itemBuilder: (context, index) {
        final word = rootWords[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
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
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Text(
              word.rootWord ?? '',
              style: boldTextStyle(size: 16, color: colorPrimary),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (word.description != null && word.description!.isNotEmpty) ...[
                  8.height,
                  Text(
                    word.description!,
                    style: secondaryTextStyle(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  8.height,
                  Text(
                    word.triLiteralWord ?? '',
                    style: secondaryTextStyle(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                2.height,

              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: colorPrimary),
                  onPressed: () => _editWord(word),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteWord(word),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

