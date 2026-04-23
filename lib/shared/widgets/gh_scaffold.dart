import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Standard GymHelper scaffold wrapper.
/// Provides consistent bgBase background, optional styled AppBar.
class GhScaffold extends StatelessWidget {
  const GhScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
    this.extendBodyBehindAppBar = false,
    this.showAppBar = true,
  });

  final Widget body;
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: (showAppBar && (title != null || titleWidget != null))
          ? AppBar(
              backgroundColor: AppColors.bgElevated,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: leading,
              automaticallyImplyLeading: leading == null,
              title: titleWidget ??
                  Text(
                    title!,
                    style: AppTypography.headline,
                  ),
              actions: actions,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  height: 1,
                  color: AppColors.divider,
                ),
              ),
            )
          : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
