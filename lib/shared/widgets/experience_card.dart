import 'package:flutter/material.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';

class ExperienceCard extends StatefulWidget {
  final String title, designation, company;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> experience;

  const ExperienceCard({
    super.key,
    required this.title,
    required this.experience,
    required this.designation,
    required this.company,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<ExperienceCard> {
  bool _isExpanded = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final String dateRange = widget.endDate.year == widget.startDate.year
        ? '${widget.startDate.year}'
        : '${widget.startDate.year} - ${widget.endDate.year}';
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(20.0),
          margin: const EdgeInsets.only(bottom: 20.0),
          decoration: BoxDecoration(
            color: _isExpanded || _isHovered
                ? AppColors.bgColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: _isExpanded || _isHovered
                  ? AppColors.bgColor.withOpacity(0.3)
                  : AppColors.bgColor.withOpacity(0.2),
              width: _isExpanded || _isHovered ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '-${widget.company}',
                          style: AppStyles.body(
                            color: AppColors.bgColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        AppUtils().vSpace(size: 8.0),
                        Text(
                          widget.designation.toUpperCase(),
                          style: AppStyles.heading(
                            color: AppColors.bgColor,
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Text(
                    '-$dateRange',
                    style: AppStyles.subheading(
                      color: AppColors.bgColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (_isExpanded && widget.experience.isNotEmpty) ...[
                AppUtils().vSpace(size: 20.0),
                Container(
                  height: 1.0,
                  color: AppColors.bgColor.withOpacity(0.2),
                ),
                AppUtils().vSpace(size: 20.0),
                ...widget.experience.map((exp) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 12.0, top: 6.0),
                        width: 6.0,
                        height: 6.0,
                        decoration: BoxDecoration(
                          color: AppColors.bgColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          exp,
                          style: AppStyles.body(
                            color: AppColors.bgColor,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

//widget.experience.map((e) {
//                 return Text(e, style: AppStyles.body(color: AppColors.bgColor));
//               }).toList()
