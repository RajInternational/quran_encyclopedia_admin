import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class KeyboardEvent {}

class KeyboardFieldFocused extends KeyboardEvent {
  final String fieldName;
  final bool showTashkeel;
  
  KeyboardFieldFocused(this.fieldName, {this.showTashkeel = false});
}

class KeyboardFieldUnfocused extends KeyboardEvent {
  final String fieldName;
  
  KeyboardFieldUnfocused(this.fieldName);
}

class KeyboardHide extends KeyboardEvent {}

class TashkeelToggled extends KeyboardEvent {
  final bool showTashkeel;
  
  TashkeelToggled(this.showTashkeel);
}

// State
class KeyboardState {
  final bool showCustomKeyboard;
  final String currentInputField;
  final bool showTashkeel;
  
  KeyboardState({
    this.showCustomKeyboard = false,
    this.currentInputField = '',
    this.showTashkeel = false,
  });
  
  KeyboardState copyWith({
    bool? showCustomKeyboard,
    String? currentInputField,
    bool? showTashkeel,
  }) {
    return KeyboardState(
      showCustomKeyboard: showCustomKeyboard ?? this.showCustomKeyboard,
      currentInputField: currentInputField ?? this.currentInputField,
      showTashkeel: showTashkeel ?? this.showTashkeel,
    );
  }
}

// Cubit
class KeyboardCubit extends Cubit<KeyboardState> {
  KeyboardCubit() : super(KeyboardState());
  
  void fieldFocused(String fieldName, {bool showTashkeel = false}) {
    emit(state.copyWith(
      showCustomKeyboard: true,
      currentInputField: fieldName,
      showTashkeel: showTashkeel,
    ));
  }
  
  void fieldUnfocused(String fieldName) {
    // Only unfocus if this is the currently active field
    if (state.currentInputField == fieldName) {
      emit(state.copyWith(
        showCustomKeyboard: false,
        currentInputField: '',
        showTashkeel: false,
      ));
    }
  }
  
  void hideKeyboard() {
    emit(state.copyWith(
      showCustomKeyboard: false,
      currentInputField: '',
      showTashkeel: false,
    ));
  }
  
  void toggleTashkeel(bool showTashkeel) {
    emit(state.copyWith(showTashkeel: showTashkeel));
  }
}
