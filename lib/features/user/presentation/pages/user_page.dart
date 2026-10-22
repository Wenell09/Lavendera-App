import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/card_widget.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/empty_widget.dart';
import 'package:lavendera/features/user/domain/entities/user.dart';
import 'package:lavendera/features/user/presentation/bloc/user_bloc.dart';
import 'package:lavendera/features/user/presentation/pages/add_user_page.dart';
import 'package:lavendera/features/user/presentation/pages/user_detail_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<UserBloc>();
    if (bloc.state is! UserLoaded) {
      bloc.add(GetUsersRequest());
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final bloc = context.read<UserBloc>();
      final state = bloc.state;
      if (state is UserLoaded && state.hasMorePages) {
        bloc.add(
          GetUsersRequest(
            search: _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
            page: state.currentPage + 1,
          ),
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final text = query.trim();
      context.read<UserBloc>().add(
        GetUsersRequest(search: text.isEmpty ? null : text, page: 1),
      );
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Manajemen Staff',
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87, size: 20),
              onPressed: () {
                final text = _searchController.text.trim();
                context.read<UserBloc>().add(
                  GetUsersRequest(search: text.isEmpty ? null : text, page: 1),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Cari nama atau email staff...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey.shade400,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF4A99AD),
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: Colors.grey.shade400,
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF4A99AD),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF4A99AD),
                    ),
                  );
                }
                if (state is UserError) {
                  final cachedUsers = state.cachedUsers ?? [];
                  if (cachedUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: AppTextStyles.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              _onSearchChanged(_searchController.text);
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  }
                }
                List<User> users = [];
                bool isPaginationLoading = false;
                if (state is UserLoaded) {
                  users = state.users;
                } else if (state is UserPaginationLoading) {
                  users = state.users;
                  isPaginationLoading = true;
                } else if (state is UserError) {
                  users = state.cachedUsers ?? [];
                }
                if (users.isEmpty) {
                  return EmptyWidget(
                    icon: Icons.admin_panel_settings_outlined,
                    title: _searchController.text.isNotEmpty
                        ? 'Staff tidak ditemukan'
                        : 'Belum ada staff',
                    subtitle: _searchController.text.isNotEmpty
                        ? 'Coba kata kunci pencarian yang lain'
                        : 'Tambahkan staff baru untuk mulai',
                  );
                }
                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                  itemCount: users.length + (isPaginationLoading ? 1 : 0),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index >= users.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF4A99AD),
                            ),
                          ),
                        ),
                      );
                    }
                    final user = users[index];
                    return CardWidget(
                      padding: EdgeInsets.zero,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserDetailPage(userId: user.id),
                          ),
                        );
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A99AD)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '?',
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: const Color(0xFF4A99AD),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: user.isActive
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                user.isActive ? 'AKTIF' : 'NONAKTIF',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: user.isActive
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  user.email,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddUserPage()),
          );
        },
        backgroundColor: const Color(0xFF4A99AD),
        elevation: 4,
        foregroundColor: const Color(0xFF4A99AD).withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Tambah Staff',
          style: AppTextStyles.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
