import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';
import 'dummy_data.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  static CollectionReference<Map<String, dynamic>> get expertsCollection =>
      _firestore.collection('experts');

  static CollectionReference<Map<String, dynamic>> get businessesCollection =>
      _firestore.collection('businesses');

  static CollectionReference<Map<String, dynamic>> get sessionsCollection =>
      _firestore.collection('sessions');

  static CollectionReference<Map<String, dynamic>> get appointmentsCollection =>
      _firestore.collection('appointments');

  static CollectionReference<Map<String, dynamic>> get chatMessagesCollection =>
      _firestore.collection('chat_messages');

  static CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');

  // New collections for missing features
  static CollectionReference<Map<String, dynamic>>
      get activeSessionsCollection => _firestore.collection('active_sessions');

  static CollectionReference<Map<String, dynamic>> get walletsCollection =>
      _firestore.collection('wallets');

  static CollectionReference<Map<String, dynamic>> get transactionsCollection =>
      _firestore.collection('transactions');

  static CollectionReference<Map<String, dynamic>> get teamUsageCollection =>
      _firestore.collection('team_usage');

  static CollectionReference<Map<String, dynamic>>
      get notificationsCollection => _firestore.collection('notifications');

  static CollectionReference<Map<String, dynamic>> get reviewsCollection =>
      _firestore.collection('reviews');

  static CollectionReference<Map<String, dynamic>> get settingsCollection =>
      _firestore.collection('settings');

  static CollectionReference<Map<String, dynamic>> get availabilityCollection =>
      _firestore.collection('availability');

  // Expert Networking Collections
  static CollectionReference<Map<String, dynamic>>
      get expertConnectionsCollection =>
          _firestore.collection('expert_connections');

  static CollectionReference<Map<String, dynamic>>
      get expertInteractionsCollection =>
          _firestore.collection('expert_interactions');

  static CollectionReference<Map<String, dynamic>>
      get expertRecommendationsCollection =>
          _firestore.collection('expert_recommendations');

  // Migrate all dummy data to Firestore
  static Future<void> migrateDummyDataToFirestore() async {
    try {
      print('Starting migration of dummy data to Firestore...');

      // Migrate experts
      await _migrateExperts();

      // Migrate businesses
      await _migrateBusinesses();

      // Migrate sessions
      await _migrateSessions();

      // Migrate appointments
      await _migrateAppointments();

      // Migrate chat messages
      await _migrateChatMessages();

      print('Migration completed successfully!');
    } catch (e) {
      print('Error during migration: $e');
      rethrow;
    }
  }

  // Migrate experts data
  static Future<void> _migrateExperts() async {
    final experts = DummyDataService.getExperts();

    for (final expert in experts) {
      final expertData = {
        'id': expert.id,
        'name': expert.name,
        'nameArabic': expert.nameArabic,
        'email': expert.email,
        'profileImage': expert.profileImage,
        'bio': expert.bio,
        'category': expert.category.toString(),
        'subcategories': expert.subcategories,
        'subcategoriesArabic': expert.subcategoriesArabic,
        'languages': expert.languages,
        'rating': expert.rating,
        'totalReviews': expert.totalReviews,
        'pricePerMinute': expert.pricePerMinute,
        'pricePerSession': expert.pricePerSession,
        'isAvailable': expert.isAvailable,
        'isVerified': expert.isVerified,
        'joinedAt': expert.joinedAt.toIso8601String(),
        'regions': expert.regions,
        'todaySessionCount': expert.todaySessionCount,
        'todayOnlineMinutes': expert.todayOnlineMinutes,
        'todayEarnings': expert.todayEarnings,
        'avgSessionRating': expert.avgSessionRating,
        'customTimeEnabled': expert.customTimeEnabled,
        'customPriceEnabled': expert.customPriceEnabled,
        'verificationStatus': expert.verificationStatus.toString(),
        'workExperience': expert.workExperience,
        'qualifications': expert.qualifications,
        'country': expert.country,
        'verificationAttachments': expert.verificationAttachments,
        'isBusinessExpert': expert.isBusinessExpert,
        'teamName': expert.teamName,
        'teamDescription': expert.teamDescription,
        'teamMemberIds': expert.teamMemberIds,
        'parentBusinessId': expert.parentBusinessId,
        'sessionConfigs': expert.sessionConfigs
            ?.map((config) => {
                  'id': config.id,
                  'name': config.name,
                  'durationMinutes': config.durationMinutes,
                  'price': config.price,
                })
            .toList(),
      };

      await expertsCollection.doc(expert.id).set(expertData);
      print('Migrated expert: ${expert.name}');
    }
  }

  // Migrate businesses data
  static Future<void> _migrateBusinesses() async {
    final businesses = DummyDataService.getBusinesses();

    for (final business in businesses) {
      final businessData = {
        'id': business.id,
        'name': business.name,
        'industry': business.industry.toString(),
        'contactEmail': business.contactEmail,
        'assignedExpertIds': business.assignedExpertIds,
        'monthlySpending': business.monthlySpending,
        'totalSessions': business.totalSessions,
        'createdAt': business.createdAt.toIso8601String(),
        'businessCode': business.businessCode,
        'verificationStatus': business.verificationStatus.toString(),
        'description': business.description,
        'website': business.website,
        'country': business.country,
        'verificationAttachments': business.verificationAttachments,
      };

      await businessesCollection.doc(business.id).set(businessData);
      print('Migrated business: ${business.name}');
    }
  }

  // Migrate sessions data
  static Future<void> _migrateSessions() async {
    final sessions = DummyDataService.getSessionHistory();

    for (final session in sessions) {
      final sessionData = {
        'id': session.id,
        'clientId': session.clientId,
        'expertId': session.expertId,
        'type': session.type.toString(),
        'status': session.status.toString(),
        'startTime': session.startTime.toIso8601String(),
        'endTime': session.endTime?.toIso8601String(),
        'totalCost': session.totalCost,
        'durationMinutes': session.durationMinutes,
        'rating': session.rating,
        'review': session.review,
        'isPaidPerMinute': session.isPaidPerMinute,
      };

      await sessionsCollection.doc(session.id).set(sessionData);
      print('Migrated session: ${session.id}');
    }
  }

  // Migrate appointments data
  static Future<void> _migrateAppointments() async {
    final appointments = DummyDataService.getAppointments();

    for (final appointment in appointments) {
      final appointmentData = {
        'id': appointment.id,
        'clientId': appointment.clientId,
        'expertId': appointment.expertId,
        'scheduledTime': appointment.scheduledTime.toIso8601String(),
        'durationMinutes': appointment.durationMinutes,
        'totalCost': appointment.totalCost,
        'title': appointment.title,
        'description': appointment.description,
        'status': appointment.status.toString(),
        'createdAt': appointment.createdAt.toIso8601String(),
        'paymentType': appointment.paymentType.toString(),
        'clientName': appointment.clientName,
        'expertName': appointment.expertName,
      };

      await appointmentsCollection.doc(appointment.id).set(appointmentData);
      print('Migrated appointment: ${appointment.id}');
    }
  }

  // Migrate chat messages data
  static Future<void> _migrateChatMessages() async {
    final sessions = DummyDataService.getSessionHistory();

    for (final session in sessions) {
      final messages = DummyDataService.getChatMessages(session.id);

      for (final message in messages) {
        final messageData = {
          'id': message.id,
          'sessionId': session.id,
          'senderId': message.senderId,
          'receiverId': message.receiverId,
          'content': message.content,
          'type': message.type.toString(),
          'timestamp': message.timestamp.toIso8601String(),
          'isRead': message.isRead,
        };

        await chatMessagesCollection.doc(message.id).set(messageData);
      }
      print('Migrated chat messages for session: ${session.id}');
    }
  }

  // Get experts from Firestore
  static Future<List<Expert>> getExperts() async {
    try {
      final querySnapshot = await expertsCollection.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Expert.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting experts from Firestore: $e');
      return [];
    }
  }

  // Get businesses from Firestore
  static Future<List<Business>> getBusinesses() async {
    try {
      final querySnapshot = await businessesCollection.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Business.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting businesses from Firestore: $e');
      return [];
    }
  }

  // Get sessions from Firestore
  static Future<List<ConsultationSession>> getSessions() async {
    try {
      final querySnapshot = await sessionsCollection.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ConsultationSession.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting sessions from Firestore: $e');
      return [];
    }
  }

  // Get appointments from Firestore
  static Future<List<Appointment>> getAppointments() async {
    try {
      final querySnapshot = await appointmentsCollection.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Appointment.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting appointments from Firestore: $e');
      return [];
    }
  }

  // Get chat messages from Firestore
  static Future<List<ChatMessage>> getChatMessages(String sessionId) async {
    try {
      final querySnapshot = await chatMessagesCollection
          .where('sessionId', isEqualTo: sessionId)
          .orderBy('timestamp')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting chat messages from Firestore: $e');
      return [];
    }
  }

  // Add new expert to Firestore
  static Future<void> addExpert(Expert expert) async {
    try {
      final expertData = expert.toJson();
      await expertsCollection.doc(expert.id).set(expertData);
      print('Added expert to Firestore: ${expert.name}');
    } catch (e) {
      print('Error adding expert to Firestore: $e');
      rethrow;
    }
  }

  // Update expert in Firestore
  static Future<void> updateExpert(Expert expert) async {
    try {
      final expertData = expert.toJson();
      await expertsCollection.doc(expert.id).update(expertData);
      print('Updated expert in Firestore: ${expert.name}');
    } catch (e) {
      print('Error updating expert in Firestore: $e');
      rethrow;
    }
  }

  // Add new session to Firestore
  static Future<void> addSession(ConsultationSession session) async {
    try {
      final sessionData = session.toJson();
      await sessionsCollection.doc(session.id).set(sessionData);
      print('Added session to Firestore: ${session.id}');
    } catch (e) {
      print('Error adding session to Firestore: $e');
      rethrow;
    }
  }

  // Add new appointment to Firestore
  static Future<void> addAppointment(Appointment appointment) async {
    try {
      final appointmentData = appointment.toJson();
      await appointmentsCollection.doc(appointment.id).set(appointmentData);
      print('Added appointment to Firestore: ${appointment.id}');
    } catch (e) {
      print('Error adding appointment to Firestore: $e');
      rethrow;
    }
  }

  // Add new chat message to Firestore
  static Future<void> addChatMessage(ChatMessage message) async {
    try {
      final messageData = message.toJson();
      await chatMessagesCollection.doc(message.id).set(messageData);
      print('Added chat message to Firestore: ${message.id}');
    } catch (e) {
      print('Error adding chat message to Firestore: $e');
      rethrow;
    }
  }

  // Real-time Session Management Methods
  static Future<void> createActiveSession(ConsultationSession session) async {
    try {
      final sessionData = {
        'id': session.id,
        'clientId': session.clientId,
        'expertId': session.expertId,
        'type': session.type.toString(),
        'status': session.status.toString(),
        'startTime': session.startTime.toIso8601String(),
        'endTime': session.endTime?.toIso8601String(),
        'totalCost': session.totalCost,
        'durationMinutes': session.durationMinutes,
        'isPaidPerMinute': session.isPaidPerMinute,
        'isActive': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await activeSessionsCollection.doc(session.id).set(sessionData);
      print('Created active session: ${session.id}');
    } catch (e) {
      print('Error creating active session: $e');
      rethrow;
    }
  }

  static Future<void> updateActiveSessionTimer(
      String sessionId, int timerSeconds) async {
    try {
      await activeSessionsCollection.doc(sessionId).update({
        'timerSeconds': timerSeconds,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating session timer: $e');
      rethrow;
    }
  }

  static Future<void> endActiveSession(String sessionId) async {
    try {
      await activeSessionsCollection.doc(sessionId).update({
        'isActive': false,
        'endTime': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('Ended active session: $sessionId');
    } catch (e) {
      print('Error ending active session: $e');
      rethrow;
    }
  }

  static Stream<DocumentSnapshot> listenToActiveSession(String sessionId) {
    return activeSessionsCollection.doc(sessionId).snapshots();
  }

  // Wallet & Transaction Management Methods
  static Future<void> createWallet(
      String businessId, double initialBalance) async {
    try {
      final walletData = {
        'businessId': businessId,
        'balance': initialBalance,
        'currency': 'USD',
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await walletsCollection.doc(businessId).set(walletData);
      print('Created wallet for business: $businessId');
    } catch (e) {
      print('Error creating wallet: $e');
      rethrow;
    }
  }

  static Future<BusinessWallet?> getWallet(String businessId) async {
    try {
      final doc = await walletsCollection.doc(businessId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return BusinessWallet.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting wallet: $e');
      return null;
    }
  }

  static Future<void> updateWalletBalance(
      String businessId, double newBalance) async {
    try {
      await walletsCollection.doc(businessId).update({
        'balance': newBalance,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('Updated wallet balance for business: $businessId');
    } catch (e) {
      print('Error updating wallet balance: $e');
      rethrow;
    }
  }

  static Future<void> addTransaction(WalletTransaction transaction) async {
    try {
      final transactionData = {
        'id': transaction.id,
        'businessId': transaction.businessId,
        'type': transaction.type.toString(),
        'amount': transaction.amount,
        'description': transaction.description,
        'sessionId': transaction.sessionId,
        'expertId': transaction.expertId,
        'createdAt': transaction.createdAt.toIso8601String(),
      };

      await transactionsCollection.doc(transaction.id).set(transactionData);
      print('Added transaction: ${transaction.id}');
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  static Future<List<WalletTransaction>> getWalletTransactions(
      String businessId) async {
    try {
      final querySnapshot = await transactionsCollection
          .where('businessId', isEqualTo: businessId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return WalletTransaction.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting wallet transactions: $e');
      return [];
    }
  }

  static Stream<DocumentSnapshot> listenToWallet(String businessId) {
    return walletsCollection.doc(businessId).snapshots();
  }

  // Notification Management Methods
  static Future<void> addNotification(ChatNotification notification) async {
    try {
      final notificationData = {
        'id': notification.id,
        'fromExpertId': notification.fromExpertId,
        'fromExpertName': notification.fromExpertName,
        'toClientId': notification.toClientId,
        'toClientName': notification.toClientName,
        'type': notification.type.toString(),
        'status': notification.status.toString(),
        'title': notification.title,
        'message': notification.message,
        'timestamp': notification.timestamp.toIso8601String(),
        'metadata': notification.metadata,
      };

      await notificationsCollection.doc(notification.id).set(notificationData);
      print('Added notification: ${notification.id}');
    } catch (e) {
      print('Error adding notification: $e');
      rethrow;
    }
  }

  static Future<List<ChatNotification>> getUserNotifications(
      String userId) async {
    try {
      final querySnapshot = await notificationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ChatNotification.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting user notifications: $e');
      return [];
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await notificationsCollection.doc(notificationId).update({
        'isRead': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('Marked notification as read: $notificationId');
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  static Future<void> deleteNotification(String notificationId) async {
    try {
      await notificationsCollection.doc(notificationId).delete();
      print('Deleted notification: $notificationId');
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  static Stream<QuerySnapshot> listenToUserNotifications(String userId) {
    return notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Review Management Methods
  static Future<void> addReview(Review review) async {
    try {
      final reviewData = {
        'id': review.id,
        'clientId': review.clientId,
        'clientName': review.clientName,
        'expertId': review.expertId,
        'expertName': review.expertName,
        'sessionId': review.sessionId,
        'type': review.type.toString(),
        'rating': review.rating,
        'comment': review.comment,
        'createdAt': review.createdAt.toIso8601String(),
      };

      await reviewsCollection.doc(review.id).set(reviewData);
      print('Added review: ${review.id}');
    } catch (e) {
      print('Error adding review: $e');
      rethrow;
    }
  }

  static Future<List<Review>> getExpertReviews(String expertId) async {
    try {
      final querySnapshot = await reviewsCollection
          .where('expertId', isEqualTo: expertId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Review.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting expert reviews: $e');
      return [];
    }
  }

  static Future<double> getExpertAverageRating(String expertId) async {
    try {
      final reviews = await getExpertReviews(expertId);
      if (reviews.isEmpty) return 0.0;

      final totalRating = reviews.map((r) => r.rating).reduce((a, b) => a + b);
      return totalRating / reviews.length;
    } catch (e) {
      print('Error calculating average rating: $e');
      return 0.0;
    }
  }

  // Settings Management Methods
  static Future<void> saveUserSettings(
      String userId, AppSettings settings) async {
    try {
      final settingsData = {
        'userId': userId,
        'language': settings.language,
        'isDarkMode': settings.isDarkMode,
        'region': settings.region,
        'currency': settings.currency,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await settingsCollection.doc(userId).set(settingsData);
      print('Saved settings for user: $userId');
    } catch (e) {
      print('Error saving settings: $e');
      rethrow;
    }
  }

  static Future<AppSettings?> getUserSettings(String userId) async {
    try {
      final doc = await settingsCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return AppSettings.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting user settings: $e');
      return null;
    }
  }

  // Availability Management Methods
  static Future<void> saveExpertAvailability(
      String expertId, ExpertAvailability availability) async {
    try {
      final availabilityData = {
        'expertId': expertId,
        'isSchedulingEnabled': availability.isSchedulingEnabled,
        'allowedDurations':
            availability.allowedDurations.map((d) => d.toString()).toList(),
        'maxBookingsPerDay': availability.maxBookingsPerDay,
        'intervalMinutesBetweenBookings':
            availability.intervalMinutesBetweenBookings,
        'weeklySchedule': availability.weeklySchedule
            .map((key, value) => MapEntry(key.toString(), value.toJson())),
        'blockedDates': availability.blockedDates
            .map((date) => date.toIso8601String())
            .toList(),
        'customBlockedSlots': availability.customBlockedSlots
            .map((slot) => slot.toJson())
            .toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await availabilityCollection.doc(expertId).set(availabilityData);
      print('Saved availability for expert: $expertId');
    } catch (e) {
      print('Error saving availability: $e');
      rethrow;
    }
  }

  static Future<ExpertAvailability?> getExpertAvailability(
      String expertId) async {
    try {
      final doc = await availabilityCollection.doc(expertId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return ExpertAvailability.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting expert availability: $e');
      return null;
    }
  }

  // Data validation methods
  static bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email) && email.length <= 254;
  }

  static bool _validateName(String name) {
    return name.trim().isNotEmpty && name.length <= 100;
  }

  static bool _validateBio(String bio) {
    return bio.length <= 1000;
  }

  static bool _validatePrice(double price) {
    return price >= 0 && price <= 10000;
  }

  static bool _validateRating(double rating) {
    return rating >= 0 && rating <= 5;
  }

  static bool _validateSessionDuration(int duration) {
    return duration > 0 && duration <= 480; // Max 8 hours
  }

  static bool _validateMessageContent(String content) {
    return content.trim().isNotEmpty && content.length <= 1000;
  }

  // Validated data methods
  static Future<void> addValidatedExpert(Expert expert) async {
    try {
      // Validate expert data
      if (!_validateEmail(expert.email)) {
        throw Exception('Invalid email format');
      }
      if (!_validateName(expert.name)) {
        throw Exception('Invalid name');
      }
      if (!_validateBio(expert.bio)) {
        throw Exception('Bio too long');
      }
      if (!_validatePrice(expert.pricePerMinute) ||
          !_validatePrice(expert.pricePerSession)) {
        throw Exception('Invalid pricing');
      }
      if (!_validateRating(expert.rating)) {
        throw Exception('Invalid rating');
      }

      final expertData = expert.toJson();
      await expertsCollection.doc(expert.id).set(expertData);
      print('Added validated expert: ${expert.name}');
    } catch (e) {
      print('Error adding validated expert: $e');
      rethrow;
    }
  }

  static Future<void> addValidatedChatMessage(ChatMessage message) async {
    try {
      // Validate message data
      if (!_validateMessageContent(message.content)) {
        throw Exception('Invalid message content');
      }
      if (message.senderId.isEmpty) {
        throw Exception('Invalid sender ID');
      }

      final messageData = message.toJson();
      await chatMessagesCollection.doc(message.id).set(messageData);
      print('Added validated chat message');
    } catch (e) {
      print('Error adding validated chat message: $e');
      rethrow;
    }
  }

  static Future<void> addValidatedReview(Review review) async {
    try {
      // Validate review data
      if (!_validateRating(review.rating)) {
        throw Exception('Invalid rating');
      }
      if (review.comment != null && review.comment!.length > 500) {
        throw Exception('Review comment too long');
      }
      if (!_validateName(review.clientName) ||
          !_validateName(review.expertName)) {
        throw Exception('Invalid names');
      }

      final reviewData = review.toJson();
      await reviewsCollection.doc(review.id).set(reviewData);
      print('Added validated review');
    } catch (e) {
      print('Error adding validated review: $e');
      rethrow;
    }
  }

  // Rate limiting (simple implementation)
  static final Map<String, DateTime> _lastActionTimes = {};
  static const Duration _rateLimitDuration = Duration(seconds: 1);

  static bool _checkRateLimit(String userId, String action) {
    final key = '${userId}_$action';
    final now = DateTime.now();
    final lastAction = _lastActionTimes[key];

    if (lastAction != null && now.difference(lastAction) < _rateLimitDuration) {
      return false; // Rate limited
    }

    _lastActionTimes[key] = now;
    return true; // Allowed
  }

  static Future<void> addRateLimitedChatMessage(ChatMessage message) async {
    if (!_checkRateLimit(message.senderId, 'chat_message')) {
      throw Exception(
          'Rate limit exceeded. Please wait before sending another message.');
    }
    await addValidatedChatMessage(message);
  }

  static Future<void> addRateLimitedReview(Review review) async {
    if (!_checkRateLimit(review.clientId, 'review')) {
      throw Exception(
          'Rate limit exceeded. Please wait before submitting another review.');
    }
    await addValidatedReview(review);
  }

  // Expert Networking Methods
  static Future<void> addExpertConnection(
      String expertId, String connectedExpertId) async {
    try {
      final connectionData = {
        'expertId': expertId,
        'connectedExpertId': connectedExpertId,
        'connectedAt': FieldValue.serverTimestamp(),
        'status': 'connected',
      };

      await expertConnectionsCollection
          .doc('${expertId}_$connectedExpertId')
          .set(connectionData);
      print('Added expert connection: $expertId -> $connectedExpertId');
    } catch (e) {
      print('Error adding expert connection: $e');
      rethrow;
    }
  }

  static Future<List<String>> getExpertConnections(String expertId) async {
    try {
      final snapshot = await expertConnectionsCollection
          .where('expertId', isEqualTo: expertId)
          .where('status', isEqualTo: 'connected')
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['connectedExpertId'] as String)
          .toList();
    } catch (e) {
      print('Error getting expert connections: $e');
      return [];
    }
  }

  static Future<void> addExpertInteraction(
      String expertId, String targetExpertId, String interactionType) async {
    try {
      final interactionData = {
        'expertId': expertId,
        'targetExpertId': targetExpertId,
        'interactionType': interactionType, // 'view', 'chat', 'book'
        'timestamp': FieldValue.serverTimestamp(),
      };

      await expertInteractionsCollection.add(interactionData);
      print(
          'Added expert interaction: $expertId -> $targetExpertId ($interactionType)');
    } catch (e) {
      print('Error adding expert interaction: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getExpertInteractions(
      String expertId) async {
    try {
      final snapshot = await expertInteractionsCollection
          .where('targetExpertId', isEqualTo: expertId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting expert interactions: $e');
      return [];
    }
  }

  static Future<void> addExpertRecommendation(
      String expertId, String recommendedExpertId, String reason) async {
    try {
      final recommendationData = {
        'expertId': expertId,
        'recommendedExpertId': recommendedExpertId,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await expertRecommendationsCollection.add(recommendationData);
      print('Added expert recommendation: $expertId -> $recommendedExpertId');
    } catch (e) {
      print('Error adding expert recommendation: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getExpertRecommendations(
      String expertId) async {
    try {
      final snapshot = await expertRecommendationsCollection
          .where('expertId', isEqualTo: expertId)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting expert recommendations: $e');
      return [];
    }
  }

  // Expert-to-Expert Chat Methods
  static Future<void> addExpertChatMessage(
      ChatMessage message, bool isExpertToExpert) async {
    try {
      final messageData = message.toJson();
      messageData['isExpertToExpert'] = isExpertToExpert;

      await chatMessagesCollection.doc(message.id).set(messageData);
      print('Added expert chat message');
    } catch (e) {
      print('Error adding expert chat message: $e');
      rethrow;
    }
  }

  static Stream<QuerySnapshot> listenToExpertChatMessages(String sessionId) {
    return chatMessagesCollection
        .where('sessionId', isEqualTo: sessionId)
        .where('isExpertToExpert', isEqualTo: true)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Expert Session Methods (for expert-to-expert sessions)
  static Future<void> createExpertSession(ConsultationSession session) async {
    try {
      final sessionData = session.toJson();
      sessionData['isExpertToExpert'] = true;
      sessionData['sessionType'] = 'expert_consultation';

      await sessionsCollection.doc(session.id).set(sessionData);
      print('Created expert session: ${session.id}');
    } catch (e) {
      print('Error creating expert session: $e');
      rethrow;
    }
  }

  static Future<List<ConsultationSession>> getExpertSessions(
      String expertId) async {
    try {
      final snapshot = await sessionsCollection
          .where('isExpertToExpert', isEqualTo: true)
          .where('expertId', isEqualTo: expertId)
          .orderBy('startTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ConsultationSession.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting expert sessions: $e');
      return [];
    }
  }
}
