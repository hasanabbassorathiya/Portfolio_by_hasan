# Modern UI Components Guide

This guide explains how to use the new modern UI components based on the Figma design.

## Components Overview

### 1. Custom Cursor (`CustomCursor`)
A beautiful animated cursor that follows mouse movement with gradient effects.

**Usage:**
```dart
CustomCursor(
  enabled: true, // Enable on desktop/web
  child: YourWidget(),
)
```

**Features:**
- Smooth gradient animation
- Click animations
- Hover effects
- Only enabled on desktop (1280px+)

### 2. Modern Button (`ModernButton`)
A modern button with gradient effects, hover animations, and smooth transitions.

**Usage:**
```dart
ModernButton(
  title: 'Let\'s talk with me',
  icon: Iconsax.arrow_right_3_copy,
  onTap: () {
    // Handle tap
  },
  variant: ButtonVariant.primary, // primary, secondary, outline
)
```

**Variants:**
- `ButtonVariant.primary` - Gradient background
- `ButtonVariant.secondary` - Alternative gradient
- `ButtonVariant.outline` - Outlined style

### 3. Modern Card (`ModernCard`)
A card component with hover effects, smooth animations, and gradient borders.

**Usage:**
```dart
ModernCard(
  onTap: () {
    // Handle tap
  },
  showGradientBorder: true,
  child: YourContent(),
)
```

### 4. Gradient Card (`GradientCard`)
A card with animated gradient background.

**Usage:**
```dart
GradientCard(
  onTap: () {
    // Handle tap
  },
  child: YourContent(),
)
```

### 5. Smooth Scroll Wrapper (`SmoothScrollWrapper`)
Enhanced scrolling with smooth physics.

**Usage:**
```dart
SmoothScrollWrapper(
  controller: scrollController,
  child: YourScrollableContent(),
)
```

### 6. Animated Section (`AnimatedSection`)
Smooth fade-in and slide-up animations for sections.

**Usage:**
```dart
AnimatedSection(
  delay: Duration(milliseconds: 200),
  curve: Curves.easeOut,
  child: YourSection(),
)
```

### 7. Cursor Aware (`CursorAware`)
Widget that changes cursor on hover.

**Usage:**
```dart
CursorAware(
  onTap: () {
    // Handle tap
  },
  onHover: () {
    // Handle hover
  },
  cursor: SystemMouseCursors.click,
  child: YourWidget(),
)
```

## Implementation Status

✅ **Completed:**
- Custom animated cursor
- Modern button component
- Modern card components
- Smooth scroll wrapper
- Animated section wrapper
- Cursor aware widget
- Integrated into main layout

🔄 **Next Steps:**
- Update all pages to use modern components
- Replace existing buttons with ModernButton
- Add ModernCard to work/blog cards
- Enhance hover effects throughout
- Add more micro-interactions

## Design Tokens

All components use the design tokens from `DesignTokens`:
- Colors: `AppColors`
- Spacing: `DesignTokens.space*`
- Typography: `AppStyles`
- Responsive: `Responsive` utilities

## Best Practices

1. **Use ModernButton** instead of AppButton for new components
2. **Wrap interactive elements** with CursorAware for better UX
3. **Use AnimatedSection** for page sections to add smooth transitions
4. **Enable CustomCursor** only on desktop (already configured)
5. **Use ModernCard** for content cards with hover effects

## Examples

### Example: Modern Work Card
```dart
ModernCard(
  onTap: () => navigateToProject(),
  showGradientBorder: true,
  child: Column(
    children: [
      Image.asset(projectImage),
      Text(projectTitle, style: AppStyles.titleLarge()),
      Text(projectDescription),
    ],
  ),
)
```

### Example: Animated Page Section
```dart
AnimatedSection(
  delay: Duration(milliseconds: 300),
  child: Column(
    children: [
      Text('Section Title', style: AppStyles.heading()),
      // Section content
    ],
  ),
)
```

## Performance Notes

- Custom cursor is only enabled on desktop to avoid performance issues on mobile
- Animations use optimized curves and durations
- Cards use Transform.scale for smooth hover effects
- All animations are GPU-accelerated

