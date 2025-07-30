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
}
