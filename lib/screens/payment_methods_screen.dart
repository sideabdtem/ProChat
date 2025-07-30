import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import '../widgets/navigation_wrapper.dart';

class PaymentMethod {
  final String id;
  final String type; // 'card', 'paypal', 'bank'
  final String displayName;
  final String lastFourDigits;
  final String? expiryDate;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.displayName,
    required this.lastFourDigits,
    this.expiryDate,
    required this.isDefault,
  });
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: '1',
      type: 'card',
      displayName: 'Visa ****1234',
      lastFourDigits: '1234',
      expiryDate: '12/25',
      isDefault: true,
    ),
    PaymentMethod(
      id: '2',
      type: 'card',
      displayName: 'Mastercard ****5678',
      lastFourDigits: '5678',
      expiryDate: '06/26',
      isDefault: false,
    ),
    PaymentMethod(
      id: '3',
      type: 'paypal',
      displayName: 'PayPal',
      lastFourDigits: '',
      isDefault: false,
    ),
  ];

  void _addPaymentMethod() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddPaymentMethodSheet(),
    ).then((result) {
      if (result != null && result is PaymentMethod) {
        setState(() {
          _paymentMethods.add(result);
        });
      }
    });
  }

  void _removePaymentMethod(String paymentMethodId) {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.translate('remove_payment_method')),
        content: Text(appState.translate('remove_payment_method_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _paymentMethods
                    .removeWhere((method) => method.id == paymentMethodId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text(appState.translate('payment_method_removed'))),
              );
            },
            child: Text(appState.translate('remove')),
          ),
        ],
      ),
    );
  }

  void _setDefaultPaymentMethod(String paymentMethodId) {
    final appState = context.read<AppState>();
    setState(() {
      _paymentMethods = _paymentMethods.map((method) {
        return PaymentMethod(
          id: method.id,
          type: method.type,
          displayName: method.displayName,
          lastFourDigits: method.lastFourDigits,
          expiryDate: method.expiryDate,
          isDefault: method.id == paymentMethodId,
        );
      }).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(appState.translate('default_payment_method_updated'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();

    return NavigationWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            appState.translate('payment_methods'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: _addPaymentMethod,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_paymentMethods.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.payment_outlined,
                      size: 100,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      appState.translate('no_payment_methods'),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appState.translate('add_payment_method_to_book'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ..._paymentMethods
                  .map((method) => _buildPaymentMethodCard(method, theme)),
            const SizedBox(height: 100),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addPaymentMethod,
          backgroundColor: theme.colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method, ThemeData theme) {
    IconData getIcon() {
      switch (method.type) {
        case 'card':
          return Icons.credit_card;
        case 'paypal':
          return Icons.account_balance_wallet;
        case 'bank':
          return Icons.account_balance;
        default:
          return Icons.payment;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            getIcon(),
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          method.displayName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (method.expiryDate != null)
              Text('Expires: ${method.expiryDate}'),
            if (method.isDefault)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'default':
                _setDefaultPaymentMethod(method.id);
                break;
              case 'remove':
                _removePaymentMethod(method.id);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!method.isDefault)
              const PopupMenuItem(
                value: 'default',
                child: Row(
                  children: [
                    Icon(Icons.star_outline),
                    SizedBox(width: 8),
                    Text('Set as default'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Remove', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddPaymentMethodSheet extends StatefulWidget {
  const AddPaymentMethodSheet({super.key});

  @override
  State<AddPaymentMethodSheet> createState() => _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState extends State<AddPaymentMethodSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedType = 'card';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _savePaymentMethod() {
    if (_formKey.currentState!.validate()) {
      final newMethod = PaymentMethod(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedType,
        displayName: _selectedType == 'card'
            ? 'Card ****${_cardNumberController.text.substring(_cardNumberController.text.length - 4)}'
            : _nameController.text,
        lastFourDigits: _selectedType == 'card'
            ? _cardNumberController.text
                .substring(_cardNumberController.text.length - 4)
            : '',
        expiryDate: _selectedType == 'card' ? _expiryDateController.text : null,
        isDefault: false,
      );

      Navigator.pop(context, newMethod);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Payment Method',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Payment Type Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTypeSelector('card', 'Card', Icons.credit_card),
                _buildTypeSelector(
                    'paypal', 'PayPal', Icons.account_balance_wallet),
                _buildTypeSelector('bank', 'Bank', Icons.account_balance),
              ],
            ),
            const SizedBox(height: 24),

            if (_selectedType == 'card') ...[
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  if (value.length < 16) {
                    return 'Card number must be at least 16 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryDateController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date',
                        hintText: 'MM/YY',
                        prefixIcon: Icon(Icons.date_range),
                      ),
                      keyboardType: TextInputType.datetime,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter expiry date';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        prefixIcon: Icon(Icons.security),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter CVV';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _selectedType == 'paypal'
                      ? 'PayPal Email'
                      : 'Account Name',
                  hintText: _selectedType == 'paypal'
                      ? 'email@example.com'
                      : 'Account holder name',
                  prefixIcon: Icon(
                      _selectedType == 'paypal' ? Icons.email : Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ${_selectedType == 'paypal' ? 'email' : 'account name'}';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(appState.translate('cancel')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _savePaymentMethod,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(appState.translate('add_payment_method')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(String type, String label, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
