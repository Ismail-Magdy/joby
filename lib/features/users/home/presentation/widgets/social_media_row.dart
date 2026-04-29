import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/features/users/home/presentation/widgets/build_contact_icon_button.dart';

class SocialMediaRow extends StatelessWidget {
  const SocialMediaRow({
    super.key,
    required this.whatsappTap,
    required this.linkedinTap,
    required this.githubTap,
  });
  final void Function() whatsappTap;
  final void Function() linkedinTap;
  final void Function() githubTap;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .center,
      children: [
        BuildContactIconButton(
          icon: Ionicons.logo_whatsapp,
          color: Colors.green,
          onTap: whatsappTap,
        ),
        horizontalSpace(20),
        BuildContactIconButton(
          icon: Ionicons.logo_linkedin,
          color: const Color(0xff0077B5),
          onTap: linkedinTap,
        ),
        horizontalSpace(20),
        BuildContactIconButton(
          icon: Ionicons.logo_github,
          color: const Color(0xff333333),
          onTap: githubTap,
        ),
      ],
    );
  }
}
