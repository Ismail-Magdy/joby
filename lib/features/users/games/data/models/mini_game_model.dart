import 'package:flutter/material.dart';

class MiniGameModel {
  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final String icon;
  final int maxRewardPoints;
  final Duration cooldownDuration;
  final Color primaryColor;
  final Color secondaryColor;
  final String routeName;

  const MiniGameModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.maxRewardPoints,
    required this.cooldownDuration,
    required this.primaryColor,
    required this.secondaryColor,
    required this.routeName,
  });
}
