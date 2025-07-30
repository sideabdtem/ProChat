import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';
import 'dummy_data.dart';
import 'firebase_service.dart';
import 'auth_service.dart';
import 'currency_service.dart';
import 'wallet_service.dart';
import 'translation_service.dart';

class AppState extends ChangeNotifier {
  AppUser? _currentUser;
  AppSettings _settings = AppSettings(
      language: 'en', isDarkMode: false, region: 'All', currency: 'USD');
  List<Expert> _experts = [];
  List<Business> _businesses = [];
  List<ConsultationSession> _sessionHistory = [];
  List<ChatMessage> _currentChatMessages = [];
  ConsultationSession? _activeSession;
  int _sessionTimer = 0;
  bool _isInSession = false;
  String? _activeExpertId;
  PaymentType? _currentPaymentType;
  SessionConfig? _selectedSessionConfig;
  List<Appointment> _appointments = [];
  List<ChatNotification> _notifications = [];
  List<Review> _reviews = [];

  // Call status properties
  bool _isCallActive = false;
  String? _activeCallExpertId;
  SessionType? _activeCallType;

  // Expert filter properties
  bool _showOnlineExpertsOnly = false;
  UserType _selectedUserType = UserType.client;

  // Expert networking and B2B functionality
  List<String> _expertConnections = [];
  List<Map<String, dynamic>> _expertInteractions = [];
  List<Map<String, dynamic>> _expertRecommendations = [];

  // Get expert networking data
  List<String> get expertConnections => _expertConnections;
  List<Map<String, dynamic>> get expertInteractions => _expertInteractions;
  List<Map<String, dynamic>> get expertRecommendations =>
      _expertRecommendations;
  UserType get selectedUserType => _selectedUserType;

  // Set selected user type
  void setSelectedUserType(UserType userType) {
    _selectedUserType = userType;
    notifyListeners();
  }

  // Getters
  AppUser? get currentUser => _currentUser;
  AppSettings get settings => _settings;
  List<Expert> get experts {
    var filteredExperts = _settings.region == 'All'
        ? _experts
        : _experts
            .where((expert) =>
                expert.regions.contains(_settings.region) ||
                expert.regions.contains('All'))
            .toList();
    if (_showOnlineExpertsOnly) {
      filteredExperts =
          filteredExperts.where((expert) => expert.isAvailable).toList();
    }
    return filteredExperts;
  }

  List<ConsultationSession> get sessionHistory => _sessionHistory;
  List<ChatMessage> get currentChatMessages => _currentChatMessages;
  ConsultationSession? get activeSession => _activeSession;
  int get sessionTimer => _sessionTimer;
  bool get isInSession => _isInSession;
  String? get activeExpertId => _activeExpertId;
  PaymentType? get currentPaymentType => _currentPaymentType;
  SessionConfig? get selectedSessionConfig => _selectedSessionConfig;
  List<Appointment> get appointments => _appointments;
  List<ChatNotification> get notifications => _notifications;
  List<Review> get reviews => _reviews;

  // Call status getters
  bool get isCallActive => _isCallActive;
  String? get activeCallExpertId => _activeCallExpertId;
  SessionType? get activeCallType => _activeCallType;

  // Expert filter getters
  bool get showOnlineExpertsOnly => _showOnlineExpertsOnly;

  // Get appointments for current user
  List<Appointment> get userAppointments => _appointments
      .where((appointment) => appointment.clientId == _currentUser?.id)
      .toList();

  // Get appointments for current expert
  List<Appointment> get expertAppointments => _appointments
      .where((appointment) => appointment.expertId == _currentUser?.id)
      .toList();

  // Get appointments for a specific expert
  List<Appointment> getExpertAppointments(String expertId) => _appointments
      .where((appointment) => appointment.expertId == expertId)
      .toList();

  bool get isRTL => TranslationService.isRTL(_settings.language);
  ThemeMode get themeMode =>
      _settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;

