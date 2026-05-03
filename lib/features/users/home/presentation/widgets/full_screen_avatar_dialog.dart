import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

void showFullScreenAvatarDialog(
  BuildContext context,
  String? avatarUrl,
  String userId,
) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Avatar",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return FadeTransition(
        opacity: animation,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Blurred Background
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(color: Colors.black.withValues(alpha: 0.6)),
                ),
              ),

              // Avatar in Center
              Center(
                child: Hero(
                  tag: "profile_avatar",
                  child: Container(
                    width: 250.r,
                    height: 250.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade800,
                      image: avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(avatarUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: avatarUrl == null
                        ? Icon(
                            Ionicons.person,
                            size: 100.sp,
                            color: Colors.grey.shade400,
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


// 190