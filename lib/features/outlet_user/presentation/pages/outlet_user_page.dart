import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/card_widget.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/empty_widget.dart';
import 'package:lavendera/features/outlet/domain/entities/outlet.dart';
import 'package:lavendera/features/outlet_user/domain/entities/user_summary.dart';
import 'package:lavendera/features/outlet_user/presentation/bloc/action/outlet_user_action_bloc.dart';
import 'package:lavendera/features/outlet_user/presentation/bloc/outlet_user/outlet_user_bloc.dart';
import 'package:lavendera/features/user/domain/entities/user.dart';
import 'package:lavendera/features/user/presentation/bloc/user_bloc.dart';

class OutletUserPage extends StatefulWidget {
  final Outlet outlet;
  const OutletUserPage({super.key, required this.outlet});

  @override
  State<OutletUserPage> createState() => _OutletUserPageState();
}

class _OutletUserPageState extends State<OutletUserPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _scrollController.addListener(_onScroll);
  }

  void _fetchUsers() {
    context.read<OutletUserBloc>().add(
      GetOutletUsersRequest(
        outletId: widget.outlet.id,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      ),
    );
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
      final bloc = context.read<OutletUserBloc>();
      final state = bloc.state;
      if (state is OutletUserLoaded && state.hasMorePages) {
        bloc.add(
          GetOutletUsersRequest(
            outletId: widget.outlet.id,
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
      _fetchUsers();
    });
    setState(() {});
  }

  void _showAddUserSheet() {
    context.read<UserBloc>().add(GetUsersRequest(page: 1, limit: 100));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddUserSelectionSheet(outletId: widget.outlet.id),
    );
  }

  void _showDeleteDialog(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Akses'),
        content: Text('Hapus akses staf "$userName" dari outlet ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<OutletUserActionBloc>().add(
                UnassignUserFromOutletActionRequest(
                  outletId: widget.outlet.id,
                  userId: userId,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OutletUserActionBloc, OutletUserActionState>(
      listener: (context, state) {
        if (state is OutletUserActionSuccess) {
          _fetchUsers();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              dismissDirection: DismissDirection.horizontal,
            ),
          );
        } else if (state is OutletUserActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              dismissDirection: DismissDirection.horizontal,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Colors.black87,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Staf & Pengguna',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.outlet.name,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari staf...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF4A99AD),
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            size: 20,
                            color: Colors.grey,
                          ),
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
              child: BlocBuilder<OutletUserBloc, OutletUserState>(
                builder: (context, state) {
                  if (state is OutletUserLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4A99AD),
                      ),
                    );
                  }

                  List<UserSummary> users = [];
                  if (state is OutletUserLoaded) {
                    users = state.users;
                  } else if (state is OutletUserError) {
                    users = state.cachedUsers ?? [];
                  }

                  if (users.isEmpty) {
                    return const EmptyWidget(
                      icon: Icons.people_outline,
                      title: 'Tidak ada staf',
                      subtitle: 'Belum ada staf yang ditugaskan di outlet ini.',
                    );
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: users.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return CardWidget(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF4A99AD)
                                .withValues(alpha: 0.1),
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Color(0xFF4A99AD),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            user.name,
                            style: AppTextStyles.titleMedium,
                          ),
                          subtitle: Text(
                            user.role,
                            style: AppTextStyles.bodySmall,
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () =>
                                _showDeleteDialog(user.id, user.name),
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
          onPressed: _showAddUserSheet,
          backgroundColor: const Color(0xFF4A99AD),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Tambah Staf',
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddUserSelectionSheet extends StatefulWidget {
  final String outletId;
  const _AddUserSelectionSheet({required this.outletId});

  @override
  State<_AddUserSelectionSheet> createState() => _AddUserSelectionSheetState();
}

class _AddUserSelectionSheetState extends State<_AddUserSelectionSheet> {
  final _sheetSearchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _sheetSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Pilih Staf',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _sheetSearchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Cari staf...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _sheetSearchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          _sheetSearchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<User> users = [];
                if (state is UserLoaded) {
                  users = state.users.where((u) => u.isActive).toList();
                }

                if (_searchQuery.isNotEmpty) {
                  users = users
                      .where(
                        (u) => u.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                      )
                      .toList();
                }

                if (users.isEmpty) {
                  return const EmptyWidget(
                    icon: Icons.search_off,
                    title: 'Tidak ditemukan',
                    subtitle: 'Tidak ada staf dengan akun aktif yang tersedia.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF4A99AD)
                            .withValues(alpha: 0.1),
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Color(0xFF4A99AD),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(user.name, style: AppTextStyles.bodyLarge),
                      subtitle: Row(
                        children: [
                          Text(user.role, style: AppTextStyles.bodySmall),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Aktif',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFF4A99AD),
                        ),
                        onPressed: () {
                          context.read<OutletUserActionBloc>().add(
                            AssignUserToOutletActionRequest(
                              outletId: widget.outletId,
                              userId: user.id,
                            ),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
