import 'dart:convert';
import 'package:flutter/material.dart';

enum UserType { client, expert, businessOwner, businessTeam }

enum SessionType { chat, voice, video, teamChat }

enum SessionStatus { active, ended, pending }

enum ExpertCategory {
  doctor,
  lawyer,
  lifeCoach,
  businessConsultant,
  therapist,
  technician,
  religion
}

enum PaymentType { perMinute, perSession }

enum VerificationStatus { unverified, underReview, verified, rejected }

// Booking availability enums
enum BookingDuration {
  minutes15,
  minutes30,
  minutes45,
  minutes60,
  minutes90,
  minutes120
}

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday
}

// Extension methods for booking durations
extension BookingDurationExtension on BookingDuration {
  int get minutes {
    switch (this) {
      case BookingDuration.minutes15:
        return 15;
      case BookingDuration.minutes30:
        return 30;
      case BookingDuration.minutes45:
        return 45;
      case BookingDuration.minutes60:
        return 60;
      case BookingDuration.minutes90:
        return 90;
      case BookingDuration.minutes120:
        return 120;
    }
  }

  String get displayName {
    switch (this) {
      case BookingDuration.minutes15:
        return '15 minutes';
      case BookingDuration.minutes30:
        return '30 minutes';
      case BookingDuration.minutes45:
        return '45 minutes';
      case BookingDuration.minutes60:
        return '1 hour';
      case BookingDuration.minutes90:
        return '1.5 hours';
      case BookingDuration.minutes120:
        return '2 hours';
    }
  }
}

extension DayOfWeekExtension on DayOfWeek {
  String get displayName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Monday';
      case DayOfWeek.tuesday:
        return 'Tuesday';
      case DayOfWeek.wednesday:
        return 'Wednesday';
      case DayOfWeek.thursday:
        return 'Thursday';
      case DayOfWeek.friday:
        return 'Friday';
      case DayOfWeek.saturday:
        return 'Saturday';
      case DayOfWeek.sunday:
        return 'Sunday';
    }
  }

  int get weekdayNumber {
    switch (this) {
      case DayOfWeek.monday:
        return 1;
      case DayOfWeek.tuesday:
        return 2;
      case DayOfWeek.wednesday:
        return 3;
      case DayOfWeek.thursday:
        return 4;
      case DayOfWeek.friday:
        return 5;
      case DayOfWeek.saturday:
        return 6;
      case DayOfWeek.sunday:
        return 7;
    }
  }

  static DayOfWeek fromDateTime(DateTime date) {
    switch (date.weekday) {
      case 1:
        return DayOfWeek.monday;
      case 2:
        return DayOfWeek.tuesday;
      case 3:
        return DayOfWeek.wednesday;
      case 4:
        return DayOfWeek.thursday;
      case 5:
        return DayOfWeek.friday;
      case 6:
        return DayOfWeek.saturday;
      case 7:
        return DayOfWeek.sunday;
      default:
        return DayOfWeek.monday;
    }
  }
}

class SessionConfig {
  final String id;
  final String name;
  final int durationMinutes;
  final double price;
  final bool isActive;

  const SessionConfig({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.price,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'durationMinutes': durationMinutes,
        'price': price,
        'isActive': isActive,
      };

  static SessionConfig fromJson(Map<String, dynamic> json) => SessionConfig(
        id: json['id'],
        name: json['name'],
        durationMinutes: json['durationMinutes'] as int? ?? 0,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        isActive: json['isActive'] ?? true,
      );
}

class ExpertAvailability {
  final bool isSchedulingEnabled;
  final Map<DayOfWeek, DayAvailability> weeklySchedule;
  final List<BookingDuration> allowedDurations;
  final int maxBookingsPerDay;
  final int intervalMinutesBetweenBookings;
  final List<DateTime> blockedDates; // Specific dates that are blocked
  final List<TimeSlot> customBlockedSlots; // Custom blocked time slots

  const ExpertAvailability({
    this.isSchedulingEnabled = false,
    this.weeklySchedule = const {},
    this.allowedDurations = const [
      BookingDuration.minutes30,
      BookingDuration.minutes60
    ],
    this.maxBookingsPerDay = 8,
    this.intervalMinutesBetweenBookings = 15,
    this.blockedDates = const [],
    this.customBlockedSlots = const [],
  });

  Map<String, dynamic> toJson() => {
        'isSchedulingEnabled': isSchedulingEnabled,
        'weeklySchedule': weeklySchedule
            .map((key, value) => MapEntry(key.name, value.toJson())),
        'allowedDurations': allowedDurations.map((d) => d.name).toList(),
        'maxBookingsPerDay': maxBookingsPerDay,
        'intervalMinutesBetweenBookings': intervalMinutesBetweenBookings,
        'blockedDates':
            blockedDates.map((date) => date.toIso8601String()).toList(),
        'customBlockedSlots':
            customBlockedSlots.map((slot) => slot.toJson()).toList(),
      };

  static ExpertAvailability fromJson(Map<String, dynamic> json) =>
      ExpertAvailability(
        isSchedulingEnabled: json['isSchedulingEnabled'] ?? false,
        weeklySchedule: json['weeklySchedule'] != null
            ? Map<DayOfWeek, DayAvailability>.fromEntries(
                (json['weeklySchedule'] as Map<String, dynamic>).entries.map(
                      (entry) => MapEntry(
                        DayOfWeek.values
                            .firstWhere((day) => day.name == entry.key),
                        DayAvailability.fromJson(entry.value),
                      ),
                    ),
              )
            : {},
        allowedDurations: json['allowedDurations'] != null
            ? (json['allowedDurations'] as List)
                .map((d) => BookingDuration.values
                    .firstWhere((duration) => duration.name == d))
                .toList()
            : [BookingDuration.minutes30, BookingDuration.minutes60],
        maxBookingsPerDay: json['maxBookingsPerDay'] ?? 8,
        intervalMinutesBetweenBookings:
            json['intervalMinutesBetweenBookings'] ?? 15,
        blockedDates: json['blockedDates'] != null
            ? (json['blockedDates'] as List)
                .map((date) => DateTime.parse(date))
                .toList()
            : [],
        customBlockedSlots: json['customBlockedSlots'] != null
            ? (json['customBlockedSlots'] as List)
                .map((slot) => TimeSlot.fromJson(slot))
                .toList()
            : [],
      );
}

class DayAvailability {
  final bool isAvailable;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<TimeSlot> breaks; // Break times during the day

