import 'package:flutter/material.dart';

import '../viewmodel/account_viewmodel.dart';
import '../widgets/account_card.dart';
import 'account_form_page.dart';

/// Danh sách tài khoản nhân viên — có search + filter role.
class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  late Future<List<AccountModel>> _accountsFuture;
  final _searchController = TextEditingController();
  String _selectedRole = '';

  static const _roleFilters = <String, String>{
    '': 'Tất cả',
    'RECEPTIONIST': 'Lễ tân',
    'SERVICE_STAFF': 'Phục vụ',
    'HOUSEKEEPER': 'Buồng phòng',
  };

  @override
  void initState() {
    super.initState();
    _accountsFuture = _loadAccounts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<AccountModel>> _loadAccounts() {
    return AccountApi.getAccounts(
      search: _searchController.text.trim(),
      role: _selectedRole,
    );
  }

  void _reload() {
    setState(() {
      _accountsFuture = _loadAccounts();
    });
  }

  Future<void> _navigateToCreate() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AccountFormPage()),
    );
    if (created == true) _reload();
  }

  Future<void> _navigateToEdit(AccountModel account) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AccountFormPage(account: account),
      ),
    );
    if (updated == true) _reload();
  }

  Future<void> _deactivate(AccountModel account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vô hiệu hóa tài khoản'),
        content: Text(
          'Bạn có chắc muốn vô hiệu hóa tài khoản "${account.fullName}" (@${account.username})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Vô hiệu hóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AccountApi.deactivateAccount(account.userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã vô hiệu hóa tài khoản')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Quản lý tài khoản'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Tạo tài khoản'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary.withValues(alpha: 0.10),
              const Color(0xFFF6F8FC),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 100),
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tài khoản nhân viên',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Quản lý tài khoản lễ tân, nhân viên phục vụ và buồng phòng.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search bar
              TextField(
                controller: _searchController,
                onChanged: (_) => _reload(),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tên, username, SĐT...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.95),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Role filter chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _roleFilters.entries.map((entry) {
                  final isSelected = _selectedRole == entry.key;
                  return ChoiceChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedRole = entry.key;
                      });
                      _reload();
                    },
                    selectedColor: scheme.primary.withValues(alpha: 0.18),
                    labelStyle: TextStyle(
                      color:
                          isSelected ? scheme.primary : Colors.grey.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Account list
              FutureBuilder<List<AccountModel>>(
                future: _accountsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return _ErrorCard(
                      message: 'Không tải được danh sách tài khoản',
                      onRetry: _reload,
                    );
                  }

                  final accounts = snapshot.data ?? [];
                  if (accounts.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text('Không tìm thấy tài khoản nào'),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: accounts
                        .map(
                          (account) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AccountCard(
                              account: account,
                              onTap: () => _navigateToEdit(account),
                              onDeactivate: account.isActive
                                  ? () => _deactivate(account)
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey.shade500),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Tải lại')),
        ],
      ),
    );
  }
}
