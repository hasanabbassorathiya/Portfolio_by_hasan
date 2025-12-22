/// JWT Token Helper Widget
/// Displays the current JWT token for easy copying to Postman
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';

class JwtTokenHelper extends StatelessWidget {
  const JwtTokenHelper({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SupabaseService.auth?.currentSession;
    final token = session?.accessToken;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.key, color: AppColors.primaryColor),
                AppUtils().hSpace(size: 12),
                Text(
                  'JWT Token for Postman',
                  style: AppStyles.heading(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            AppUtils().vSpace(size: 16),
            if (token == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade700),
                    AppUtils().hSpace(size: 12),
                    Expanded(
                      child: Text(
                        'Not logged in. Please login first to get your JWT token.',
                        style: AppStyles.body(color: Colors.orange.shade900),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your JWT Token:',
                    style: AppStyles.body(fontWeight: FontWeight.bold),
                  ),
                  AppUtils().vSpace(size: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            token,
                            style: AppStyles.body(fontSize: 12).copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        AppUtils().hSpace(size: 8),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy to clipboard',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: token));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('JWT token copied to clipboard!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  AppUtils().vSpace(size: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            AppUtils().hSpace(size: 8),
                            Text(
                              'How to use in Postman:',
                              style: AppStyles.body(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        AppUtils().vSpace(size: 8),
                        Text(
                          '1. Copy the token above\n'
                          '2. Open Postman → Environments\n'
                          '3. Edit your environment\n'
                          '4. Set JWT_TOKEN variable to the copied token\n'
                          '5. Save and use admin endpoints',
                          style: AppStyles.body(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

