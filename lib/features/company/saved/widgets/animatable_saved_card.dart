import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joby/features/company/home/presentation/components/seeker_card.dart';
import 'package:joby/features/users/user_info/data/models/user_info_model.dart';
import 'package:joby/features/company/home/manager/company_home_cubit.dart';
import 'package:thanos_snap_effect/thanos_snap_effect.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:joby/core/di/dependency_injection.dart';

class AnimatableSavedCard extends StatefulWidget {
  final UserInfoModel seeker;

  const AnimatableSavedCard({super.key, required this.seeker});

  @override
  State<AnimatableSavedCard> createState() => AnimatableSavedCardState();
}

class AnimatableSavedCardState extends State<AnimatableSavedCard>
    with SingleTickerProviderStateMixin {
  bool _isCollapsing = false;
  late final AnimationController _snapController;
  bool _isSnapping = false;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _isCollapsing
          ? const SizedBox.shrink()
          : Snappable(
              animation: _snapController,
              child: SeekerCard(
                seeker: widget.seeker,
                isSaved: true,
                onBookmarkTapOverride: (bool isCurrentlySaved) async {
                  if (_isSnapping) return isCurrentlySaved;

                  setState(() => _isSnapping = true);

                  // Play the delete sound
                  getIt<AudioPlayer>().play(AssetSource("sounds/delete.mp3"));

                  // Start the snap disintegration animation
                  _snapController.forward();

                  // Wait for the animation to complete
                  await Future.delayed(const Duration(milliseconds: 800));

                  // Collapse the widget smoothly before removal
                  setState(() => _isCollapsing = true);
                  await Future.delayed(const Duration(milliseconds: 300));

                  // Actually remove from state & local storage
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    context.read<CompanyHomeCubit>().toggleBookmark(
                      widget.seeker.id.toString(),
                    );
                  }

                  // Return false so the LikeButton shows un-saved state
                  return false;
                },
              ),
            ),
    );
  }
}
