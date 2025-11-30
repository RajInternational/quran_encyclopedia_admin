import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/DictionaryWordModel.dart';
import 'package:quizeapp/models/RootWordModel.dart';
import 'package:quizeapp/services/DictionaryWordsService.dart';
import 'package:quizeapp/services/RootWordsService.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';

class DictionaryWordsView extends StatefulWidget {
  const DictionaryWordsView({Key? key}) : super(key: key);

  @override
  State<DictionaryWordsView> createState() => _DictionaryWordsViewState();
}

class _DictionaryWordsViewState extends State<DictionaryWordsView> {
  final DictionaryWordsService _dictionaryWordsService = DictionaryWordsService();
  final RootWordsService _rootWordsService = RootWordsService();

  final TextEditingController _arabicWordController = TextEditingController();
  final TextEditingController _rootSearchController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<RootWordModel> _rootWords = [];
  List<RootWordModel> _filteredRootWords = [];

  String? _selectedRootHash;
  bool _showForm = false;
  bool _showSuggestions = false;
  bool _isSaving = false;

  DictionaryWordModel? _editingWord;

  @override
  void initState() {
    super.initState();
    _loadRootWords();
  }

  Future<void> _loadRootWords() async {
    try {
      _rootWords = await _rootWordsService.getRootWordsFuture();
      setState(() {});
    } catch (e) {
      toast("Error loading root words");
    }
  }

  void _openAddForm() {
    setState(() {
      _editingWord = null;
      _arabicWordController.clear();
      _rootSearchController.clear();
      _selectedRootHash = null;
      _filteredRootWords = [];
      _showSuggestions = false;
      _showForm = true;
    });
  }

  void _openEditForm(DictionaryWordModel word) {
    final root = _rootWords.firstWhere(
          (e) => e.id == word.rootHash,
      orElse: () => RootWordModel(rootWord: "Unknown"),
    );

    setState(() {
      _editingWord = word;
      _arabicWordController.text = word.arabicWord ?? "";
      _rootSearchController.text = root.rootWord ?? "";
      _selectedRootHash = root.id;
      _showSuggestions = false;
      _showForm = true;
    });
  }

  void _filterRootWords(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredRootWords = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() {
      _filteredRootWords = _rootWords
          .where((e) => (e.rootWord ?? "").toLowerCase().contains(query.toLowerCase()))
          .toList();

      _showSuggestions = _filteredRootWords.isNotEmpty;
    });
  }

  void _selectRootWord(RootWordModel root) {
    setState(() {
      _rootSearchController.text = root.rootWord ?? "";
      _selectedRootHash = root.id;
      _showSuggestions = false;
    });
  }

  Future<void> _saveWord() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRootHash == null) {
      toast("Please select a root word");
      return;
    }

    setState(() => _isSaving = true);

    try {
      final newWord = DictionaryWordModel(
        id: _editingWord?.id,
        arabicWord: _arabicWordController.text.trim(),
        rootHash: _selectedRootHash,
      );

      if (_editingWord == null) {
        await _dictionaryWordsService.addDictionaryWord(newWord);
        toast("Word added");
      } else {
        await _dictionaryWordsService.updateDictionaryWord(newWord);
        toast("Word updated");
      }

      setState(() => _showForm = false);
    } catch (e) {
      toast("Error saving word");
    }

    setState(() => _isSaving = false);
  }

  Future<void> _deleteWord(DictionaryWordModel word) async {
    bool? confirm = await showConfirmDialog(context, "Delete this word?");
    if (confirm ?? false) {
      await _dictionaryWordsService.deleteDictionaryWord(word.id!);
      toast("Deleted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dictionary Words", style: boldTextStyle(color: white)),
        backgroundColor: colorPrimary,
        actions: [
          if (!_showForm)
            IconButton(
              icon: Icon(Icons.add, color: white),
              onPressed: _openAddForm,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_showForm)
            Container(
              padding: EdgeInsets.all(16),
              color: white,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    10.height,

                    AppTextField(
                      controller: _arabicWordController,
                      textFieldType: TextFieldType.NAME,
                      decoration: inputDecoration(labelText: "Arabic Word *"),
                      validator: (v) => v!.trim().isEmpty ? "Required" : null,
                    ),

                    20.height,

                    AppTextField(
                      controller: _rootSearchController,
                      textFieldType: TextFieldType.NAME,
                      decoration: inputDecoration(labelText: "Search Root Word *"),
                      onChanged: _filterRootWords,
                      onTap: () {
                        setState(() {
                          _filteredRootWords = _rootWords;
                          _showSuggestions = true;
                        });
                      },
                      validator: (v) {
                        if (_selectedRootHash == null) return "Select a root word";
                        return null;
                      },
                    ),

                    if (_showSuggestions)
                      Container(
                        height: 180,
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: radius(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListView.builder(
                          itemCount: _filteredRootWords.length,
                          itemBuilder: (_, i) {
                            final word = _filteredRootWords[i];
                            return ListTile(
                              title: Text(word.rootWord ?? ""),
                              subtitle: Text(
                                word.description ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _selectRootWord(word),
                            );
                          },
                        ),
                      ),

                    20.height,

                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: _editingWord == null ? "Add Word" : "Update Word",
                            onTap: _isSaving ? null : _saveWord,
                            color: colorPrimary,
                          ),
                        ),
                        10.width,
                        Expanded(
                          child: AppButton(
                            text: "Cancel",
                            color: white,
                            textStyle: boldTextStyle(color: colorPrimary),
                            onTap: () => setState(() => _showForm = false),
                          ),
                        ),
                      ],
                    ),

                    if (_isSaving) 20.height,
                    if (_isSaving) CircularProgressIndicator(),
                  ],
                ),
              ),
            ),

          Expanded(
            child: StreamBuilder<List<DictionaryWordModel>>(
              stream: _dictionaryWordsService.streamDictionaryWords(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final list = snap.data!;

                if (list.isEmpty) {
                  return Center(child: Text("No dictionary words found"));
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final word = list[i];
                    final root = _rootWords.firstWhere(
                          (e) => e.id == word.rootHash,
                      orElse: () => RootWordModel(rootWord: "Unknown"),
                    );

                    return Card(
                      margin: EdgeInsets.all(12),
                      child: ListTile(
                        title: Text(word.arabicWord ?? ""),
                        subtitle: Text("Root: ${root.rootWord}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _openEditForm(word),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteWord(word),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
