import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/controllers/KeyboardCubit.dart';

class KeyboardController {
  final TextEditingController textController;
  final FocusNode focusNode;
  final String fieldName;
  final KeyboardCubit keyboardCubit;

  KeyboardController({
    required this.textController,
    required this.focusNode,
    required this.fieldName,
    required this.keyboardCubit,
  }) {
    _setupFocusListener();
  }

  bool get showCustomKeyboard => keyboardCubit.state.showCustomKeyboard;
  bool get showTashkeel => keyboardCubit.state.showTashkeel;
  String get currentInputField => keyboardCubit.state.currentInputField;

  void _setupFocusListener() {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        keyboardCubit.fieldFocused(fieldName);
        print('DEBUG: Focus gained for field: $fieldName');
      } else {
        keyboardCubit.fieldUnfocused(fieldName);
        print('DEBUG: Focus lost for field: $fieldName');
      }
    });
  }

  void insertText(String text) {
    final currentText = textController.text;
    final selection = textController.selection;
    final newText = currentText.substring(0, selection.start) + text + currentText.substring(selection.end);
    textController.text = newText;
    textController.selection = TextSelection.collapsed(offset: selection.start + text.length);
  }

  void backspace() {
    final currentText = textController.text;
    final selection = textController.selection;
    
    if (selection.start > 0) {
      final newText = currentText.substring(0, selection.start - 1) + currentText.substring(selection.end);
      textController.text = newText;
      textController.selection = TextSelection.collapsed(offset: selection.start - 1);
    }
  }

  void clearText() {
    textController.clear();
  }

  Future<void> pasteText() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      insertText(data!.text!);
    }
  }

  void copyText() {
    if (textController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: textController.text));
      toast('Text copied to clipboard');
    }
  }

  void hideKeyboard() {
    keyboardCubit.hideKeyboard();
    focusNode.unfocus();
  }

  void toggleTashkeel() {
    keyboardCubit.toggleTashkeel(!keyboardCubit.state.showTashkeel);
  }

  void setShowTashkeel(bool value) {
    keyboardCubit.toggleTashkeel(value);
  }

  void dispose() {
    textController.dispose();
    focusNode.dispose();
  }
}
