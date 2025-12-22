/// Image fallback utility
/// Provides fallback images when blog images are not available
class ImageFallback {
  static const List<String> fallbackImageUrls = [
    'https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=800',
    'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800',
    'https://images.unsplash.com/photo-1486312338219-ce68d2c6f44d?w=800',
    'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800',
    'https://images.unsplash.com/photo-1504868584819-f8e8b4b6d7e3?w=800',
    'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800',
    'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800',
    'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800',
  ];

  /// Get a random fallback image URL
  static String getRandomFallback() {
    final random = DateTime.now().millisecondsSinceEpoch %
        fallbackImageUrls.length;
    return fallbackImageUrls[random];
  }

  /// Get fallback image URL by index
  static String getFallbackByIndex(int index) {
    return fallbackImageUrls[index % fallbackImageUrls.length];
  }
}

