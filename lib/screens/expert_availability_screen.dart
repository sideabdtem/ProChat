import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prochat/models/app_models.dart';
import 'package:prochat/services/app_state.dart';

class ExpertAvailabilityScreen extends StatefulWidget {
  const ExpertAvailabilityScreen({super.key});

  @override
  State<ExpertAvailabilityScreen> createState() =>
      _ExpertAvailabilityScreenState();
}

class _ExpertAvailabilityScreenState extends State<ExpertAvailabilityScreen> {
  late ExpertAvailability availability;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    final expert = appState.getCurrentExpert();
    availability = expert?.availability ?? const ExpertAvailability();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.read<AppState>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(appState.translate('availability_settings')),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveAvailability,
            child: Text(
              'Save',
              style: TextStyle(
                  color: theme.primaryColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSchedulingToggle(),
            if (availability.isSchedulingEnabled) ...[
              const SizedBox(height: 24),
              _buildBookingLimitsSection(),
              const SizedBox(height: 24),
              _buildSessionDurationsSection(),
              const SizedBox(height: 24),
              _buildWeeklyScheduleSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulingToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Schedule Bookings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Allow clients to schedule appointments with you',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                  availability.isSchedulingEnabled ? 'Enabled' : 'Disabled'),
              subtitle: Text(availability.isSchedulingEnabled
                  ? 'Clients can book appointments during your available hours'
                  : 'Clients cannot schedule appointments'),
              value: availability.isSchedulingEnabled,
              onChanged: (value) {
                setState(() {
                  availability = ExpertAvailability(
                    isSchedulingEnabled: value,
                    weeklySchedule: availability.weeklySchedule,
                    allowedDurations: availability.allowedDurations,
                    maxBookingsPerDay: availability.maxBookingsPerDay,
                    intervalMinutesBetweenBookings:
                        availability.intervalMinutesBetweenBookings,
                    blockedDates: availability.blockedDates,
                    customBlockedSlots: availability.customBlockedSlots,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingLimitsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Booking Limits',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSliderSetting(
              'Maximum bookings per day',
              availability.maxBookingsPerDay.toDouble(),
              1.0,
              20.0,
              (value) {
                setState(() {
                  availability = ExpertAvailability(
                    isSchedulingEnabled: availability.isSchedulingEnabled,
                    weeklySchedule: availability.weeklySchedule,
                    allowedDurations: availability.allowedDurations,
                    maxBookingsPerDay: value.round(),
                    intervalMinutesBetweenBookings:
                        availability.intervalMinutesBetweenBookings,
                    blockedDates: availability.blockedDates,
                    customBlockedSlots: availability.customBlockedSlots,
                  );
                });
              },
              divisions: 19,
              valueDisplay: availability.maxBookingsPerDay.toString(),
            ),
            const SizedBox(height: 16),
            _buildSliderSetting(
              'Break between bookings (minutes)',
              availability.intervalMinutesBetweenBookings.toDouble(),
              5.0,
              60.0,
              (value) {
                setState(() {
                  availability = ExpertAvailability(
                    isSchedulingEnabled: availability.isSchedulingEnabled,
                    weeklySchedule: availability.weeklySchedule,
                    allowedDurations: availability.allowedDurations,
                    maxBookingsPerDay: availability.maxBookingsPerDay,
                    intervalMinutesBetweenBookings: value.round(),
                    blockedDates: availability.blockedDates,
                    customBlockedSlots: availability.customBlockedSlots,
                  );
                });
              },
              divisions: 11,
              valueDisplay:
                  '${availability.intervalMinutesBetweenBookings} min',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionDurationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Session Durations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Select the session lengths clients can book',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BookingDuration.values.map((duration) {
                final isSelected =
                    availability.allowedDurations.contains(duration);
                return FilterChip(
                  label: Text(duration.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      final newDurations = List<BookingDuration>.from(
                          availability.allowedDurations);
                      if (selected) {
                        newDurations.add(duration);
                      } else {
                        newDurations.remove(duration);
                      }
                      availability = ExpertAvailability(
                        isSchedulingEnabled: availability.isSchedulingEnabled,
                        weeklySchedule: availability.weeklySchedule,
                        allowedDurations: newDurations,
                        maxBookingsPerDay: availability.maxBookingsPerDay,
                        intervalMinutesBetweenBookings:
                            availability.intervalMinutesBetweenBookings,
                        blockedDates: availability.blockedDates,
                        customBlockedSlots: availability.customBlockedSlots,
                      );
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyScheduleSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Weekly Schedule',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Set your working hours for each day',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...DayOfWeek.values.map((day) => _buildDaySchedule(day)),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySchedule(DayOfWeek day) {
    final dayAvailability =
        availability.weeklySchedule[day] ?? DayAvailability();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  day.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Switch(
                value: dayAvailability.isAvailable,
                onChanged: (value) => _updateDayAvailability(day, value),
              ),
              if (dayAvailability.isAvailable) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTimeButton(
                          '${dayAvailability.startTime.format(context)}',
                          () => _selectTime(context, dayAvailability.startTime,
                              (time) {
                            _updateDayTimes(day, time, dayAvailability.endTime);
                          }),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(' - '),
                      ),
                      Expanded(
                        child: _buildTimeButton(
                          '${dayAvailability.endTime.format(context)}',
                          () => _selectTime(context, dayAvailability.endTime,
                              (time) {
                            _updateDayTimes(
                                day, dayAvailability.startTime, time);
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _buildSliderSetting(
    String title,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    int? divisions,
    required String valueDisplay,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(valueDisplay,
                style: TextStyle(color: Theme.of(context).primaryColor)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _updateDayAvailability(DayOfWeek day, bool isAvailable) {
    setState(() {
      final newSchedule =
          Map<DayOfWeek, DayAvailability>.from(availability.weeklySchedule);
      newSchedule[day] = DayAvailability(
        isAvailable: isAvailable,
        startTime: availability.weeklySchedule[day]?.startTime ??
            const TimeOfDay(hour: 9, minute: 0),
        endTime: availability.weeklySchedule[day]?.endTime ??
            const TimeOfDay(hour: 17, minute: 0),
        breaks: availability.weeklySchedule[day]?.breaks ?? [],
      );

      availability = ExpertAvailability(
        isSchedulingEnabled: availability.isSchedulingEnabled,
        weeklySchedule: newSchedule,
        allowedDurations: availability.allowedDurations,
        maxBookingsPerDay: availability.maxBookingsPerDay,
        intervalMinutesBetweenBookings:
            availability.intervalMinutesBetweenBookings,
        blockedDates: availability.blockedDates,
        customBlockedSlots: availability.customBlockedSlots,
      );
    });
  }

  void _updateDayTimes(DayOfWeek day, TimeOfDay startTime, TimeOfDay endTime) {
    setState(() {
      final newSchedule =
          Map<DayOfWeek, DayAvailability>.from(availability.weeklySchedule);
      newSchedule[day] = DayAvailability(
        isAvailable: true,
        startTime: startTime,
        endTime: endTime,
        breaks: availability.weeklySchedule[day]?.breaks ?? [],
      );

      availability = ExpertAvailability(
        isSchedulingEnabled: availability.isSchedulingEnabled,
        weeklySchedule: newSchedule,
        allowedDurations: availability.allowedDurations,
        maxBookingsPerDay: availability.maxBookingsPerDay,
        intervalMinutesBetweenBookings:
            availability.intervalMinutesBetweenBookings,
        blockedDates: availability.blockedDates,
        customBlockedSlots: availability.customBlockedSlots,
      );
    });
  }

  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime,
      ValueChanged<TimeOfDay> onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  void _saveAvailability() {
    if (!_formKey.currentState!.validate()) return;

    final appState = context.read<AppState>();
    final expert = appState.getCurrentExpert();
    if (expert != null) {
      final updatedExpert = expert.copyWith(availability: availability);
      appState.updateExpert(updatedExpert);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.translate('availability_settings_saved')),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}
