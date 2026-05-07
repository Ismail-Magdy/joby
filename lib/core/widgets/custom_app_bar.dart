import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/extensions.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.text, this.actions});
  final String text;
  final List<Widget>? actions;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
        onPressed: () => context.pop(),
      ),
      title: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: .bold,
          fontSize: 18.sp,
          fontFamily: "BrunoAceSC",
        ),
      ),
      centerTitle: true,
      actions: actions,
    );
  }
}
