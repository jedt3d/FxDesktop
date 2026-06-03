# Undo Guide

FxDesktop undo is designed for desktop app workflows where users expect
commands such as Undo Change Status, Undo Edit Customer, or Undo Resize Panel.

## Mental Model

Use two undo layers:

1. Native Flutter text undo for keystroke-level editing inside focused text
   fields.
2. `FxUndoController` for committed app-state changes.

The controller does not inspect widgets. It records semantic actions supplied by
the app:

```dart
undo.commitValue<String>(
  'Change customer',
  oldValue: oldCustomer,
  newValue: newCustomer,
  apply: (value) => setState(() => customer = value),
);
```

## Component Coverage

| Component | Undo target | Commit trigger |
|---|---|---|
| `FxCheckBox` | checked, unchecked, indeterminate | `onChanged` |
| `FxRadioButton` | selected option | `onChanged` |
| `FxRadioGroup` | selected group value | `onChanged` |
| `FxPopupMenu` | selected option | `onChanged` |
| `FxComboBox` | typed value or selected suggestion | blur, submit, option selected |
| `FxTextField` | committed single-line text | blur or submit |
| `FxTextArea` | committed multiline text | blur or editing completion |
| `FxDateTimePicker` | selected date/time/datetime or clear | picker confirm or clear |
| `FxSlider` | numeric value | `onChangeEnd` |
| `FxColorPicker` | selected color | picker confirm |
| `FxSegmentedButton` | selected segment | `onChanged` |
| `FxDisclosureTriangle` | expanded or collapsed | toggle |
| `FxTabPanel` | selected tab index | tab selection |
| `FxPagePanel` | selected page index | index change |
| `FxCardContainer` | selected card index | index change |
| `FxListBox` | selected row, future row edits | selection or edit commit |
| `FxGrid` | selected cell/row, future cell edits | selection or edit commit |
| `FxFlexLayout` | future layout spec changes | layout property commit |
| `FxGridLayout` | future grid spec changes | layout property commit |

Display-only controls do not own undo history: `FxLabel`, `FxStyledLabel`,
`FxButton`, `FxGroupBox`, `FxProgressBar`, `FxProgressWheel`, `FxSeparator`, and
`FxTheme`.

## Transactions

Use `commitBatch` when one user operation changes multiple fields:

```dart
undo.commitBatch('Update customer details', [
  FxUndoAction(
    label: 'Change name',
    apply: () => setState(() => name = nextName),
    revert: () => setState(() => name = oldName),
  ),
  FxUndoAction(
    label: 'Change status',
    apply: () => setState(() => status = nextStatus),
    revert: () => setState(() => status = oldStatus),
  ),
]);
```

Use a single clear label for the user-visible action. Internal sub-action labels
are useful for debugging, but the menu or toolbar should show the batch label.
