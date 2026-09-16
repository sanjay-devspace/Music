import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/controllers/auth_controller.dart';
import 'package:tunehive/core/animation/fade_slide.dart';
import 'package:tunehive/widgets/empty_state.dart';

enum _Filter { all, music, activity }

class NotificationCenterView extends StatefulWidget {
  const NotificationCenterView({super.key});

  @override
  State<NotificationCenterView> createState() => _NotificationCenterViewState();
}

class _NotificationCenterViewState extends State<NotificationCenterView> {
  _Filter _filter = _Filter.all;
  final Set<int> _readIndices = {};

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(auth),
            _buildFilters(),
            Expanded(
              child: Obx(() {
                final all = auth.notifications;
                final filtered = _applyFilter(all);

                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: 'No notifications',
                    message: 'You are all caught up!',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final originalIndex = all.indexOf(item);
                    final isRead = _readIndices.contains(originalIndex);

                    return FadeSlide(
                      delay: Duration(milliseconds: 60 + index * 50),
                      child: _buildNotificationCard(
                        title: item['title'] ?? '',
                        body: item['body'] ?? '',
                        time: item['time'] ?? '',
                        isMusic: _isMusicNotification(item),
                        isRead: isRead,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                item['body'] ?? '',
                                style: const TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                ),
                              ),
                              backgroundColor: AppColors.surface,
                            ),
                          );
                          setState(() {
                            _readIndices.add(originalIndex);
                          });
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _applyFilter(RxList<Map<String, String>> all) {
    switch (_filter) {
      case _Filter.all:
        return all.toList();
      case _Filter.music:
        return all.where((n) => _isMusicNotification(n)).toList();
      case _Filter.activity:
        return all.where((n) => !_isMusicNotification(n)).toList();
    }
  }

  bool _isMusicNotification(Map<String, String> n) {
    final lower = (n['body'] ?? '').toLowerCase();
    return lower.contains('playlist') || lower.contains('mix');
  }

  Widget _buildHeader(AuthController auth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Obx(() {
            final count = auth.notifications.length;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textMuted,
                  size: 22,
                ),
                if (count > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          _filterChip('All', _Filter.all),
          const SizedBox(width: 8),
          _filterChip('Music', _Filter.music),
          const SizedBox(width: 8),
          _filterChip('Activity', _Filter.activity),
        ],
      ),
    );
  }

  Widget _filterChip(String label, _Filter value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.onPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String body,
    required String time,
    required bool isMusic,
    required bool isRead,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMusic
                        ? Icons.music_note_rounded
                        : Icons.announcement_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        time,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRead)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
