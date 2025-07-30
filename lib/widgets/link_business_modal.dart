import 'package:flutter/material.dart';

class LinkBusinessModal extends StatefulWidget {
  final BuildContext? parentContext;
  
  const LinkBusinessModal({super.key, this.parentContext});

  @override
  State<LinkBusinessModal> createState() => _LinkBusinessModalState();
}

class _LinkBusinessModalState extends State<LinkBusinessModal> {
  final _businessCodeController = TextEditingController();
  final _businessEmailController = TextEditingController();
  bool _isLoading = false;
  int _selectedMethod = 0; // 0 for code, 1 for email

  @override
  void dispose() {
    _businessCodeController.dispose();
    _businessEmailController.dispose();
    super.dispose();
  }

  void _showErrorMessage(String message) {
    try {
      final contextToUse = widget.parentContext ?? context;
      ScaffoldMessenger.of(contextToUse).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // Fallback: show dialog if ScaffoldMessenger fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _sendLinkRequest() async {
    final code = _businessCodeController.text.trim();
    final email = _businessEmailController.text.trim();
    
    if (_selectedMethod == 0 && code.isEmpty) {
      _showErrorMessage('Please enter a business code');
      return;
    }
    
    if (_selectedMethod == 1 && email.isEmpty) {
      _showErrorMessage('Please enter a business email');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.pop(context, {
        'success': true,
        'businessName': _selectedMethod == 0 ? 'Demo Business Corp' : 'Partner Company LLC',
        'method': _selectedMethod == 0 ? 'code' : 'email',
        'identifier': _selectedMethod == 0 ? code : email,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.business,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Link to Business',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Method selection
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  RadioListTile<int>(
                    value: 0,
                    groupValue: _selectedMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedMethod = value!;
                      });
                    },
                    title: const Text('Business Code'),
                    subtitle: const Text('Enter the code provided by your business'),
                  ),
                  const Divider(height: 1),
                  RadioListTile<int>(
                    value: 1,
                    groupValue: _selectedMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedMethod = value!;
                      });
                    },
                    title: const Text('Business Email'),
                    subtitle: const Text('Send a link request to business email'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Input field
            if (_selectedMethod == 0)
              TextFormField(
                controller: _businessCodeController,
                decoration: InputDecoration(
                  labelText: 'Business Code',
                  hintText: 'Enter business code or ID',
                  prefixIcon: const Icon(Icons.qr_code),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            else
              TextFormField(
                controller: _businessEmailController,
                decoration: InputDecoration(
                  labelText: 'Business Email',
                  hintText: 'Enter business email address',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendLinkRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_selectedMethod == 0 ? 'Link Now' : 'Send Request'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}