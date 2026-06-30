# FxDesktop v0.3.6 Manual Verification Checklist

This checklist covers the latest shipped ListBox/Grid gallery behavior in
`v0.3.6`. Run the demo application with:

```bash
cd example-listbox-demo
flutter run -d macos
```

Navigate to **Page 10: Lookup Fields & Custom Rendering** and **Page 11:
Advanced Grid Editors**. Update this file by changing `[ ]` to `[x]` and
adding feedback next to each item.

---

## 1. Custom Cell Rendering & Sparklines (Page 10)
- [ ] **Custom Painters**: Verify that the "Sales Trend (Sparkline Renderer)" column draws a continuous blue trend line using CustomPaint instead of displaying raw coordinate lists.
  *User feedback / status:* 
- [ ] **Inline Badges / Text**: Verify that the sparkline trend has a percentage text next to it (e.g. `24%` or `N/A`) aligned properly.
  *User feedback / status:* 
- [ ] **RepaintBoundary Caching**: Hover and select rows in the listbox. Verify that cell selection changes are fast and there is no stuttering or unnecessary repainting on the sparkline custom canvas.
  *User feedback / status:* 

---

## 2. Category Lookup Map (`FxMapLookupProvider` - Page 10)
- [ ] **Display Value Resolution**: Verify that the cells show readable category names ("Electronics", "Apparel", "Home & Kitchen") rather than raw database keys (`1`, `2`, `3`).
  *User feedback / status:* 
- [ ] **Overlay Portal Activation**: Double-click a Category cell. Verify that a text-input field with a dropdown icon appears and a floating CompositedTransformFollower overlay opens showing the selectable options.
  *User feedback / status:* 
- [ ] **Interactive Autocomplete**: Type letters (e.g., `ap` or `el`) and verify the list is filtered to display matches.
  *User feedback / status:* 
- [ ] **Keyboard Navigation**: Press Arrow Down/Up to move the highlighted option in the dropdown, and press Enter to commit the choice. Verify that the cell updates.
  *User feedback / status:* 
- [ ] **Click Selection**: Tap/click an option directly inside the floating dropdown. Verify that the dropdown closes and the cell commits the correct choice.
  *User feedback / status:* 
- [ ] **Scroll Dismissal**: Open the dropdown edit overlay on any cell, then scroll the ListBox vertically or horizontally. Verify that the edit is automatically cancelled and the overlay closes immediately to prevent stray/detached floating elements.
  *User feedback / status:* 

---

## 3. Priority Lookup Enum (`FxEnumLookupProvider` - Page 10)
- [ ] **Enum Name Resolution**: Verify that the cells show custom labels like "Critical Priority" or "High Priority" instead of standard raw enum stringifications (`TestStatus.critical`, etc.).
  *User feedback / status:* 
- [ ] **Enum Combobox Commit**: Double-click a priority cell, select a different enum option, and verify it updates the display value.
  *User feedback / status:* 

---

## 4. Undo/Redo & Integration
- [ ] **Single Undo**: Edit a Category or Priority cell. Click **Undo Action** on the right sidebar panel (or press `Cmd+Z` / `Ctrl+Z`). Verify that the cell reverts back to its original key and visual label.
  *User feedback / status:* 
- [ ] **Redo Action**: Click Redo (if available in the sidebar / keyboard shortcut `Cmd+Shift+Z`) and verify the edit is reapplied.
  *User feedback / status:* 
- [ ] **Transaction Cleanliness**: Edit multiple lookup values, perform undo/redo, and verify the console log output prints correct state updates without throws or warnings.
  *User feedback / status:* 

---

## 5. Advanced Grid Editors (Page 11)
- [ ] **Active Row/Column Background Saturation Highlighting**: Select any cell (e.g., in Page 11 or Page 9/10). Verify that no heavy darker borders are drawn around the active row/column (crosshair lines are gone, standard borders are shown). Verify that instead, the entire active row and active column are highlighted by an elegant 20% increase in background saturation (tinted pastel color matching the theme primary color).
  *User feedback / status:* 
- [ ] **Multi-Column Lookup (`FxDbLookupProvider`)**: Double-click a Vendor cell. Verify that a wide tabular dropdown opens displaying 3 columns: "Code", "Vendor Name", and "Rating" with a bold header row at the top. Select a vendor (e.g. Globex Industries) and verify that the cell updates to display the resolved name.
  *User feedback / status:* 
- [ ] **Input Masking - Phone**: Double-click a Phone cell. Try to type letters (they should be ignored) and numbers. Verify that the characters are formatted on-the-fly to the mask format `(###) ###-####` (e.g. `(555) 123-4567`).
  *User feedback / status:* 
- [ ] **Input Masking - SSN**: Double-click an SSN cell. Type digits and verify they are formatted to the mask pattern `###-##-####` on-the-fly.
  *User feedback / status:* 
- [ ] **Cell Action Button (Ellipsis Dialog)**: Double-click an Attachment cell. Verify that an ellipsis icon button `[...]` appears at the right end. Click it and verify that a dialog pops up displaying: `"Okay this is the simulation of a file selector."`. Click **OK** and verify that a new randomly generated file name (e.g., `attachment_428.pdf`) is attached and updates the cell text.
  *User feedback / status:* 
- [ ] **Page 11 Undo/Redo**: Change a phone number, select a new vendor, and pick a new file attachment. Click **Undo** and verify that all operations are reverted sequentially on Page 11.
  *User feedback / status:* 

---
*Checked by:* (Your name / signature here)  
*Checklist last reconciled:* 2026-06-30  