  AppState() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _loadSettings();
      await _loadDummyData();
      await _loadSavedUserSession();
    } catch (e) {
      print('Error initializing app state: $e');
      // Initialize with safe defaults if something fails
      _settings = AppSettings(
        language: 'en',
        isDarkMode: false,
        notificationsEnabled: true,
        region: 'All',
        currency: 'USD',
      );
      _experts = [];
      _businesses = [];
      _sessionHistory = [];
      _appointments = [];
      _notifications = [];
      _reviews = [];
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool('isDarkMode') ?? false;
      final language = prefs.getString('language') ?? _getDeviceLanguage();
      final region = prefs.getString('region') ?? 'All';
      final notificationsEnabled =
          prefs.getBool('notificationsEnabled') ?? true;
      final currency =
          prefs.getString('currency') ?? _getDefaultCurrencyForRegion(region);

      _settings = AppSettings(
        language: language,
        isDarkMode: isDarkMode,
        notificationsEnabled: notificationsEnabled,
        region: region,
        currency: currency,
      );
    } catch (e) {
      print('Error loading settings: $e');
      // Reset to default settings if loading fails
      _settings = AppSettings(
        language: 'en',
        isDarkMode: false,
        notificationsEnabled: true,
        region: 'All',
        currency: 'USD',
      );
      // Clear corrupted data
      await _clearCorruptedPreferences();
    }
  }

  Future<void> _clearCorruptedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Clear only settings-related keys, keep user session intact
      await prefs.remove('isDarkMode');
      await prefs.remove('language');
      await prefs.remove('region');
      await prefs.remove('notificationsEnabled');
      await prefs.remove('currency');
      print('Cleared corrupted preferences');
    } catch (e) {
      print('Error clearing preferences: $e');
    }
  }

  String _getDefaultCurrencyForRegion(String region) {
    switch (region) {
      case 'UAE':
        return 'AED';
      case 'UK':
        return 'GBP';
      default:
        return 'USD';
    }
  }

  String _getDeviceLanguage() {
    final locale = WidgetsBinding.instance.window.locale;
    final languageCode = locale.languageCode;

    // Check if the device language is supported
    if (TranslationService.getSupportedLanguages().contains(languageCode)) {
      return languageCode;
    }

    // Default to English if device language is not supported
    return 'en';
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _settings.isDarkMode);
      await prefs.setString('language', _settings.language);
      await prefs.setString('region', _settings.region);
      await prefs.setBool(
          'notificationsEnabled', _settings.notificationsEnabled);
      await prefs.setString('currency', _settings.currency);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  Future<void> _loadDummyData() async {
    try {
      // Load data from Firebase Firestore
      _experts = await FirebaseService.getExperts();
      _businesses = await FirebaseService.getBusinesses();
      _sessionHistory = await FirebaseService.getSessions();
      _appointments = await FirebaseService.getAppointments();

      // If no data in Firestore, use dummy data as fallback
      if (_experts.isEmpty) {
        print('No experts found in Firestore, using dummy data as fallback');
        _experts = DummyDataService.getExperts();
      }
      if (_businesses.isEmpty) {
        print('No businesses found in Firestore, using dummy data as fallback');
        _businesses = DummyDataService.getBusinesses();
      }
      if (_sessionHistory.isEmpty) {
        print('No sessions found in Firestore, using dummy data as fallback');
        _sessionHistory = DummyDataService.getSessionHistory();
      }
      if (_appointments.isEmpty) {
        print(
            'No appointments found in Firestore, using dummy data as fallback');
        _appointments = DummyDataService.getAppointments();
      }

      notifyListeners();
    } catch (e) {
      print('Error loading data from Firebase, using dummy data: $e');
      // Fallback to dummy data
      _experts = DummyDataService.getExperts();
      _businesses = DummyDataService.getBusinesses();
      _sessionHistory = DummyDataService.getSessionHistory();
      _appointments = DummyDataService.getAppointments();
      notifyListeners();
    }
  }

  // Load saved user session for auto-login
  Future<void> _loadSavedUserSession() async {
    try {
      final savedUser = await AuthService.getSavedUserSession();
      if (savedUser != null) {
        _currentUser = savedUser;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading saved user session: $e');
      // Clear corrupted session data
      await AuthService.clearUserSession();
    }
  }

  // Authentication methods
  Future<bool> login(String email, String password, UserType userType) async {
    try {
      final user = await AuthService.signInWithEmailAndPassword(
          email, password, userType);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login failed: $e');
      return false;
    }
  }

  Future<bool> signup(
      String name, String email, String password, UserType userType) async {
    try {
      final user = await AuthService.createUserWithEmailAndPassword(
          name, email, password, userType);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Signup failed: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await AuthService.signOut();
      _currentUser = null;
      _activeSession = null;
      _isInSession = false;
      _currentChatMessages.clear();

      // Clear call status
      _isCallActive = false;
      _activeCallExpertId = null;
      _activeCallType = null;

      notifyListeners();
    } catch (e) {
      print('Logout failed: $e');
    }
  }

  void setCurrentUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateExpertVerificationStatus(String expertId, bool isVerified) {
    final expertIndex = _experts.indexWhere((e) => e.id == expertId);
    if (expertIndex != -1) {
      _experts[expertIndex] =
          _experts[expertIndex].copyWith(isVerified: isVerified);
      notifyListeners();
    }
  }

  // Business methods
  List<Business> getAllBusinesses() => _businesses;

  void addBusiness(Business business) {
    _businesses.add(business);
    notifyListeners();
  }

  void updateBusiness(Business business) {
    final index = _businesses.indexWhere((b) => b.id == business.id);
    if (index != -1) {
      _businesses[index] = business;
      notifyListeners();
    }
  }

  // Expert methods
  List<Expert> getAllExperts() => _experts;

  void addExpert(Expert expert) {
    _experts.add(expert);
    notifyListeners();
  }

  void updateExpert(Expert expert) {
    final index = _experts.indexWhere((e) => e.id == expert.id);
    if (index != -1) {
      _experts[index] = expert;
      notifyListeners();
    }
  }

  // Settings methods
  void toggleDarkMode() {
    _settings = AppSettings(
      language: _settings.language,
      isDarkMode: !_settings.isDarkMode,
      notificationsEnabled: _settings.notificationsEnabled,
      region: _settings.region,
      currency: _settings.currency,
    );
    _saveSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void changeLanguage(String language) {
    _settings = AppSettings(
      language: language,
      isDarkMode: _settings.isDarkMode,
      notificationsEnabled: _settings.notificationsEnabled,
      region: _settings.region,
      currency: _settings.currency,
    );
    _saveSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void changeRegion(String region) {
    // Auto-update currency when region changes
    final newCurrency = _getDefaultCurrencyForRegion(region);
    _settings = AppSettings(
      language: _settings.language,
      isDarkMode: _settings.isDarkMode,
      notificationsEnabled: _settings.notificationsEnabled,
      region: region,
      currency: newCurrency,
    );
    _saveSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void setLanguage(String language) {
    _settings = AppSettings(
      language: language,
      isDarkMode: _settings.isDarkMode,
      notificationsEnabled: _settings.notificationsEnabled,
      region: _settings.region,
      currency: _settings.currency,
    );
    _saveSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void setRegion(String region) {
    changeRegion(region);
  }

  void changeCurrency(String currency) {
    _settings = AppSettings(
      language: _settings.language,
      isDarkMode: _settings.isDarkMode,
      notificationsEnabled: _settings.notificationsEnabled,
      region: _settings.region,
      currency: currency,
    );
    _saveSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void updateSettings(AppSettings newSettings) {
    _settings = newSettings;
    _saveSettings();

    // Schedule notification for next frame to avoid widget tree conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Expert filter methods
  void toggleOnlineFilter() {
    _showOnlineExpertsOnly = !_showOnlineExpertsOnly;
    notifyListeners();
  }

  void setOnlineFilter(bool showOnlineOnly) {
    _showOnlineExpertsOnly = showOnlineOnly;
    notifyListeners();
  }

  // Expert methods
  List<Expert> getExpertsByCategory(ExpertCategory category) {
    var filteredExperts = _experts
        .where((expert) =>
            expert.category == category &&
            (_settings.region == 'All' ||
                expert.regions.contains(_settings.region) ||
                expert.regions.contains('All')))
        .toList();
    if (_showOnlineExpertsOnly) {
      filteredExperts =
          filteredExperts.where((expert) => expert.isAvailable).toList();
    }
    return filteredExperts;
  }

  Expert? getExpertById(String id) {
    try {
      return _experts.firstWhere((expert) => expert.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Expert> searchExperts(String query) {
    var regionFilteredExperts = _settings.region == 'All'
        ? _experts
        : _experts
            .where((expert) =>
                expert.regions.contains(_settings.region) ||
                expert.regions.contains('All'))
            .toList();

    if (_showOnlineExpertsOnly) {
      regionFilteredExperts =
          regionFilteredExperts.where((expert) => expert.isAvailable).toList();
    }

    if (query.isEmpty) return regionFilteredExperts;

    return regionFilteredExperts.where((expert) {
      return expert.name.toLowerCase().contains(query.toLowerCase()) ||
          expert.categoryName.toLowerCase().contains(query.toLowerCase()) ||
          expert.bio.toLowerCase().contains(query.toLowerCase()) ||
          expert.subcategories.any((subcategory) =>
              subcategory.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  // Session methods
  Future<bool> startSession(
      String expertId, SessionType sessionType, bool isPaidPerMinute,
      {WalletService? walletService,
      String? businessId,
      String? teamMemberId,
      String? teamMemberName}) async {
    final expert = getExpertById(expertId);
    if (expert == null) return false;

    // Calculate estimated cost for the session
    double estimatedCost = isPaidPerMinute
        ? expert.pricePerMinute * 30
        : expert.pricePerSession; // Assume 30 min for per-minute

    // If this is a business user, check and deduct credits from wallet
    if (businessId != null &&
        teamMemberId != null &&
        teamMemberName != null &&
        walletService != null) {
      final success = walletService.deductCredits(
        businessId,
        teamMemberId,
        teamMemberName,
        estimatedCost,
        expert.name,
        sessionType,
        isPaidPerMinute ? 30 : 60, // Estimated duration
      );

      if (!success) {
        return false; // Insufficient credits
      }
    }

    _activeSession = ConsultationSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      clientId: _currentUser?.id ?? '',
      expertId: expertId,
      type: sessionType,
      status: SessionStatus.active,
      startTime: DateTime.now(),
      totalCost: estimatedCost,
      durationMinutes: 0,
      isPaidPerMinute: isPaidPerMinute,
      // Business session fields
      initiatedBy: businessId != null ? "business" : "client",
      businessId: businessId,
      teamMemberId: teamMemberId,
      paidFrom: businessId != null ? "businessWallet" : "personalPayment",
    );

    _isInSession = true;
    _activeExpertId = expertId;
    _sessionTimer = 0;

    // Load chat messages if it's a chat session
    if (sessionType == SessionType.chat) {
      _currentChatMessages =
          await FirebaseService.getChatMessages(_activeSession!.id);
    }

    notifyListeners();
    return true;
  }

  void startTeamChat(ConsultationSession session) {
    _activeSession = session;
    _isInSession = true;
    _activeExpertId = null; // No expert for team chats
    _sessionTimer = 0;

    // Load or initialize team chat messages
    _currentChatMessages = []; // Start with empty messages for team chat

    notifyListeners();
  }

  void endSession() {
    if (_activeSession == null) return;

    final duration = _sessionTimer ~/ 60; // Convert to minutes
    double cost = 0.0;

    // Handle team chats differently - they are free
    if (_activeSession!.isTeamChat) {
      cost = 0.0;
    } else {
      final expert = getExpertById(_activeSession!.expertId);
      if (expert == null) return;

      cost = _activeSession!.isPaidPerMinute
          ? expert.pricePerMinute * duration
          : expert.pricePerSession;
    }

    final completedSession = _activeSession!.copyWith(
      status: SessionStatus.ended,
      endTime: DateTime.now(),
      totalCost: cost,
      durationMinutes: duration,
    );

    _sessionHistory.insert(0, completedSession);
    _activeSession = null;
    _isInSession = false;
    _activeExpertId = null;
    _sessionTimer = 0;
    _currentChatMessages.clear();

    notifyListeners();
  }

  void updateSessionTimer(int seconds) {
    _sessionTimer = seconds;

    // Automatically end session when timer runs out for per-session payments
    if (_activeSession != null &&
        _sessionTimer <= 0 &&
        !_activeSession!.isPaidPerMinute) {
      _endSessionAutomatically();
    }

    notifyListeners();
  }

  void _endSessionAutomatically() {
    if (_activeSession == null) return;

    final duration =
        _sessionTimer > 0 ? _sessionTimer ~/ 60 : 0; // Convert to minutes
    double cost = 0.0;

    // Handle team chats differently - they are free
    if (_activeSession!.isTeamChat) {
      cost = 0.0;
    } else {
      final expert = getExpertById(_activeSession!.expertId);
      if (expert == null) return;

      cost = _activeSession!.isPaidPerMinute
          ? expert.pricePerMinute * duration
          : expert.pricePerSession;
    }

    final completedSession = _activeSession!.copyWith(
      status: SessionStatus.ended,
      endTime: DateTime.now(),
      totalCost: cost,
      durationMinutes: duration,
    );

    _sessionHistory.insert(0, completedSession);
    _activeSession = null;
    _isInSession = false;
    _activeExpertId = null;
    _sessionTimer = 0;
    // Don't clear chat messages - keep them for view-only mode

    notifyListeners();
  }

  // Chat methods
  void sendMessage(String content, MessageType type) {
    if (_activeSession == null || _currentUser == null) return;

    final message = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _currentUser!.id,
      receiverId: _activeSession!.expertId,
      content: content,
      type: type,
      timestamp: DateTime.now(),
    );

    _currentChatMessages.add(message);
    notifyListeners();

    // Simulate expert response after a delay
    Future.delayed(const Duration(seconds: 2), () {
      _simulateExpertResponse();
    });
  }

  void _simulateExpertResponse() {
    if (_activeSession == null || !_isInSession) return;

    final responses = [
      'Thank you for sharing that information.',
      'I understand your concern. Let me help you with that.',
      'That\'s a great question. Here\'s what I recommend...',
      'Based on what you\'ve told me, I suggest...',
      'I\'d like to ask you a few more questions to better understand.',
      'That sounds like a common issue. Let me explain...',
    ];

    final randomResponse =
        responses[DateTime.now().millisecond % responses.length];

    final expertMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _activeSession!.expertId,
      receiverId: _currentUser!.id,
      content: randomResponse,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );

    _currentChatMessages.add(expertMessage);
    notifyListeners();
  }

  // Localization helper
  String translate(String key) {
    return TranslationService.translate(key, _settings.language);
  }

  // Helper method to get formatted session duration
  String getFormattedDuration(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0) {
      return '$hours ${translate('hours')} $minutes ${translate('minutes')}';
    } else {
      return '$minutes ${translate('minutes')}';
    }
  }

  // Helper method to get formatted session timer
  String getFormattedTimer() {
    final minutes = _sessionTimer ~/ 60;
    final seconds = _sessionTimer % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Helper method to calculate current session cost
  double getCurrentSessionCost() {
    if (_activeSession == null || _activeExpertId == null) return 0.0;

    final expert = getExpertById(_activeExpertId!);
    if (expert == null) return 0.0;

    final minutes = _sessionTimer ~/ 60;

    return _activeSession!.isPaidPerMinute
        ? expert.pricePerMinute * minutes
        : expert.pricePerSession;
  }

  void setPaymentType(PaymentType paymentType) {
    _currentPaymentType = paymentType;
    notifyListeners();
  }

  void setSelectedSessionConfig(SessionConfig? sessionConfig) {
    _selectedSessionConfig = sessionConfig;
    notifyListeners();
  }

  // Appointment management methods
  Future<bool> bookAppointment({
    required String expertId,
    required DateTime scheduledTime,
    required int durationMinutes,
    required double totalCost,
    required String title,
    required String description,
    required PaymentType paymentType,
  }) async {
    if (_currentUser == null) return false;

    final expert = getExpertById(expertId);
    if (expert == null) return false;

    final appointment = Appointment(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
      clientId: _currentUser!.id,
      expertId: expertId,
      scheduledTime: scheduledTime,
      durationMinutes: durationMinutes,
      totalCost: totalCost,
      title: title,
      description: description,
      status: AppointmentStatus.scheduled,
      createdAt: DateTime.now(),
      paymentType: paymentType,
      clientName: _currentUser!.name,
      expertName: expert.name,
    );

    _appointments.add(appointment);
    notifyListeners();
    return true;
  }

  void cancelAppointment(String appointmentId) {
    final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
    if (index != -1) {
      _appointments[index] = Appointment(
        id: _appointments[index].id,
        clientId: _appointments[index].clientId,
        expertId: _appointments[index].expertId,
        scheduledTime: _appointments[index].scheduledTime,
        durationMinutes: _appointments[index].durationMinutes,
        totalCost: _appointments[index].totalCost,
        title: _appointments[index].title,
        description: _appointments[index].description,
        status: AppointmentStatus.cancelled,
        createdAt: _appointments[index].createdAt,
        paymentType: _appointments[index].paymentType,
        clientName: _appointments[index].clientName,
        expertName: _appointments[index].expertName,
      );
      notifyListeners();
    }
  }

  void completeAppointment(String appointmentId) {
    final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
    if (index != -1) {
      _appointments[index] = Appointment(
        id: _appointments[index].id,
        clientId: _appointments[index].clientId,
        expertId: _appointments[index].expertId,
        scheduledTime: _appointments[index].scheduledTime,
        durationMinutes: _appointments[index].durationMinutes,
        totalCost: _appointments[index].totalCost,
        title: _appointments[index].title,
        description: _appointments[index].description,
        status: AppointmentStatus.completed,
        createdAt: _appointments[index].createdAt,
        paymentType: _appointments[index].paymentType,
        clientName: _appointments[index].clientName,
        expertName: _appointments[index].expertName,
      );
      notifyListeners();
    }
  }

  List<Appointment> getAppointmentsForDate(DateTime date) {
    return _appointments
        .where((apt) =>
            apt.scheduledTime.year == date.year &&
            apt.scheduledTime.month == date.month &&
            apt.scheduledTime.day == date.day)
        .toList();
  }

  List<Appointment> getExpertAppointmentsForDate(
      String expertId, DateTime date) {
    return _appointments
        .where((apt) =>
            apt.expertId == expertId &&
            apt.scheduledTime.year == date.year &&
            apt.scheduledTime.month == date.month &&
            apt.scheduledTime.day == date.day)
        .toList();
  }

  bool isTimeSlotAvailable(
      String expertId, DateTime dateTime, int durationMinutes) {
    final endTime = dateTime.add(Duration(minutes: durationMinutes));

    final conflictingAppointments = _appointments
        .where((apt) =>
            apt.expertId == expertId &&
            apt.status == AppointmentStatus.scheduled &&
            apt.scheduledTime.isBefore(endTime) &&
            apt.scheduledTime
                .add(Duration(minutes: apt.durationMinutes))
                .isAfter(dateTime))
        .toList();

    return conflictingAppointments.isEmpty;
  }

  // Expert region management
  void updateExpertRegions(String expertId, List<String> newRegions) {
    final expertIndex = _experts.indexWhere((expert) => expert.id == expertId);
    if (expertIndex != -1) {
      final expert = _experts[expertIndex];
      _experts[expertIndex] = expert.copyWith(regions: newRegions);
      notifyListeners();
    }
  }

  void toggleExpertRegion(String expertId, String region) {
    final expertIndex = _experts.indexWhere((expert) => expert.id == expertId);
    if (expertIndex != -1) {
      final expert = _experts[expertIndex];
      final newRegions = List<String>.from(expert.regions);

      if (newRegions.contains(region)) {
        newRegions.remove(region);
      } else {
        newRegions.add(region);
      }

      updateExpertRegions(expertId, newRegions);
    }
  }

  void updateExpertSubcategories(String expertId, List<String> subcategories) {
    final expertIndex = _experts.indexWhere((expert) => expert.id == expertId);
    if (expertIndex != -1) {
      final expert = _experts[expertIndex];
      _experts[expertIndex] = expert.copyWith(subcategories: subcategories);
      notifyListeners();
    }
  }

  Expert? getCurrentExpert() {
    if (_currentUser?.userType == UserType.expert) {
      try {
        return _experts.firstWhere((expert) => expert.id == _currentUser?.id);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  List<String> getAvailableRegions() {
    return ['All', 'UAE', 'UK'];
  }

  List<String> getClientRegions() {
    return ['All', 'UAE', 'UK'];
  }

  // User profile management methods
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? profileImage,
  }) async {
    if (_currentUser == null) return;

    final updatedUser = AppUser(
      id: _currentUser!.id,
      name: name ?? _currentUser!.name,
      email: email ?? _currentUser!.email,
      profileImage: profileImage ?? _currentUser!.profileImage,
      userType: _currentUser!.userType,
      language: _currentUser!.language,
      createdAt: _currentUser!.createdAt,
    );

    _currentUser = updatedUser;

    // If user is an expert, also update the expert profile
    if (_currentUser!.userType == UserType.expert) {
      final expertIndex =
          _experts.indexWhere((expert) => expert.id == _currentUser!.id);
      if (expertIndex != -1) {
        final expert = _experts[expertIndex];
        _experts[expertIndex] = expert.copyWith(
          name: name ?? expert.name,
          email: email ?? expert.email,
          profileImage: profileImage ?? expert.profileImage,
        );
      }
    }

    await _saveUserData();
    notifyListeners();
  }

  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        await prefs.setString('current_user', _currentUser!.id);
      }
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  // Notification methods
  void sendExpertChatRequest(
      String clientId, String clientName, String expertId, String expertName) {
    final notification = ChatNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      fromExpertId: expertId,
      fromExpertName: expertName,
      toClientId: clientId,
      toClientName: clientName,
      type: NotificationType.expertRequest,
      status: NotificationStatus.sent,
      title: 'Expert wants to connect',
      message: '$expertName would like to start a chat session with you.',
      timestamp: DateTime.now(),
      metadata: {
        'expertId': expertId,
        'expertName': expertName,
      },
    );

    _notifications.add(notification);
    notifyListeners();
  }

  void acceptExpertChatRequest(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        status: NotificationStatus.accepted,
      );
      notifyListeners();
    }
  }

  void rejectExpertChatRequest(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        status: NotificationStatus.rejected,
      );
      notifyListeners();
    }
  }

  void markNotificationAsViewed(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 &&
        _notifications[index].status == NotificationStatus.sent) {
      _notifications[index] = _notifications[index].copyWith(
        status: NotificationStatus.viewed,
      );
      notifyListeners();
    }
  }

  List<ChatNotification> get pendingNotifications => _notifications
      .where((n) =>
          n.status == NotificationStatus.sent ||
          n.status == NotificationStatus.viewed)
      .toList();

  List<ChatNotification> get userNotifications =>
      _notifications.where((n) => n.toClientId == _currentUser?.id).toList();

  void clearNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  void loadViewOnlyMessages() {
    if (_currentChatMessages.isEmpty) {
      // Add some sample messages for view-only mode
      final messages = [
        ChatMessage(
          id: 'msg_1',
          senderId: 'client1',
          receiverId: _currentUser?.id ?? 'expert1',
          content: 'Hello, I need some help with my issue.',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        ChatMessage(
          id: 'msg_2',
          senderId: _currentUser?.id ?? 'expert1',
          receiverId: 'client1',
          content:
              'Of course! I\'d be happy to help you. Can you tell me more about your specific situation?',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
        ),
        ChatMessage(
          id: 'msg_3',
          senderId: 'client1',
          receiverId: _currentUser?.id ?? 'expert1',
          content:
              'I\'ve been having trouble with my business strategy and need some guidance on market analysis.',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
        ChatMessage(
          id: 'msg_4',
          senderId: _currentUser?.id ?? 'expert1',
          receiverId: 'client1',
          content:
              'That\'s exactly what I can help you with. Let me share some insights on effective market analysis techniques.',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(minutes: 22)),
        ),
      ];

      _currentChatMessages.addAll(messages);
      notifyListeners();
    }
  }

  // Currency helper methods
  String formatPrice(double amount, {String? currencyCode}) {
    final currency = currencyCode ?? _settings.currency;
    return CurrencyService.formatPrice(amount, currency);
  }

  String convertAndFormatPrice(double amount, String fromCurrency,
      {String? toCurrency}) {
    final targetCurrency = toCurrency ?? _settings.currency;
    return CurrencyService.convertAndFormatPrice(
        amount, fromCurrency, targetCurrency);
  }

  double convertCurrency(double amount, String fromCurrency,
      {String? toCurrency}) {
    final targetCurrency = toCurrency ?? _settings.currency;
    return CurrencyService.convertCurrency(
        amount, fromCurrency, targetCurrency);
  }

  String getCurrencySymbol({String? currencyCode}) {
    final currency = currencyCode ?? _settings.currency;
    return CurrencyService.getCurrencySymbol(currency);
  }

  String getCurrencyName({String? currencyCode, bool isArabic = false}) {
    final currency = currencyCode ?? _settings.currency;
    return CurrencyService.getCurrencyName(currency,
        isArabic: isArabic || _settings.language == 'ar');
  }

  List<String> getAvailableCurrencies() {
    return CurrencyService.getAvailableCurrencies();
  }

  // Review management methods
  Future<bool> addReview({
    required String expertId,
    required double rating,
    String? comment,
    String? sessionId,
    ReviewType type = ReviewType.session,
  }) async {
    if (_currentUser == null) return false;

    final expert = getExpertById(expertId);
    if (expert == null) return false;

    final review = Review(
      id: 'review_${DateTime.now().millisecondsSinceEpoch}',
      clientId: _currentUser!.id,
      clientName: _currentUser!.name,
      expertId: expertId,
      expertName: expert.name,
      sessionId: sessionId,
      type: type,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    _reviews.add(review);

    // Update expert's average rating and total reviews
    await _updateExpertRating(expertId);

    notifyListeners();
    return true;
  }

  Future<void> _updateExpertRating(String expertId) async {
    final expertReviews =
        _reviews.where((r) => r.expertId == expertId).toList();
    if (expertReviews.isEmpty) return;

    final avgRating =
        expertReviews.map((r) => r.rating).reduce((a, b) => a + b) /
            expertReviews.length;
    final totalReviews = expertReviews.length;

    final expertIndex = _experts.indexWhere((e) => e.id == expertId);
    if (expertIndex != -1) {
      _experts[expertIndex] = _experts[expertIndex].copyWith(
        rating: avgRating,
        totalReviews: totalReviews,
      );
    }
  }

  List<Review> getExpertReviews(String expertId) {
    return _reviews.where((r) => r.expertId == expertId).toList();
  }

  List<Review> getUserReviews(String userId) {
    return _reviews.where((r) => r.clientId == userId).toList();
  }

  double getExpertAverageRating(String expertId) {
    final expertReviews = getExpertReviews(expertId);
    if (expertReviews.isEmpty) return 0.0;
    return expertReviews.map((r) => r.rating).reduce((a, b) => a + b) /
        expertReviews.length;
  }

  bool hasUserReviewedSession(String sessionId) {
    if (_currentUser == null) return false;
    return _reviews
        .any((r) => r.sessionId == sessionId && r.clientId == _currentUser!.id);
  }

  // Call status management methods
  void startCall(String expertId, SessionType callType) {
    _isCallActive = true;
    _activeCallExpertId = expertId;
    _activeCallType = callType;
    notifyListeners();
  }

  void endCall() {
    _isCallActive = false;
    _activeCallExpertId = null;
    _activeCallType = null;
    notifyListeners();
  }

  // Real-time session management
  StreamSubscription<DocumentSnapshot>? _sessionSubscription;

  // Start a real-time session
  Future<bool> startRealTimeSession(ConsultationSession session) async {
    try {
      // Create active session in Firebase
      await FirebaseService.createActiveSession(session);

      // Set as active session
      _activeSession = session;
      _sessionTimer = 0;

      // Listen to real-time updates
      _sessionSubscription?.cancel();
      _sessionSubscription =
          FirebaseService.listenToActiveSession(session.id).listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          _sessionTimer = data['timerSeconds'] ?? 0;
          notifyListeners();
        }
      });

      notifyListeners();
      return true;
    } catch (e) {
      print('Error starting real-time session: $e');
      return false;
    }
  }

  // End real-time session
  Future<void> endRealTimeSession() async {
    if (_activeSession != null) {
      try {
        await FirebaseService.endActiveSession(_activeSession!.id);
        _sessionSubscription?.cancel();
        _activeSession = null;
        _sessionTimer = 0;
        notifyListeners();
      } catch (e) {
        print('Error ending real-time session: $e');
      }
    }
  }

  // Wallet management
  BusinessWallet? _currentWallet;
  List<WalletTransaction> _walletTransactions = [];
  StreamSubscription<DocumentSnapshot>? _walletSubscription;

  // Load wallet for current business
  Future<void> loadWallet(String businessId) async {
    try {
      _currentWallet = await FirebaseService.getWallet(businessId);
      _walletTransactions =
          await FirebaseService.getWalletTransactions(businessId);

      // Listen to real-time wallet updates
      _walletSubscription?.cancel();
      _walletSubscription =
          FirebaseService.listenToWallet(businessId).listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          _currentWallet = BusinessWallet.fromJson(data);
          notifyListeners();
        }
      });

      notifyListeners();
    } catch (e) {
      print('Error loading wallet: $e');
    }
  }

  // Create wallet for business
  Future<void> createWallet(String businessId, double initialBalance) async {
    try {
      await FirebaseService.createWallet(businessId, initialBalance);
      await loadWallet(businessId);
    } catch (e) {
      print('Error creating wallet: $e');
    }
  }

  // Update wallet balance
  Future<void> updateWalletBalance(double newBalance) async {
    if (_currentWallet != null) {
      try {
        await FirebaseService.updateWalletBalance(
            _currentWallet!.businessId, newBalance);
        _currentWallet = _currentWallet!.copyWith(balance: newBalance);
        notifyListeners();
      } catch (e) {
        print('Error updating wallet balance: $e');
      }
    }
  }

  // Add transaction
  Future<void> addWalletTransaction(WalletTransaction transaction) async {
    try {
      await FirebaseService.addTransaction(transaction);
      _walletTransactions.insert(0, transaction);

      // Update wallet balance
      if (_currentWallet != null) {
        double newBalance = _currentWallet!.balance;
        if (transaction.type == TransactionType.credit) {
          newBalance += transaction.amount;
        } else {
          newBalance -= transaction.amount;
        }
        await updateWalletBalance(newBalance);
      }

      notifyListeners();
    } catch (e) {
      print('Error adding wallet transaction: $e');
    }
  }

  // Get wallet data
  BusinessWallet? get currentWallet => _currentWallet;
  List<WalletTransaction> get walletTransactions => _walletTransactions;

  // Notification management with Firebase integration
  StreamSubscription<QuerySnapshot>? _notificationSubscription;

  // Load user notifications from Firebase
  Future<void> loadUserNotifications(String userId) async {
    try {
      _notifications = await FirebaseService.getUserNotifications(userId);

      // Listen to real-time notification updates
      _notificationSubscription?.cancel();
      _notificationSubscription =
          FirebaseService.listenToUserNotifications(userId).listen((snapshot) {
        _notifications = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ChatNotification.fromJson(data);
        }).toList();
        notifyListeners();
      });

      notifyListeners();
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  // Add notification with Firebase
  Future<void> addNotificationWithFirebase(
      ChatNotification notification) async {
    try {
      await FirebaseService.addNotification(notification);
      _notifications.insert(0, notification);
      notifyListeners();
    } catch (e) {
      print('Error adding notification: $e');
    }
  }

  // Mark notification as read with Firebase
  Future<void> markNotificationAsReadWithFirebase(String notificationId) async {
    try {
      await FirebaseService.markNotificationAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] =
            _notifications[index].copyWith(status: NotificationStatus.viewed);
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Delete notification with Firebase
  Future<void> deleteNotificationWithFirebase(String notificationId) async {
    try {
      await FirebaseService.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Review management with Firebase integration
  Future<void> addReviewWithFirebase(Review review) async {
    try {
      await FirebaseService.addReview(review);
      _reviews.insert(0, review);

      // Update expert's average rating
      final avgRating =
          await FirebaseService.getExpertAverageRating(review.expertId);
      final expertIndex = _experts.indexWhere((e) => e.id == review.expertId);
      if (expertIndex != -1) {
        _experts[expertIndex] = _experts[expertIndex].copyWith(
          rating: avgRating,
          totalReviews:
              _reviews.where((r) => r.expertId == review.expertId).length,
        );
      }

      notifyListeners();
    } catch (e) {
      print('Error adding review: $e');
    }
  }

  // Load expert reviews from Firebase
  Future<void> loadExpertReviews(String expertId) async {
    try {
      final reviews = await FirebaseService.getExpertReviews(expertId);
      _reviews = reviews;
      notifyListeners();
    } catch (e) {
      print('Error loading expert reviews: $e');
    }
  }

  // Settings management with Firebase integration
  Future<void> saveUserSettingsWithFirebase(
      String userId, AppSettings settings) async {
    try {
      await FirebaseService.saveUserSettings(userId, settings);
      _settings = settings;
      notifyListeners();
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Load user settings from Firebase
  Future<void> loadUserSettingsFromFirebase(String userId) async {
    try {
      final settings = await FirebaseService.getUserSettings(userId);
      if (settings != null) {
        _settings = settings;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  // Availability management with Firebase integration
  Future<void> saveExpertAvailabilityWithFirebase(
      String expertId, ExpertAvailability availability) async {
    try {
      await FirebaseService.saveExpertAvailability(expertId, availability);

      // Update expert's availability in local state
      final expertIndex = _experts.indexWhere((e) => e.id == expertId);
      if (expertIndex != -1) {
        _experts[expertIndex] = _experts[expertIndex].copyWith(
          availability: availability,
        );
      }

      notifyListeners();
    } catch (e) {
      print('Error saving availability: $e');
    }
  }

  // Load expert availability from Firebase
  Future<void> loadExpertAvailabilityFromFirebase(String expertId) async {
    try {
      final availability =
          await FirebaseService.getExpertAvailability(expertId);
      if (availability != null) {
        final expertIndex = _experts.indexWhere((e) => e.id == expertId);
        if (expertIndex != -1) {
          _experts[expertIndex] = _experts[expertIndex].copyWith(
            availability: availability,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading availability: $e');
    }
  }

  // Load expert connections
  Future<void> loadExpertConnections(String expertId) async {
    try {
      _expertConnections = await FirebaseService.getExpertConnections(expertId);
      notifyListeners();
    } catch (e) {
      print('Error loading expert connections: $e');
    }
  }

  // Load expert interactions
  Future<void> loadExpertInteractions(String expertId) async {
    try {
      _expertInteractions =
          await FirebaseService.getExpertInteractions(expertId);
      notifyListeners();
    } catch (e) {
      print('Error loading expert interactions: $e');
    }
  }

  // Load expert recommendations
  Future<void> loadExpertRecommendations(String expertId) async {
    try {
      _expertRecommendations =
          await FirebaseService.getExpertRecommendations(expertId);
      notifyListeners();
    } catch (e) {
      print('Error loading expert recommendations: $e');
    }
  }

  // Connect with another expert
  Future<void> connectWithExpert(String targetExpertId) async {
    try {
      if (_currentUser == null) return;

      await FirebaseService.addExpertConnection(
          _currentUser!.id, targetExpertId);
      await loadExpertConnections(_currentUser!.id);
    } catch (e) {
      print('Error connecting with expert: $e');
      rethrow;
    }
  }

  // Record expert interaction
  Future<void> recordExpertInteraction(
      String targetExpertId, String interactionType) async {
    try {
      if (_currentUser == null) return;

      await FirebaseService.addExpertInteraction(
          _currentUser!.id, targetExpertId, interactionType);
    } catch (e) {
      print('Error recording expert interaction: $e');
    }
  }

  // Recommend an expert
  Future<void> recommendExpert(
      String recommendedExpertId, String reason) async {
    try {
      if (_currentUser == null) return;

      await FirebaseService.addExpertRecommendation(
          _currentUser!.id, recommendedExpertId, reason);
    } catch (e) {
      print('Error recommending expert: $e');
      rethrow;
    }
  }

  // Start expert-to-expert session
  Future<bool> startExpertSession(Expert targetExpert) async {
    try {
      if (_currentUser == null) return false;

      final session = ConsultationSession(
        id: 'expert_session_${DateTime.now().millisecondsSinceEpoch}',
        clientId: _currentUser!.id,
        expertId: targetExpert.id,
        type: SessionType.chat,
        status: SessionStatus.active,
        startTime: DateTime.now(),
        totalCost: 0, // Free for expert-to-expert
        durationMinutes: 0,
        isPaidPerMinute: false,
      );

      await FirebaseService.createExpertSession(session);
      _activeSession = session;
      _isInSession = true;

      // Record interaction
      await recordExpertInteraction(targetExpert.id, 'session');

      notifyListeners();
      return true;
    } catch (e) {
      print('Error starting expert session: $e');
      return false;
    }
  }

  // Send expert-to-expert chat message
  Future<void> sendExpertChatMessage(String content, String receiverId) async {
    try {
      if (_currentUser == null || _activeSession == null) return;

      final message = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: _currentUser!.id,
        receiverId: receiverId,
        content: content,
        type: MessageType.text,
        timestamp: DateTime.now(),
      );

      await FirebaseService.addExpertChatMessage(message, true);
      _currentChatMessages.add(message);

      notifyListeners();
    } catch (e) {
      print('Error sending expert chat message: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    _walletSubscription?.cancel();
    _notificationSubscription?.cancel();
    super.dispose();
  }
}
