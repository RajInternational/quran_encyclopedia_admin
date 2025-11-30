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
  final TextEditingController _rootWordSearchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  DictionaryWordModel? _editingWord;
  String? _selectedRootHash;
  String? _selectedRootWordText;
  List<RootWordModel> _rootWords = [];
  List<RootWordModel> _filteredRootWords = [];
  bool _isLoading = false;
  bool _showForm = false;
  bool _loadingRootWords = false;
  bool _showRootWordSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadRootWords();
  }

  @override
  void dispose() {
    _arabicWordController.dispose();
    _rootWordSearchController.dispose();
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
    _rootWordSearchController.clear();
    _selectedRootHash = null;
    _selectedRootWordText = null;
    _editingWord = null;
    _filteredRootWords = [];
    _showRootWordSuggestions = false;
    if (hideForm) {
      _showForm = false;
    }
  }

  void _editWord(DictionaryWordModel word) {
    setState(() {
      _editingWord = word;
      _arabicWordController.text = word.arabicWord ?? '';
      _selectedRootHash = word.rootHash;
      // Find and set the root word text
      final rootWord = _rootWords.firstWhere(
        (rw) => rw.id == word.rootHash,
        orElse: () => RootWordModel(rootWord: 'Unknown'),
      );
      _selectedRootWordText = rootWord.rootWord;
      _rootWordSearchController.text = rootWord.rootWord ?? '';
      _showForm = true;
    });
  }

  void _filterRootWords(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredRootWords = [];
        _showRootWordSuggestions = false;
      } else {
        _filteredRootWords = _rootWords
            .where((rootWord) =>
                rootWord.rootWord?.toLowerCase().contains(query.toLowerCase()) ?? false)
            .toList();
        _showRootWordSuggestions = _filteredRootWords.isNotEmpty;
      }
    });
  }

  void _selectRootWord(RootWordModel rootWord) {
    setState(() {
      _selectedRootHash = rootWord.id;
      _selectedRootWordText = rootWord.rootWord;
      _rootWordSearchController.text = rootWord.rootWord ?? '';
      _showRootWordSuggestions = false;
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
                    // Root Word Search Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          controller: _rootWordSearchController,
                          textFieldType: TextFieldType.NAME,
                          decoration: inputDecoration(
                            labelText: 'Search Root Word *',
                            hintText: 'Type to search root words...',
                          ),
                          onChanged: _filterRootWords,
                          onTap: () {
                            if (_rootWordSearchController.text.isEmpty) {
                              setState(() {
                                _filteredRootWords = _rootWords;
                                _showRootWordSuggestions = _rootWords.isNotEmpty;
                              });
                            }
                          },
                          validator: (value) {
                            if (_selectedRootHash == null || _selectedRootHash!.isEmpty) {
                              return 'Please select a root word';
                            }
                            return null;
                          },
                          // suffixIcon: _selectedRootHash != null
                          //     ? IconButton(
                          //         icon: Icon(Icons.clear, color: Colors.grey),
                          //         onPressed: () {
                          //           setState(() {
                          //             _selectedRootHash = null;
                          //             _selectedRootWordText = null;
                          //             _rootWordSearchController.clear();
                          //             _showRootWordSuggestions = false;
                          //           });
                          //         },
                          //       )
                          //     : Icon(Icons.search, color: Colors.grey),
                        ),
                        // Suggestions List
                        if (_showRootWordSuggestions && _filteredRootWords.isNotEmpty)
                          Container(
                            constraints: BoxConstraints(maxHeight: 200),
                            margin: EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredRootWords.length,
                              itemBuilder: (context, index) {
                                final rootWord = _filteredRootWords[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    rootWord.rootWord ?? '',
                                    style: primaryTextStyle(),
                                  ),
                                  subtitle: rootWord.description != null &&
                                          rootWord.description!.isNotEmpty
                                      ? Text(
                                          rootWord.description!,
                                          style: secondaryTextStyle(size: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : null,
                                  onTap: () => _selectRootWord(rootWord),
                                  hoverColor: colorPrimary.withOpacity(0.1),
                                );
                              },
                            ),
                          ),
                        // Selected Root Word Display
                        if (_selectedRootHash != null && _selectedRootWordText != null) ...[
                          8.height,
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colorPrimary.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: colorPrimary, size: 20),
                                8.width,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selected: $_selectedRootWordText',
                                        style: boldTextStyle(color: colorPrimary),
                                      ),
                                      if (_rootWords
                                              .firstWhere(
                                                (rw) => rw.id == _selectedRootHash,
                                                orElse: () => RootWordModel(),
                                              )
                                              .description !=
                                          null)
                                        Text(
                                          _rootWords
                                              .firstWhere(
                                                (rw) => rw.id == _selectedRootHash,
                                                orElse: () => RootWordModel(),
                                              )
                                              .description!,
                                          style: secondaryTextStyle(size: 12),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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

