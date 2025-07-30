import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/app_models.dart';

class B2BService extends ChangeNotifier {
  static final B2BService _instance = B2BService._internal();
  factory B2BService() => _instance;
  B2BService._internal();

  // Current business data (dummy)
  Business? _currentBusiness;
  List<Expert> _allExperts = [];
  List<BusinessSessionUsage> _sessionUsages = [];
  List<BusinessLinkRequest> _linkRequests = [];
  
  // Getters
  Business? get currentBusiness => _currentBusiness;
  List<Expert> get allExperts => _allExperts;
  List<Expert> get assignedExperts => _allExperts.where((expert) => 
    expert.businessID == _currentBusiness?.id).toList();
  List<Expert> get availableExperts => _allExperts.where((expert) => 
    expert.businessID == null).toList();
  List<BusinessSessionUsage> get sessionUsages => _sessionUsages;
  List<BusinessLinkRequest> get linkRequests => _linkRequests;

  // Generate a unique business code
  String _generateBusinessCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += chars[random.nextInt(chars.length)];
    }
    return code;
  }

  // Extract business code from invite link
  String? extractBusinessCode(String input) {
    if (input.isEmpty) return null;
    
    // Check if it's a full invite link
    if (input.contains('join?code=')) {
      final uri = Uri.tryParse(input);
      if (uri != null) {
        return uri.queryParameters['code'];
      }
    }
    
    // Otherwise, assume it's just the code
    return input.trim().toUpperCase();
  }

  // Find business by code
  Business? findBusinessByCode(String code) {
    // In a real app, this would query the database
    // For now, check if it matches our dummy business
    if (_currentBusiness?.businessCode == code) {
      return _currentBusiness;
    }
    return null;
  }

  // Initialize with dummy data
  void initializeDummyData() {
    _initializeDummyBusiness();
    _initializeDummyExperts();
    _initializeDummySessionUsages();
    _initializeDummyLinkRequests();
    notifyListeners();
  }

  void _initializeDummyBusiness() {
    _currentBusiness = Business(
      id: 'business_1',
      name: 'TechCorp Solutions',
      industry: BusinessIndustry.technology,
      contactEmail: 'admin@techcorp.com',
      logoUrl: 'https://via.placeholder.com/150x150/4A90E2/FFFFFF?text=TC',
      assignedExpertIds: ['expert_1', 'expert_3'], // Keep for backwards compatibility
      monthlySpending: 1250.0,
      totalSessions: 24,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      billingModel: BillingModel.prepaid,
      prepaidBalance: 2500.0,
      invoiceAmount: 0.0,
      favoriteExpertIds: ['expert_1'],
      businessCode: 'TECH123',
      verificationStatus: VerificationStatus.verified,
      description: 'Leading technology consulting firm specializing in digital transformation.',
      website: 'https://techcorp.com',
      country: 'United States',
    );
  }

  void _initializeDummyExperts() {
    _allExperts = [
      Expert(
        id: 'expert_1',
        name: 'Dr. Sarah Johnson',
        email: 'sarah.johnson@example.com',
        profileImage: 'https://via.placeholder.com/150x150/E74C3C/FFFFFF?text=SJ',
        bio: 'Healthcare consultant with 15+ years experience',
        category: ExpertCategory.doctor,
        languages: ['English', 'Spanish'],
        rating: 4.8,
        totalReviews: 245,
        pricePerMinute: 2.5,
        pricePerSession: 75.0,
        isAvailable: true,
        isVerified: true,
        joinedAt: DateTime.now().subtract(const Duration(days: 120)),
        regions: ['UAE', 'USA'],
        businessID: 'business_1', // Linked to current business
        businessName: 'TechCorp Solutions',
        customTimeEnabled: true,
        customPriceEnabled: false,
        sessionConfigs: [],
        todaySessionCount: 3,
        todayOnlineMinutes: 180,
        todayEarnings: 450.0,
        avgSessionRating: 4.8,
      ),
      Expert(
        id: 'expert_2',
        name: 'Michael Chen',
        email: 'michael.chen@example.com',
        profileImage: 'https://via.placeholder.com/150x150/2ECC71/FFFFFF?text=MC',
        bio: 'Business strategy consultant and entrepreneur',
        category: ExpertCategory.businessConsultant,
        languages: ['English', 'Chinese'],
        rating: 4.9,
        totalReviews: 189,
        pricePerMinute: 3.0,
        pricePerSession: 90.0,
        isAvailable: true,
        isVerified: true,
        joinedAt: DateTime.now().subtract(const Duration(days: 90)),
        regions: ['UAE', 'China'],
        businessID: null, // Not linked to any business
        businessName: null,
        customTimeEnabled: true,
        customPriceEnabled: true,
        sessionConfigs: [],
        todaySessionCount: 4,
        todayOnlineMinutes: 240,
        todayEarnings: 720.0,
        avgSessionRating: 4.9,
      ),
      Expert(
        id: 'expert_3',
        name: 'Emma Williams',
        email: 'emma.williams@example.com',
        profileImage: 'https://via.placeholder.com/150x150/9B59B6/FFFFFF?text=EW',
        bio: 'Corporate legal advisor specializing in tech law',
        category: ExpertCategory.lawyer,
        languages: ['English', 'French'],
        rating: 4.7,
        totalReviews: 156,
        pricePerMinute: 4.0,
        pricePerSession: 120.0,
        isAvailable: true,
        isVerified: true,
        joinedAt: DateTime.now().subtract(const Duration(days: 60)),
        regions: ['UAE', 'UK'],
        businessID: 'business_1', // Linked to current business
        businessName: 'TechCorp Solutions',
        customTimeEnabled: false,
        customPriceEnabled: false,
        sessionConfigs: [],
        todaySessionCount: 2,
        todayOnlineMinutes: 120,
        todayEarnings: 240.0,
        avgSessionRating: 4.7,
      ),
      Expert(
        id: 'expert_4',
        name: 'David Rodriguez',
        email: 'david.rodriguez@example.com',
        profileImage: 'https://via.placeholder.com/150x150/F39C12/FFFFFF?text=DR',
        bio: 'Senior life coach and workplace wellness expert',
        category: ExpertCategory.lifeCoach,
        languages: ['English', 'Spanish'],
        rating: 4.6,
        totalReviews: 203,
        pricePerMinute: 2.0,
        pricePerSession: 60.0,
        isAvailable: true,
        isVerified: true,
        joinedAt: DateTime.now().subtract(const Duration(days: 150)),
        regions: ['UAE', 'Spain'],
        businessID: null, // Not linked to any business
        businessName: null,
        customTimeEnabled: true,
        customPriceEnabled: true,
        sessionConfigs: [],
        todaySessionCount: 5,
        todayOnlineMinutes: 300,
        todayEarnings: 600.0,
        avgSessionRating: 4.6,
      ),
    ];
  }

  void _initializeDummySessionUsages() {
    _sessionUsages = [
      BusinessSessionUsage(
        id: 'session_1',
        businessId: 'business_1',
        expertId: 'expert_1',
        expertName: 'Dr. Sarah Johnson',
        sessionType: SessionType.video,
        date: DateTime.now().subtract(const Duration(days: 1)),
        durationMinutes: 45,
        cost: 112.50,
        clientName: 'John Smith',
      ),
      BusinessSessionUsage(
        id: 'session_2',
        businessId: 'business_1',
        expertId: 'expert_3',
        expertName: 'Emma Williams',
        sessionType: SessionType.chat,
        date: DateTime.now().subtract(const Duration(days: 2)),
        durationMinutes: 30,
        cost: 120.00,
        clientName: 'Alice Johnson',
      ),
      BusinessSessionUsage(
        id: 'session_3',
        businessId: 'business_1',
        expertId: 'expert_1',
        expertName: 'Dr. Sarah Johnson',
        sessionType: SessionType.voice,
        date: DateTime.now().subtract(const Duration(days: 3)),
        durationMinutes: 60,
        cost: 150.00,
        clientName: 'Bob Wilson',
      ),
      BusinessSessionUsage(
        id: 'session_4',
        businessId: 'business_1',
        expertId: 'expert_3',
        expertName: 'Emma Williams',
        sessionType: SessionType.video,
        date: DateTime.now().subtract(const Duration(days: 4)),
        durationMinutes: 90,
        cost: 360.00,
        clientName: 'Carol Davis',
      ),
      BusinessSessionUsage(
        id: 'session_5',
        businessId: 'business_1',
        expertId: 'expert_1',
        expertName: 'Dr. Sarah Johnson',
        sessionType: SessionType.chat,
        date: DateTime.now().subtract(const Duration(days: 5)),
        durationMinutes: 25,
        cost: 62.50,
        clientName: 'David Brown',
      ),
    ];
  }

  // Business registration
  void registerBusiness({
    required String name,
    required BusinessIndustry industry,
    required String contactEmail,
    String? logoUrl,
    BillingModel billingModel = BillingModel.prepaid,
  }) {
    _currentBusiness = Business(
      id: 'business_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      industry: industry,
      contactEmail: contactEmail,
      logoUrl: logoUrl,
      assignedExpertIds: [],
      monthlySpending: 0.0,
      totalSessions: 0,
      createdAt: DateTime.now(),
      billingModel: billingModel,
      prepaidBalance: billingModel == BillingModel.prepaid ? 500.0 : 0.0, // Demo initial balance
      invoiceAmount: 0.0,
      favoriteExpertIds: [],
      businessCode: _generateBusinessCode(), // Auto-generate business code
      verificationStatus: VerificationStatus.unverified,
      description: null,
      website: null,
      country: null,
    );
    notifyListeners();
  }

  // Expert management
  void assignExpert(String expertId) {
    if (_currentBusiness != null) {
      final updatedIds = List<String>.from(_currentBusiness!.assignedExpertIds);
      if (!updatedIds.contains(expertId)) {
        updatedIds.add(expertId);
        _currentBusiness = _currentBusiness!.copyWith(assignedExpertIds: updatedIds);
        notifyListeners();
      }
    }
  }

  void removeExpert(String expertId) {
    if (_currentBusiness != null) {
      final updatedIds = List<String>.from(_currentBusiness!.assignedExpertIds);
      updatedIds.remove(expertId);
      _currentBusiness = _currentBusiness!.copyWith(assignedExpertIds: updatedIds);
      notifyListeners();
    }
  }

  // Utility methods
  double get totalEarningsThisMonth {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return _sessionUsages
        .where((session) => session.date.isAfter(startOfMonth))
        .fold(0.0, (sum, session) => sum + session.cost);
  }

  int get totalSessionsThisMonth {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return _sessionUsages
        .where((session) => session.date.isAfter(startOfMonth))
        .length;
  }

  Map<String, double> get expertEarningsBreakdown {
    final breakdown = <String, double>{};
    for (final session in _sessionUsages) {
      breakdown[session.expertName] = (breakdown[session.expertName] ?? 0.0) + session.cost;
    }
    return breakdown;
  }

  List<BusinessSessionUsage> get recentSessions {
    final sessions = List<BusinessSessionUsage>.from(_sessionUsages);
    sessions.sort((a, b) => b.date.compareTo(a.date));
    return sessions.take(10).toList();
  }

  // Billing methods
  void processSessionPayment(double amount) {
    if (_currentBusiness == null) return;
    
    if (_currentBusiness!.billingModel == BillingModel.prepaid) {
      // Deduct from prepaid balance
      final newBalance = _currentBusiness!.prepaidBalance - amount;
      _currentBusiness = _currentBusiness!.copyWith(
        prepaidBalance: newBalance,
        monthlySpending: _currentBusiness!.monthlySpending + amount,
      );
    } else {
      // Add to invoice amount
      final newInvoiceAmount = _currentBusiness!.invoiceAmount + amount;
      _currentBusiness = _currentBusiness!.copyWith(
        invoiceAmount: newInvoiceAmount,
        monthlySpending: _currentBusiness!.monthlySpending + amount,
      );
    }
    notifyListeners();
  }

  void topUpPrepaidBalance(double amount) {
    if (_currentBusiness == null || _currentBusiness!.billingModel != BillingModel.prepaid) return;
    
    _currentBusiness = _currentBusiness!.copyWith(
      prepaidBalance: _currentBusiness!.prepaidBalance + amount,
    );
    notifyListeners();
  }

  void switchBillingModel(BillingModel newModel) {
    if (_currentBusiness == null) return;
    
    _currentBusiness = _currentBusiness!.copyWith(
      billingModel: newModel,
      prepaidBalance: newModel == BillingModel.prepaid ? 500.0 : 0.0,
      invoiceAmount: newModel == BillingModel.invoice ? 0.0 : _currentBusiness!.invoiceAmount,
    );
    notifyListeners();
  }

  void toggleExpertFavorite(String expertId) {
    if (_currentBusiness == null) return;
    
    final favoriteIds = List<String>.from(_currentBusiness!.favoriteExpertIds);
    if (favoriteIds.contains(expertId)) {
      favoriteIds.remove(expertId);
    } else {
      favoriteIds.add(expertId);
    }
    
    _currentBusiness = _currentBusiness!.copyWith(favoriteExpertIds: favoriteIds);
    notifyListeners();
  }

  Invoice generateInvoice() {
    if (_currentBusiness == null) return _getDummyInvoice();
    
    final items = _sessionUsages.map((session) => InvoiceItem(
      id: session.id,
      description: '${session.sessionType.name.toUpperCase()} session with ${session.expertName}',
      quantity: session.durationMinutes,
      unitPrice: session.cost / session.durationMinutes,
      totalPrice: session.cost,
      date: session.date,
    )).toList();
    
    return Invoice(
      id: 'invoice_${DateTime.now().millisecondsSinceEpoch}',
      businessId: _currentBusiness!.id,
      generatedDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      amount: _currentBusiness!.invoiceAmount,
      status: InvoiceStatus.draft,
      items: items,
      invoiceNumber: 'INV-${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
    );
  }

  Invoice _getDummyInvoice() {
    return Invoice(
      id: 'invoice_dummy',
      businessId: 'business_1',
      generatedDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      amount: 1250.0,
      status: InvoiceStatus.draft,
      items: [
        InvoiceItem(
          id: 'item_1',
          description: 'VIDEO session with Dr. Sarah Johnson',
          quantity: 45,
          unitPrice: 2.0,
          totalPrice: 90.0,
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
        InvoiceItem(
          id: 'item_2',
          description: 'CHAT session with Michael Chen',
          quantity: 30,
          unitPrice: 1.5,
          totalPrice: 45.0,
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      invoiceNumber: 'INV-2024-12-27',
    );
  }

  void clearInvoiceAmount() {
    if (_currentBusiness == null) return;
    
    _currentBusiness = _currentBusiness!.copyWith(invoiceAmount: 0.0);
    notifyListeners();
  }

  // Initialize dummy link requests
  void _initializeDummyLinkRequests() {
    _linkRequests = [
      BusinessLinkRequest(
        id: 'link_req_1',
        expertId: 'expert_2',
        businessId: 'business_1',
        expertEmail: 'sarah.johnson@example.com',
        businessName: 'TechCorp Solutions',
        businessEmail: 'admin@techcorp.com',
        category: ExpertCategory.therapist,
        status: BusinessLinkStatus.invited,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        message: 'We would like to invite you to join our business portal for employee wellness consultations.',
      ),
      BusinessLinkRequest(
        id: 'link_req_2',
        expertId: 'expert_4',
        businessId: 'business_1',
        expertEmail: 'ali.hassan@example.com',
        businessName: 'TechCorp Solutions',
        businessEmail: 'admin@techcorp.com',
        category: ExpertCategory.doctor,
        status: BusinessLinkStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        message: 'Expert requested to join our business portal.',
      ),
    ];
  }

  // Business linking methods
  
  // Get pending invites for an expert
  List<BusinessLinkRequest> getExpertPendingInvites(String expertId) {
    return _linkRequests.where((request) => 
      request.expertId == expertId && 
      request.status == BusinessLinkStatus.invited).toList();
  }
  
  // Get pending requests for a business
  List<BusinessLinkRequest> getBusinessPendingRequests(String businessId) {
    return _linkRequests.where((request) => 
      request.businessId == businessId && 
      request.status == BusinessLinkStatus.pending).toList();
  }
  
  // Get linked experts for a business
  List<BusinessLinkRequest> getBusinessLinkedExperts(String businessId) {
    return _linkRequests.where((request) => 
      request.businessId == businessId && 
      request.status == BusinessLinkStatus.linked).toList();
  }
  
  // Expert requests to link with business
  bool requestToLinkWithBusiness(String expertId, String businessEmail, ExpertCategory category) {
    try {
      // Find business by email (dummy lookup)
      final business = _findBusinessByEmail(businessEmail);
      if (business == null) return false;
      
      // Find expert
      final expert = _allExperts.firstWhere((e) => e.id == expertId, orElse: () => throw Exception('Expert not found'));
      
      // Create new link request
      final request = BusinessLinkRequest(
        id: 'link_req_${DateTime.now().millisecondsSinceEpoch}',
        expertId: expertId,
        businessId: business.id,
        expertEmail: expert.email,
        businessName: business.name,
        businessEmail: business.contactEmail,
        category: category,
        status: BusinessLinkStatus.pending,
        createdAt: DateTime.now(),
        message: 'Expert requested to join business portal.',
      );
      
      _linkRequests.add(request);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Business invites expert
  bool inviteExpertToBusiness(String businessId, String expertEmail, ExpertCategory category, String message) {
    try {
      // Find business
      final business = _findBusinessById(businessId);
      if (business == null) return false;
      
      // Find expert by email (dummy lookup)
      final expert = _findExpertByEmail(expertEmail);
      if (expert == null) return false;
      
      // Create new invitation
      final request = BusinessLinkRequest(
        id: 'link_req_${DateTime.now().millisecondsSinceEpoch}',
        expertId: expert.id,
        businessId: businessId,
        expertEmail: expertEmail,
        businessName: business.name,
        businessEmail: business.contactEmail,
        category: category,
        status: BusinessLinkStatus.invited,
        createdAt: DateTime.now(),
        message: message,
      );
      
      _linkRequests.add(request);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Expert accepts invitation
  bool acceptBusinessInvitation(String requestId) {
    try {
      final requestIndex = _linkRequests.indexWhere((r) => r.id == requestId);
      if (requestIndex == -1) return false;
      
      final request = _linkRequests[requestIndex];
      
      // Update request status
      _linkRequests[requestIndex] = request.copyWith(
        status: BusinessLinkStatus.linked,
        respondedAt: DateTime.now(),
      );
      
      // Assign businessID to expert
      final expertIndex = _allExperts.indexWhere((expert) => expert.id == request.expertId);
      if (expertIndex != -1) {
        _allExperts[expertIndex] = _allExperts[expertIndex].copyWith(
          businessID: request.businessId,
          businessName: request.businessName,
        );
      }
      
      // Add expert to business assigned experts (for backwards compatibility)
      if (_currentBusiness != null && _currentBusiness!.id == request.businessId) {
        final updatedIds = List<String>.from(_currentBusiness!.assignedExpertIds);
        if (!updatedIds.contains(request.expertId)) {
          updatedIds.add(request.expertId);
          _currentBusiness = _currentBusiness!.copyWith(assignedExpertIds: updatedIds);
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Reject invitation/request
  bool rejectBusinessLink(String requestId) {
    try {
      final requestIndex = _linkRequests.indexWhere((r) => r.id == requestId);
      if (requestIndex == -1) return false;
      
      final request = _linkRequests[requestIndex];
      
      // Update request status
      _linkRequests[requestIndex] = request.copyWith(
        status: BusinessLinkStatus.rejected,
        respondedAt: DateTime.now(),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Approve expert request
  bool approveExpertRequest(String requestId) {
    try {
      final requestIndex = _linkRequests.indexWhere((r) => r.id == requestId);
      if (requestIndex == -1) return false;
      
      final request = _linkRequests[requestIndex];
      
      // Update request status
      _linkRequests[requestIndex] = request.copyWith(
        status: BusinessLinkStatus.linked,
        respondedAt: DateTime.now(),
      );
      
      // Assign businessID to expert
      final expertIndex = _allExperts.indexWhere((expert) => expert.id == request.expertId);
      if (expertIndex != -1) {
        _allExperts[expertIndex] = _allExperts[expertIndex].copyWith(
          businessID: request.businessId,
          businessName: request.businessName,
        );
      }
      
      // Add expert to business assigned experts (for backwards compatibility)
      if (_currentBusiness != null && _currentBusiness!.id == request.businessId) {
        final updatedIds = List<String>.from(_currentBusiness!.assignedExpertIds);
        if (!updatedIds.contains(request.expertId)) {
          updatedIds.add(request.expertId);
          _currentBusiness = _currentBusiness!.copyWith(assignedExpertIds: updatedIds);
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Helper methods for dummy data lookup
  Business? _findBusinessByEmail(String email) {
    // Dummy implementation - in real app, this would query a database
    if (email == 'admin@techcorp.com') {
      return _currentBusiness;
    }
    return null;
  }
  
  Business? _findBusinessById(String id) {
    // Dummy implementation
    if (id == _currentBusiness?.id) {
      return _currentBusiness;
    }
    return null;
  }
  
  Expert? _findExpertByEmail(String email) {
    // Dummy implementation
    try {
      return _allExperts.firstWhere((expert) => expert.email == email);
    } catch (e) {
      return null;
    }
  }

  // Unlink expert from business
  bool unlinkExpertFromBusiness(String expertId) {
    try {
      final expertIndex = _allExperts.indexWhere((expert) => expert.id == expertId);
      if (expertIndex == -1) return false;
      
      // Remove businessID from expert
      _allExperts[expertIndex] = _allExperts[expertIndex].copyWith(
        businessID: null,
        businessName: null,
      );
      
      // Remove from business assigned experts (for backwards compatibility)
      if (_currentBusiness != null) {
        final updatedIds = List<String>.from(_currentBusiness!.assignedExpertIds);
        updatedIds.remove(expertId);
        _currentBusiness = _currentBusiness!.copyWith(assignedExpertIds: updatedIds);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  bool linkExpertToBusiness(String expertId) {
    try {
      final expertIndex = _allExperts.indexWhere((expert) => expert.id == expertId);
      if (expertIndex == -1 || _currentBusiness == null) return false;
      
      // Add businessID to expert
      _allExperts[expertIndex] = _allExperts[expertIndex].copyWith(
        businessID: _currentBusiness!.id,
        businessName: _currentBusiness!.name,
      );
      
      // Add to business assigned experts
      final updatedIds = List<String>.from(_currentBusiness!.assignedExpertIds);
      if (!updatedIds.contains(expertId)) {
        updatedIds.add(expertId);
        _currentBusiness = _currentBusiness!.copyWith(assignedExpertIds: updatedIds);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}