import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:joby/core/themes/app_colors.dart';

class IntlPhoneWidget extends StatelessWidget {
  const IntlPhoneWidget({
    super.key,
    required this.initialValue,
    required this.initialCountryCode,
    required this.isPhoneValid,
    required this.onChangedPhone,
    required this.onChangedCountry,
  });
  final String? initialValue;
  final String? initialCountryCode;
  final bool isPhoneValid;
  final void Function(PhoneNumber)? onChangedPhone;
  final void Function(Country)? onChangedCountry;

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      cursorColor: AppColors.primaryColor,
      initialValue: initialValue,
      initialCountryCode: initialCountryCode,
      invalidNumberMessage: "Invalid number for the selected country",
      pickerDialogStyle: PickerDialogStyle(backgroundColor: Colors.white),

      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: .circular(12.r),
          borderSide: BorderSide(
            color: isPhoneValid ? AppColors.primaryColor : Colors.red.shade400,
            width: 2,
          ),
        ),
        labelText: "WhatsApp Number",
        labelStyle: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 14.sp,
          fontWeight: .w600,
        ),
        counterText: "",
        border: OutlineInputBorder(
          borderRadius: .circular(12.r),
          borderSide: BorderSide(
            color: isPhoneValid ? Colors.grey.shade300 : Colors.red.shade400,
          ),
        ),
      ),
      onChanged: onChangedPhone,
      onCountryChanged: onChangedCountry,
    );
  }
}
