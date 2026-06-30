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

  @override
  String get ribbonToolbarSemantics => 'แถบริบบอน';

  @override
  String get ribbonNoTabs => 'ไม่มีแท็บริบบอน';

  @override
  String get ribbonCollapse => 'ยุบริบบอน';

  @override
  String get ribbonExpand => 'ขยายริบบอน';

  @override
  String get ribbonOpenMenu => 'เปิดเมนู';

  @override
  String get ribbonMenuEmpty => 'ไม่มีรายการเมนู';

  @override
  String ribbonGroupSemantics(String group) {
    return 'กลุ่มริบบอน $group';
  }

  @override
  String get ribbonDesignerTitle => 'ตัวออกแบบริบบอน';

  @override
  String get ribbonDesignerNew => 'ใหม่';

  @override
  String get ribbonDesignerAddTab => 'เพิ่มแท็บ';

  @override
  String get ribbonDesignerAddGroup => 'เพิ่มกลุ่ม';

  @override
  String get ribbonDesignerAddItem => 'เพิ่มรายการ';

  @override
  String get ribbonDesignerDelete => 'ลบ';

  @override
  String get ribbonDesignerExport => 'ส่งออก JSON';

  @override
  String get ribbonDesignerExported => 'ส่งออก JSON ของริบบอนแล้ว';

  @override
  String get ribbonDesignerPreviewLocale => 'โลเคลตัวอย่าง';

  @override
  String get ribbonDesignerStructure => 'โครงสร้าง';

  @override
  String get ribbonDesignerJsonPreview => 'ตัวอย่าง JSON';

  @override
  String get ribbonDesignerInspector => 'ตัวตรวจสอบ';

  @override
  String get ribbonDesignerNoSelection => 'เลือกแท็บ กลุ่ม หรือรายการ';

  @override
  String get ribbonDesignerStatusReady => 'พร้อม';

  @override
  String get ribbonDesignerCaption => 'คำบรรยาย';

  @override
  String get ribbonDesignerKeyTip => 'KeyTip';

  @override
  String get ribbonDesignerContextual => 'แท็บตามบริบท';

  @override
  String get ribbonDesignerContextGroup => 'กลุ่มบริบท';

  @override
  String get ribbonDesignerCommandTag => 'แท็กคำสั่ง';

  @override
  String get ribbonDesignerItemType => 'ชนิดรายการ';

  @override
  String get ribbonDesignerTooltip => 'ทูลทิป';

  @override
  String get ribbonDesignerIconKey => 'คีย์ไอคอน';

  @override
  String get ribbonDesignerEnabled => 'เปิดใช้งาน';

  @override
  String get ribbonDesignerChecked => 'เลือกแล้ว';

  @override
  String get ribbonDesignerLocalizedCaptions => 'คำบรรยายหลายภาษา';

  @override
  String get ribbonItemTypeLarge => 'ปุ่มใหญ่';

  @override
  String get ribbonItemTypeSmall => 'ปุ่มเล็ก';

  @override
  String get ribbonItemTypeMedium => 'ปุ่มขนาดกลาง';

  @override
  String get ribbonItemTypeDropdown => 'ดรอปดาวน์';

  @override
  String get ribbonItemTypeSplitButton => 'ปุ่มแยก';

  @override
  String get ribbonItemTypeMediumDropdown => 'ดรอปดาวน์ขนาดกลาง';

  @override
  String get ribbonItemTypeMediumSplitButton => 'ปุ่มแยกขนาดกลาง';

  @override
  String get ribbonItemTypeGallery => 'แกลเลอรี';

  @override
  String get ribbonItemTypeToggle => 'สลับ';

  @override
  String get ribbonItemTypeCheckBox => 'เช็กบ็อกซ์';

  @override
  String get ribbonItemTypeSeparator => 'ตัวคั่น';

  @override
  String get ribbonItemTypeColumnBreak => 'แบ่งคอลัมน์';
}
