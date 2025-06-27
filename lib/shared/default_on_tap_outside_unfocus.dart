import 'package:flutter/material.dart';

/// Action triggered when a tap is detected outside an [EditableText] widget.
///
/// This action extends [ContextAction] to handle the
/// [EditableTextTapOutsideIntent].
/// When invoked, it unfocuses the associated [FocusNode],
/// typically dismissing the on-screen keyboard.
class EditableTextTapOutsideAction
    extends ContextAction<EditableTextTapOutsideIntent> {
  EditableTextTapOutsideAction();

  /// Invokes the action when a tap outside the [EditableText] is detected.
  ///
  /// Removes focus from the [FocusNode] provided in the intent,
  /// which usually hides the keyboard.
  @override
  void invoke(EditableTextTapOutsideIntent intent, [BuildContext? context]) {
    intent.focusNode.unfocus();
  }
}
