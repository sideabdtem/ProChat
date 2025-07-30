import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/app_models.dart';

class WalletService extends ChangeNotifier {
  // Mock data for development
  final Map<String, BusinessWallet> _wallets = {};
  final Map<String, List<TeamMemberUsage>> _teamUsage = {};
  final Map<String, List<WalletTransaction>> _transactions = {};

  // Initialize wallet for a business
  void initializeWallet(String businessId, String ownerId) {
    if (!_wallets.containsKey(businessId)) {
      _wallets[businessId] = BusinessWallet(
        businessId: businessId,
        balance: 1000.0, // Start with demo balance
        ownerId: ownerId,
        lastUpdated: DateTime.now(),
        transactions: [],
      );
      
      // Initialize demo team usage
      _initializeDemoTeamUsage(businessId);
      
      notifyListeners();
    }
  }

  // Get wallet balance for a business
  double getWalletBalance(String businessId) {
    return _wallets[businessId]?.balance ?? 0.0;
  }

  // Get wallet for a business
  BusinessWallet? getWallet(String businessId) {
    return _wallets[businessId];
  }

  // Top up wallet (simulate payment)
  Future<bool> topUpWallet(String businessId, double amount, String description) async {
    try {
      final wallet = _wallets[businessId];
      if (wallet == null) return false;

      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Create transaction
      final transaction = WalletTransaction(
        id: _generateTransactionId(),
        businessId: businessId,
        type: TransactionType.topUp,
        amount: amount,
        timestamp: DateTime.now(),
        description: description,
      );

      // Update wallet
      _wallets[businessId] = wallet.copyWith(
        balance: wallet.balance + amount,
        lastUpdated: DateTime.now(),
        transactions: [...wallet.transactions, transaction],
      );

      // Add to transactions list
      _transactions[businessId] = _transactions[businessId] ?? [];
      _transactions[businessId]!.add(transaction);

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Deduct credits for session
  bool deductCredits(String businessId, String teamMemberId, String teamMemberName, 
                    double amount, String expertName, SessionType sessionType, int durationMinutes) {
    final wallet = _wallets[businessId];
    if (wallet == null || wallet.balance < amount) return false;

    // Create transaction
    final transaction = WalletTransaction(
      id: _generateTransactionId(),
      businessId: businessId,
      type: TransactionType.sessionCharge,
      amount: -amount, // Negative for deduction
      timestamp: DateTime.now(),
      description: 'Session with $expertName ($durationMinutes min)',
      teamMemberId: teamMemberId,
      teamMemberName: teamMemberName,
      sessionId: _generateSessionId(),
    );

    // Update wallet
    _wallets[businessId] = wallet.copyWith(
      balance: wallet.balance - amount,
      lastUpdated: DateTime.now(),
      transactions: [...wallet.transactions, transaction],
    );

    // Update team member usage
    _updateTeamMemberUsage(businessId, teamMemberId, teamMemberName, amount, 
                          expertName, sessionType, durationMinutes, transaction.sessionId!);

    // Add to transactions list
    _transactions[businessId] = _transactions[businessId] ?? [];
    _transactions[businessId]!.add(transaction);

    notifyListeners();
    return true;
  }

  // Get team member usage for a business
  List<TeamMemberUsage> getTeamUsage(String businessId) {
    return _teamUsage[businessId] ?? [];
  }

  // Get transactions for a business
  List<WalletTransaction> getTransactions(String businessId) {
    return _transactions[businessId] ?? [];
  }

  // Update team member usage
  void _updateTeamMemberUsage(String businessId, String memberId, String memberName, 
                             double creditsUsed, String expertName, SessionType sessionType, 
                             int durationMinutes, String sessionId) {
    _teamUsage[businessId] = _teamUsage[businessId] ?? [];
    final usage = _teamUsage[businessId]!;
    
    final existingIndex = usage.indexWhere((u) => u.memberId == memberId);
    
    final newSession = UsageSession(
      sessionId: sessionId,
      expertName: expertName,
      sessionType: sessionType,
      creditsUsed: creditsUsed,
      timestamp: DateTime.now(),
      durationMinutes: durationMinutes,
    );

    if (existingIndex >= 0) {
      // Update existing member
      final existing = usage[existingIndex];
      usage[existingIndex] = TeamMemberUsage(
        memberId: memberId,
        memberName: memberName,
        totalCreditsUsed: existing.totalCreditsUsed + creditsUsed,
        sessionCount: existing.sessionCount + 1,
        lastActivity: DateTime.now(),
        sessions: [...existing.sessions, newSession],
      );
    } else {
      // Add new member
      usage.add(TeamMemberUsage(
        memberId: memberId,
        memberName: memberName,
        totalCreditsUsed: creditsUsed,
        sessionCount: 1,
        lastActivity: DateTime.now(),
        sessions: [newSession],
      ));
    }
  }

  // Initialize demo team usage
  void _initializeDemoTeamUsage(String businessId) {
    final now = DateTime.now();
    _teamUsage[businessId] = [
      TeamMemberUsage(
        memberId: '1',
        memberName: 'John Doe',
        totalCreditsUsed: 120.0,
        sessionCount: 4,
        lastActivity: now.subtract(const Duration(hours: 2)),
        sessions: [
          UsageSession(
            sessionId: 'session_1',
            expertName: 'Dr. Smith',
            sessionType: SessionType.video,
            creditsUsed: 45.0,
            timestamp: now.subtract(const Duration(days: 1)),
            durationMinutes: 30,
          ),
          UsageSession(
            sessionId: 'session_2',
            expertName: 'John Legal Expert',
            sessionType: SessionType.chat,
            creditsUsed: 75.0,
            timestamp: now.subtract(const Duration(hours: 5)),
            durationMinutes: 60,
          ),
        ],
      ),
      TeamMemberUsage(
        memberId: '2',
        memberName: 'Jane Smith',
        totalCreditsUsed: 85.0,
        sessionCount: 3,
        lastActivity: now.subtract(const Duration(hours: 1)),
        sessions: [
          UsageSession(
            sessionId: 'session_3',
            expertName: 'Tech Consultant',
            sessionType: SessionType.voice,
            creditsUsed: 85.0,
            timestamp: now.subtract(const Duration(hours: 3)),
            durationMinutes: 45,
          ),
        ],
      ),
      TeamMemberUsage(
        memberId: '3',
        memberName: 'Mike Johnson',
        totalCreditsUsed: 200.0,
        sessionCount: 6,
        lastActivity: now.subtract(const Duration(minutes: 30)),
        sessions: [
          UsageSession(
            sessionId: 'session_4',
            expertName: 'Business Coach',
            sessionType: SessionType.video,
            creditsUsed: 100.0,
            timestamp: now.subtract(const Duration(hours: 1)),
            durationMinutes: 60,
          ),
          UsageSession(
            sessionId: 'session_5',
            expertName: 'Marketing Expert',
            sessionType: SessionType.chat,
            creditsUsed: 100.0,
            timestamp: now.subtract(const Duration(days: 2)),
            durationMinutes: 90,
          ),
        ],
      ),
    ];
  }

  // Generate unique transaction ID
  String _generateTransactionId() {
    final random = Random();
    return 'txn_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1000)}';
  }

  // Generate unique session ID
  String _generateSessionId() {
    final random = Random();
    return 'sess_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1000)}';
  }

  // Get usage summary
  Map<String, dynamic> getUsageSummary(String businessId) {
    final usage = getTeamUsage(businessId);
    final totalCreditsUsed = usage.fold<double>(0.0, (sum, u) => sum + u.totalCreditsUsed);
    final totalSessions = usage.fold<int>(0, (sum, u) => sum + u.sessionCount);
    final activeMembersCount = usage.where((u) => 
      u.lastActivity.isAfter(DateTime.now().subtract(const Duration(days: 7)))
    ).length;

    return {
      'totalCreditsUsed': totalCreditsUsed,
      'totalSessions': totalSessions,
      'activeMembersCount': activeMembersCount,
      'totalMembers': usage.length,
    };
  }

  // Sort team usage by different criteria
  List<TeamMemberUsage> getSortedTeamUsage(String businessId, {String sortBy = 'credits'}) {
    final usage = List<TeamMemberUsage>.from(getTeamUsage(businessId));
    
    switch (sortBy) {
      case 'credits':
        usage.sort((a, b) => b.totalCreditsUsed.compareTo(a.totalCreditsUsed));
        break;
      case 'sessions':
        usage.sort((a, b) => b.sessionCount.compareTo(a.sessionCount));
        break;
      case 'activity':
        usage.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
        break;
      case 'name':
        usage.sort((a, b) => a.memberName.compareTo(b.memberName));
        break;
    }
    
    return usage;
  }
}