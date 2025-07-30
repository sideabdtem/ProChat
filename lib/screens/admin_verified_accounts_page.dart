import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';

class AdminVerifiedAccountsPage extends StatefulWidget {
  const AdminVerifiedAccountsPage({super.key});

  @override
  State<AdminVerifiedAccountsPage> createState() => _AdminVerifiedAccountsPageState();
}

class _AdminVerifiedAccountsPageState extends State<AdminVerifiedAccountsPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final verifiedExperts = appState.getAllExperts()
            .where((expert) => expert.verificationStatus == VerificationStatus.verified)
            .toList();
        
        final verifiedBusinesses = appState.getAllBusinesses()
            .where((business) => business.verificationStatus == VerificationStatus.verified)
            .toList();

        return Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: 'Verified Experts'),
                Tab(text: 'Verified Businesses'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Verified Experts Tab
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: verifiedExperts.length,
                    itemBuilder: (context, index) {
                      final expert = verifiedExperts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
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
                              Text('${expert.categoryName} • ${expert.email}'),
                              if (expert.country != null) Text('Country: ${expert.country}'),
                              if (expert.linkedBusinessId != null)
                                Text('Linked to Business: ${_getBusinessName(expert.linkedBusinessId!)}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: Colors.green),
                              const SizedBox(width: 8),
                              Text('${expert.rating.toStringAsFixed(1)}⭐'),
                            ],
                          ),
                          onTap: () => _showExpertProfile(expert),
                        ),
                      );
                    },
                  ),
                  // Verified Businesses Tab
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: verifiedBusinesses.length,
                    itemBuilder: (context, index) {
                      final business = verifiedBusinesses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
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
                              Text('${business.industry.name} • ${business.contactEmail}'),
                              if (business.country != null) Text('Country: ${business.country}'),
                              Text('Business Code: ${business.businessCode}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: Colors.green),
                              const SizedBox(width: 8),
                              Text('${business.totalSessions} sessions'),
                            ],
                          ),
                          onTap: () => _showBusinessProfile(business),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _getBusinessName(String businessId) {
    // Demo mode - return dummy name
    return 'Demo Business';
  }

  void _showExpertProfile(Expert expert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: expert.profileImage != null
                        ? NetworkImage(expert.profileImage!)
                        : null,
                    child: expert.profileImage == null
                        ? Text(expert.name[0].toUpperCase(), style: const TextStyle(fontSize: 20))
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expert.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          expert.categoryName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.verified, color: Colors.green, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Info
              _buildInfoRow('Email:', expert.email),
              if (expert.country != null) _buildInfoRow('Country:', expert.country!),
              _buildInfoRow('Rating:', '${expert.rating.toStringAsFixed(1)}⭐ (${expert.totalReviews} reviews)'),
              _buildInfoRow('Joined:', '${expert.joinedAt.day}/${expert.joinedAt.month}/${expert.joinedAt.year}'),
              _buildInfoRow('Price:', '\$${expert.pricePerMinute}/min • \$${expert.pricePerSession}/session'),
              
              const SizedBox(height: 16),
              
              // Bio
              const Text('Bio:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(expert.bio),
              
              if (expert.verificationAttachments.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Verification Attachments:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: expert.verificationAttachments.length,
                    itemBuilder: (context, index) {
                      final attachment = expert.verificationAttachments[index];
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              attachment['type'] == 'Image' 
                                ? Icons.image
                                : attachment['type'] == 'Link' 
                                  ? Icons.link
                                  : Icons.insert_drive_file,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              attachment['title'] ?? 'Untitled',
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (attachment['description']?.isNotEmpty == true)
                              Text(
                                attachment['description']!,
                                style: TextStyle(color: Colors.grey[600], fontSize: 10),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBusinessProfile(Business business) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: business.logoUrl != null
                        ? NetworkImage(business.logoUrl!)
                        : null,
                    child: business.logoUrl == null
                        ? Text(business.name[0].toUpperCase(), style: const TextStyle(fontSize: 20))
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          business.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          business.industry.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.verified, color: Colors.green, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Info
              _buildInfoRow('Email:', business.contactEmail),
              if (business.country != null) _buildInfoRow('Country:', business.country!),
              _buildInfoRow('Business Code:', business.businessCode),
              _buildInfoRow('Total Sessions:', business.totalSessions.toString()),
              _buildInfoRow('Created:', '${business.createdAt.day}/${business.createdAt.month}/${business.createdAt.year}'),
              
              const SizedBox(height: 16),
              
              // Description
              const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(business.description ?? 'No description provided'),
              
              if (business.verificationAttachments.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Verification Attachments:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: business.verificationAttachments.length,
                    itemBuilder: (context, index) {
                      final attachment = business.verificationAttachments[index];
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              attachment['type'] == 'Image' 
                                ? Icons.image
                                : attachment['type'] == 'Link' 
                                  ? Icons.link
                                  : Icons.insert_drive_file,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              attachment['title'] ?? 'Untitled',
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (attachment['description']?.isNotEmpty == true)
                              Text(
                                attachment['description']!,
                                style: TextStyle(color: Colors.grey[600], fontSize: 10),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}