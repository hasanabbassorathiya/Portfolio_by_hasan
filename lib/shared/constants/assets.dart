/// Application asset paths
/// Contains all asset references for images, icons, and other resources
class AppAssets {
  AppAssets._();

  // ==================== Icons ====================
  static const String halfCircle = 'assets/icons/half_circle.svg';
  static const String logo1 = 'assets/icons/logo1.svg';
  static const String logo2 = 'assets/icons/logo2.svg';
  static const String logo3 = 'assets/icons/logo3.svg';
  static const String logo4 = 'assets/icons/logo4.svg';
  static const String wLogo = 'assets/icons/W-Logo.svg';

  // ==================== Avatars ====================
  static const String user = 'assets/hasan.png';
  static const String aboutAvatar = 'assets/about_avatar.svg';
  static const String homeAvatar = 'assets/home_avatar.svg';

  // ==================== Works/Projects ====================
  // Works images are available in both root and works/ folder
  static const String work1 = 'assets/work1.png';
  static const String work2 = 'assets/work2.png';
  static const String work3 = 'assets/work3.png';
  static const String work4 = 'assets/work4.png';
  static const String testimonial1 = 'assets/testimonial_1.png';
  static const String testimonial2 = 'assets/works/testimonial_2.png';
  static const String testimonial3 = 'assets/works/testimonial_3.png';

  // ==================== Blogs ====================
  static const String blog1 = 'assets/blogs/blog1.png';
  static const String blog2 = 'assets/blogs/blog2-2bfb9d.png';
  static const String blog3 = 'assets/blogs/blog3.png';

  // ==================== Services ====================
  static const String branding = 'assets/services/branding.svg';
  static const String consulting = 'assets/services/consulting.svg';
  static const String mobile = 'assets/services/mobile.svg';
  static const String seo = 'assets/services/seo.svg';
  static const String uiux = 'assets/services/uiux.svg';
  static const String web = 'assets/services/web.svg';
  static const String mobileApp = 'assets/mobile_app.png';

  // ==================== Hero Images ====================
  static const String heroImage = 'assets/hero_image-271e69.png';

  // ==================== Mobile App ====================
  static const String mobileAppImage = 'assets/mobile_app.png';

  // ==================== Helper Methods ====================
  /// Get work image by index (1-4)
  static String getWorkImage(int index) {
    switch (index) {
      case 1:
        return work1;
      case 2:
        return work2;
      case 3:
        return work3;
      case 4:
        return work4;
      default:
        return work1;
    }
  }

  /// Get blog image by index (1-3)
  static String getBlogImage(int index) {
    switch (index) {
      case 1:
        return blog1;
      case 2:
        return blog2;
      case 3:
        return blog3;
      default:
        return blog1;
    }
  }

  /// Get testimonial image by index (1-3)
  static String getTestimonialImage(int index) {
    switch (index) {
      case 1:
        return testimonial1;
      case 2:
        return testimonial2;
      case 3:
        return testimonial3;
      default:
        return testimonial1;
    }
  }
}
