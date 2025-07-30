import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import '../screens/payment_screen.dart';
import '../screens/auth_screen.dart';
import '../widgets/navigation_wrapper.dart';

// Helper function to convert DateTime to DayOfWeek
DayOfWeek _getDayOfWeek(DateTime date) {
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

class AppointmentBookingScreen extends StatefulWidget {
  final Expert expert;

  const AppointmentBookingScreen({super.key, required this.expert});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  BookingSlot? _selectedTimeSlot;
  SessionConfig? _selectedSessionPackage;
  PaymentType _selectedPaymentType = PaymentType.perSession;

  List<BookingSlot> _availableTimeSlots = [];
  List<SessionConfig> _availableSessionPackages = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadAvailableSessionPackages();
    _loadAvailableTimeSlotsForDay(_selectedDay!);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadAvailableSessionPackages() {
    // Load the expert's configured session packages
    _availableSessionPackages = widget.expert.sessionConfigs
        .where((config) => config.isActive)
        .toList();

    // If no session packages are configured, create default ones based on allowed durations
    if (_availableSessionPackages.isEmpty &&
        widget.expert.availability.allowedDurations.isNotEmpty) {
      _availableSessionPackages =
          widget.expert.availability.allowedDurations.map((duration) {
        return SessionConfig(
          id: duration.name,
          name: duration.displayName,
          durationMinutes: duration.minutes,
          price: widget.expert.pricePerSession,
          isActive: true,
        );
      }).toList();
    }

    // Select the first available session package by default
    if (_selectedSessionPackage == null &&
        _availableSessionPackages.isNotEmpty) {
      _selectedSessionPackage = _availableSessionPackages.first;
    }
  }

  void _loadAvailableTimeSlotsForDay(DateTime day) {
    _availableTimeSlots.clear();
    _selectedTimeSlot = null;

    if (!widget.expert.availability.isSchedulingEnabled) {
      return;
    }

    final dayOfWeek = _getDayOfWeek(day);
    final dayAvailability =
        widget.expert.availability.weeklySchedule[dayOfWeek];

    if (dayAvailability == null || !dayAvailability.isAvailable) {
      return;
    }

    // Generate time slots based on expert's availability and allowed durations
    final startHour = dayAvailability.startTime.hour;
    final startMinute = dayAvailability.startTime.minute;
    final endHour = dayAvailability.endTime.hour;
    final endMinute = dayAvailability.endTime.minute;

    final startDateTime =
        DateTime(day.year, day.month, day.day, startHour, startMinute);
    final endDateTime =
        DateTime(day.year, day.month, day.day, endHour, endMinute);

    // Create time slots with intervals
    final intervalMinutes =
        widget.expert.availability.intervalMinutesBetweenBookings;
    DateTime currentTime = startDateTime;

    while (currentTime.add(Duration(minutes: 30)).isBefore(endDateTime) ||
        currentTime.add(Duration(minutes: 30)).isAtSameMomentAs(endDateTime)) {
      // Check if this time slot conflicts with breaks
      bool isBlocked = false;
      for (final breakSlot in dayAvailability.breaks) {
        final breakStart = DateTime(day.year, day.month, day.day,
            breakSlot.startTime.hour, breakSlot.startTime.minute);
        final breakEnd = DateTime(day.year, day.month, day.day,
            breakSlot.endTime.hour, breakSlot.endTime.minute);

        if (currentTime.isBefore(breakEnd) &&
            currentTime.add(Duration(minutes: 30)).isAfter(breakStart)) {
          isBlocked = true;
          break;
        }
      }

      // Check if this time slot is in the past
      final now = DateTime.now();
      if (currentTime.isBefore(now)) {
        isBlocked = true;
      }

      _availableTimeSlots.add(BookingSlot(
        startTime: currentTime,
        endTime: currentTime.add(Duration(minutes: 30)),
        duration: BookingDuration.minutes30,
        isAvailable: !isBlocked,
      ));

      currentTime = currentTime.add(Duration(minutes: intervalMinutes));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    return NavigationWrapper(
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Book Appointment',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildExpertHeader(theme),
                    const SizedBox(height: 24),
                    _buildCalendar(theme, appState),
                    const SizedBox(height: 24),
                    _buildTimeSlotSelector(theme),
                    const SizedBox(height: 24),
                    _buildSessionPackageSelector(theme),
                    const SizedBox(height: 24),
                    _buildPriceInfo(theme),
                    const SizedBox(height: 32),
                    _buildBookButton(theme, appState),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpertHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(widget.expert.profileImage ??
                "https://pixabay.com/get/g0b9e67536f622e2f5d3afdc31b9520ef1bd79bf3409dee0a2029a5099d6a5acb05822f0a24ae143e18a2cd816987b2d926fe86dc2c85cd51cf5fbbd425acca3b_1280.jpg"),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.expert.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.expert.categoryName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.expert.rating.toStringAsFixed(1),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
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
  }

  Widget _buildCalendar(ThemeData theme, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TableCalendar<Appointment>(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            eventLoader: (day) {
              return appState.getExpertAppointmentsForDate(
                  widget.expert.id, day);
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              titleTextStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ) ??
                  const TextStyle(),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              if (selectedDay
                  .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
                return;
              }
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _loadAvailableTimeSlotsForDay(selectedDay);
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Times',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _availableTimeSlots.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'No available time slots for this date',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableTimeSlots.map((timeSlot) {
                    final isSelected =
                        _selectedTimeSlot?.startTime == timeSlot.startTime;
                    final timeString =
                        '${timeSlot.startTime.hour.toString().padLeft(2, '0')}:${timeSlot.startTime.minute.toString().padLeft(2, '0')}';

                    return GestureDetector(
                      onTap: timeSlot.isAvailable
                          ? () {
                              setState(() {
                                _selectedTimeSlot = timeSlot;
                              });
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: !timeSlot.isAvailable
                              ? theme.colorScheme.onSurface.withOpacity(0.1)
                              : isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: !timeSlot.isAvailable
                                ? theme.colorScheme.outline.withOpacity(0.2)
                                : isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline
                                        .withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          timeString,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: !timeSlot.isAvailable
                                ? theme.colorScheme.onSurface.withOpacity(0.4)
                                : isSelected
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildSessionPackageSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Packages',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _availableSessionPackages.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'No session packages configured',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: _availableSessionPackages.map((sessionPackage) {
                    final isSelected =
                        _selectedSessionPackage?.id == sessionPackage.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: sessionPackage.isActive
                            ? () {
                                setState(() {
                                  _selectedSessionPackage = sessionPackage;
                                });
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: !sessionPackage.isActive
                                ? theme.colorScheme.onSurface.withOpacity(0.1)
                                : isSelected
                                    ? theme.colorScheme.primary.withOpacity(0.1)
                                    : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: !sessionPackage.isActive
                                  ? theme.colorScheme.outline.withOpacity(0.2)
                                  : isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline
                                          .withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline
                                          .withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sessionPackage.name,
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: !sessionPackage.isActive
                                            ? theme.colorScheme.onSurface
                                                .withOpacity(0.4)
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${sessionPackage.durationMinutes} minutes',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: !sessionPackage.isActive
                                            ? theme.colorScheme.onSurface
                                                .withOpacity(0.4)
                                            : theme.colorScheme.onSurface
                                                .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Consumer<AppState>(
                                builder: (context, appState, child) {
                                  return Text(
                                    appState.formatPrice(sessionPackage.price),
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: !sessionPackage.isActive
                                          ? theme.colorScheme.onSurface
                                              .withOpacity(0.4)
                                          : theme.colorScheme.primary,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(ThemeData theme) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final totalCost = _selectedSessionPackage?.price ?? 0.0;

        return _buildPriceInfoContent(theme, appState, totalCost);
      },
    );
  }

  Widget _buildPriceInfoContent(
      ThemeData theme, AppState appState, double totalCost) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Price Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Session:',
                style: theme.textTheme.bodyLarge,
              ),
              Text(
                _selectedSessionPackage?.name ?? 'No session selected',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Duration:',
                style: theme.textTheme.bodyLarge,
              ),
              Text(
                _selectedSessionPackage != null
                    ? '${_selectedSessionPackage!.durationMinutes} minutes'
                    : 'No duration selected',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price:',
                style: theme.textTheme.bodyLarge,
              ),
              Text(
                _selectedSessionPackage != null
                    ? appState.formatPrice(_selectedSessionPackage!.price)
                    : 'No price available',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Cost:',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                appState.formatPrice(totalCost),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton(ThemeData theme, AppState appState) {
    final isValidBooking = _selectedDay != null &&
        _selectedTimeSlot != null &&
        _selectedSessionPackage != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            isValidBooking ? () => _handleBookAppointment(appState) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today),
            const SizedBox(width: 12),
            Text(
              'Book Appointment',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Removed _selectTime method as we now use predefined time slots

  void _handleBookAppointment(AppState appState) {
    if (appState.currentUser == null) {
      // Store the pending action and navigate to auth screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AuthScreen(),
        ),
      );
      return;
    }

    // Navigate to payment screen with appointment details
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          expert: widget.expert,
          isForAppointment: true,
          appointmentDetails: {
            'scheduledTime': _selectedTimeSlot!.startTime,
            'durationMinutes': _selectedSessionPackage!.durationMinutes,
            'paymentType': PaymentType.perSession,
            'sessionPackage': _selectedSessionPackage!.toJson(),
            'totalCost': _selectedSessionPackage!.price,
          },
        ),
      ),
    );
  }
}
