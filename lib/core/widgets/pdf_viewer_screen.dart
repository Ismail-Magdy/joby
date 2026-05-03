import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/widgets/custom_app_bar.dart';
import 'package:shimmer/shimmer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    this.title = "Document Viewer",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(text: title),
      body:
          PDF(
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false,
            pageFling: true,
          ).cachedFromUrl(
            pdfUrl,
            placeholder: (double progress) => _buildLoadingAnimation(),
            errorWidget: (dynamic error) => Center(
              child: Column(
                mainAxisSize: .min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 50.sp),
                  verticalSpace(10),
                  SizedBox(height: 10.h),
                  Text(
                    "Failed to load document\n$error",
                    textAlign: .center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildLoadingAnimation() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 3,
        padding: .all(20.r),
        itemBuilder: (context, index) {
          return Container(
            height: 300.h,
            margin: .only(bottom: 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: .circular(12.r),
            ),
          );
        },
      ),
    );
  }
}
