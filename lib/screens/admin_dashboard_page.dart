import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import 'admin_pending_expert_approvals_page.dart';
import 'admin_pending_business_approvals_page.dart';
import 'admin_verified_accounts_page.dart';
import 'admin_reports_flags_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(appState.translate('admin_dashboard')),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Expert Approvals'),
            Tab(text: 'Business Approvals'),
            Tab(text: 'Verified Accounts'),
            Tab(text: 'Reports & Flags'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdminPendingExpertApprovalsPage(),
          AdminPendingBusinessApprovalsPage(),
          AdminVerifiedAccountsPage(),
          AdminReportsFlagsPage(),
        ],
      ),
    );
  }
}
