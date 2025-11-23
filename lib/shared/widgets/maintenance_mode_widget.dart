/// Maintenance Mode Widget
/// Shows maintenance message when enabled via Remote Config
import 'package:flutter/material.dart';
import 'package:portfolio/core/services/remote_config_service.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';

class MaintenanceModeWidget extends StatefulWidget {
  final Widget child;

  const MaintenanceModeWidget({super.key, required this.child});

  @override
  State<MaintenanceModeWidget> createState() => _MaintenanceModeWidgetState();
}

class _MaintenanceModeWidgetState extends State<MaintenanceModeWidget> {
  bool _isMaintenanceMode = false;
  String _maintenanceMessage = 'We are currently performing maintenance. Please check back soon.';

  @override
  void initState() {
    super.initState();
    _checkMaintenanceMode();
    // Check periodically
    Future.delayed(const Duration(minutes: 5), _checkMaintenanceMode);
  }

  Future<void> _checkMaintenanceMode() async {
    try {
      final isMaintenance = await RemoteConfigService.isMaintenanceMode();
      final message = await RemoteConfigService.getString(
        'maintenance_message',
        defaultValue: _maintenanceMessage,
      );

      if (mounted) {
        setState(() {
          _isMaintenanceMode = isMaintenance;
          _maintenanceMessage = message;
        });
      }
    } catch (e) {
      // Silently fail - don't block app if remote config fails
      debugPrint('Error checking maintenance mode: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isMaintenanceMode) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.build_circle_outlined,
                    size: 80,
                    color: Colors.white,
                  ),
                  AppUtils().vSpace(size: 24),
                  Text(
                    'Under Maintenance',
                    style: AppStyles.heading(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppUtils().vSpace(size: 16),
                  Text(
                    _maintenanceMessage,
                    style: AppStyles.body(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}