  const DayAvailability({
    this.isAvailable = false,
    this.startTime = const TimeOfDay(hour: 9, minute: 0),
    this.endTime = const TimeOfDay(hour: 17, minute: 0),
    this.breaks = const [],
  });

  Map<String, dynamic> toJson() => {
        'isAvailable': isAvailable,
        'startTime': {'hour': startTime.hour, 'minute': startTime.minute},
        'endTime': {'hour': endTime.hour, 'minute': endTime.minute},
        'breaks': breaks.map((b) => b.toJson()).toList(),
      };

  static DayAvailability fromJson(Map<String, dynamic> json) => DayAvailability(
        isAvailable: json['isAvailable'] ?? false,
        startTime: json['startTime'] != null
            ? TimeOfDay(
                hour: json['startTime']['hour'] ?? 9,
                minute: json['startTime']['minute'] ?? 0,
              )
            : const TimeOfDay(hour: 9, minute: 0),
        endTime: json['endTime'] != null
            ? TimeOfDay(
                hour: json['endTime']['hour'] ?? 17,
                minute: json['endTime']['minute'] ?? 0,
              )
            : const TimeOfDay(hour: 17, minute: 0),
        breaks: json['breaks'] != null
            ? (json['breaks'] as List).map((b) => TimeSlot.fromJson(b)).toList()
            : [],
      );
}

class TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? reason; // Optional reason for blocked slots

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    this.reason,
  });

  Map<String, dynamic> toJson() => {
        'startTime': {'hour': startTime.hour, 'minute': startTime.minute},
        'endTime': {'hour': endTime.hour, 'minute': endTime.minute},
        'reason': reason,
      };

  static TimeSlot fromJson(Map<String, dynamic> json) => TimeSlot(
        startTime: TimeOfDay(
          hour: json['startTime']['hour'] ?? 0,
          minute: json['startTime']['minute'] ?? 0,
        ),
        endTime: TimeOfDay(
          hour: json['endTime']['hour'] ?? 0,
          minute: json['endTime']['minute'] ?? 0,
        ),
        reason: json['reason'],
      );
}

class BookingSlot {
  final DateTime startTime;
  final DateTime endTime;
  final BookingDuration duration;
  final bool isAvailable;
  final String? bookedByClientId;
  final String? bookedByClientName;

  const BookingSlot({
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.isAvailable = true,
    this.bookedByClientId,
    this.bookedByClientName,
  });

  Map<String, dynamic> toJson() => {
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'duration': duration.name,
        'isAvailable': isAvailable,
        'bookedByClientId': bookedByClientId,
        'bookedByClientName': bookedByClientName,
      };

  static BookingSlot fromJson(Map<String, dynamic> json) => BookingSlot(
        startTime: DateTime.parse(json['startTime']),
        endTime: DateTime.parse(json['endTime']),
        duration: BookingDuration.values
            .firstWhere((d) => d.name == json['duration']),
        isAvailable: json['isAvailable'] ?? true,
        bookedByClientId: json['bookedByClientId'],
        bookedByClientName: json['bookedByClientName'],
      );
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final UserType userType;
  final String language;
  final DateTime createdAt;
  final String? businessId; // For business owners and team members

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.userType,
    required this.language,
    required this.createdAt,
    this.businessId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'profileImage': profileImage,
        'userType': userType.name,
        'language': language,
        'createdAt': createdAt.toIso8601String(),
        'businessId': businessId,
      };

  static AppUser fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        profileImage: json['profileImage'],
        userType: UserType.values.firstWhere((e) => e.name == json['userType'],
            orElse: () => UserType.client),
        language: json['language'],
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        businessId: json['businessId'],
      );
}

class Expert {
  final String id;
  final String name;
  final String? nameArabic;
  final String email;
  final String? profileImage;
  final String bio;
  final String? bioArabic; // Arabic bio
  final ExpertCategory category;
  final List<String>
      subcategories; // Optional subcategories within the main category
  final List<String>? subcategoriesArabic; // Arabic subcategories
  final List<String> languages;
  final double rating;
  final int totalReviews;
  final double pricePerMinute;
  final double pricePerSession;
  final bool isAvailable;
  final bool isVerified;
  final DateTime joinedAt;
  final List<String> regions;

  // Business linking - old system (deprecated)
  final String? businessID;
  final String? businessName;

  // Team/Business expert functionality
  final bool isBusinessExpert;
  final String? teamName;
  final String? teamDescription;
  final List<String> teamMemberIds;
  final String? parentBusinessId; // For team members
  final String? linkedBusinessId; // New field for business linking via code

  // Pricing configuration
  final bool customTimeEnabled;
  final bool customPriceEnabled;
  final List<SessionConfig> sessionConfigs;

  // Dashboard metrics
  final int todaySessionCount;
  final int todayOnlineMinutes;
  final double todayEarnings;
  final double avgSessionRating;

  // Verification fields
  final VerificationStatus verificationStatus;
  final String? workExperience;
  final String? qualifications;
  final String? country;
  final List<Map<String, String>> verificationAttachments;

  // Booking availability
  final ExpertAvailability availability;

