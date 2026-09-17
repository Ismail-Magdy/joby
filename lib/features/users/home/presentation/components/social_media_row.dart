import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/features/users/home/presentation/widgets/build_contact_icon_button.dart';

class SocialMediaRow extends StatelessWidget {
  const SocialMediaRow({
    super.key,
    required this.whatsappTap,
    this.linkedinTap,
    this.githubTap,
    this.behanceTap,
    this.showLinkedin = true,
    this.showGithub = true,
    this.showBehance = false,
  });

  final void Function() whatsappTap;
  final void Function()? linkedinTap;
  final void Function()? githubTap;
  final void Function()? behanceTap;
  final bool showLinkedin;
  final bool showGithub;
  final bool showBehance;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .center,
      children: [
        //
        BuildContactIconButton(
          icon: Ionicons.logoWhatsapp,
          color: Colors.green,
          onTap: whatsappTap,
        ),
        //
        if (showLinkedin) ...[
          //
          horizontalSpace(20),
          //
          BuildContactIconButton(
            icon: Ionicons.logoLinkedin,
            color: const Color(0xff0077B5),
            onTap: linkedinTap ?? () {},
          ),
          //
        ],
        if (showGithub) ...[
          //
          horizontalSpace(20),
          //
          BuildContactIconButton(
            icon: Ionicons.logoGithub,
            color: const Color(0xff333333),
            onTap: githubTap ?? () {},
          ),
          //
        ],
        if (showBehance) ...[
          //
          horizontalSpace(20),
          //
          BuildContactIconButton(
            icon: Ionicons.logoBehance,
            color: const Color(0xff1769FF),
            onTap: behanceTap ?? () {},
          ),
          //
        ],
      ],
    );
  }
}
