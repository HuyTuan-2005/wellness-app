import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';

class FeedbackItem extends StatelessWidget {
  final String name;
  final String email;
  final String content;
  final String date;
  final bool isRead;
  final VoidCallback onTap;

  const FeedbackItem({
    super.key,
    required this.name,
    required this.email,
    required this.content,
    required this.date,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.all(Radius.circular(20)),

        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),

          decoration: BoxDecoration(
            color: isRead ? AppColors.surface : AppColors.primary.withAlpha(10),
            borderRadius: BorderRadius.all(Radius.circular(20)),
            border: BoxBorder.all(
              color: isRead
                  ? AppColors.border
                  : AppColors.primary.withAlpha(80),
            ),
          ),

          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: isRead
                          ? AppColors.textDark
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(email, style: TextStyle(color: AppColors.textSecondary)),
                  SizedBox(height: 5),

                  Text(
                    content,
                    maxLines: 3,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                      color: isRead
                          ? AppColors.textSecondary
                          : AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 10),

                  Align(
                    alignment: AlignmentGeometry.centerRight,
                    child: Text(
                      date,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isRead)
                Positioned(
                  right: 0,
                  top: 5,
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 5,
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
