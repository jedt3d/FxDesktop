// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fx_desktop_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class FxDesktopLocalizationsTh extends FxDesktopLocalizations {
  FxDesktopLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get datePickerEmptyHint => 'เลือกวันที่';

  @override
  String get timePickerEmptyHint => 'เลือกเวลา';

  @override
  String get dateTimePickerEmptyHint => 'เลือกวันที่และเวลา';

  @override
  String get popupMenuNoOptions => 'ไม่มีตัวเลือก';

  @override
  String get lookupNoOptionsFound => 'ไม่พบตัวเลือก';

  @override
  String get colorPickerNoColorButton => 'ไม่มีสี';

  @override
  String get colorPickerNoColorValue => 'ไม่มีสี';

  @override
  String colorPickerPreviewLabel(String color) {
    return 'ตัวอย่าง: $color';
  }

  @override
  String get colorPickerHueLabel => 'เฉดสี';

  @override
  String get colorPickerSaturationLabel => 'ความอิ่มสี';

  @override
  String get colorPickerValueLabel => 'ความสว่าง';

  @override
  String get colorPickerRgbHexLabel => 'RGB #RRGGBB';

  @override
  String get colorPickerHexError => 'ป้อนสีในรูปแบบ #RRGGBB';

  @override
  String get colorPickerCancelButton => 'ยกเลิก';

  @override
  String get colorPickerApplyButton => 'นำไปใช้';

  @override
  String get tableNoRecords => 'ไม่มีระเบียนให้แสดง';

  @override
  String get tableLoadError => 'เกิดข้อผิดพลาดขณะโหลดข้อมูล';

  @override
  String tableEditUndoLabel(String column) {
    return 'แก้ไข $column';
  }

  @override
  String get tablePasteValuesUndoLabel => 'วางค่า';

  @override
  String tableAutoFitUndoLabel(String column) {
    return 'ปรับพอดี $column';
  }

  @override
  String tableMovingRowFeedback(int row) {
    return 'กำลังย้ายแถว $row';
  }

  @override
  String get tableBooleanChecked => 'เลือกแล้ว';

  @override
  String get tableBooleanUnchecked => 'ยังไม่เลือก';

  @override
  String tableCellSemantics(int row, String column, String value) {
    return 'แถว $row, คอลัมน์ $column: $value';
  }

  @override
  String tableValidationErrorSuffix(String error) {
    return 'ข้อผิดพลาดการตรวจสอบ: $error';
  }

  @override
  String get gridContextMenuCopySelection => 'คัดลอกส่วนที่เลือก';

  @override
  String get designerEditMenuCopyItem => 'คัดลอก';

  @override
  String get galleryTitle => 'แกลเลอรีการแปล FxDesktop';

  @override
  String get gallerySubtitle =>
      'พื้นที่เดสก์ท็อปเดียวสำหรับสลับข้อความของคอมโพเนนต์ FxDesktop ในภาษาที่รองรับ';

  @override
  String get galleryLanguageEnglish => 'อังกฤษ';

  @override
  String get galleryLanguageThai => 'ไทย';

  @override
  String get galleryLanguageJapanese => 'ญี่ปุ่น';

  @override
  String get galleryLanguageNepali => 'เนปาล';

  @override
  String get galleryLocaleLabel => 'โลเคล';

  @override
  String get galleryDirectionLabel => 'ทิศทาง';

  @override
  String get galleryFormSection => 'ตัวควบคุมฟอร์ม';

  @override
  String get galleryChoiceSection => 'ตัวควบคุมตัวเลือก';

  @override
  String get galleryNavigationSection => 'ตัวควบคุมนำทาง';

  @override
  String get galleryDateTimeColorSection => 'วันที่ เวลา และสี';

  @override
  String get galleryTableSection => 'ListBox และ Grid';

  @override
  String get galleryStateSection => 'สถานะและการตรวจสอบ';

  @override
  String get galleryPoSection => 'สะพาน PO';

  @override
  String get galleryCustomerLabel => 'ลูกค้า';

  @override
  String get galleryCustomerHint => 'ชื่อบริษัทหรือบุคคล';

  @override
  String get galleryStatusLabel => 'สถานะ';

  @override
  String get galleryPriorityLabel => 'ความสำคัญ';

  @override
  String get galleryEnabledLabel => 'เปิดใช้งาน';

  @override
  String get gallerySelectedLabel => 'เลือกแล้ว';

  @override
  String get galleryCompactLabel => 'กะทัดรัด';

  @override
  String get galleryDetailedLabel => 'ละเอียด';

  @override
  String get gallerySummaryTab => 'สรุป';

  @override
  String get galleryAuditTab => 'ตรวจสอบ';

  @override
  String get galleryStartDateLabel => 'วันที่เริ่มต้น';

  @override
  String get galleryAccentColorLabel => 'สีเน้น';

  @override
  String get galleryOrderColumn => 'คำสั่ง';

  @override
  String get galleryOwnerColumn => 'ผู้รับผิดชอบ';

  @override
  String get galleryStateColumn => 'สถานะ';

  @override
  String get galleryOpenStatus => 'เปิด';

  @override
  String get galleryClosedStatus => 'ปิด';

  @override
  String get galleryPoStatus =>
      'ARB ยังเป็นแหล่งข้อความตอนรันไทม์ ส่วน PO และ POT เป็นไฟล์สะพานสำหรับนักแปล';
}