  Expert({
    required this.id,
    required this.name,
    this.nameArabic,
    required this.email,
    this.profileImage,
    required this.bio,
    this.bioArabic,
    required this.category,
    this.subcategories = const [],
    this.subcategoriesArabic,
    required this.languages,
    required this.rating,
    required this.totalReviews,
    required this.pricePerMinute,
    required this.pricePerSession,
    required this.isAvailable,
    required this.isVerified,
    required this.joinedAt,
    required this.regions,
    this.businessID,
    this.businessName,
    this.customTimeEnabled = false,
    this.customPriceEnabled = false,
    this.sessionConfigs = const [],
    this.todaySessionCount = 0,
    this.todayOnlineMinutes = 0,
    this.todayEarnings = 0.0,
    this.avgSessionRating = 0.0,
    this.isBusinessExpert = false,
    this.teamName,
    this.teamDescription,
    this.teamMemberIds = const [],
    this.parentBusinessId,
    this.linkedBusinessId,
    this.verificationStatus = VerificationStatus.unverified,
    this.workExperience,
    this.qualifications,
    this.country,
    this.verificationAttachments = const [],
    this.availability = const ExpertAvailability(),
  });

  String get categoryName {
    switch (category) {
      case ExpertCategory.doctor:
        return 'Doctor';
      case ExpertCategory.lawyer:
        return 'Lawyer';
      case ExpertCategory.lifeCoach:
        return 'Life Coach';
      case ExpertCategory.businessConsultant:
        return 'Business Consultant';
      case ExpertCategory.therapist:
        return 'Therapist';
      case ExpertCategory.technician:
        return 'Technician';
      case ExpertCategory.religion:
        return 'Religion';
    }
  }

