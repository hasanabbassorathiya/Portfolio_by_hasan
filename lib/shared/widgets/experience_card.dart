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
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '-${widget.startDate.year}\t - ${widget.endDate.year}',
                  style: AppStyles.subheading(
                    color: AppColors.bgColor,
                    fontSize: 18.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  '-${widget.company}',
                  style: AppStyles.body(
                    color: AppColors.bgColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppUtils().vSpace(),
          Text(
            widget.designation,
            style: AppStyles.heading(
              color: AppColors.bgColor,
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

//widget.experience.map((e) {
//                 return Text(e, style: AppStyles.body(color: AppColors.bgColor));
//               }).toList()
