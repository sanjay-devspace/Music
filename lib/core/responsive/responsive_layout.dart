import 'package:flutter/widgets.dart';
import 'responsive.dart';
import 'device_type.dart';

/// Responsive layout builder that wraps all major views.
///
/// It computes a [Responsive] once per build and puts it in an
/// [InheritedWidget] so descendants can call `Responsive.of(context)`.
///
/// Provides a declarative builder API:
///
/// ```dart
/// ResponsiveLayoutBuilder(
///   phone: (context) => MobileLayout(),
///   tablet: (context) => TabletLayout(),
///   desktop: (context) => DesktopLayout(),
/// )
/// ```
class ResponsiveLayoutBuilder extends StatelessWidget {
  const ResponsiveLayoutBuilder({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    return _ResponsiveScope(responsive: responsive, child: child);
  }
}

/// Full-screen layout builder used by individual screens.
///
/// Chooses the layout based on the current [DeviceType]:
///
/// * **phone**  → typically full-screen mobile layout
/// * **tablet** → 2-column / wider padded content
/// * **desktop**→ sidebar / grid
class ResponsiveFullScreenLayout extends StatelessWidget {
  const ResponsiveFullScreenLayout({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(child: child);
  }
}

/// Full declarative screen builder with typed device layouts.
class ResponsiveScreenBuilder extends StatelessWidget {
  const ResponsiveScreenBuilder({
    super.key,
    required this.builder,
    this.phoneBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
  });

  final Widget Function(BuildContext context, Responsive responsive) builder;
  final Widget Function(BuildContext context, Responsive responsive)? phoneBuilder;
  final Widget Function(BuildContext context, Responsive responsive)? tabletBuilder;
  final Widget Function(BuildContext context, Responsive responsive)? desktopBuilder;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    if (r.isDesktop && desktopBuilder != null) {
      return desktopBuilder!(context, r);
    }
    if (r.isTablet && tabletBuilder != null) {
      return tabletBuilder!(context, r);
    }
    if ((r.isPhone || r.isPhoneSmall) && phoneBuilder != null) {
      return phoneBuilder!(context, r);
    }
    return builder(context, r);
  }
}

// ---------------------------------------------------------------------------
// InheritedWidget that provides [Responsive] down the tree.
// ---------------------------------------------------------------------------

class _ResponsiveScope extends InheritedWidget {
  const _ResponsiveScope({required this.responsive, required super.child});

  final Responsive responsive;

  static Responsive of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_ResponsiveScope>();
    assert(inherited != null, 'No _ResponsiveScope ancestor found.');
    return inherited!.responsive;
  }

  @override
  bool updateShouldNotify(_ResponsiveScope oldWidget) =>
      oldWidget.responsive != responsive;
}

/// Extension on [BuildContext] so views can do `context.responsive`.
extension ResponsiveScopeExtension on BuildContext {
  Responsive get responsive => _ResponsiveScope.of(this);
}