import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import '../services/dummy_data.dart';

class AdminPendingExpertApprovalsPage extends StatefulWidget {
  const AdminPendingExpertApprovalsPage({super.key});

  @override
  State<AdminPendingExpertApprovalsPage> createState() => _AdminPendingExpertApprovalsPageState();
}

class _AdminPendingExpertApprovalsPageState extends State<AdminPendingExpertApprovalsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final pendingExperts = appState.getAllExperts()
            .where((expert) => expert.verificationStatus == VerificationStatus.underReview)
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingExperts.length,
          itemBuilder: (context, index) {
            final expert = pendingExperts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundImage: expert.profileImage != null
                      ? NetworkImage(expert.profileImage!)
                      : null,
                  child: expert.profileImage == null
                      ? Text(expert.name[0].toUpperCase())
                      : null,
                ),
                title: Text(expert.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${expert.email}'),
                    Text('Category: ${expert.categoryName}'),
                    if (expert.country != null) Text('Country: ${expert.country}'),
                    if (expert.linkedBusinessId != null)
                      Text('Linked to Business: ${_getBusinessName(expert.linkedBusinessId!)}'),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bio:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(expert.bio),
                        const SizedBox(height: 8),
                        if (expert.workExperience != null) ...[
                          const Text('Work Experience:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(expert.workExperience!),
                          const SizedBox(height: 8),
                        ],
                        if (expert.qualifications != null) ...[
                          const Text('Qualifications:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(expert.qualifications!),
                          const SizedBox(height: 8),
                        ],
                        if (expert.verificationAttachments.isNotEmpty) ...[
                          const Text('Verification Attachments:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          ...expert.verificationAttachments.map((attachment) => Container(
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
                              onPressed: () => _updateExpertStatus(expert, VerificationStatus.verified),
                              icon: const Icon(Icons.check),
                              label: const Text('Verify'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _updateExpertStatus(expert, VerificationStatus.underReview),
                              icon: const Icon(Icons.info),
                              label: const Text('More Info'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _updateExpertStatus(expert, VerificationStatus.rejected),
                              icon: const Icon(Icons.close),
                              label: const Text('Reject'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
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

  String _getBusinessName(String businessId) {
    // Demo mode - return dummy name
    return 'Demo Business';
  }

  void _updateExpertStatus(Expert expert, VerificationStatus status) {
    final appState = context.read<AppState>();
    
    // Update expert status
    final updatedExpert = expert.copyWith(
      verificationStatus: status,
      isVerified: status == VerificationStatus.verified,
    );
    
    // Update in app state
    appState.updateExpert(updatedExpert);
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Expert ${expert.name} status updated to ${status.name}'),
        backgroundColor: status == VerificationStatus.verified ? Colors.green : 
                        status == VerificationStatus.rejected ? Colors.red : Colors.orange,
      ),
    );
  }
}