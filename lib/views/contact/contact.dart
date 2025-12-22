import 'package:flutter/material.dart';
import 'package:portfolio/core/repositories/contact_repository.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/shared/constants/links.dart';
import 'package:portfolio/shared/utils/link_utils.dart';
import 'package:portfolio/shared/widgets/button.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/core/services/analytics_service.dart';
import 'package:portfolio/core/services/error_handler.dart';

class Contact extends StatefulWidget {
  // Add isActive parameter
  final bool isActive;

  const Contact({super.key, this.isActive = false});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> with SingleTickerProviderStateMixin {
  // Add AnimationController and animation
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ContactRepository _contactRepository = ContactRepository();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Add hover state variables
  bool _isHoveringPhoneNumber = false;
  bool _isHoveringEmail = false;
  bool _isHoveringFacebook = false; // Add state for Facebook
  bool _isHoveringTwitter = false; // Add state for Twitter
  bool _isHoveringInstagram = false; // Add state for Instagram
  bool _isHoveringLinkedIn = false; // Add state for LinkedIn

  @override
  void initState() {
    super.initState();
    _trackPageView();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Adjust duration as needed
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut, // Adjust curve as needed
    );
  }

  void _trackPageView() {
    AnalyticsService.trackPageView(
      pagePath: '/contact',
      pageTitle: 'Contact',
    );
  }

