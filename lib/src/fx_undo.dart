import 'package:flutter/widgets.dart';

/// A reversible semantic operation tracked by [FxUndoController].
class FxUndoAction {
  /// Creates an undoable action.
  const FxUndoAction({
    required this.label,
    required this.apply,
    required this.revert,
  });

  /// Creates one action from multiple operations.
  ///
  /// The operations are applied in order and reverted in reverse order so
  /// grouped form or grid edits behave as one user-visible undo step.
  factory FxUndoAction.batch({
    required String label,
    required Iterable<FxUndoAction> actions,
  }) {
    final actionList = List<FxUndoAction>.unmodifiable(actions);
    return FxUndoAction(
      label: label,
      apply: () {
        for (final action in actionList) {
          action.apply();
        }
      },
      revert: () {
        for (final action in actionList.reversed) {
          action.revert();
        }
      },
    );
  }

  /// Human-readable action name shown in menus and toolbars.
  final String label;

  /// Applies or reapplies the operation.
  final VoidCallback apply;

  /// Reverts the operation.
  final VoidCallback revert;
}

/// Tracks app-level semantic undo and redo actions for FxDesktop apps.
class FxUndoController extends ChangeNotifier {
  final List<FxUndoAction> _undoStack = <FxUndoAction>[];
  final List<FxUndoAction> _redoStack = <FxUndoAction>[];

  /// Whether an undo operation is available.
  bool get canUndo => _undoStack.isNotEmpty;

  /// Whether a redo operation is available.
  bool get canRedo => _redoStack.isNotEmpty;

  /// Label for the next undo operation, if available.
  String? get undoLabel => canUndo ? _undoStack.last.label : null;

  /// Label for the next redo operation, if available.
  String? get redoLabel => canRedo ? _redoStack.last.label : null;

  /// Number of undoable actions currently retained.
  int get undoDepth => _undoStack.length;

  /// Number of redoable actions currently retained.
  int get redoDepth => _redoStack.length;

  /// Applies [action], stores it on the undo stack, and clears redo history.
  void commit(FxUndoAction action) {
    action.apply();
    _undoStack.add(action);
    _redoStack.clear();
    notifyListeners();
  }

  /// Commits a value change if [oldValue] and [newValue] are different.
  ///
  /// Returns `true` when an undoable action was recorded.
  bool commitValue<T>(
    String label, {
    required T oldValue,
    required T newValue,
    required ValueChanged<T> apply,
  }) {
    if (oldValue == newValue) {
      return false;
    }

    commit(
      FxUndoAction(
        label: label,
        apply: () => apply(newValue),
        revert: () => apply(oldValue),
      ),
    );
    return true;
  }

  /// Commits multiple actions as one user-visible undo step.
  ///
  /// Empty batches are ignored and return `false`.
  bool commitBatch(String label, Iterable<FxUndoAction> actions) {
    final actionList = actions.toList(growable: false);
    if (actionList.isEmpty) {
      return false;
    }

    commit(FxUndoAction.batch(label: label, actions: actionList));
    return true;
  }

  /// Reverts the latest action and makes it redoable.
  void undo() {
    if (!canUndo) {
      return;
    }

    final action = _undoStack.removeLast();
    action.revert();
    _redoStack.add(action);
    notifyListeners();
  }

  /// Reapplies the latest undone action.
  void redo() {
    if (!canRedo) {
      return;
    }

    final action = _redoStack.removeLast();
    action.apply();
    _undoStack.add(action);
    notifyListeners();
  }

  /// Clears both undo and redo history.
  void clear() {
    if (_undoStack.isEmpty && _redoStack.isEmpty) {
      return;
    }

    _undoStack.clear();
    _redoStack.clear();
    notifyListeners();
  }
}

/// Provides an [FxUndoController] to a widget subtree.
class FxUndoScope extends InheritedNotifier<FxUndoController> {
  /// Creates an undo scope.
  const FxUndoScope({
    super.key,
    required FxUndoController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Returns the nearest undo controller, or `null` when no scope exists.
  static FxUndoController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FxUndoScope>()?.notifier;
  }

  /// Returns the nearest undo controller.
  static FxUndoController of(BuildContext context) {
    final controller = maybeOf(context);
    if (controller == null) {
      throw FlutterError(
        'FxUndoScope.of() was called without an FxUndoScope ancestor.',
      );
    }
    return controller;
  }
}
