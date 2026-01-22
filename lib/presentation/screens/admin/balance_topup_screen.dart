import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/services/admin_balance_service.dart';
import '../../../domain/services/balance_service.dart';
import '../../providers/auth_provider.dart';

/// Balance top-up screen for admin
/// Allows admin to search for companies and top up their balance
class BalanceTopUpScreen extends ConsumerStatefulWidget {
  const BalanceTopUpScreen({super.key});

  @override
  ConsumerState<BalanceTopUpScreen> createState() => _BalanceTopUpScreenState();
}

class _BalanceTopUpScreenState extends ConsumerState<BalanceTopUpScreen> {
  final _searchController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final AdminBalanceService _adminBalanceService;
  late final BalanceService _balanceService;

  List<Map<String, dynamic>> _companies = [];
  Map<String, dynamic>? _selectedCompany;
  double? _currentBalance;
  bool _isSearching = false;
  bool _isLoadingBalance = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _adminBalanceService = AdminBalanceService();
    _balanceService = BalanceService();
    _loadRecentCompanies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentCompanies() async {
    setState(() => _isSearching = true);
    try {
      final companies = await _adminBalanceService.searchCompanies('');
      setState(() {
        _companies = companies;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки компаний: $e')),
        );
      }
    }
  }

  Future<void> _searchCompanies(String query) async {
    setState(() => _isSearching = true);
    try {
      final companies = await _adminBalanceService.searchCompanies(query);
      setState(() {
        _companies = companies;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка поиска: $e')),
        );
      }
    }
  }

  Future<void> _selectCompany(Map<String, dynamic> company) async {
    setState(() {
      _selectedCompany = company;
      _isLoadingBalance = true;
      _currentBalance = null;
    });

    try {
      final balance = await _balanceService.getBalance(company['id']);
      setState(() {
        _currentBalance = balance;
        _isLoadingBalance = false;
      });
    } catch (e) {
      setState(() => _isLoadingBalance = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки баланса: $e')),
        );
      }
    }
  }

  Future<void> _processTopUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите компанию')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Неверная сумма')),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog(amount);
    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      final user = ref.read(authStateProvider).value;
      await _adminBalanceService.topUpBalance(
        companyId: _selectedCompany!['id'],
        adminId: user!.id,
        amount: amount,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        adminName: user.fullName,
        companyName: _selectedCompany!['companyName'],
      );

      setState(() => _isProcessing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Баланс успешно пополнен'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh balance
        _selectCompany(_selectedCompany!);

        // Clear form
        _amountController.clear();
        _notesController.clear();
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog(double amount) async {
    final oldBalance = _currentBalance ?? 0;
    final newBalance = oldBalance + amount;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Подтверждение пополнения'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Компания: ${_selectedCompany!['companyName']}'),
                const SizedBox(height: 8),
                Text('Сумма пополнения: ${amount.toStringAsFixed(0)} сум'),
                const SizedBox(height: 8),
                Text('Текущий баланс: ${oldBalance.toStringAsFixed(0)} сум'),
                const SizedBox(height: 8),
                Text(
                  'Новый баланс: ${newBalance.toStringAsFixed(0)} сум',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Подтвердить'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пополнение баланса'),
      ),
      body: Column(
        children: [
          // Search section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Поиск компании',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Введите название компании или имя пользователя',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadRecentCompanies();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      _loadRecentCompanies();
                    } else {
                      _searchCompanies(value);
                    }
                  },
                ),
              ],
            ),
          ),

          // Company list
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _companies.isEmpty
                    ? const Center(
                        child: Text('Компании не найдены'),
                      )
                    : ListView.builder(
                        itemCount: _companies.length,
                        itemBuilder: (context, index) {
                          final company = _companies[index];
                          final isSelected = _selectedCompany?['id'] == company['id'];

                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: Colors.blue[50],
                            leading: CircleAvatar(
                              backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                              child: Icon(
                                Icons.business,
                                color: isSelected ? Colors.white : Colors.grey[600],
                              ),
                            ),
                            title: Text(
                              company['companyName'] ?? 'Без названия',
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              '@${company['username']} • ${company['phoneNumber']}',
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Colors.blue)
                                : null,
                            onTap: () => _selectCompany(company),
                          );
                        },
                      ),
          ),

          // Top-up form
          if (_selectedCompany != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Current balance
                    if (_isLoadingBalance)
                      const Center(child: CircularProgressIndicator())
                    else if (_currentBalance != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Текущий баланс:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${_currentBalance!.toStringAsFixed(0)} сум',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Amount input
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Сумма пополнения',
                        hintText: 'Введите сумму (10,000 - 10,000,000)',
                        suffixText: 'сум',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите сумму';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null) {
                          return 'Неверная сумма';
                        }
                        if (amount < 10000) {
                          return 'Минимум: 10,000 сум';
                        }
                        if (amount > 10000000) {
                          return 'Максимум: 10,000,000 сум';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Notes input
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Примечание (необязательно)',
                        hintText: 'Добавьте примечание',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Submit button
                    ElevatedButton(
                      onPressed: _isProcessing ? null : _processTopUp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Пополнить баланс',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
