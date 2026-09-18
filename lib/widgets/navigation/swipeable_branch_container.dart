import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tunehive/app/theme/app_motion.dart';
import 'package:tunehive/controllers/shell_controller.dart';

/// Wraps the GoRouter branches in a PageView to enable horizontal swiping.
/// Ensures inner scroll states are kept alive.
class SwipeableBranchContainer extends StatefulWidget {
  const SwipeableBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
    required this.onChange,
  });

  final int currentIndex;
  final List<Widget> children;
  final ValueChanged<int> onChange;

  @override
  State<SwipeableBranchContainer> createState() => _SwipeableBranchContainerState();
}

class _SwipeableBranchContainerState extends State<SwipeableBranchContainer> {
  late final PageController _pageController;
  StreamSubscription? _indexSub;
  bool _isAnimatingFromTap = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentIndex);

    final shell = Get.find<ShellController>();
    
    // Ensure ShellController matches GoRouter state upon mounting
    // (e.g. returning to the shell after a logout/login flow)
    if (shell.currentIndex.value != widget.currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        shell.onIndexChanged(widget.currentIndex);
      });
    }

    // Sync PageController when ShellController changes (e.g. from navbar tap)
    _indexSub = shell.currentIndex.listen((index) {
      if (_pageController.hasClients && _pageController.page?.round() != index) {
        _isAnimatingFromTap = true;
        _pageController
            .animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: AppMotion.easeOut,
            )
            .then((_) => _isAnimatingFromTap = false);
      }
    });
  }

  @override
  void didUpdateWidget(covariant SwipeableBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      // GoRouter changed the index externally (e.g. context.go('/search'))
      final shell = Get.find<ShellController>();
      if (shell.currentIndex.value != widget.currentIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          shell.onIndexChanged(widget.currentIndex);
        });
      }

      if (_pageController.hasClients && !_isAnimatingFromTap) {
        // Fallback jump if GoRouter changes index externally without animation
        if (_pageController.page?.round() != widget.currentIndex) {
          _pageController.jumpToPage(widget.currentIndex);
        }
      }
    }
  }

  @override
  void dispose() {
    _indexSub?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (!_isAnimatingFromTap) {
      // Swiped manually by the user
      widget.onChange(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      physics: const ClampingScrollPhysics(), // Prevent bouncy overscroll on iOS edges
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double value = 1.0;
            if (_pageController.position.haveDimensions) {
              value = _pageController.page! - index;
              value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
            }
            
            // value is 1.0 when fully active, drops down to 0.7 when swiping away.
            // We use this to drive opacity and scale.
            final opacity = (value - 0.7) / 0.3; // normalize to 0..1
            
            return Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.995 + (0.005 * opacity.clamp(0.0, 1.0)),
                child: child,
              ),
            );
          },
          child: _KeepAliveBranch(child: widget.children[index]),
        );
      },
    );
  }
}

/// Keeps the branch alive in the PageView so scroll positions and nested
/// states are not lost when swiping back and forth.
class _KeepAliveBranch extends StatefulWidget {
  const _KeepAliveBranch({required this.child});
  final Widget child;

  @override
  State<_KeepAliveBranch> createState() => _KeepAliveBranchState();
}

class _KeepAliveBranchState extends State<_KeepAliveBranch> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
