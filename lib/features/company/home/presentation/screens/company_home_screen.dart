import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joby/features/company/home/presentation/components/bottom_section_company_home.dart';
import 'package:joby/features/company/home/presentation/components/fixed_header_company_home.dart';
import '../../manager/company_home_cubit.dart';

class CompanyHomeScreen extends StatefulWidget {
  const CompanyHomeScreen({super.key});

  @override
  State<CompanyHomeScreen> createState() => _CompanyHomeScreenState();
}

class _CompanyHomeScreenState extends State<CompanyHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CompanyHomeCubit>().fetchSeekers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Fixed Header
          FixedHeaderCompanyHome(),
          //
          BottomSectionCompanyHome(),
          //
        ],
      ),
    );
  }
}
//180