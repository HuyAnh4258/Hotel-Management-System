import 'dart:math';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../viewmodel/account_viewmodel.dart';

/// Form page for Create and Update account.
/// If [account] is null → Create mode; otherwise → Edit mode.
class AccountFormPage extends StatefulWidget {
  const AccountFormPage({super.key, this.account});

  final AccountModel? account;

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _salaryController = TextEditingController();

  String _selectedRole = 'RECEPTIONIST';
  bool _submitting = false;

  bool get _isEditMode => widget.account != null;

  static const _roleOptions = <String, String>{
    'RECEPTIONIST': 'Lễ tân',
    'SERVICE_STAFF': 'Nhân viên phục vụ',
    'HOUSEKEEPER': 'Nhân viên buồng phòng',
  };

  String _generateSecurePassword() {
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const digits = '0123456789';
    const specials = r'@#$%&*!';
    
    final r = Random.secure();
    final charList = [
      upper[r.nextInt(upper.length)],
      lower[r.nextInt(lower.length)],
      digits[r.nextInt(digits.length)],
      specials[r.nextInt(specials.length)],
    ];
    
    const allChars = '$upper$lower$digits$specials';
    for (var i = 0; i < 6; i++) {
      charList.add(allChars[r.nextInt(allChars.length)]);
    }
    
    charList.shuffle(r);
    return charList.join();
  }

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final a = widget.account!;
      _usernameController.text = a.username;
      _emailController.text = a.email;
      _fullNameController.text = a.fullName;
      _phoneController.text = a.phone;
      _salaryController.text =
          a.salary != null ? a.salary!.toStringAsFixed(0) : '';
      _selectedRole = _roleOptions.containsKey(a.roleName.toUpperCase())
          ? a.roleName.toUpperCase()
          : 'RECEPTIONIST';
    } else {
      // Sinh mật khẩu ngẫu nhiên thỏa mãn validation khi tạo tài khoản mới
      _passwordController.text = _generateSecurePassword();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      if (_isEditMode) {
        await AccountApi.updateAccount(
          widget.account!.userId,
          UpdateAccountPayload(
            email: _emailController.text.trim(),
            fullName: _fullNameController.text.trim(),
            phone: _phoneController.text.trim(),
            roleName: _selectedRole,
            salary: _salaryController.text.trim().isNotEmpty
                ? double.tryParse(_salaryController.text.trim())
                : null,
            // Không truyền password khi edit (được quản lý riêng bởi User qua Quên mật khẩu)
            password: null,
          ),
        );
      } else {
        await AccountApi.createAccount(
          CreateAccountPayload(
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            fullName: _fullNameController.text.trim(),
            phone: _phoneController.text.trim(),
            roleName: _selectedRole,
            salary: _salaryController.text.trim().isNotEmpty
                ? double.tryParse(_salaryController.text.trim())
                : null,
          ),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Cập nhật tài khoản thành công'
                : 'Tạo tài khoản thành công',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString();
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          errorMsg = data['message'].toString();
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $errorMsg')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Cập nhật tài khoản' : 'Tạo tài khoản'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 40),
          children: [
            // Header card
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
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _isEditMode
                              ? Icons.edit_rounded
                              : Icons.person_add_rounded,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _isEditMode
                              ? 'Chỉnh sửa thông tin'
                              : 'Tạo tài khoản mới',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isEditMode
                        ? 'Cập nhật thông tin tài khoản nhân viên. Để trống mật khẩu nếu không đổi.'
                        : 'Điền đầy đủ thông tin để tạo tài khoản nhân viên mới.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Username
                  TextFormField(
                    controller: _usernameController,
                    enabled: !_isEditMode,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.95),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _isEditMode
                          ? const Icon(Icons.lock_rounded, size: 18)
                          : null,
                    ),
                    validator: (v) {
                      if (!_isEditMode && (v == null || v.trim().isEmpty)) {
                        return 'Nhập username';
                      }
                      if (!_isEditMode && v!.trim().length < 3) {
                        return 'Username tối thiểu 3 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_rounded),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.95),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Nhập email';
                      if (!v.contains('@')) return 'Email không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Password (Chỉ hiển thị khi tạo mới, dạng Read-only và cho phép copy)
                  if (!_isEditMode) ...[
                    TextFormField(
                      controller: _passwordController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu tạm thời (Tự động sinh)',
                        helperText: 'Nhân viên sẽ dùng chức năng Quên mật khẩu để đổi lại',
                        prefixIcon: const Icon(Icons.lock_rounded),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.copy_rounded),
                          tooltip: 'Sao chép mật khẩu',
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: _passwordController.text),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Đã sao chép mật khẩu tạm thời vào Clipboard',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Full name
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Họ và tên',
                      prefixIcon: const Icon(Icons.person_rounded),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.95),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Nhập họ và tên';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: const Icon(Icons.phone_rounded),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.95),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Nhập số điện thoại';
                      }
                      if (v.trim().length != 10) {
                        return 'SĐT phải đúng 10 chữ số';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Salary
                  TextFormField(
                    controller: _salaryController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Lương (VNĐ) — không bắt buộc',
                      prefixIcon: const Icon(Icons.payments_rounded),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.95),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Role dropdown
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vai trò',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        ..._roleOptions.entries.map((entry) {
                          final isSelected = _selectedRole == entry.key;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                setState(() => _selectedRole = entry.key);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? scheme.primary
                                          .withValues(alpha: 0.10)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? scheme.primary
                                        : Colors.grey.shade200,
                                    width: isSelected ? 1.4 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons
                                              .radio_button_unchecked_rounded,
                                      color: isSelected
                                          ? scheme.primary
                                          : Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      entry.value,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _submitting ? null : _submit,
                      icon: Icon(
                        _isEditMode ? Icons.save_rounded : Icons.add_rounded,
                      ),
                      label: Text(
                        _submitting
                            ? 'Đang xử lý...'
                            : _isEditMode
                                ? 'Lưu thay đổi'
                                : 'Tạo tài khoản',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
