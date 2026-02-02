import 'package:flutter/material.dart';
import 'package:quizeapp/utils/Colors.dart';

/// Standalone Urdu keyboard with full character set.
/// Use with TextEditingController - inserts text on key press.
class UrduKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onBackspace;
  final VoidCallback? onEnter;
  final Color? keyColor;
  final Color? keyTextColor;
  final double keyHeight;
  final double keyFontSize;

  const UrduKeyboard({
    Key? key,
    required this.controller,
    this.onBackspace,
    this.onEnter,
    this.keyColor,
    this.keyTextColor,
    this.keyHeight = 44,
    this.keyFontSize = 18,
  }) : super(key: key);

  @override
  State<UrduKeyboard> createState() => _UrduKeyboardState();
}

class _UrduKeyboardState extends State<UrduKeyboard> {
  int _selectedTab = 0; // 0: Letters, 1: Numbers & Symbols, 2: Diacritics

  void _onKeyTap(String char) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final baseOffset = selection.baseOffset.clamp(0, text.length);
    final extentOffset = selection.extentOffset.clamp(0, text.length);
    final start = baseOffset < extentOffset ? baseOffset : extentOffset;
    final end = baseOffset > extentOffset ? baseOffset : extentOffset;

    String newText;
    int newCursorPos;

    if (char == '\b') {
      if (start == end && start > 0) {
        newText = text.substring(0, start - 1) + text.substring(start);
        newCursorPos = start - 1;
      } else if (start != end) {
        newText = text.substring(0, start) + text.substring(end);
        newCursorPos = start;
      } else {
        return;
      }
      widget.onBackspace?.call();
    } else if (char == '\n') {
      newText = text.substring(0, start) + '\n' + text.substring(end);
      newCursorPos = start + 1;
      widget.onEnter?.call();
    } else {
      newText = text.substring(0, start) + char + text.substring(end);
      newCursorPos = start + char.length;
    }

    widget.controller.text = newText;
    widget.controller.selection = TextSelection.collapsed(offset: newCursorPos);
    setState(() {});
  }

  Widget _buildKey(String char, {double flex = 1}) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Padding(
        padding: EdgeInsets.all(2),
        child: Material(
          color: widget.keyColor ?? Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          elevation: 1,
          child: InkWell(
            onTap: () => _onKeyTap(char),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: widget.keyHeight,
              alignment: Alignment.center,
              child: char == '\b'
                  ? Icon(Icons.backspace_outlined, size: 22, color: Colors.black87)
                  : char == '\n'
                      ? Icon(Icons.keyboard_return, size: 22, color: Colors.black87)
                      : Text(
                          char,
                          style: TextStyle(
                            fontFamily: char.runes.any((r) => r >= 0x0600 && r <= 0x06FF)
                                ? 'ArabicFonts'
                                : null,
                            fontSize: char.length > 1 ? widget.keyFontSize - 2 : widget.keyFontSize,
                            color: widget.keyTextColor ?? Colors.black87,
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyRow(List<String> keys, {List<double>? flexValues}) {
    return Row(
      children: List.generate(keys.length, (i) {
        return _buildKey(keys[i], flex: flexValues != null && i < flexValues.length ? flexValues[i] : 1);
      }),
    );
  }

  Widget _buildLettersLayout() {
    final row1 = ['ا', 'ب', 'پ', 'ت', 'ٹ', 'ث', 'ج', 'چ', 'ح', 'خ'];
    final row2 = ['د', 'ڈ', 'ذ', 'ر', 'ڑ', 'ز', 'ژ', 'س', 'ش', 'ص'];
    final row3 = ['ض', 'ط', 'ظ', 'ع', 'غ', 'ف', 'ق', 'ک', 'گ', 'ل'];
    final row4 = ['م', 'ن', 'ں', 'و', 'ہ', 'ھ', 'ء', 'ی', 'ے', 'ۓ'];
    final row5 = ['آ', 'أ', 'إ', 'ؤ', 'ئ', 'ٔ', 'ٰ', 'ة', 'ه', 'و'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildKeyRow(row1),
        SizedBox(height: 4),
        _buildKeyRow(row2),
        SizedBox(height: 4),
        _buildKeyRow(row3),
        SizedBox(height: 4),
        _buildKeyRow(row4),
        SizedBox(height: 4),
        _buildKeyRow(row5),
      ],
    );
  }

  Widget _buildNumbersLayout() {
    final row1 = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    final row2 = ['۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹', '۰'];
    final row3 = ['،', '۔', '؛', '؟', '!', '(', ')', '-', '_', '='];
    final row4 = ['+', '[', ']', '{', '}', '@', '#', '\$', '%', '^'];
    final row5 = ['&', '*', '"', "'", '<', '>', '/', '\\', '|', '~'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildKeyRow(row1),
        SizedBox(height: 4),
        _buildKeyRow(row2),
        SizedBox(height: 4),
        _buildKeyRow(row3),
        SizedBox(height: 4),
        _buildKeyRow(row4),
        SizedBox(height: 4),
        _buildKeyRow(row5),
      ],
    );
  }

  Widget _buildDiacriticsLayout() {
    final row1 = ['َ', 'ُ', 'ِ', 'ْ', 'ّ', 'ً', 'ٌ', 'ٍ', 'ٰ', 'ٔ'];
    final row2 = ['ٓ', 'ٖ', 'ٗ', '٘', 'ٙ', 'ٚ', 'ٛ', 'ٜ', 'ٝ', 'ٞ'];
    final row3 = ['ٟ', 'ۖ', 'ۗ', 'ۘ', 'ۙ', 'ۚ', 'ۛ', 'ۜ', '۝', '۞'];
    final row4 = ['۟', '۠', 'ۡ', 'ۢ', 'ۣ', 'ۤ', 'ۥ', 'ۦ', 'ۧ', 'ۨ'];
    final row5 = ['۩', '۪', '۫', '۬', 'ۭ', 'ـ', '٠', '١', '٢', '٣'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildKeyRow(row1),
        SizedBox(height: 4),
        _buildKeyRow(row2),
        SizedBox(height: 4),
        _buildKeyRow(row3),
        SizedBox(height: 4),
        _buildKeyRow(row4),
        SizedBox(height: 4),
        _buildKeyRow(row5),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tabs: Letters | Numbers | Diacritics
          Row(
            children: [
              _buildTab(0, 'حروف'),
              _buildTab(1, 'اعداد'),
              _buildTab(2, 'اعراب'),
            ],
          ),
          SizedBox(height: 8),
          // Keyboard layout
          AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: _selectedTab == 0
                ? KeyedSubtree(key: ValueKey('letters'), child: _buildLettersLayout())
                : _selectedTab == 1
                    ? KeyedSubtree(key: ValueKey('numbers'), child: _buildNumbersLayout())
                    : KeyedSubtree(key: ValueKey('diacritics'), child: _buildDiacriticsLayout()),
          ),
          SizedBox(height: 8),
          // Action row
          Row(
            children: [
              _buildKey(' ', flex: 5),
              _buildKey('\b', flex: 1.5),
              _buildKey('\n', flex: 1.5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: isSelected ? colorPrimary : Colors.grey[400],
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => setState(() => _selectedTab = index),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'ArabicFonts',
                  fontSize: 16,
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