  String get categoryNameArabic {
    switch (category) {
      case ExpertCategory.doctor:
        return 'طبيب';
      case ExpertCategory.lawyer:
        return 'محامي';
      case ExpertCategory.lifeCoach:
        return 'مدرب حياة';
      case ExpertCategory.businessConsultant:
        return 'استشاري أعمال';
      case ExpertCategory.therapist:
        return 'معالج نفسي';
      case ExpertCategory.technician:
        return 'تقني';
      case ExpertCategory.religion:
        return 'شؤون دينية';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case ExpertCategory.doctor:
        return Icons.medical_services;
      case ExpertCategory.lawyer:
        return Icons.gavel;
      case ExpertCategory.lifeCoach:
        return Icons.psychology;
      case ExpertCategory.businessConsultant:
        return Icons.business;
      case ExpertCategory.therapist:
        return Icons.favorite;
      case ExpertCategory.technician:
        return Icons.build;
      case ExpertCategory.religion:
        return Icons.mosque;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameArabic': nameArabic,
        'email': email,
        'profileImage': profileImage,
        'bio': bio,
        'category': category.name,
        'subcategories': subcategories,
        'subcategoriesArabic': subcategoriesArabic,
        'languages': languages,
        'rating': rating,
        'totalReviews': totalReviews,
        'pricePerMinute': pricePerMinute,
        'pricePerSession': pricePerSession,
        'isAvailable': isAvailable,
        'isVerified': isVerified,
        'joinedAt': joinedAt.toIso8601String(),
        'regions': regions,
        'businessID': businessID,
        'businessName': businessName,
        'customTimeEnabled': customTimeEnabled,
        'customPriceEnabled': customPriceEnabled,
        'sessionConfigs':
            sessionConfigs.map((config) => config.toJson()).toList(),
        'todaySessionCount': todaySessionCount,
        'todayOnlineMinutes': todayOnlineMinutes,
        'todayEarnings': todayEarnings,
        'avgSessionRating': avgSessionRating,
        'isBusinessExpert': isBusinessExpert,
        'teamName': teamName,
        'teamDescription': teamDescription,
        'teamMemberIds': teamMemberIds,
        'parentBusinessId': parentBusinessId,
        'linkedBusinessId': linkedBusinessId,
        'verificationStatus': verificationStatus.name,
        'workExperience': workExperience,
        'qualifications': qualifications,
        'country': country,
        'verificationAttachments': verificationAttachments,
        'availability': availability.toJson(),
      };

  static Expert fromJson(Map<String, dynamic> json) => Expert(
        id: json['id'],
        name: json['name'],
        nameArabic: json['nameArabic'],
        email: json['email'],
        profileImage: json['profileImage'],
        bio: json['bio'],
        category: ExpertCategory.values.firstWhere(
            (e) => e.name == json['category'],
            orElse: () => ExpertCategory.businessConsultant),
        subcategories: List<String>.from(json['subcategories'] ?? []),
        subcategoriesArabic: json['subcategoriesArabic'] != null
            ? List<String>.from(json['subcategoriesArabic'])
            : null,
        languages: List<String>.from(json['languages']),
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: json['totalReviews'] as int? ?? 0,
        pricePerMinute: (json['pricePerMinute'] as num?)?.toDouble() ?? 0.0,
        pricePerSession: (json['pricePerSession'] as num?)?.toDouble() ?? 0.0,
        isAvailable: json['isAvailable'],
        isVerified: json['isVerified'],
        joinedAt: DateTime.tryParse(json['joinedAt'] ?? '') ?? DateTime.now(),
        regions: List<String>.from(json['regions']),
        businessID: json['businessID'],
        businessName: json['businessName'],
        customTimeEnabled: json['customTimeEnabled'] ?? false,
        customPriceEnabled: json['customPriceEnabled'] ?? false,
        sessionConfigs: json['sessionConfigs'] != null
            ? (json['sessionConfigs'] as List)
                .map((config) => SessionConfig.fromJson(config))
                .toList()
            : [],
        todaySessionCount: json['todaySessionCount'] ?? 0,
        todayOnlineMinutes: json['todayOnlineMinutes'] ?? 0,
        todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ?? 0.0,
        avgSessionRating: (json['avgSessionRating'] as num?)?.toDouble() ?? 0.0,
        isBusinessExpert: json['isBusinessExpert'] ?? false,
        teamName: json['teamName'],
        teamDescription: json['teamDescription'],
        teamMemberIds: List<String>.from(json['teamMemberIds'] ?? []),
        parentBusinessId: json['parentBusinessId'],
        linkedBusinessId: json['linkedBusinessId'],
        verificationStatus: VerificationStatus.values.firstWhere(
            (v) => v.name == (json['verificationStatus'] ?? 'unverified')),
        workExperience: json['workExperience'],
        qualifications: json['qualifications'],
        country: json['country'],
        verificationAttachments: json['verificationAttachments'] != null
            ? List<Map<String, String>>.from(json['verificationAttachments']
                .map((x) => Map<String, String>.from(x)))
            : [],
        availability: json['availability'] != null
            ? ExpertAvailability.fromJson(json['availability'])
            : const ExpertAvailability(),
      );

  Expert copyWith({
    String? id,
    String? name,
    String? nameArabic,
    String? email,
    String? profileImage,
    String? bio,
    ExpertCategory? category,
    List<String>? subcategories,
    List<String>? subcategoriesArabic,
    List<String>? languages,
    double? rating,
    int? totalReviews,
    double? pricePerMinute,
    double? pricePerSession,
    bool? isAvailable,
    bool? isVerified,
    DateTime? joinedAt,
    List<String>? regions,
    String? businessID,
    String? businessName,
    bool? customTimeEnabled,
    bool? customPriceEnabled,
    List<SessionConfig>? sessionConfigs,
    int? todaySessionCount,
    int? todayOnlineMinutes,
    double? todayEarnings,
    double? avgSessionRating,
    bool? isBusinessExpert,
    String? teamName,
    String? teamDescription,
    List<String>? teamMemberIds,
    String? parentBusinessId,
    String? linkedBusinessId,
    VerificationStatus? verificationStatus,
    String? workExperience,
    String? qualifications,
    String? country,
    List<Map<String, String>>? verificationAttachments,
    ExpertAvailability? availability,
  }) {
    return Expert(
      id: id ?? this.id,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      category: category ?? this.category,
      subcategories: subcategories ?? this.subcategories,
      subcategoriesArabic: subcategoriesArabic ?? this.subcategoriesArabic,
      languages: languages ?? this.languages,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      pricePerMinute: pricePerMinute ?? this.pricePerMinute,
      pricePerSession: pricePerSession ?? this.pricePerSession,
      isAvailable: isAvailable ?? this.isAvailable,
      isVerified: isVerified ?? this.isVerified,
      joinedAt: joinedAt ?? this.joinedAt,
      regions: regions ?? this.regions,
      businessID: businessID ?? this.businessID,
      businessName: businessName ?? this.businessName,
      customTimeEnabled: customTimeEnabled ?? this.customTimeEnabled,
      customPriceEnabled: customPriceEnabled ?? this.customPriceEnabled,
      sessionConfigs: sessionConfigs ?? this.sessionConfigs,
      todaySessionCount: todaySessionCount ?? this.todaySessionCount,
      todayOnlineMinutes: todayOnlineMinutes ?? this.todayOnlineMinutes,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      avgSessionRating: avgSessionRating ?? this.avgSessionRating,
      isBusinessExpert: isBusinessExpert ?? this.isBusinessExpert,
      teamName: teamName ?? this.teamName,
      teamDescription: teamDescription ?? this.teamDescription,
      teamMemberIds: teamMemberIds ?? this.teamMemberIds,
      parentBusinessId: parentBusinessId ?? this.parentBusinessId,
      linkedBusinessId: linkedBusinessId ?? this.linkedBusinessId,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      workExperience: workExperience ?? this.workExperience,
      qualifications: qualifications ?? this.qualifications,
      country: country ?? this.country,
      verificationAttachments:
          verificationAttachments ?? this.verificationAttachments,
      availability: availability ?? this.availability,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  static ChatMessage fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'],
        senderId: json['senderId'],
        receiverId: json['receiverId'],
        content: json['content'],
        type: MessageType.values.firstWhere((t) => t.name == json['type'],
            orElse: () => MessageType.text),
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        isRead: json['isRead'] ?? false,
      );
}

enum MessageType { text, image, audio, document }

class ConsultationSession {
  final String id;
  final String clientId;
  final String expertId;
  final SessionType type;
  final SessionStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalCost;
  final int durationMinutes;
  final double? rating;
  final String? review;
  final bool isPaidPerMinute;
  final bool isTeamChat;
  final String? teamMemberName;
  // Business session fields
  final String? initiatedBy; // "client" or "business"
  final String? businessId;
  final String? teamMemberId;
  final String? paidFrom; // "personalPayment" or "businessWallet"

  ConsultationSession({
    required this.id,
    required this.clientId,
    required this.expertId,
    required this.type,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.totalCost,
    required this.durationMinutes,
    this.rating,
    this.review,
    required this.isPaidPerMinute,
    this.isTeamChat = false,
    this.teamMemberName,
    this.initiatedBy,
    this.businessId,
    this.teamMemberId,
    this.paidFrom,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'expertId': expertId,
        'type': type.name,
        'status': status.name,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'totalCost': totalCost,
        'durationMinutes': durationMinutes,
        'rating': rating,
        'review': review,
        'isPaidPerMinute': isPaidPerMinute,
        'isTeamChat': isTeamChat,
        'teamMemberName': teamMemberName,
        'initiatedBy': initiatedBy,
        'businessId': businessId,
        'teamMemberId': teamMemberId,
        'paidFrom': paidFrom,
      };

  static ConsultationSession fromJson(Map<String, dynamic> json) =>
      ConsultationSession(
        id: json['id'],
        clientId: json['clientId'],
        expertId: json['expertId'],
        type: SessionType.values.firstWhere((t) => t.name == json['type'],
            orElse: () => SessionType.chat),
        status: SessionStatus.values.firstWhere((s) => s.name == json['status'],
            orElse: () => SessionStatus.pending),
        startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
        endTime:
            json['endTime'] != null ? DateTime.tryParse(json['endTime']) : null,
        totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
        durationMinutes: json['durationMinutes'],
        rating: (json['rating'] as num?)?.toDouble(),
        review: json['review'],
        isPaidPerMinute: json['isPaidPerMinute'],
        isTeamChat: json['isTeamChat'] ?? false,
        teamMemberName: json['teamMemberName'],
        initiatedBy: json['initiatedBy'],
        businessId: json['businessId'],
        teamMemberId: json['teamMemberId'],
        paidFrom: json['paidFrom'],
      );

  ConsultationSession copyWith({
    String? id,
    String? clientId,
    String? expertId,
    SessionType? type,
    SessionStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    double? totalCost,
    int? durationMinutes,
    double? rating,
    String? review,
    bool? isPaidPerMinute,
    bool? isTeamChat,
    String? teamMemberName,
    String? initiatedBy,
    String? businessId,
    String? teamMemberId,
    String? paidFrom,
  }) {
    return ConsultationSession(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      expertId: expertId ?? this.expertId,
      type: type ?? this.type,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalCost: totalCost ?? this.totalCost,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      isPaidPerMinute: isPaidPerMinute ?? this.isPaidPerMinute,
      isTeamChat: isTeamChat ?? this.isTeamChat,
      teamMemberName: teamMemberName ?? this.teamMemberName,
      initiatedBy: initiatedBy ?? this.initiatedBy,
      businessId: businessId ?? this.businessId,
      teamMemberId: teamMemberId ?? this.teamMemberId,
      paidFrom: paidFrom ?? this.paidFrom,
    );
  }

  String get sessionTypeLabel {
    switch (type) {
      case SessionType.chat:
        return 'Chat';
      case SessionType.voice:
        return 'Voice Call';
      case SessionType.video:
        return 'Video Call';
      case SessionType.teamChat:
        return 'Team Chat';
    }
  }

  IconData get sessionIcon {
    switch (type) {
      case SessionType.chat:
        return Icons.chat;
      case SessionType.voice:
        return Icons.call;
      case SessionType.video:
        return Icons.videocam;
      case SessionType.teamChat:
        return Icons.group;
    }
  }
}

class AppSettings {
  final String language;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final String region;
  final String currency;

  AppSettings({
    required this.language,
    required this.isDarkMode,
    this.notificationsEnabled = true,
    required this.region,
    required this.currency,
  });

  Map<String, dynamic> toJson() => {
        'language': language,
        'isDarkMode': isDarkMode,
        'notificationsEnabled': notificationsEnabled,
        'region': region,
        'currency': currency,
      };

  static AppSettings fromJson(Map<String, dynamic> json) => AppSettings(
        language: json['language'] ?? 'en',
        isDarkMode: json['isDarkMode'] ?? false,
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        region: json['region'] ?? 'All',
        currency: json['currency'] ??
            _getDefaultCurrencyForRegion(json['region'] ?? 'All'),
      );

  static String _getDefaultCurrencyForRegion(String region) {
    switch (region) {
      case 'UAE':
        return 'AED';
      case 'UK':
        return 'GBP';
      default:
        return 'USD';
    }
  }

  AppSettings copyWith({
    String? language,
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? region,
    String? currency,
  }) {
    return AppSettings(
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      region: region ?? this.region,
      currency: currency ?? this.currency,
    );
  }
}

enum AppointmentStatus { scheduled, completed, cancelled }

class Appointment {
  final String id;
  final String clientId;
  final String expertId;
  final DateTime scheduledTime;
  final int durationMinutes;
  final double totalCost;
  final String title;
  final String description;
  final AppointmentStatus status;
  final DateTime createdAt;
  final PaymentType paymentType;
  final String clientName;
  final String expertName;

  Appointment({
    required this.id,
    required this.clientId,
    required this.expertId,
    required this.scheduledTime,
    required this.durationMinutes,
    required this.totalCost,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.paymentType,
    required this.clientName,
    required this.expertName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'expertId': expertId,
        'scheduledTime': scheduledTime.toIso8601String(),
        'durationMinutes': durationMinutes,
        'totalCost': totalCost,
        'title': title,
        'description': description,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'paymentType': paymentType.name,
        'clientName': clientName,
        'expertName': expertName,
      };

  static Appointment fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'],
        clientId: json['clientId'],
        expertId: json['expertId'],
        scheduledTime:
            DateTime.tryParse(json['scheduledTime'] ?? '') ?? DateTime.now(),
        durationMinutes: json['durationMinutes'],
        totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
        title: json['title'],
        description: json['description'],
        status: AppointmentStatus.values
            .firstWhere((s) => s.name == json['status']),
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        paymentType:
            PaymentType.values.firstWhere((p) => p.name == json['paymentType']),
        clientName: json['clientName'],
        expertName: json['expertName'],
      );
}

// B2B Models
enum BusinessIndustry {
  healthcare,
  legal,
  technology,
  consulting,
  education,
  finance,
  retail,
  manufacturing,
  hospitality,
  other
}

enum BillingModel { prepaid, invoice }

enum BusinessLinkStatus { invited, pending, linked, rejected }

class BusinessLinkRequest {
  final String id;
  final String expertId;
  final String businessId;
  final String expertEmail;
  final String businessName;
  final String businessEmail;
  final ExpertCategory category;
  final BusinessLinkStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? message;

  BusinessLinkRequest({
    required this.id,
    required this.expertId,
    required this.businessId,
    required this.expertEmail,
    required this.businessName,
    required this.businessEmail,
    required this.category,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.message,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'expertId': expertId,
        'businessId': businessId,
        'expertEmail': expertEmail,
        'businessName': businessName,
        'businessEmail': businessEmail,
        'category': category.name,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'respondedAt': respondedAt?.toIso8601String(),
        'message': message,
      };

  static BusinessLinkRequest fromJson(Map<String, dynamic> json) =>
      BusinessLinkRequest(
        id: json['id'],
        expertId: json['expertId'],
        businessId: json['businessId'],
        expertEmail: json['expertEmail'],
        businessName: json['businessName'],
        businessEmail: json['businessEmail'],
        category:
            ExpertCategory.values.firstWhere((c) => c.name == json['category']),
        status: BusinessLinkStatus.values
            .firstWhere((s) => s.name == json['status']),
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        respondedAt: json['respondedAt'] != null
            ? DateTime.tryParse(json['respondedAt'])
            : null,
        message: json['message'],
      );

  BusinessLinkRequest copyWith({
    String? id,
    String? expertId,
    String? businessId,
    String? expertEmail,
    String? businessName,
    String? businessEmail,
    ExpertCategory? category,
    BusinessLinkStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? message,
  }) {
    return BusinessLinkRequest(
      id: id ?? this.id,
      expertId: expertId ?? this.expertId,
      businessId: businessId ?? this.businessId,
      expertEmail: expertEmail ?? this.expertEmail,
      businessName: businessName ?? this.businessName,
      businessEmail: businessEmail ?? this.businessEmail,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      message: message ?? this.message,
    );
  }
}

class Business {
  final String id;
  final String name;
  final BusinessIndustry industry;
  final String contactEmail;
  final String? logoUrl;
  final List<String> assignedExpertIds;
  final double monthlySpending;
  final int totalSessions;
  final DateTime createdAt;
  final bool isActive;
  final BillingModel billingModel;
  final double prepaidBalance;
  final double invoiceAmount;
  final List<String> favoriteExpertIds;
  final String businessCode;
  final VerificationStatus verificationStatus;
  final String? description;
  final String? legalDocument;
  final String? website;
  final String? country;
  final List<Map<String, String>> verificationAttachments;

  Business({
    required this.id,
    required this.name,
    required this.industry,
    required this.contactEmail,
    this.logoUrl,
    required this.assignedExpertIds,
    required this.monthlySpending,
    required this.totalSessions,
    required this.createdAt,
    this.isActive = true,
    this.billingModel = BillingModel.prepaid,
    this.prepaidBalance = 0.0,
    this.invoiceAmount = 0.0,
    this.favoriteExpertIds = const [],
    required this.businessCode,
    this.verificationStatus = VerificationStatus.unverified,
    this.description,
    this.legalDocument,
    this.website,
    this.country,
    this.verificationAttachments = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'industry': industry.name,
        'contactEmail': contactEmail,
        'logoUrl': logoUrl,
        'assignedExpertIds': assignedExpertIds,
        'monthlySpending': monthlySpending,
        'totalSessions': totalSessions,
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive,
        'billingModel': billingModel.name,
        'prepaidBalance': prepaidBalance,
        'invoiceAmount': invoiceAmount,
        'favoriteExpertIds': favoriteExpertIds,
        'businessCode': businessCode,
        'verificationStatus': verificationStatus.name,
        'description': description,
        'legalDocument': legalDocument,
        'website': website,
        'country': country,
        'verificationAttachments': verificationAttachments,
      };

  static Business fromJson(Map<String, dynamic> json) => Business(
        id: json['id'],
        name: json['name'],
        industry: BusinessIndustry.values
            .firstWhere((i) => i.name == json['industry']),
        contactEmail: json['contactEmail'],
        logoUrl: json['logoUrl'],
        assignedExpertIds: List<String>.from(json['assignedExpertIds']),
        monthlySpending: (json['monthlySpending'] as num?)?.toDouble() ?? 0.0,
        totalSessions: json['totalSessions'],
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        isActive: json['isActive'] ?? true,
        billingModel: BillingModel.values
            .firstWhere((b) => b.name == (json['billingModel'] ?? 'prepaid')),
        prepaidBalance: (json['prepaidBalance'] as num?)?.toDouble() ?? 0.0,
        invoiceAmount: (json['invoiceAmount'] as num?)?.toDouble() ?? 0.0,
        favoriteExpertIds: List<String>.from(json['favoriteExpertIds'] ?? []),
        businessCode: json['businessCode'] ?? '',
        verificationStatus: VerificationStatus.values.firstWhere(
            (v) => v.name == (json['verificationStatus'] ?? 'unverified')),
        description: json['description'],
        legalDocument: json['legalDocument'],
        website: json['website'],
        country: json['country'],
        verificationAttachments: json['verificationAttachments'] != null
            ? List<Map<String, String>>.from(json['verificationAttachments']
                .map((x) => Map<String, String>.from(x)))
            : [],
      );

  Business copyWith({
    String? id,
    String? name,
    BusinessIndustry? industry,
    String? contactEmail,
    String? logoUrl,
    List<String>? assignedExpertIds,
    double? monthlySpending,
    int? totalSessions,
    DateTime? createdAt,
    bool? isActive,
    BillingModel? billingModel,
    double? prepaidBalance,
    double? invoiceAmount,
    List<String>? favoriteExpertIds,
    String? businessCode,
    VerificationStatus? verificationStatus,
    String? description,
    String? legalDocument,
    String? website,
    String? country,
    List<Map<String, String>>? verificationAttachments,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      contactEmail: contactEmail ?? this.contactEmail,
      logoUrl: logoUrl ?? this.logoUrl,
      assignedExpertIds: assignedExpertIds ?? this.assignedExpertIds,
      monthlySpending: monthlySpending ?? this.monthlySpending,
      totalSessions: totalSessions ?? this.totalSessions,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      billingModel: billingModel ?? this.billingModel,
      prepaidBalance: prepaidBalance ?? this.prepaidBalance,
      invoiceAmount: invoiceAmount ?? this.invoiceAmount,
      favoriteExpertIds: favoriteExpertIds ?? this.favoriteExpertIds,
      businessCode: businessCode ?? this.businessCode,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      description: description ?? this.description,
      legalDocument: legalDocument ?? this.legalDocument,
      website: website ?? this.website,
      country: country ?? this.country,
      verificationAttachments:
          verificationAttachments ?? this.verificationAttachments,
    );
  }
}

// Wallet and Credit System Models
class BusinessWallet {
  final String businessId;
  final double balance;
  final String ownerId;
  final DateTime lastUpdated;
  final List<WalletTransaction> transactions;

  BusinessWallet({
    required this.businessId,
    required this.balance,
    required this.ownerId,
    required this.lastUpdated,
    this.transactions = const [],
  });

  Map<String, dynamic> toJson() => {
        'businessId': businessId,
        'balance': balance,
        'ownerId': ownerId,
        'lastUpdated': lastUpdated.toIso8601String(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

  static BusinessWallet fromJson(Map<String, dynamic> json) => BusinessWallet(
        businessId: json['businessId'],
        balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
        ownerId: json['ownerId'],
        lastUpdated:
            DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
        transactions: json['transactions'] != null
            ? (json['transactions'] as List)
                .map((t) => WalletTransaction.fromJson(t))
                .toList()
            : [],
      );

  BusinessWallet copyWith({
    String? businessId,
    double? balance,
    String? ownerId,
    DateTime? lastUpdated,
    List<WalletTransaction>? transactions,
  }) {
    return BusinessWallet(
      businessId: businessId ?? this.businessId,
      balance: balance ?? this.balance,
      ownerId: ownerId ?? this.ownerId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      transactions: transactions ?? this.transactions,
    );
  }
}

enum TransactionType { topUp, sessionCharge, refund, credit }

class WalletTransaction {
  final String id;
  final String businessId;
  final TransactionType type;
  final double amount;
  final DateTime timestamp;
  final String description;
  final String? teamMemberId;
  final String? teamMemberName;
  final String? sessionId;
  final String? expertId;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.businessId,
    required this.type,
    required this.amount,
    required this.timestamp,
    required this.description,
    this.teamMemberId,
    this.teamMemberName,
    this.sessionId,
    this.expertId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? timestamp;

  Map<String, dynamic> toJson() => {
        'id': id,
        'businessId': businessId,
        'type': type.name,
        'amount': amount,
        'timestamp': timestamp.toIso8601String(),
        'description': description,
        'teamMemberId': teamMemberId,
        'teamMemberName': teamMemberName,
        'sessionId': sessionId,
        'expertId': expertId,
        'createdAt': createdAt.toIso8601String(),
      };

  static WalletTransaction fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: json['id'],
        businessId: json['businessId'],
        type: TransactionType.values.firstWhere((t) => t.name == json['type']),
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        description: json['description'],
        teamMemberId: json['teamMemberId'],
        teamMemberName: json['teamMemberName'],
        sessionId: json['sessionId'],
        expertId: json['expertId'],
        createdAt:
            DateTime.tryParse(json['createdAt'] ?? json['timestamp'] ?? '') ??
                DateTime.now(),
      );
}

class TeamMemberUsage {
  final String memberId;
  final String memberName;
  final double totalCreditsUsed;
  final int sessionCount;
  final DateTime lastActivity;
  final List<UsageSession> sessions;

  TeamMemberUsage({
    required this.memberId,
    required this.memberName,
    required this.totalCreditsUsed,
    required this.sessionCount,
    required this.lastActivity,
    this.sessions = const [],
  });

  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'memberName': memberName,
        'totalCreditsUsed': totalCreditsUsed,
        'sessionCount': sessionCount,
        'lastActivity': lastActivity.toIso8601String(),
        'sessions': sessions.map((s) => s.toJson()).toList(),
      };

  static TeamMemberUsage fromJson(Map<String, dynamic> json) => TeamMemberUsage(
        memberId: json['memberId'],
        memberName: json['memberName'],
        totalCreditsUsed: (json['totalCreditsUsed'] as num?)?.toDouble() ?? 0.0,
        sessionCount: json['sessionCount'] ?? 0,
        lastActivity:
            DateTime.tryParse(json['lastActivity'] ?? '') ?? DateTime.now(),
        sessions: json['sessions'] != null
            ? (json['sessions'] as List)
                .map((s) => UsageSession.fromJson(s))
                .toList()
            : [],
      );
}

class UsageSession {
  final String sessionId;
  final String expertName;
  final SessionType sessionType;
  final double creditsUsed;
  final DateTime timestamp;
  final int durationMinutes;

  UsageSession({
    required this.sessionId,
    required this.expertName,
    required this.sessionType,
    required this.creditsUsed,
    required this.timestamp,
    required this.durationMinutes,
  });

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'expertName': expertName,
        'sessionType': sessionType.name,
        'creditsUsed': creditsUsed,
        'timestamp': timestamp.toIso8601String(),
        'durationMinutes': durationMinutes,
      };

  static UsageSession fromJson(Map<String, dynamic> json) => UsageSession(
        sessionId: json['sessionId'],
        expertName: json['expertName'],
        sessionType:
            SessionType.values.firstWhere((t) => t.name == json['sessionType']),
        creditsUsed: (json['creditsUsed'] as num?)?.toDouble() ?? 0.0,
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        durationMinutes: json['durationMinutes'] ?? 0,
      );
}

class BusinessSessionUsage {
  final String id;
  final String businessId;
  final String expertId;
  final String expertName;
  final SessionType sessionType;
  final DateTime date;
  final int durationMinutes;
  final double cost;
  final String clientName;

  BusinessSessionUsage({
    required this.id,
    required this.businessId,
    required this.expertId,
    required this.expertName,
    required this.sessionType,
    required this.date,
    required this.durationMinutes,
    required this.cost,
    required this.clientName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'businessId': businessId,
        'expertId': expertId,
        'expertName': expertName,
        'sessionType': sessionType.name,
        'date': date.toIso8601String(),
        'durationMinutes': durationMinutes,
        'cost': cost,
        'clientName': clientName,
      };

  static BusinessSessionUsage fromJson(Map<String, dynamic> json) =>
      BusinessSessionUsage(
        id: json['id'],
        businessId: json['businessId'],
        expertId: json['expertId'],
        expertName: json['expertName'],
        sessionType:
            SessionType.values.firstWhere((s) => s.name == json['sessionType']),
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        durationMinutes: json['durationMinutes'],
        cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
        clientName: json['clientName'],
      );
}

// Invoice Models
enum InvoiceStatus { draft, sent, paid, overdue }

class Invoice {
  final String id;
  final String businessId;
  final DateTime generatedDate;
  final DateTime dueDate;
  final double amount;
  final InvoiceStatus status;
  final List<InvoiceItem> items;
  final String invoiceNumber;

  Invoice({
    required this.id,
    required this.businessId,
    required this.generatedDate,
    required this.dueDate,
    required this.amount,
    required this.status,
    required this.items,
    required this.invoiceNumber,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'businessId': businessId,
        'generatedDate': generatedDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'amount': amount,
        'status': status.name,
        'items': items.map((item) => item.toJson()).toList(),
        'invoiceNumber': invoiceNumber,
      };

  static Invoice fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'],
        businessId: json['businessId'],
        generatedDate:
            DateTime.tryParse(json['generatedDate'] ?? '') ?? DateTime.now(),
        dueDate: DateTime.tryParse(json['dueDate'] ?? '') ?? DateTime.now(),
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        status:
            InvoiceStatus.values.firstWhere((s) => s.name == json['status']),
        items: (json['items'] as List)
            .map((item) => InvoiceItem.fromJson(item))
            .toList(),
        invoiceNumber: json['invoiceNumber'],
      );
}

class InvoiceItem {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime date;

  InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
        'date': date.toIso8601String(),
      };

  static InvoiceItem fromJson(Map<String, dynamic> json) => InvoiceItem(
        id: json['id'],
        description: json['description'],
        quantity: json['quantity'],
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
        totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      );
}

// Team Member Models
class TeamMember {
  final String id;
  final String name;
  final String email;
  final String businessId;
  final DateTime joinedAt;
  final bool isActive;

  TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.businessId,
    required this.joinedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'businessId': businessId,
        'joinedAt': joinedAt.toIso8601String(),
        'isActive': isActive,
      };

  static TeamMember fromJson(Map<String, dynamic> json) => TeamMember(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        businessId: json['businessId'],
        joinedAt: DateTime.tryParse(json['joinedAt'] ?? '') ?? DateTime.now(),
        isActive: json['isActive'] ?? true,
      );
}

// Notification Models
enum NotificationType {
  expertRequest,
  paymentReminder,
  sessionStart,
  sessionEnd,
  general
}

enum NotificationStatus { sent, viewed, accepted, rejected }

class ChatNotification {
  final String id;
  final String fromExpertId;
  final String fromExpertName;
  final String toClientId;
  final String toClientName;
  final NotificationType type;
  final NotificationStatus status;
  final String title;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ChatNotification({
    required this.id,
    required this.fromExpertId,
    required this.fromExpertName,
    required this.toClientId,
    required this.toClientName,
    required this.type,
    required this.status,
    required this.title,
    required this.message,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromExpertId': fromExpertId,
        'fromExpertName': fromExpertName,
        'toClientId': toClientId,
        'toClientName': toClientName,
        'type': type.name,
        'status': status.name,
        'title': title,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };

  static ChatNotification fromJson(Map<String, dynamic> json) =>
      ChatNotification(
        id: json['id'],
        fromExpertId: json['fromExpertId'],
        fromExpertName: json['fromExpertName'],
        toClientId: json['toClientId'],
        toClientName: json['toClientName'],
        type: NotificationType.values.firstWhere((t) => t.name == json['type']),
        status: NotificationStatus.values
            .firstWhere((s) => s.name == json['status']),
        title: json['title'],
        message: json['message'],
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        metadata: json['metadata'],
      );

  ChatNotification copyWith({
    String? id,
    String? fromExpertId,
    String? fromExpertName,
    String? toClientId,
    String? toClientName,
    NotificationType? type,
    NotificationStatus? status,
    String? title,
    String? message,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return ChatNotification(
      id: id ?? this.id,
      fromExpertId: fromExpertId ?? this.fromExpertId,
      fromExpertName: fromExpertName ?? this.fromExpertName,
      toClientId: toClientId ?? this.toClientId,
      toClientName: toClientName ?? this.toClientName,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum ReviewType { session, expert }

class Review {
  final String id;
  final String clientId;
  final String clientName;
  final String expertId;
  final String expertName;
  final String? sessionId;
  final ReviewType type;
  final double rating; // 1-5 stars
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Review({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.expertId,
    required this.expertName,
    this.sessionId,
    required this.type,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'clientName': clientName,
        'expertId': expertId,
        'expertName': expertName,
        'sessionId': sessionId,
        'type': type.name,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static Review fromJson(Map<String, dynamic> json) => Review(
        id: json['id'],
        clientId: json['clientId'],
        clientName: json['clientName'],
        expertId: json['expertId'],
        expertName: json['expertName'],
        sessionId: json['sessionId'],
        type: ReviewType.values.firstWhere((e) => e.name == json['type']),
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        comment: json['comment'],
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'])
            : null,
      );

  Review copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? expertId,
    String? expertName,
    String? sessionId,
    ReviewType? type,
    double? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Review(
        id: id ?? this.id,
        clientId: clientId ?? this.clientId,
        clientName: clientName ?? this.clientName,
        expertId: expertId ?? this.expertId,
        expertName: expertName ?? this.expertName,
        sessionId: sessionId ?? this.sessionId,
        type: type ?? this.type,
        rating: rating ?? this.rating,
        comment: comment ?? this.comment,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
