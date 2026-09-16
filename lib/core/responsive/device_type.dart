/// Device category classification.
enum DeviceType {
  phoneSmall,
  phone,
  tablet,
  desktop,
  largeDesktop;

  bool get isPhone => this == phoneSmall || this == phone;
  bool get isTablet => this == tablet;
  bool get isDesktop => this == desktop || this == largeDesktop;
  bool get isMobile => isPhone || isTablet;
}

extension DeviceTypeLabel on DeviceType {
  String get label => switch (this) {
        DeviceType.phoneSmall => 'phone-small',
        DeviceType.phone => 'phone',
        DeviceType.tablet => 'tablet',
        DeviceType.desktop => 'desktop',
        DeviceType.largeDesktop => 'large-desktop',
      };
}