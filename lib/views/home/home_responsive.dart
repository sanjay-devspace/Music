import 'package:tunehive/core/responsive/responsive.dart';

/// Responsive configuration for the Home screen.
///
/// Centralizes every measurement the Home content uses so the file stays
/// readable and the layout truly adapts between phones, tablets and desktops.
class HomeResponsive {
  HomeResponsive(this.r);

  final Responsive r;

  // ---- Layout ---------------------------------------------------------------
  /// Horizontal padding around the feed (larger on desktop).
  double get horizontalPadding {
    if (r.isPhone) return 20;
    if (r.isTablet) return 28;
    return 36;
  }

  /// Vertical rhythm between sections.
  double get sectionGap {
    if (r.isPhoneSmall) return 14;
    if (r.isPhone) return 20;
    if (r.isTablet) return 36;
    return 44;
  }

  double get headerTop => r.isDesktop ? 24 : 12;

  /// Content max width on desktop (centered).
  double get contentWidth {
    if (r.isDesktop) return r.maxContentWidth;
    return r.width;
  }

  // ---- Hero ------------------------------------------------------------------
  double get heroHeight {
    if (r.isPhoneSmall) return 234;
    if (r.isPhone) return 240;
    if (r.isTablet) return 320;
    if (r.isLandscape && r.isDesktop) return 360;
    return 380;
  }

  double get heroFontSizeTitle {
    if (r.isPhoneSmall) return r.fontSize.title * 1.0;
    if (r.isPhone) return r.fontSize.title * 1.2;
    return r.fontSize.headline;
  }

  // ---- Cards ------------------------------------------------------------------
  double get songCardWidth {
    if (r.isPhoneSmall) return (r.width - horizontalPadding * 2) * 0.38;
    if (r.isPhone) return (r.width - horizontalPadding * 2) * 0.42;
    if (r.isTablet) return 180;
    return 200;
  }

  double get playlistCardWidth {
    if (r.isPhoneSmall) return (r.width - horizontalPadding * 2) * 0.55;
    if (r.isPhone) return (r.width - horizontalPadding * 2) * 0.55;
    if (r.isTablet) return 200;
    return 232;
  }

  double get artistAvatar {
    if (r.isPhoneSmall) return 76;
    if (r.isPhone) return 88;
    if (r.isTablet) return 104;
    return 120;
  }

  /// Editor card grid size on desktop.
  int get editorGridColumns {
    if (r.isLargeDesktop) return 4;
    if (r.isDesktop) return 3;
    if (r.isTablet) return 2;
    return 1;
  }

  // ---- Typography ----------------------------------------------------------------
  double get greetingSize => r.fontSize.headline * 1.15;

  double get nameSize => greetingSize * 0.72;

  double get sectionTitleSize {
    if (r.isPhoneSmall) return r.fontSize.title * 0.9;
    if (r.isPhone) return r.fontSize.title;
    return r.fontSize.title * 1.15;
  }

  // ---- Motion ------------------------------------------------------------------
  Duration get staggerStep => Duration(milliseconds: r.isDesktop ? 55 : 40);
}