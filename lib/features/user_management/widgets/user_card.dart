import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';

class UserCard extends StatefulWidget {
  final String? _avatarUrl;
  final String _title;
  final String _subTitle;
  final bool _isActive;

  const UserCard({
    super.key,
    String? avatarUrl,
    required String title,
    required String subTitle,
    required bool isActive,
  }) : _avatarUrl = avatarUrl,
       _title = title,
       _subTitle = subTitle,
       _isActive = isActive;

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  Widget leading() {
    if (widget._avatarUrl != null && widget._avatarUrl!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: AssetImage(widget._avatarUrl!)),
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: Text(
            widget._title.split(' ').last[0],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 22,
            ),
          ),
        ),
      );
    }
  }

  Widget trailing() {
    if (widget._isActive) {
      return IconButton.filled(
        color: AppColors.error,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
        ),
        onPressed: () {},
        icon: Icon(Icons.block_flipped),
      );
    } else {
      return IconButton.filled(
        color: AppColors.success,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
        ),
        onPressed: () {},
        icon: Icon(Icons.task_alt),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading(),
      title: Text(widget._title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(widget._subTitle, style: TextStyle(fontSize: 13)),
      trailing: trailing(),
      tileColor: AppColors.background,
      selectedColor: AppColors.textSecondary,
    );
  }
}
