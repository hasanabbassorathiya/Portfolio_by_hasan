# Design System Documentation

This document describes the design system extracted from the Figma design and implemented in the Flutter portfolio application.

## Overview

The design system has been extracted from the Figma design file and implemented with full responsive support for all screen sizes, from small mobile devices (360px) to large desktop screens (1920px+).

## Design Tokens

### Colors

The color palette is extracted from the Figma design:

- **Primary Dark**: `#141313` - Main text and primary elements
- **Background White**: `#FFFFFF` - Main background
- **Background Dark**: `#171717` - Dark sections
- **Gradient Colors**:
  - Orange: `#FFB147`
  - Red: `#FF6C63`
  - Purple: `#B86ADF`

### Typography

**Font Families:**
- Primary: IBM Plex Sans
- Secondary: Poppins (for hero text)
- Tertiary: Jost (for body text)
- Serif: IBM Plex Serif (for logo)

**Font Sizes:**
- Hero: 102px (responsive)
- Display Large: 48px
- Heading: 40px
- Title Large: 32px
- Title Medium: 24px
- Body: 16-18px
- Small: 11px

### Spacing

Spacing system based on 4px unit:
- Small: 4-12px
- Medium: 16-24px
- Large: 40-64px
- Extra Large: 85-285px

### Responsive Breakpoints

- **Mobile**: < 600px
- **Phablet**: 600px - 768px
- **Tablet**: 768px - 1024px
- **Tablet Large**: 1024px - 1280px
- **Desktop**: 1280px - 1920px
- **Desktop Large**: 1920px+

## Usage

### Using Design Tokens

```dart
import 'package:portfolio/shared/constants/design_tokens.dart';

// Colors
Container(color: DesignTokens.primaryDark)

// Spacing
Padding(padding: EdgeInsets.all(DesignTokens.space16))

// Typography
Text('Hello', style: AppStyles.heading())
```

### Using Responsive Utilities

```dart
import 'package:portfolio/shared/utils/responsive.dart';

// Get responsive value
final padding = Responsive.horizontalPadding(context);

// Check screen size
if (Responsive.isMobile(context)) {
  // Mobile-specific code
}

// Responsive builder widget
ResponsiveBuilder(
  mobile: MobileWidget(),
  tablet: TabletWidget(),
  desktop: DesktopWidget(),
)
```

### Using Theme

The theme is automatically applied in `main.dart`. You can access theme values:

```dart
Theme.of(context).textTheme.headlineLarge
Theme.of(context).colorScheme.primary
```

## Assets

All assets have been downloaded from Figma and are available through `AppAssets`:

```dart
import 'package:portfolio/shared/constants/assets.dart';

// Images
Image.asset(AppAssets.work1)
Image.asset(AppAssets.blog1)
Image.asset(AppAssets.heroImage)

// Icons
SvgPicture.asset(AppAssets.aboutAvatar)
```

## Responsive Design

The design system automatically scales for different screen sizes:

- **Font Sizes**: Automatically scaled down on smaller screens
- **Spacing**: Responsive padding and margins
- **Layout**: Sidebar hidden on mobile, smaller on tablet
- **Grids**: Column count adjusts based on screen size

## Files Structure

```
lib/shared/
├── constants/
│   ├── design_tokens.dart    # All design tokens
│   ├── colors.dart           # Color constants
│   ├── textstyles.dart       # Text style definitions
│   └── assets.dart           # Asset paths
├── theme/
│   └── app_theme.dart        # Theme configuration
└── utils/
    └── responsive.dart        # Responsive utilities
```

## Best Practices

1. **Always use design tokens** instead of hardcoded values
2. **Use responsive utilities** for layout decisions
3. **Test on multiple screen sizes** during development
4. **Use AppStyles** for consistent typography
5. **Use AppColors** for consistent colors

## Next Steps

- Implement responsive layouts in all screens
- Add dark mode support (theme already configured)
- Add animations and transitions
- Optimize images for web and mobile