  // Method to activate page animations and scroll to top
  void _activatePage() {
    _animationController.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(covariant Contact oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the page has become active
    if (widget.isActive && !oldWidget.isActive) {
      _activatePage();
    } else if (!widget.isActive && oldWidget.isActive) {
      // Optionally reset animations when page becomes inactive
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _contactRepository.submitContactMessage(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        message: _messageController.text.trim(),
      );

      // Track successful submission
      AnalyticsService.trackContactSubmission();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
      }
    } catch (e, stackTrace) {
      // Record error to Crashlytics
      await ErrorHandler.handleError(
        e,
        stackTrace,
        reason: 'Contact form submission failed',
        context: context,
        userMessage: 'Error sending message. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmall = screenWidth < 700;
    final bool isMedium = screenWidth < 1200 && !isSmall;

    // Define padding based on screen size
    final EdgeInsets pagePadding = EdgeInsets.symmetric(
      horizontal:
          isSmall
              ? 20
              : isMedium
              ? 60
              : 100,
      vertical: isSmall ? 20 : 60,
    );

    // The main content for the Contact page
    return Padding(
      padding: pagePadding,
      child: FadeTransition(
        // Wrap content with FadeTransition
        opacity: _fadeInAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact', style: AppStyles.subheading(fontSize: 18)),
            AppUtils().vSpace(size: 12),
            Text(
              'GET IN TOUCH'.toUpperCase(),
              style: AppStyles.heading(
                fontSize: isSmall ? 32 : 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppUtils().vSpace(size: 48),

            // Responsive layout for Contact Info and Contact Form
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  // Example breakpoint for side-by-side layout
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact Info Section (Placeholder)
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contact Info',
                              style: AppStyles.heading(fontSize: 24),
                            ),
                            AppUtils().vSpace(size: 20),
                            // Add Contact Info details here (e.g., email, phone, address)
                            Text(
                              '10st Abd EL Aziz Al Soud, 05th Floor, Manial,\n Roda, Cairo, Egypt.', // Address from Figma
                              style: AppStyles.body(),
                            ),
                            AppUtils().vSpace(
                              size: 20,
                            ), // Spacing based on Figma
                            InkWell(
                              onTap:
                                  () => LinkUtils.launchPhone(
                                    AppLinks.phoneNumber,
                                  ), // Use constant and LinkUtils
                              onHover: (value) {
                                setState(() {
                                  _isHoveringPhoneNumber = value;
                                });
                              },
                              child: Text(
                                AppLinks
                                    .phoneNumber, // Use phone number constant
                                style: AppStyles.heading(fontSize: 20).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _isHoveringPhoneNumber
                                          ? AppColors.primaryColor
                                          : Colors
                                              .black, // Change color on hover
                                ), // Style based on Figma
                              ),
                            ),
                            AppUtils().vSpace(
                              size: 12,
                            ), // Spacing based on Figma
                            InkWell(
                              onTap:
                                  () => LinkUtils.launchEmail(
                                    AppLinks.email,
                                  ), // Use constant and LinkUtils
                              onHover: (value) {
                                setState(() {
                                  _isHoveringEmail = value;
                                });
                              },
                              child: Text(
                                AppLinks.email, // Use email constant
                                style: AppStyles.heading(fontSize: 20).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _isHoveringEmail
                                          ? AppColors.primaryColor
                                          : Colors
                                              .black, // Change color on hover
                                ), // Style based on Figma
                              ),
                            ),
                            // Add social media icons here
                            AppUtils().vSpace(
                              size: 24,
                            ), // Space before social icons
                            Wrap(
                              spacing: 16, // Horizontal spacing between items
                              runSpacing: 12, // Vertical spacing if items wrap
                              children: [
                                // Social Media Text Links
                                InkWell(
                                  onTap:
                                      () => LinkUtils.launchUrl(
                                        AppLinks.facebook,
                                      ), // Use constant and LinkUtils
                                  onHover: (value) {
                                    setState(() {
                                      _isHoveringFacebook = value;
                                    });
                                  },
                                  child: Text(
                                    'FACEBOOK',
                                    style: AppStyles.body(
                                      fontSize: 14,
                                    ).copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _isHoveringFacebook
                                              ? AppColors.primaryColor
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap:
                                      () => LinkUtils.launchUrl(
                                        AppLinks.twitter,
                                      ), // Use constant and LinkUtils
                                  onHover: (value) {
                                    setState(() {
                                      _isHoveringTwitter = value;
                                    });
                                  },
                                  child: Text(
                                    'TWITTER',
                                    style: AppStyles.body(
                                      fontSize: 14,
                                    ).copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _isHoveringTwitter
                                              ? AppColors.primaryColor
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap:
                                      () => LinkUtils.launchUrl(
                                        AppLinks.instagram,
                                      ), // Use constant and LinkUtils
                                  onHover: (value) {
                                    setState(() {
                                      _isHoveringInstagram = value;
                                    });
                                  },
                                  child: Text(
                                    'INSTAGRAM',
                                    style: AppStyles.body(
                                      fontSize: 14,
                                    ).copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _isHoveringInstagram
                                              ? AppColors.primaryColor
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap:
                                      () => LinkUtils.launchUrl(
                                        AppLinks.linkedIn,
                                      ), // Use constant and LinkUtils
                                  onHover: (value) {
                                    setState(() {
                                      _isHoveringLinkedIn = value;
                                    });
                                  },
                                  child: Text(
                                    'LINKEDIN',
                                    style: AppStyles.body(
                                      fontSize: 14,
                                    ).copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _isHoveringLinkedIn
                                              ? AppColors.primaryColor
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ), // Social icons wrap
                          ],
                        ),
                      ),
                      SizedBox(width: 40), // Space between columns
                      // Contact Form Section (Placeholder)
                      Expanded(
                        flex: 2, // Form can take more space
                        child: _buildContactForm(
                          isSmall,
                          isMedium,
                        ), // Call helper method for form
                      ),
                    ],
                  );
                } else {
                  // Vertical layout for smaller screens
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact Info Section (Placeholder)
                      Text(
                        'Contact Info',
                        style: AppStyles.heading(fontSize: 24),
                      ),
                      AppUtils().vSpace(size: 20),
                      // Add Contact Info details here (e.g., email, phone, address)
                      Text(
                        '10st Abd EL Aziz Al Soud, 05th Floor, Manial,\n Roda, Cairo, Egypt.', // Address from Figma
                        style: AppStyles.body(),
                      ),
                      AppUtils().vSpace(size: 20), // Spacing based on Figma
                      InkWell(
                        onTap:
                            () => LinkUtils.launchPhone(
                              AppLinks.phoneNumber,
                            ), // Use constant and LinkUtils
                        onHover: (value) {
                          setState(() {
                            _isHoveringPhoneNumber = value;
                          });
                        },
                        child: Text(
                          AppLinks.phoneNumber, // Use phone number constant
                          style: AppStyles.heading(fontSize: 20).copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                _isHoveringPhoneNumber
                                    ? AppColors.primaryColor
                                    : Colors.black, // Change color on hover
                          ), // Style based on Figma
                        ),
                      ),
                      AppUtils().vSpace(size: 12), // Spacing based on Figma
                      InkWell(
                        onTap:
                            () => LinkUtils.launchEmail(
                              AppLinks.email,
                            ), // Use constant and LinkUtils
                        onHover: (value) {
                          setState(() {
                            _isHoveringEmail = value;
                          });
                        },
                        child: Text(
                          AppLinks.email, // Use email constant
                          style: AppStyles.heading(fontSize: 20).copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                _isHoveringEmail
                                    ? AppColors.primaryColor
                                    : Colors.black, // Change color on hover
                          ), // Style based on Figma
                        ),
                      ),
                      // Add social media icons here
                      AppUtils().vSpace(size: 24), // Space before social icons
                      Wrap(
                        spacing: 16, // Horizontal spacing between items
                        runSpacing: 12, // Vertical spacing if items wrap
                        children: [
                          // Social Media Text Links
                          InkWell(
                            onTap:
                                () => LinkUtils.launchUrl(
                                  AppLinks.facebook,
                                ), // Use constant and LinkUtils
                            onHover: (value) {
                              setState(() {
                                _isHoveringFacebook = value;
                              });
                            },
                            child: Text(
                              'FACEBOOK',
                              style: AppStyles.body(fontSize: 14).copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    _isHoveringFacebook
                                        ? AppColors.primaryColor
                                        : Colors.black,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap:
                                () => LinkUtils.launchUrl(
                                  AppLinks.twitter,
                                ), // Use constant and LinkUtils
                            onHover: (value) {
                              setState(() {
                                _isHoveringTwitter = value;
                              });
                            },
                            child: Text(
                              'TWITTER',
                              style: AppStyles.body(fontSize: 14).copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    _isHoveringTwitter
                                        ? AppColors.primaryColor
                                        : Colors.black,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap:
                                () => LinkUtils.launchUrl(
                                  AppLinks.instagram,
                                ), // Use constant and LinkUtils
                            onHover: (value) {
                              setState(() {
                                _isHoveringInstagram = value;
                              });
                            },
                            child: Text(
                              'INSTAGRAM',
                              style: AppStyles.body(fontSize: 14).copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    _isHoveringInstagram
                                        ? AppColors.primaryColor
                                        : Colors.black,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap:
                                () => LinkUtils.launchUrl(
                                  AppLinks.linkedIn,
                                ), // Use constant and LinkUtils
                            onHover: (value) {
                              setState(() {
                                _isHoveringLinkedIn = value;
                              });
                            },
                            child: Text(
                              'LINKEDIN',
                              style: AppStyles.body(fontSize: 14).copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    _isHoveringLinkedIn
                                        ? AppColors.primaryColor
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ), // Social icons row
                      AppUtils().vSpace(size: 40), // Space between sections
                      // Contact Form Section (Placeholder)
                      _buildContactForm(
                        isSmall,
                        isMedium,
                      ), // Call helper method for form
                    ],
                  );
                }
              },
            ),

            AppUtils().vSpace(size: 48), // Space at the bottom
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm(bool isSmall, bool isMedium) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 20 : 40),
      decoration: BoxDecoration(
        gradient: AppUtils().appGradient,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ANY PROJECT?',
              style: AppStyles.heading(
                fontSize: isSmall ? 24 : 32,
              ).copyWith(color: Colors.white),
            ), // Form title from Figma
            AppUtils().vSpace(size: 40), // Spacing based on Figma
            // Name and Email Input (Side by side on larger screens)
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  // Breakpoint for side by side name and email
                  return Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'NAME',
                          _nameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                      ),
                      AppUtils().hSpace(size: 20),
                      Expanded(
                        child: _buildTextField(
                          'EMAIL',
                          _emailController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildTextField(
                        'NAME',
                        _nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      AppUtils().vSpace(size: 20),
                      _buildTextField(
                        'EMAIL',
                        _emailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ],
                  );
                }
              },
            ),
            AppUtils().vSpace(
              size: 20,
            ), // Spacing between name/email and message
            // Message Input
            _buildTextField(
              'MESSAGE',
              _messageController,
              maxLines: 6,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your message';
                }
                return null;
              },
            ),
            AppUtils().vSpace(size: 20), // Spacing
            // Attach File
            Row(
              children: [
                Icon(
                  Icons.attach_file,
                  color: Colors.white,
                ), // Attach file icon
                AppUtils().hSpace(size: 8), // Spacing
                Text(
                  'ATTACH FILE',
                  style: AppStyles.body(
                    fontSize: 14,
                  ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ), // Attach file text
              ],
            ),
            AppUtils().vSpace(size: 40), // Spacing before button
            // Submit Button
            AppButton(
              title: _isSubmitting ? 'Submitting...' : 'Submit now',
              icons: Icons.arrow_forward,
              onTap: _isSubmitting ? null : _submitForm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      onTap: () {
        // Track form field interaction
        AnalyticsService.trackEvent(
          eventName: 'form_field_focused',
          eventData: {'field_name': label.toLowerCase()},
        );
      },
      style: AppStyles.body(fontSize: 16).copyWith(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppStyles.body(
          fontSize: 14,
        ).copyWith(color: Colors.white.withOpacity(0.7)), // Label text style
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.5),
          ), // Underline color when enabled
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
          ), // Underline color when focused
        ), // Underline border
        hintStyle: AppStyles.body(
          fontSize: 16,
        ).copyWith(color: Colors.white.withOpacity(0.7)), // Hint text style
        contentPadding: EdgeInsets.only(
          bottom: 8.0,
        ), // Adjust padding below text
      ),
    );
  }
}
