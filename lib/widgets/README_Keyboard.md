# Arabic/Urdu Keyboard - Reusable Components

This directory contains reusable components for implementing Arabic and Urdu keyboards in Flutter applications.

## Components

### 1. ArabicUrduKeyboard Widget (`ArabicUrduKeyboard.dart`)
A complete, self-contained keyboard widget that can be used in any screen.

**Features:**
- Arabic and Urdu character layouts
- Tashkeel marks (zabar, zair, pesh, etc.)
- Special characters and punctuation
- Copy, paste, clear, and backspace functionality
- Toggle between letters and tashkeel marks
- Responsive design that adapts to screen size

### 2. KeyboardController (`../controllers/KeyboardController.dart`)
A controller class that manages keyboard state and logic.

**Features:**
- Text insertion and manipulation
- Clipboard operations (copy/paste)
- Focus management
- State tracking (show/hide keyboard, tashkeel mode)

## Usage

### Basic Implementation

```dart
import 'package:quizeapp/widgets/ArabicUrduKeyboard.dart';
import 'package:quizeapp/controllers/KeyboardController.dart';

class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final _textController = TextEditingController();
  late KeyboardController _keyboardController;
  
  bool _showCustomKeyboard = false;
  bool _showTashkeel = false;
  String _currentInputField = '';

  @override
  void initState() {
    super.initState();
    
    // Initialize keyboard controller
    _keyboardController = KeyboardController(
      textController: _textController,
      focusNode: FocusNode(),
      fieldName: 'myField',
    );
    
    // Listen to keyboard state changes
    _keyboardController.focusNode.addListener(_onKeyboardStateChanged);
  }

  void _onKeyboardStateChanged() {
    setState(() {
      _showCustomKeyboard = _keyboardController.showCustomKeyboard;
      _currentInputField = _keyboardController.currentInputField;
      _showTashkeel = _keyboardController.showTashkeel;
    });
  }

  // Keyboard action handlers
  void _onTextInsert(String text) {
    _keyboardController.insertText(text);
  }

  void _onBackspace() {
    _keyboardController.backspace();
  }

  void _onClear() {
    _keyboardController.clearText();
  }

  void _onPaste() {
    _keyboardController.pasteText();
  }

  void _onCopy() {
    _keyboardController.copyText();
  }

  void _onHideKeyboard() {
    _keyboardController.hideKeyboard();
  }

  void _onTashkeelToggle(bool value) {
    _keyboardController.setShowTashkeel(value);
    setState(() {
      _showTashkeel = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: TextFormField(
              controller: _textController,
              focusNode: _keyboardController.focusNode,
              textDirection: ui.TextDirection.rtl,
              readOnly: true, // Important: Prevent default keyboard
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'NotoNastaliq',
              ),
            ),
          ),
          
          // Add the keyboard widget
          if (_showCustomKeyboard) 
            ArabicUrduKeyboard(
              onTextInsert: _onTextInsert,
              onBackspace: _onBackspace,
              onClear: _onClear,
              onPaste: _onPaste,
              onCopy: _onCopy,
              onHide: _onHideKeyboard,
              currentField: _currentInputField,
              showTashkeel: _showTashkeel,
              onTashkeelToggle: _onTashkeelToggle,
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _keyboardController.dispose();
    super.dispose();
  }
}
```

### Multiple Fields

For multiple fields, create separate controllers:

```dart
// Create controllers for each field
late KeyboardController _field1Controller;
late KeyboardController _field2Controller;

@override
void initState() {
  super.initState();
  
  _field1Controller = KeyboardController(
    textController: _field1TextController,
    focusNode: FocusNode(),
    fieldName: 'field1',
  );
  
  _field2Controller = KeyboardController(
    textController: _field2TextController,
    focusNode: FocusNode(),
    fieldName: 'field2',
  );
  
  // Listen to all controllers
  _field1Controller.focusNode.addListener(_onKeyboardStateChanged);
  _field2Controller.focusNode.addListener(_onKeyboardStateChanged);
}

void _onKeyboardStateChanged() {
  setState(() {
    _showCustomKeyboard = _field1Controller.showCustomKeyboard || 
                         _field2Controller.showCustomKeyboard;
    
    if (_field1Controller.showCustomKeyboard) {
      _currentInputField = _field1Controller.currentInputField;
      _showTashkeel = _field1Controller.showTashkeel;
    } else if (_field2Controller.showCustomKeyboard) {
      _currentInputField = _field2Controller.currentInputField;
      _showTashkeel = _field2Controller.showTashkeel;
    }
  });
}

KeyboardController _getCurrentController() {
  switch (_currentInputField) {
    case 'field1':
      return _field1Controller;
    case 'field2':
      return _field2Controller;
    default:
      return _field1Controller;
  }
}
```

## Features

### Keyboard Layouts
- **Arabic Layout**: Standard Arabic characters
- **Urdu Layout**: Urdu-specific characters (ی, ے, ں, etc.)
- **Tashkeel Marks**: Diacritical marks (َ ُ ِ ّ ْ etc.)
- **Special Characters**: Punctuation and symbols

### Actions
- **Text Insertion**: Add characters at cursor position
- **Backspace**: Remove character before cursor
- **Clear**: Clear entire field
- **Copy**: Copy field text to clipboard
- **Paste**: Paste clipboard text into field
- **Space**: Insert space character
- **Toggle Tashkeel**: Switch between letters and diacritical marks

### Styling
- Responsive height (40% of screen height)
- Customizable button colors
- RTL text direction support
- NotoNastaliq font for proper rendering

## Requirements

- Flutter 3.0+
- `nb_utils` package for toast messages
- `NotoNastaliq` font (included in assets)

## Example

See `../examples/KeyboardUsageExample.dart` for a complete working example.

## Notes

- Always set `readOnly: true` on TextFormField to prevent default keyboard
- Use `textDirection: ui.TextDirection.rtl` for proper RTL text display
- Remember to dispose controllers in the dispose method
- The keyboard automatically shows/hides based on focus state
