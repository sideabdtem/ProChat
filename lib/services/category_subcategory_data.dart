import '../models/app_models.dart';

class CategorySubcategoryData {
  static const Map<ExpertCategory, List<String>> categorySubcategories = {
    ExpertCategory.doctor: [
      'General Medicine',
      'Cardiology',
      'Dermatology',
      'Pediatrics',
      'Orthopedics',
      'Gynecology',
      'Neurology',
      'Psychiatry',
      'Radiology',
      'Surgery',
      'Emergency Medicine',
      'Internal Medicine',
    ],
    ExpertCategory.lawyer: [
      'Corporate Law',
      'Criminal Law',
      'Family Law',
      'Immigration Law',
      'Real Estate Law',
      'Tax Law',
      'Intellectual Property',
      'Labor Law',
      'Environmental Law',
      'Personal Injury',
      'Contract Law',
      'International Law',
    ],
    ExpertCategory.therapist: [
      'Cognitive Behavioral Therapy',
      'Marriage Counseling',
      'Child Psychology',
      'Addiction Counseling',
      'Trauma Therapy',
      'Group Therapy',
      'Art Therapy',
      'Music Therapy',
      'Behavioral Therapy',
      'Psychoanalysis',
      'Family Therapy',
      'Grief Counseling',
    ],
    ExpertCategory.lifeCoach: [
      'Career Coaching',
      'Relationship Coaching',
      'Health & Wellness',
      'Financial Coaching',
      'Leadership Coaching',
      'Personal Development',
      'Spiritual Coaching',
      'Business Coaching',
      'Executive Coaching',
      'Performance Coaching',
      'Mindfulness Coaching',
      'Transition Coaching',
    ],
    ExpertCategory.businessConsultant: [
      'Strategic Planning',
      'Marketing Strategy',
      'Financial Planning',
      'Operations Management',
      'Human Resources',
      'IT Consulting',
      'Supply Chain Management',
      'Risk Management',
      'Change Management',
      'Project Management',
      'Digital Transformation',
      'Startup Consulting',
    ],
    ExpertCategory.technician: [
      'IT Support',
      'Network Administration',
      'Software Development',
      'Web Development',
      'Database Management',
      'Cybersecurity',
      'Mobile App Development',
      'Cloud Computing',
      'DevOps',
      'System Administration',
      'Quality Assurance',
      'Data Analytics',
    ],
    ExpertCategory.religion: [
      'Islamic Studies',
      'Biblical Studies',
      'Comparative Religion',
      'Theology',
      'Religious Counseling',
      'Spiritual Guidance',
      'Interfaith Dialogue',
      'Religious History',
      'Meditation & Prayer',
      'Religious Law',
      'Pastoral Care',
      'Religious Education',
    ],
  };

  static const Map<ExpertCategory, List<String>> categorySubcategoriesArabic = {
    ExpertCategory.doctor: [
      'الطب العام',
      'أمراض القلب',
      'الأمراض الجلدية',
      'طب الأطفال',
      'جراحة العظام',
      'طب النساء',
      'طب الأعصاب',
      'طب النفس',
      'الأشعة',
      'الجراحة',
      'طب الطوارئ',
      'طب الباطنة',
    ],
    ExpertCategory.lawyer: [
      'القانون التجاري',
      'القانون الجنائي',
      'قانون الأسرة',
      'قانون الهجرة',
      'قانون العقارات',
      'قانون الضرائب',
      'الملكية الفكرية',
      'قانون العمل',
      'القانون البيئي',
      'إصابات شخصية',
      'قانون العقود',
      'القانون الدولي',
    ],
    ExpertCategory.therapist: [
      'العلاج المعرفي السلوكي',
      'الاستشارة الزوجية',
      'علم نفس الطفل',
      'علاج الإدمان',
      'علاج الصدمات',
      'العلاج الجماعي',
      'العلاج بالفن',
      'العلاج بالموسيقى',
      'العلاج السلوكي',
      'التحليل النفسي',
      'العلاج الأسري',
      'علاج الحزن',
    ],
    ExpertCategory.lifeCoach: [
      'التدريب المهني',
      'تدريب العلاقات',
      'الصحة والعافية',
      'التدريب المالي',
      'تدريب القيادة',
      'التطوير الشخصي',
      'التدريب الروحي',
      'التدريب التجاري',
      'تدريب التنفيذيين',
      'تدريب الأداء',
      'تدريب اليقظة',
      'تدريب التحول',
    ],
    ExpertCategory.businessConsultant: [
      'التخطيط الاستراتيجي',
      'استراتيجية التسويق',
      'التخطيط المالي',
      'إدارة العمليات',
      'الموارد البشرية',
      'استشارات تكنولوجيا المعلومات',
      'إدارة سلسلة التوريد',
      'إدارة المخاطر',
      'إدارة التغيير',
      'إدارة المشاريع',
      'التحول الرقمي',
      'استشارات الشركات الناشئة',
    ],
    ExpertCategory.technician: [
      'الدعم التقني',
      'إدارة الشبكات',
      'تطوير البرمجيات',
      'تطوير الويب',
      'إدارة قواعد البيانات',
      'الأمن السيبراني',
      'تطوير تطبيقات الجوال',
      'الحوسبة السحابية',
      'DevOps',
      'إدارة الأنظمة',
      'ضمان الجودة',
      'تحليل البيانات',
    ],
    ExpertCategory.religion: [
      'الدراسات الإسلامية',
      'الدراسات الكتابية',
      'الديانات المقارنة',
      'اللاهوت',
      'الاستشارة الدينية',
      'الإرشاد الروحي',
      'الحوار بين الأديان',
      'التاريخ الديني',
      'التأمل والصلاة',
      'القانون الديني',
      'الرعاية الرعوية',
      'التعليم الديني',
    ],
  };

  static List<String> getSubcategoriesForCategory(ExpertCategory category) {
    return categorySubcategories[category] ?? [];
  }

  static List<String> getSubcategoriesForCategoryArabic(ExpertCategory category) {
    return categorySubcategoriesArabic[category] ?? [];
  }

  static String getCategoryDisplayName(ExpertCategory category) {
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
        return 'Religious Advisor';
    }
  }
}