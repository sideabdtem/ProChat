import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import '../services/dummy_data.dart';
import 'dart:math';

class AdminPendingBusinessApprovalsPage extends StatefulWidget {
  const AdminPendingBusinessApprovalsPage({super.key});

  @override
  State<AdminPendingBusinessApprovalsPage> createState() => _AdminPendingBusinessApprovalsPageState();
}

class _AdminPendingBusinessApprovalsPageState extends State<AdminPendingBusinessApprovalsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final pendingBusinesses = appState.getAllBusinesses()
            .where((business) => business.verificationStatus == VerificationStatus.underReview)
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingBusinesses.length,
          itemBuilder: (context, index) {
            final business = pendingBusinesses[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundImage: business.logoUrl != null
                      ? NetworkImage(business.logoUrl!)
                      : null,
                  child: business.logoUrl == null
                      ? Text(business.name[0].toUpperCase())
                      : null,
                ),
                title: Text(business.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${business.contactEmail}'),
                    Text('Industry: ${business.industry.name}'),
                    if (business.country != null) Text('Country: ${business.country}'),
                    Text('Business Code: ${business.businessCode}'),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (business.description != null) ...[
                          const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(business.description!),
                          const SizedBox(height: 8),
                        ],
                        if (business.website != null) ...[
                          const Text('Website:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(business.website!),
                          const SizedBox(height: 8),
                        ],
                        if (business.legalDocument != null) ...[
                          const Text('Legal Document:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Document uploaded: ${business.legalDocument}'),
                          const SizedBox(height: 8),
                        ],
                        if (business.verificationAttachments.isNotEmpty) ...[
                          const Text('Verification Attachments:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          ...business.verificationAttachments.map((attachment) => Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  attachment['type'] == 'Image' 
                                    ? Icons.image
                                    : attachment['type'] == 'Link' 
                                      ? Icons.link
                                      : Icons.insert_drive_file,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        attachment['title'] ?? 'Untitled',
                                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                                      ),
                                      if (attachment['description']?.isNotEmpty == true)
                                        Text(
                                          attachment['description']!,
                                          style: TextStyle(color: Colors.grey[600], fontSize: 10),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.open_in_new, size: 14, color: Colors.grey[600]),
                              ],
                            ),
                          )),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _updateBusinessStatus(business, VerificationStatus.verified),
                              icon: const Icon(Icons.check),
                              label: const Text('Verify'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _updateBusinessStatus(business, VerificationStatus.underReview),
                              icon: const Icon(Icons.info),
                              label: const Text('More Info'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _updateBusinessStatus(business, VerificationStatus.rejected),
                              icon: const Icon(Icons.close),
                              label: const Text('Reject'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (business.verificationStatus == VerificationStatus.verified)
                          ElevatedButton.icon(
                            onPressed: () => _regenerateBusinessCode(business),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Regenerate Code'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _updateBusinessStatus(Business business, VerificationStatus status) {
    final appState = context.read<AppState>();
    
    String businessCode = business.businessCode;
    
    // Generate new business code if approved
    if (status == VerificationStatus.verified && business.businessCode.isEmpty) {
      businessCode = _generateBusinessCode();
    }
    
    // Update business status
    final updatedBusiness = business.copyWith(
      verificationStatus: status,
      businessCode: businessCode,
    );
    
    // Update in app state
    appState.updateBusiness(updatedBusiness);
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Business ${business.name} status updated to ${status.name}'),
        backgroundColor: status == VerificationStatus.verified ? Colors.green : 
                        status == VerificationStatus.rejected ? Colors.red : Colors.orange,
      ),
    );
  }

  void _regenerateBusinessCode(Business business) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate Business Code'),
        content: const Text('Are you sure you want to regenerate the business code? This will invalidate the current code.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final appState = context.read<AppState>();
              final newCode = _generateBusinessCode();
              final updatedBusiness = business.copyWith(businessCode: newCode);
              appState.updateBusiness(updatedBusiness);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('New business code generated: $newCode'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );
  }

  String _generateBusinessCode() {
    final random = Random();
    final numbers = List.generate(6, (_) => random.nextInt(10)).join();
    return 'BIZ-$numbers';
  }
}