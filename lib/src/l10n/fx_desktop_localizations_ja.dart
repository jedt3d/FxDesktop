// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fx_desktop_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class FxDesktopLocalizationsJa extends FxDesktopLocalizations {
  FxDesktopLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get datePickerEmptyHint => '日付を選択';

  @override
  String get timePickerEmptyHint => '時刻を選択';

  @override
  String get dateTimePickerEmptyHint => '日付と時刻を選択';

  @override
  String get popupMenuNoOptions => '選択肢がありません';

  @override
  String get lookupNoOptionsFound => '選択肢が見つかりません';

  @override
  String get colorPickerNoColorButton => '色なし';

  @override
  String get colorPickerNoColorValue => '色なし';

  @override
  String colorPickerPreviewLabel(String color) {
    return 'プレビュー: $color';
  }

  @override
  String get colorPickerHueLabel => '色相';

  @override
  String get colorPickerSaturationLabel => '彩度';

  @override
  String get colorPickerValueLabel => '明度';

  @override
  String get colorPickerRgbHexLabel => 'RGB #RRGGBB';

  @override
  String get colorPickerHexError => '#RRGGBB の形式で色を入力してください。';

  @override
  String get colorPickerCancelButton => 'キャンセル';

  @override
  String get colorPickerApplyButton => '適用';

  @override
  String get tableNoRecords => '表示するレコードはありません';

  @override
  String get tableLoadError => 'データの読み込み中にエラーが発生しました';

  @override
  String tableEditUndoLabel(String column) {
    return '$column を編集';
  }

  @override
  String get tablePasteValuesUndoLabel => '値を貼り付け';

  @override
  String tableAutoFitUndoLabel(String column) {
    return '$column を自動調整';
  }

  @override
  String tableMovingRowFeedback(int row) {
    return '行 $row を移動中';
  }

  @override
  String get tableBooleanChecked => 'チェック済み';

  @override
  String get tableBooleanUnchecked => '未チェック';

  @override
  String tableCellSemantics(int row, String column, String value) {
    return '行 $row, 列 $column: $value';
  }

  @override
  String tableValidationErrorSuffix(String error) {
    return '検証エラー: $error';
  }

  @override
  String get gridContextMenuCopySelection => '選択範囲をコピー';

  @override
  String get designerEditMenuCopyItem => 'コピー';

  @override
  String get galleryTitle => 'FxDesktop ローカライズギャラリー';

  @override
  String get gallerySubtitle =>
      '対応ロケールで FxDesktop 所有のコンポーネント文言を切り替える単一のデスクトップ画面です。';

  @override
  String get galleryLanguageEnglish => '英語';

  @override
  String get galleryLanguageThai => 'タイ語';

  @override
  String get galleryLanguageJapanese => '日本語';

  @override
  String get galleryLanguageNepali => 'ネパール語';

  @override
  String get galleryLocaleLabel => 'ロケール';

  @override
  String get galleryDirectionLabel => '方向';

  @override
  String get galleryFormSection => 'フォームコントロール';

  @override
  String get galleryChoiceSection => '選択コントロール';

  @override
  String get galleryNavigationSection => 'ナビゲーションコントロール';

  @override
  String get galleryDateTimeColorSection => '日付、時刻、色';

  @override
  String get galleryTableSection => 'ListBox と Grid';

  @override
  String get galleryStateSection => '状態と検証';

  @override
  String get galleryPoSection => 'PO ブリッジ';

  @override
  String get galleryCustomerLabel => '顧客';

  @override
  String get galleryCustomerHint => '会社名または個人名';

  @override
  String get galleryStatusLabel => '状態';

  @override
  String get galleryPriorityLabel => '優先度';

  @override
  String get galleryEnabledLabel => '有効';

  @override
  String get gallerySelectedLabel => '選択済み';

  @override
  String get galleryCompactLabel => 'コンパクト';

  @override
  String get galleryDetailedLabel => '詳細';

  @override
  String get gallerySummaryTab => '概要';

  @override
  String get galleryAuditTab => '監査';

  @override
  String get galleryStartDateLabel => '開始日';

  @override
  String get galleryAccentColorLabel => 'アクセントカラー';

  @override
  String get galleryOrderColumn => '注文';

  @override
  String get galleryOwnerColumn => '担当者';

  @override
  String get galleryStateColumn => '状態';

  @override
  String get galleryOpenStatus => '未完了';

  @override
  String get galleryClosedStatus => '完了';

  @override
  String get galleryPoStatus =>
      'ARB はランタイムの文言ソースのままです。PO と POT は翻訳者向けのブリッジファイルです。';

  @override
  String get ribbonToolbarSemantics => 'リボンツールバー';

  @override
  String get ribbonNoTabs => 'リボンタブがありません';

  @override
  String get ribbonCollapse => 'リボンを折りたたむ';

  @override
  String get ribbonExpand => 'リボンを展開';

  @override
  String get ribbonOpenMenu => 'メニューを開く';

  @override
  String get ribbonMenuEmpty => 'メニュー項目がありません';

  @override
  String ribbonGroupSemantics(String group) {
    return 'リボングループ $group';
  }

  @override
  String get ribbonDesignerTitle => 'リボンデザイナー';

  @override
  String get ribbonDesignerNew => '新規';

  @override
  String get ribbonDesignerAddTab => 'タブを追加';

  @override
  String get ribbonDesignerAddGroup => 'グループを追加';

  @override
  String get ribbonDesignerAddItem => '項目を追加';

  @override
  String get ribbonDesignerDelete => '削除';

  @override
  String get ribbonDesignerExport => 'JSON をエクスポート';

  @override
  String get ribbonDesignerExported => 'リボン JSON をエクスポートしました。';

  @override
  String get ribbonDesignerPreviewLocale => 'プレビュー ロケール';

  @override
  String get ribbonDesignerStructure => '構造';

  @override
  String get ribbonDesignerJsonPreview => 'JSON プレビュー';

  @override
  String get ribbonDesignerInspector => 'インスペクター';

  @override
  String get ribbonDesignerNoSelection => 'タブ、グループ、または項目を選択してください。';

  @override
  String get ribbonDesignerStatusReady => '準備完了。';

  @override
  String get ribbonDesignerCaption => 'キャプション';

  @override
  String get ribbonDesignerKeyTip => 'KeyTip';

  @override
  String get ribbonDesignerContextual => 'コンテキスト タブ';

  @override
  String get ribbonDesignerContextGroup => 'コンテキスト グループ';

  @override
  String get ribbonDesignerCommandTag => 'コマンドタグ';

  @override
  String get ribbonDesignerItemType => '項目タイプ';

  @override
  String get ribbonDesignerTooltip => 'ツールチップ';

  @override
  String get ribbonDesignerIconKey => 'アイコンキー';

  @override
  String get ribbonDesignerEnabled => '有効';

  @override
  String get ribbonDesignerChecked => 'チェック済み';

  @override
  String get ribbonDesignerLocalizedCaptions => 'ローカライズ済みキャプション';

  @override
  String get ribbonItemTypeLarge => '大ボタン';

  @override
  String get ribbonItemTypeSmall => '小ボタン';

  @override
  String get ribbonItemTypeDropdown => 'ドロップダウン';

  @override
  String get ribbonItemTypeSplitButton => '分割ボタン';

  @override
  String get ribbonItemTypeToggle => 'トグル';

  @override
  String get ribbonItemTypeCheckBox => 'チェックボックス';

  @override
  String get ribbonItemTypeSeparator => '区切り';
}
