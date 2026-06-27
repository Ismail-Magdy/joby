import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/features/common/about_us/components/cards_and_footer_section.dart';
import '../components/about_header_delegate.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //
      body: CustomScrollView(
        slivers: [
          // Collapsing Animated Header
          SliverPersistentHeader(
            pinned: true,
            delegate: AboutHeaderDelegate(version: "V 1.0.0"),
          ),
          // Content Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: .symmetric(horizontal: 20.w),
              child: CardsAndFooterSection(),
            ),
          ),
          //
        ],
      ),
    );
  }
}
