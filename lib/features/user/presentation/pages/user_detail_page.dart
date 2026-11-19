import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/core/di/injection.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/dialog_widget.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/info_tile_widget.dart';
import 'package:lavendera/features/user/presentation/bloc/action/user_action_bloc.dart';
import 'package:lavendera/features/user/presentation/bloc/detail/user_detail_bloc.dart';
import 'package:lavendera/features/user/presentation/bloc/user_bloc.dart';
import 'package:lavendera/features/user/presentation/pages/edit_user_page.dart';

class UserDetailPage extends StatelessWidget {
  final String userId;
  const UserDetailPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => sl<UserDetailBloc>()..add(GetUserByIdRequest(id: userId)),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            BlocBuilder<UserDetailBloc, UserDetailState>(
              builder: (context, state) {
                if (state is! UserDetailLoaded) {
                  return const SizedBox.shrink();
                }
                final user = state.user;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                        : colorScheme.surfaceContainerLowest,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUserPage(user: user),
                      ),
                    ),
                  ),
                );
              },
            ),
            BlocBuilder<UserDetailBloc, UserDetailState>(
              builder: (context, state) {
                if (state is! UserDetailLoaded) {
                  return const SizedBox.shrink();
                }
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: colorScheme.error,
                      size: 20,
                    ),
                    onPressed: () => _showDeleteDialog(context, state.user.id),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocListener<UserActionBloc, UserActionState>(
          listener: (context, state) {
            if (state is UserActionSuccess) {
              context.read<UserBloc>().add(GetUsersRequest());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                  dismissDirection: DismissDirection.horizontal,
                ),
              );
            } else if (state is UserActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  dismissDirection: DismissDirection.horizontal,
                ),
              );
            }
          },
          child: BlocBuilder<UserDetailBloc, UserDetailState>(
            builder: (context, state) {
              if (state is UserDetailLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colorScheme.primary,
                  ),
                );
              }
              if (state is UserDetailError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          final detailBloc = context.read<UserDetailBloc>();
                          final parent = context
                              .findAncestorWidgetOfExactType<UserDetailPage>();
                          if (parent != null) {
                            detailBloc.add(
                              GetUserByIdRequest(id: parent.userId),
                            );
                          }
                        },
                        child: Text(
                          'Coba Lagi',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (state is UserDetailLoaded) {
                final user = state.user;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Center(
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.displayLarge.copyWith(
                              color: colorScheme.primary,
                              fontSize: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        user.name,
                        style: AppTextStyles.displaySmall.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? colorScheme.surfaceContainer : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? colorScheme.outlineVariant.withValues(alpha: 0.2)
                                : Colors.grey.shade100,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.02,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            InfoTileWidget(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: user.email,
                            ),
                            Divider(
                              height: 32,
                              thickness: 0.5,
                              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                            ),
                            InfoTileWidget(
                              icon: Icons.check_circle_outline,
                              label: 'Status Akun',
                              value: user.isActive ? 'Aktif' : 'Nonaktif',
                              iconColor: user.isActive
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            Divider(
                              height: 32,
                              thickness: 0.5,
                              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                            ),
                            InfoTileWidget(
                              icon: Icons.badge_outlined,
                              label: 'User ID',
                              value: user.id,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? colorScheme.surfaceContainer : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? colorScheme.outlineVariant.withValues(alpha: 0.2)
                                : Colors.grey.shade100,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.02,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            InfoTileWidget(
                              icon: Icons.calendar_today_outlined,
                              label: 'Dibuat Pada',
                              value: _formatDate(user.createdAt),
                              iconColor: colorScheme.onSurfaceVariant,
                            ),
                            Divider(
                              height: 32,
                              thickness: 0.5,
                              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                            ),
                            InfoTileWidget(
                              icon: Icons.update_outlined,
                              label: 'Terakhir Diperbarui',
                              value: _formatDate(user.updatedAt),
                              iconColor: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String userId) async {
    final confirmed = await DialogWidget.showDeleteConfirmation(
      context,
      title: 'Hapus Pengguna?',
      content: 'Tindakan ini tidak dapat dibatalkan. Pengguna ini tidak akan dapat mengakses sistem lagi.',
    );
    if (confirmed == true && context.mounted) {
      context.read<UserActionBloc>().add(DeleteUserActionRequest(id: userId));
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
