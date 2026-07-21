import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/themes/app_colors.dart';

class AutocompleteTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final List<String> suggestions;
  final String? Function(String?)? validator;

  const AutocompleteTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    required this.suggestions,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            final query = textEditingValue.text.toLowerCase();
            return suggestions.where(
              (option) => option.toLowerCase().contains(query),
            );
          },
          onSelected: (String selection) {
            controller.text = selection;
          },
          optionsMaxHeight: 200.h,
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: .topLeft,
              //
              child: Material(
                elevation: 4,
                borderRadius: .circular(12.r),
                color: Colors.white,
                //
                child: Container(
                  width: constraints.maxWidth,
                  constraints: BoxConstraints(maxHeight: 200.h),
                  decoration: BoxDecoration(
                    borderRadius: .circular(12.r),
                    border: .all(
                      color: AppColors.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: ListView.separated(
                    padding: .symmetric(vertical: 4.h),
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        visualDensity: .compact,
                        title: Text(
                          option,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black87,
                          ),
                        ),
                        leading: Icon(
                          prefixIcon,
                          color: AppColors.primaryColor,
                          size: 18.sp,
                        ),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
                //
              ),
            );
          },
          fieldViewBuilder:
              (context, textController, focusNode, onFieldSubmitted) {
                textController.text = controller.text;
                textController.addListener(() {
                  if (controller.text != textController.text) {
                    controller.text = textController.text;
                  }
                });

                return TextFormField(
                  controller: textController,
                  focusNode: focusNode,
                  validator: validator,
                  decoration: InputDecoration(
                    labelText: labelText,
                    prefixIcon: Icon(prefixIcon),
                  ),
                  onFieldSubmitted: (_) => onFieldSubmitted(),
                );
              },
        );
      },
    );
  }
}
