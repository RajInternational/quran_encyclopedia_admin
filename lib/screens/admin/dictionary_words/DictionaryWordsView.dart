import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/DictionaryWordModel.dart';
import 'package:quizeapp/models/RootWordModel.dart';
import 'package:quizeapp/services/DictionaryWordsService.dart';
import 'package:quizeapp/services/RootWordsService.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import '../../../main.dart';

class DictionaryWordsView extends StatefulWidget {
  const DictionaryWordsView({Key? key}) : super(key: key);

  @override
  State<DictionaryWordsView> createState() => _DictionaryWordsViewState();
}

class _DictionaryWordsViewState extends State<DictionaryWordsView> {
  final DictionaryWordsService _dictionaryWordsService = DictionaryWordsService();
  final RootWordsService _rootWordsService = RootWordsService();
  final TextEditingController _arabicWordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  DictionaryWordModel? _editingWord;
  String? _selectedRootHash;
  List<RootWordModel> _rootWords = [];
  bool _isLoading = false;
  bool _showForm = false;
  bool _loadingRootWords = false;

  @override
  void initState() {
    super.initState();
    _loadRootWords();
  }

  @override
  void dispose() {
    _arabicWordController.dispose();
    super.dispose();
  }

  Future<void> _loadRootWords() async {
    setState(() {
      _loadingRootWords = true;
    });

    try {
      final rootWords = await _rootWordsService.getRootWordsFuture();
      setState(() {
        _rootWords = rootWords;
      });
    } catch (e) {
      toast('Error loading root words: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _loadingRootWords = false;
        });
      }
    }
  }

  void _clearForm({bool hideForm = true}) {
    _arabicWordController.clear();
    _selectedRootHash = null;
    _editingWord = null;
    if (hideForm) {
      _showForm = false;
    }
  }

  void _editWord(DictionaryWordModel word) {
    setState(() {
      _editingWord = word;
      _arabicWordController.text = word.arabicWord ?? '';
      _selectedRootHash = word.rootHash;
      _showForm = true;
    });
  }

  Future<void> _saveDictionaryWord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRootHash == null || _selectedRootHash!.isEmpty) {
      toast('Please select a root word');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dictionaryWord = DictionaryWordModel(
        id: _editingWord?.id,
        arabicWord: _arabicWordController.text.trim(),
        rootHash: _selectedRootHash,
      );

      if (_editingWord == null) {
        await _dictionaryWordsService.addDictionaryWord(dictionaryWord);
        toast('Dictionary word added successfully');
      } else {
        await _dictionaryWordsService.updateDictionaryWord(dictionaryWord);
        toast('Dictionary word updated successfully');
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

  Future<void> _deleteWord(DictionaryWordModel word) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Dictionary Word'),
          content: Text('Are you sure you want to delete "${word.arabicWord}"?'),
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
        await _dictionaryWordsService.deleteDictionaryWord(word.id!);
        toast('Dictionary word deleted successfully');
      } catch (e) {
        toast('Error deleting dictionary word: ${e.toString()}');
      }
    }
  }

  String? _getRootWordText(String? rootHash) {
    if (rootHash == null) return null;
    final rootWord = _rootWords.firstWhere(
      (rw) => rw.id == rootHash,
      orElse: () => RootWordModel(rootWord: 'Unknown'),
    );
    return rootWord.rootWord;
  }

  bool get _isWideScreen => MediaQuery.of(context).size.width > 600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Dictionary Words Management', style: boldTextStyle(color: Colors.white)),
        backgroundColor: colorPrimary,
        elevation: 0,
        actions: [
          if (!_showForm)
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                if (_rootWords.isEmpty) {
                  toast('Please add root words first');
                  return;
                }
                setState(() {
                  _clearForm(hideForm: false);
                  _showForm = true;
                });
              },
              tooltip: 'Add New Dictionary Word',
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
                          _editingWord == null ? 'Add Dictionary Word' : 'Edit Dictionary Word',
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
                      controller: _arabicWordController,
                      textFieldType: TextFieldType.NAME,
                      decoration: inputDecoration(labelText: 'Arabic Word *'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Arabic word is required';
                        }
                        return null;
                      },
                    ),
                    16.height,
                    DropdownButtonFormField<String>(
                      value: _selectedRootHash,
                      decoration: inputDecoration(labelText: 'Root Word *'),
                      items: _rootWords.map((rootWord) {
                        return DropdownMenuItem<String>(
                          value: rootWord.id,
                          child: Text(rootWord.rootWord ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRootHash = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Root word is required';
                        }
                        return null;
                      },
                    ),
                    16.height,
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: _editingWord == null ? 'Add Dictionary Word' : 'Update Dictionary Word',
                            textStyle: boldTextStyle(color: white),
                            color: colorPrimary,
                            onTap: _isLoading ? null : _saveDictionaryWord,
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
            child: StreamBuilder<List<DictionaryWordModel>>(
              stream: _dictionaryWordsService.streamDictionaryWords(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: colorPrimary),
                        16.height,
                        Text('Loading dictionary words...'),
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
                        Text('Error loading dictionary words'),
                        8.height,
                        Text(snapshot.error.toString(), style: secondaryTextStyle()),
                      ],
                    ),
                  );
                }

                final dictionaryWords = snapshot.data ?? [];

                if (dictionaryWords.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.translate_outlined, size: 64, color: Colors.grey[400]),
                        16.height,
                        Text('No Dictionary Words', style: boldTextStyle(size: 18, color: Colors.grey[600])),
                        8.height,
                        Text('Add your first dictionary word to get started', style: secondaryTextStyle(color: Colors.grey[500])),
                        24.height,
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_rootWords.isEmpty) {
                              toast('Please add root words first');
                              return;
                            }
                            setState(() {
                              _clearForm(hideForm: false);
                              _showForm = true;
                            });
                          },
                          icon: Icon(Icons.add),
                          label: Text('Add First Dictionary Word'),
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
                    ? _buildDataTable(dictionaryWords)
                    : _buildListView(dictionaryWords);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<DictionaryWordModel> dictionaryWords) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(colorPrimary.withOpacity(0.1)),
          columns: [
            DataColumn(label: Text('Arabic Word', style: boldTextStyle())),
            DataColumn(label: Text('Root Word', style: boldTextStyle())),
            DataColumn(label: Text('Created At', style: boldTextStyle())),
            DataColumn(label: Text('Actions', style: boldTextStyle())),
          ],
          rows: dictionaryWords.map((word) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    word.arabicWord ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'NotoNastaliq',
                      fontWeight: FontWeight.w600,
                      color: colorPrimary,
                    ),
                    textDirection: ui.TextDirection.rtl,
                  ),
                ),
                DataCell(Text(
                  _getRootWordText(word.rootHash) ?? 'N/A',
                  style: primaryTextStyle(),
                )),
                DataCell(Text(
                  word.createdAt != null
                      ? DateFormat('yyyy-MM-dd HH:mm').format(word.createdAt!)
                      : 'N/A',
                  style: secondaryTextStyle(size: 12),
                )),
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

  Widget _buildListView(List<DictionaryWordModel> dictionaryWords) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: dictionaryWords.length,
      itemBuilder: (context, index) {
        final word = dictionaryWords[index];
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
              word.arabicWord ?? '',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'NotoNastaliq',
                fontWeight: FontWeight.w600,
                color: colorPrimary,
              ),
              textDirection: ui.TextDirection.rtl,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                8.height,
                Row(
                  children: [
                    Icon(Icons.book, size: 14, color: Colors.grey[500]),
                    4.width,
                    Text(
                      'Root Word: ${_getRootWordText(word.rootHash) ?? 'N/A'}',
                      style: secondaryTextStyle(),
                    ),
                  ],
                ),
                8.height,
                Text(
                  'Created: ${word.createdAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(word.createdAt!) : 'N/A'}',
                  style: secondaryTextStyle(size: 12),
                ),
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

