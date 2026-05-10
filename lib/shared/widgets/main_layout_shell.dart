import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/widgets/sidebar.dart';
import 'package:portfolio/shared/widgets/smooth_scroll_wrapper.dart';
import 'package:portfolio/views/home/home.dart';
import 'package:portfolio/views/about/about.dart';
import 'package:portfolio/views/services/services.dart';
import 'package:portfolio/views/experiences/experiences.dart';
import 'package:portfolio/views/works/works.dart';
import 'package:portfolio/views/blogs/blogs.dart';
import 'package:portfolio/views/contact/contact.dart';

class MainLayoutShell extends StatefulWidget {
  const MainLayoutShell({super.key, required this.child});
  final Widget child;
  @override
  State<MainLayoutShell> createState() => _MainLayoutShellState();
}

class _MainLayoutShellState extends State<MainLayoutShell> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(7, (_) => GlobalKey());
  int _activeSection = 0;

  void _scrollToSection(int index) {
    final context = _sectionKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
        alignment: 0.0, // Align to top
      );
      setState(() {
        _activeSection = index;
      });
    }
  }

  void _onScroll() {
    for (int i = 0; i < _sectionKeys.length; i++) {
      final context = _sectionKeys[i].currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        final offset = box.localToGlobal(Offset.zero, ancestor: null).dy;
        if (offset >= 0 && offset < MediaQuery.of(context).size.height / 2) {
          if (_activeSection != i) {
            setState(() {
              _activeSection = i;
            });
          }
          break;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Add post-frame callback to check initial route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? location = GoRouterState.of(context).uri.toString();
      if (location != null) {
        final index = _routeToSectionIndex(location);
        _scrollToSection(index);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar:
          isSmall
              ? AppBar(
                leading: Builder(
                  builder:
                      (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                ),
                title: Text(
                  _sectionTitle(_activeSection),
                  style: AppStyles.heading(fontSize: 20),
                ),
                centerTitle: true,
              )
              : null,
      drawer:
          isSmall
              ? AppSidebar(
                currentLocation: _sectionRoute(_activeSection),
                onMenuItemTap: (route) {
                  final index = _routeToSectionIndex(route);
                  _scrollToSection(index);
                  if (isSmall) Navigator.of(context).pop();
                },
              )
              : null,
      body: Row(
        children: [
          if (!isSmall)
            AppSidebar(
              currentLocation: _sectionRoute(_activeSection),
              onMenuItemTap: (route) {
                final index = _routeToSectionIndex(route);
                _scrollToSection(index);
              },
            ),
          Expanded(
            child: SmoothScrollWrapper(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedSection(
                    delay: Duration.zero,
                    child: _SectionContainer(
                      key: _sectionKeys[0],
                      child: Home(isActive: _activeSection == 0),
                    ),
                  ),
                  AnimatedSection(
                    delay: const Duration(milliseconds: 100),
                    child: _SectionContainer(
                      key: _sectionKeys[1],
                      child: About(isActive: _activeSection == 1),
                    ),
                  ),
                  AnimatedSection(
                    delay: const Duration(milliseconds: 200),
                    child: _SectionContainer(
                      key: _sectionKeys[2],
                      child: Services(isActive: _activeSection == 2),
                    ),
                  ),
                  AnimatedSection(
                    delay: const Duration(milliseconds: 300),
                    child: _SectionContainer(
                      key: _sectionKeys[3],
                      child: Experiences(isActive: _activeSection == 3),
                    ),
                  ),
                  AnimatedSection(
                    delay: const Duration(milliseconds: 400),
                    child: _SectionContainer(
                      key: _sectionKeys[4],
                      child: Works(isActive: _activeSection == 4),
                    ),
                  ),
                  AnimatedSection(
                    delay: const Duration(milliseconds: 500),
                    child: _SectionContainer(
                      key: _sectionKeys[5],
                      child: Blogs(isActive: _activeSection == 5),
                    ),
                  ),
                  AnimatedSection(
                    delay: const Duration(milliseconds: 600),
                    child: _SectionContainer(
                      key: _sectionKeys[6],
                      child: Contact(isActive: _activeSection == 6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sectionTitle(int index) {
    switch (index) {
      case 0:
        return 'HOME';
      case 1:
        return 'ABOUT';
      case 2:
        return 'SERVICES';
      case 3:
        return 'EXPERIENCES';
      case 4:
        return 'WORKS';
      case 5:
        return 'BLOGS';
      case 6:
        return 'CONTACT';
      default:
        return '';
    }
  }

  String _sectionRoute(int index) {
    switch (index) {
      case 0:
        return '/';
      case 1:
        return '/about';
      case 2:
        return '/services';
      case 3:
        return '/experiences';
      case 4:
        return '/works';
      case 5:
        return '/blogs';
      case 6:
        return '/contact';
      default:
        return '/';
    }
  }

  int _routeToSectionIndex(String route) {
    switch (route) {
      case '/':
        return 0;
      case '/about':
        return 1;
      case '/services':
        return 2;
      case '/experiences':
        return 3;
      case '/works':
        return 4;
      case '/blogs':
        return 5;
      case '/contact':
        return 6;
      default:
        return 0;
    }
  }
}

class _SectionContainer extends StatelessWidget {
  final Widget child;
  const _SectionContainer({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(width: double.infinity, child: child);
  }
}
