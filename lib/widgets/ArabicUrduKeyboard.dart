import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/utils/Colors.dart';

class ArabicUrduKeyboard extends StatefulWidget {
  final Function(String) onTextInsert;
  final Function() onBackspace;
  final Function() onClear;
  final Function() onPaste;
  final Function() onCopy;
  final Function() onHide;
  final String currentField;
  final bool showTashkeel;
  final Function(bool) onTashkeelToggle;

  const ArabicUrduKeyboard({
    Key? key,
    required this.onTextInsert,
    required this.onBackspace,
    required this.onClear,
    required this.onPaste,
    required this.onCopy,
    required this.onHide,
    required this.currentField,
    required this.showTashkeel,
    required this.onTashkeelToggle,
  }) : super(key: key);

  @override
  _ArabicUrduKeyboardState createState() => _ArabicUrduKeyboardState();
}

class _ArabicUrduKeyboardState extends State<ArabicUrduKeyboard> {
  // Arabic Keyboard Layout (like real keyboard) - Reduced characters per row
  final List<List<String>> _arabicKeys = [
    ['ض', 'ص', 'ث', 'ق', 'ف', 'غ', 'ع', 'ه', 'خ', 'ح'],
    ['ش', 'س', 'ي', 'ب', 'ل', 'ا', 'ت', 'ن', 'م', 'ك'],
    ['ئ', 'ء', 'ؤ', 'ر', 'لا', 'ى', 'ة', 'و', 'ز', 'د'],
    ['إ', 'أ', 'آ', 'ظ', 'ط', 'ذ', 'خ', 'غ'],
  ];

  // Urdu Keyboard Layout (proper Urdu characters) - Reduced characters per row
  final List<List<String>> _urduKeys = [
    ['ض', 'ص', 'ث', 'ق', 'ف', 'غ', 'ع', 'ہ', 'خ', 'ح'],
    ['ش', 'س', 'ی', 'ب', 'ل', 'ا', 'ت', 'ن', 'م', 'ک'],
    ['ئ', 'ء', 'ؤ', 'ر', 'لا', 'ی', 'ے', 'و', 'ز', 'د'],
    ['ں', 'گ', 'ڈ', 'ڑ', 'پ', 'چ', 'ژ', 'ٹ'],
  ];

  // Tashkeel Marks (zabar, zair, pesh, etc.)
  final List<String> _tashkeelMarks = ['َ', 'ُ', 'ِ', 'ّ', 'ْ', 'ً', 'ٌ', 'ٍ', 'ٰ', 'ٓ', 'ٔ', 'ٕ'];

  // Special Characters - Reduced to prevent overflow
  final List<String> _specialChars = ['،', '؛', '؟', '۔', '٪', '(', ')', '[', ']', '"', '"', ''', ''', '-', '_'];

  Widget _buildKeyboardButton(String text, {Color? color, double? width}) {
    return Container(
      width: width ?? 26,
      height: 36,
      margin: EdgeInsets.all(1),
      child: ElevatedButton(
        onPressed: () => widget.onTextInsert(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.grey[200],
          foregroundColor: Colors.black87,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          elevation: 1,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'NotoNastaliq',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed, {Color? color}) {
    return Container(
      width: 32,
      height: 32,
      margin: EdgeInsets.all(1),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? colorPrimary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          elevation: 1,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  String _getCurrentFieldDisplayName() {
    switch (widget.currentField) {
      case 'arabicWord':
        return 'Arabic Word';
      case 'rootWord':
        return 'Root Word';
      case 'description':
        return 'Description (Urdu)';
      case 'reference':
        return 'Reference (English)';
      default:
        return 'Text Field';
    }
  }

  List<List<String>> _getCurrentKeyboard() {
    // Use Urdu keyboard for description field, Arabic for others
    if (widget.currentField == 'description') {
      return _urduKeys;
    } else {
      return _arabicKeys;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Current field indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.grey[200],
            child: Row(
              children: [
                Icon(Icons.keyboard, size: 16, color: Colors.grey[600]),
                8.width,
                Text(
                  'Current: ${_getCurrentFieldDisplayName()}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Spacer(),
                IconButton(
                  onPressed: widget.onHide,
                  icon: Icon(Icons.keyboard_hide, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Main keyboard content
          Expanded(
            child: Column(
              children: [
                // Action buttons row
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      _buildActionButton(Icons.content_paste, widget.onPaste, color: Colors.blue),
                      8.width,
                      _buildActionButton(Icons.copy, widget.onCopy, color: Colors.green),
                      8.width,
                      _buildActionButton(Icons.clear, widget.onClear, color: Colors.orange),
                      8.width,
                      _buildActionButton(Icons.backspace, widget.onBackspace, color: Colors.red),
                      Spacer(),
                      _buildActionButton(Icons.space_bar, () => widget.onTextInsert(' '), color: Colors.grey),
                    ],
                  ),
                ),

                // Arabic/Urdu letters (main keyboard)
                if (!widget.showTashkeel) ...[
                  // First row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Row(
                      children: _getCurrentKeyboard()[0].map((key) => Expanded(
                        child: _buildKeyboardButton(key),
                      )).toList(),
                    ),
                  ),
                  
                  // Second row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Row(
                      children: _getCurrentKeyboard()[1].map((key) => Expanded(
                        child: _buildKeyboardButton(key),
                      )).toList(),
                    ),
                  ),
                  
                  // Third row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Row(
                      children: _getCurrentKeyboard()[2].map((key) => Expanded(
                        child: _buildKeyboardButton(key),
                      )).toList(),
                    ),
                  ),
                  
                  // Fourth row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Row(
                      children: _getCurrentKeyboard()[3].map((key) => Expanded(
                        child: _buildKeyboardButton(key),
                      )).toList(),
                    ),
                  ),
                ],

                // Tashkeel marks (when toggled)
                if (widget.showTashkeel) ...[
                  // Tashkeel row 1
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Row(
                      children: _tashkeelMarks.take(6).map((mark) => Expanded(
                        child: _buildKeyboardButton(mark),
                      )).toList(),
                    ),
                  ),
                  
                  // Tashkeel row 2
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Row(
                      children: _tashkeelMarks.skip(6).map((mark) => Expanded(
                        child: _buildKeyboardButton(mark),
                      )).toList(),
                    ),
                  ),
                  
                  // Special characters row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Row(
                      children: _specialChars.take(8).map((char) => Expanded(
                        child: _buildKeyboardButton(char),
                      )).toList(),
                    ),
                  ),
                  
                  // More special characters
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Row(
                      children: _specialChars.skip(8).map((char) => Expanded(
                        child: _buildKeyboardButton(char),
                      )).toList(),
                    ),
                  ),
                ],

                // Bottom row with toggle button and space
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      // Tashkeel toggle button
                      Expanded(
                        flex: 2,
                        child: _buildActionButton(
                          widget.showTashkeel ? Icons.keyboard : Icons.text_fields,
                          () => widget.onTashkeelToggle(!widget.showTashkeel),
                          color: widget.showTashkeel ? Colors.purple : Colors.grey[600],
                        ),
                      ),
                      8.width,
                      // Space bar
                      Expanded(
                        flex: 6,
                        child: _buildActionButton(
                          Icons.space_bar,
                          () => widget.onTextInsert(' '),
                          color: Colors.grey[400],
                        ),
                      ),
                      8.width,
                      // Backspace
                      Expanded(
                        flex: 2,
                        child: _buildActionButton(
                          Icons.backspace,
                          widget.onBackspace,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
