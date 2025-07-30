import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import '../screens/auth_screen.dart';
import '../screens/expert_settings_page.dart';
import '../screens/expert_navigation.dart';
import '../screens/payment_page.dart';

class ExpertDashboard extends StatefulWidget {
  const ExpertDashboard({super.key});

  @override
  State<ExpertDashboard> createState() => _ExpertDashboardState();
}

class _ExpertDashboardState extends State<ExpertDashboard> {
  bool _isOnline = true;
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    final appState = context.read<AppState>();
    final appointments = appState.getExpertAppointmentsForDate(
        appState.currentUser?.id ?? '', day);

    return appointments
        .where((apt) => apt.status == AppointmentStatus.scheduled)
        .map((appointment) => Event(
              '${appointment.clientName} - ${appointment.title}',
              appointment.scheduledTime,
            ))
        .toList();
  }

  Event? _getNextUpcomingAppointment() {
    final appState = context.read<AppState>();
    final appointments = appState.expertAppointments
        .where((apt) =>
            apt.scheduledTime.isAfter(DateTime.now()) &&
            apt.status == AppointmentStatus.scheduled)
        .toList();

    if (appointments.isEmpty) return null;

    appointments.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    final nextAppointment = appointments.first;

    return Event(
      '${nextAppointment.clientName} - ${nextAppointment.title}',
      nextAppointment.scheduledTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Dashboard',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Online/Offline Toggle
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  _isOnline ? Icons.circle : Icons.circle_outlined,
                  color: _isOnline ? Colors.green : Colors.grey,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _isOnline,
                  onChanged: (value) {
                    setState(() {
                      _isOnline = value;
                    });
                  },
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.grey,
                ),
              ],
            ),
          ),
          // Logout Button
          IconButton(
            onPressed: () {
              appState.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(appState, theme),
            const SizedBox(height: 16),

            // Verification Status Banner
            _buildVerificationBanner(appState, theme),
            const SizedBox(height: 16),

            // Statistics Cards
            _buildStatisticsGrid(theme),
            const SizedBox(height: 16),

            // Credit and Session Count Widget
            _buildCreditSessionWidget(theme),
            const SizedBox(height: 16),

            // Scheduled Bookings Section
            _buildScheduledBookingsSection(theme),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(AppState appState, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  "https://images.unsplash.com/photo-1594754276102-d37d31af0d0e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTE2NTA1Njh8&ixlib=rb-4.1.0&q=80&w=1080",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      appState.currentUser?.name ?? 'Expert',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'You\'re doing great today! Keep up the excellent work.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard(
          title: 'Today\'s Earnings',
          value: '\$245.80',
          icon: Icons.attach_money,
          color: Colors.green,
          theme: theme,
        ),
        _buildStatCard(
          title: 'Time Online',
          value: '6h 32m',
          icon: Icons.access_time,
          color: Colors.blue,
          theme: theme,
        ),
        _buildStatCard(
          title: 'Session Rating',
          value: '4.8/5',
          icon: Icons.star,
          color: Colors.amber,
          theme: theme,
        ),
        _buildStatCard(
          title: 'Total Clients',
          value: '127',
          icon: Icons.people,
          color: Colors.purple,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditSessionWidget(ThemeData theme) {
    final appState = context.watch<AppState>();
    final currentUser = appState.currentUser;

    // Find current expert data
    final currentExpert = appState.experts.firstWhere(
      (expert) => expert.id == currentUser?.id,
      orElse: () => appState.experts.first,
    );

    int sessionCount;
    double creditEarned;

    // Check if user is business/team owner or individual expert
    if (currentExpert.isBusinessExpert &&
        currentExpert.teamMemberIds.isNotEmpty) {
      // Business/Team Owner: aggregate team member data
      sessionCount = currentExpert.todaySessionCount;
      creditEarned = currentExpert.todayEarnings;

      // Add team members' data
      for (String memberId in currentExpert.teamMemberIds) {
        final member = appState.experts.firstWhere(
          (expert) => expert.id == memberId,
          orElse: () => Expert(
            id: '',
            name: '',
            email: '',
            bio: '',
            category: ExpertCategory.doctor,
            languages: [],
            rating: 0,
            totalReviews: 0,
            pricePerMinute: 0,
            pricePerSession: 0,
            isAvailable: false,
            isVerified: false,
            joinedAt: DateTime.now(),
            regions: [],
          ),
        );
        if (member.id.isNotEmpty) {
          sessionCount += member.todaySessionCount;
          creditEarned += member.todayEarnings;
        }
      }
    } else {
      // Individual Expert: show only their own data
      sessionCount = currentExpert.todaySessionCount;
      creditEarned = currentExpert.todayEarnings;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Credits & Sessions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${creditEarned.toStringAsFixed(2)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            currentExpert.isBusinessExpert &&
                                    currentExpert.teamMemberIds.isNotEmpty
                                ? 'Team Credits'
                                : 'Current Credits',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer
                                  .withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaymentPage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onPrimaryContainer
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.add,
                              color: theme.colorScheme.onPrimaryContainer,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.timeline,
                        color: theme.colorScheme.onSecondaryContainer,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$sessionCount',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      Text(
                        currentExpert.isBusinessExpert &&
                                currentExpert.teamMemberIds.isNotEmpty
                            ? 'Team Sessions'
                            : 'Session Count',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer
                              .withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showExpertHistory(sessionCount, creditEarned),
              icon: const Icon(Icons.history, size: 18),
              label: Text(appState.translate('view_history')),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointmentSection(ThemeData theme,
      [Event? upcomingAppointment]) {
    upcomingAppointment ??= _getNextUpcomingAppointment();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: theme.colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Upcoming Appointment',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (upcomingAppointment != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.person,
                      color: theme.colorScheme.primary,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          upcomingAppointment.title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${upcomingAppointment.time.day}/${upcomingAppointment.time.month}/${upcomingAppointment.time.year} at ${upcomingAppointment.time.hour.toString().padLeft(2, '0')}:${upcomingAppointment.time.minute.toString().padLeft(2, '0')}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Next',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No upcoming appointments',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduledBookingsSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Scheduled Bookings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Upcoming Appointment Section
          Consumer<AppState>(
            builder: (context, appState, _) {
              final appointments = appState.expertAppointments
                  .where((apt) =>
                      apt.scheduledTime.isAfter(DateTime.now()) &&
                      apt.status == AppointmentStatus.scheduled)
                  .toList();

              if (appointments.isEmpty) return const SizedBox();

              appointments
                  .sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
              final nextAppointment = appointments.first;

              final upcomingAppointment = Event(
                '${nextAppointment.clientName} - ${nextAppointment.title}',
                nextAppointment.scheduledTime,
              );

              return _buildUpcomingAppointmentSection(
                  theme, upcomingAppointment);
            },
          ),
          const SizedBox(height: 16),

          // Calendar
          Consumer<AppState>(
            builder: (context, appState, _) {
              return TableCalendar<Event>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                eventLoader: (day) {
                  final appointments = appState.getExpertAppointmentsForDate(
                      appState.currentUser?.id ?? '', day);

                  return appointments
                      .map((appointment) => Event(
                            '${appointment.clientName} - ${appointment.title}',
                            appointment.scheduledTime,
                          ))
                      .toList();
                },
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    final appointments = appState.getExpertAppointmentsForDate(
                        appState.currentUser?.id ?? '', selectedDay);
                    _selectedEvents.value = appointments
                        .where(
                            (apt) => apt.status == AppointmentStatus.scheduled)
                        .map((appointment) => Event(
                              '${appointment.clientName} - ${appointment.title}',
                              appointment.scheduledTime,
                            ))
                        .toList();
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: theme.colorScheme.error),
                  holidayTextStyle: TextStyle(color: theme.colorScheme.error),
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      final appointments = appState.expertAppointments
                          .where((apt) =>
                              apt.scheduledTime.isAfter(DateTime.now()) &&
                              apt.status == AppointmentStatus.scheduled)
                          .toList();

                      if (appointments.isEmpty) return null;

                      appointments.sort(
                          (a, b) => a.scheduledTime.compareTo(b.scheduledTime));
                      final nextAppointment = appointments.first;

                      final isUpcoming =
                          isSameDay(day, nextAppointment.scheduledTime);

                      return Container(
                        margin: const EdgeInsets.only(top: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isUpcoming
                                    ? Colors.red
                                    : theme.colorScheme.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (events.length > 1) ...[
                              const SizedBox(width: 2),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isUpcoming
                                      ? Colors.red
                                      : theme.colorScheme.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }
                    return null;
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    final appointments = appState.expertAppointments
                        .where((apt) =>
                            apt.scheduledTime.isAfter(DateTime.now()) &&
                            apt.status == AppointmentStatus.scheduled)
                        .toList();

                    if (appointments.isEmpty) return null;

                    appointments.sort(
                        (a, b) => a.scheduledTime.compareTo(b.scheduledTime));
                    final nextAppointment = appointments.first;

                    final isUpcoming =
                        isSameDay(day, nextAppointment.scheduledTime);

                    if (isUpcoming) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: theme.colorScheme.primary,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.primary,
                  ),
                  titleTextStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ) ??
                      const TextStyle(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Events for selected day
          ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, events, _) {
              if (events.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'No bookings scheduled for this day',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bookings for ${_selectedDay?.day}/${_selectedDay?.month}/${_selectedDay?.year}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...events.map((event) => _buildEventItem(event, theme)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(Event event, ThemeData theme) {
    final appState = Provider.of<AppState>(context, listen: false);

    // Find the actual appointment for this event
    final appointment = appState
        .getExpertAppointmentsForDate(
            appState.currentUser?.id ?? '', event.time)
        .firstWhere(
          (apt) =>
              apt.scheduledTime.hour == event.time.hour &&
              apt.scheduledTime.minute == event.time.minute,
          orElse: () => throw Exception('Appointment not found'),
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: theme.colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.clientName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appointment.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: appointment.status == AppointmentStatus.scheduled
                      ? theme.colorScheme.secondary.withOpacity(0.1)
                      : theme.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  appointment.status.name.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: appointment.status == AppointmentStatus.scheduled
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '${event.time.hour.toString().padLeft(2, '0')}:${event.time.minute.toString().padLeft(2, '0')}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.timer,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '${appointment.durationMinutes} min',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.attach_money,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '\$${appointment.totalCost.toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (appointment.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              appointment.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (appointment.status == AppointmentStatus.scheduled) ...[
                TextButton.icon(
                  onPressed: () => _showCancelConfirmation(appointment),
                  icon: Icon(
                    Icons.cancel,
                    size: 14,
                    color: theme.colorScheme.error,
                  ),
                  label: Text(
                    'Cancel',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              TextButton.icon(
                onPressed: () => _showAppointmentDetails(appointment),
                icon: Icon(
                  Icons.info_outline,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                label: Text(
                  'Details',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(Appointment appointment) {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.translate('cancel_appointment')),
        content: Text(
            'Are you sure you want to cancel the appointment with ${appointment.clientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.translate('no')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelAppointment(appointment);
            },
            child: Text(appState.translate('yes_cancel')),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(Appointment appointment) {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.cancelAppointment(appointment.id);

    // Update the selected events to refresh the calendar
    final appointments = appState.getExpertAppointmentsForDate(
        appState.currentUser?.id ?? '', _selectedDay!);
    _selectedEvents.value = appointments
        .where((apt) => apt.status == AppointmentStatus.scheduled)
        .map((appointment) => Event(
              '${appointment.clientName} - ${appointment.title}',
              appointment.scheduledTime,
            ))
        .toList();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${appState.translate('appointment_cancelled')} ${appointment.clientName}'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showAppointmentDetails(Appointment appointment) {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.translate('appointment_details')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                  appState.translate('client'), appointment.clientName),
              _buildDetailRow(appState.translate('title'), appointment.title),
              _buildDetailRow(appState.translate('date'),
                  '${appointment.scheduledTime.day}/${appointment.scheduledTime.month}/${appointment.scheduledTime.year}'),
              _buildDetailRow(appState.translate('time'),
                  '${appointment.scheduledTime.hour.toString().padLeft(2, '0')}:${appointment.scheduledTime.minute.toString().padLeft(2, '0')}'),
              _buildDetailRow(appState.translate('duration'),
                  '${appointment.durationMinutes} minutes'),
              _buildDetailRow(appState.translate('cost'),
                  '\$${appointment.totalCost.toStringAsFixed(2)}'),
              _buildDetailRow(appState.translate('payment_type'),
                  appointment.paymentType.name),
              _buildDetailRow(appState.translate('status'),
                  appointment.status.name.toUpperCase()),
              if (appointment.description.isNotEmpty)
                _buildDetailRow(
                    appState.translate('description'), appointment.description),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.translate('close')),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBanner(AppState appState, ThemeData theme) {
    // Get current expert data
    final currentUser = appState.currentUser;
    final expert = appState.experts.firstWhere(
      (e) => e.id == currentUser?.id,
      orElse: () => appState.experts.first,
    );

    if (expert.isVerified) {
      return const SizedBox.shrink(); // Don't show banner if verified
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Account Not Verified',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your account is not yet verified. Some features may be restricted.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.orange[600],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExpertSettingsPage(),
                  ),
                );
              },
              icon: const Icon(Icons.verified_user, size: 18),
              label: Text(appState.translate('submit_for_verification')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExpertHistory(int sessionCount, double creditEarned) {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Session History & Earnings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Summary Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$sessionCount',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                        ),
                        Text(
                          'Total Sessions',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withOpacity(0.8),
                                  ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withOpacity(0.3),
                    ),
                    Column(
                      children: [
                        Text(
                          '\$${creditEarned.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                        ),
                        Text(
                          'Credits Earned',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withOpacity(0.8),
                                  ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withOpacity(0.3),
                    ),
                    Column(
                      children: [
                        Text(
                          '4.8/5',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                        ),
                        Text(
                          'Avg Rating',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withOpacity(0.8),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Recent Sessions List
              Row(
                children: [
                  Text(
                    'Recent Sessions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'This Month: \$${(creditEarned * 0.6).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final sessionDate =
                        DateTime.now().subtract(Duration(days: index + 1));
                    final sessionCost = 25.0 + (index * 8.0);
                    final sessionDuration = 45 + (index * 15);
                    final clientName = [
                      'John Doe',
                      'Sarah Smith',
                      'Mike Johnson',
                      'Emily Davis',
                      'Alex Brown',
                      'Lisa Wilson',
                      'David Taylor'
                    ][index];
                    final sessionType =
                        ['Chat', 'Video Call', 'Voice Call'][index % 3];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                sessionType == 'Chat'
                                    ? Icons.chat
                                    : sessionType == 'Video Call'
                                        ? Icons.videocam
                                        : Icons.call,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$clientName - $sessionType',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              Text(
                                '\$${sessionCost.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${sessionDate.day}/${sessionDate.month}/${sessionDate.year}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.timer,
                                size: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${sessionDuration}m',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(4.0 + (index % 10) * 0.1).toStringAsFixed(1)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Download Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(appState
                            .translate('downloading_session_history_report')),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.download),
                  label: Text(appState.translate('download_report')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Event {
  final String title;
  final DateTime time;

  Event(this.title, this.time);

  @override
  String toString() => title;
}
