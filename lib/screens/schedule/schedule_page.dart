import 'package:flutter/material.dart';
import 'package:health_check/screens/schedule/schedule_widgets.dart';
import 'package:provider/provider.dart';
import 'package:health_check/states/schedule_state.dart';
import 'package:health_check/states/user_state.dart';
import 'package:health_check/models/schedule.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScheduleState _scheduleState;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scheduleState = ScheduleState();
    
    // Load schedules on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserSchedules();
    });

    // Listen to tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _onTabChanged(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserSchedules() {
    final user = context.read<UserState>().user;
    if (user != null) {
      _scheduleState.loadSchedules(user.id);
    }
  }

  void _onTabChanged(int index) {
    ScheduleType type;
    switch (index) {
      case 0:
        type = ScheduleType.day;
        break;
      case 1:
        type = ScheduleType.week;
        break;
      case 2:
        type = ScheduleType.month;
        break;
      default:
        type = ScheduleType.day;
    }
    _scheduleState.setScheduleType(type);
  }

  void _showAddScheduleDialog() {
    final user = context.read<UserState>().user;
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddScheduleBottomSheet(
        userId: user.id,
        onScheduleAdded: (schedule) {
          _scheduleState.addSchedule(schedule);
        },
        initialType: _scheduleState.selectedType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _scheduleState,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          title: const Text(
            'Schedule',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Consumer<ScheduleState>(
              builder: (context, scheduleState, child) {
                final upcomingCount = scheduleState.getUpcomingSchedules().length;
                final overdueCount = scheduleState.getOverdueSchedules().length;
                
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => _showNotificationsDialog(context),
                    ),
                    if (upcomingCount > 0 || overdueCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: overdueCount > 0 ? Colors.red : Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${upcomingCount + overdueCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: () => _showDatePicker(),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorWeight: 3,
            tabs: const [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.today, size: 18),
                    SizedBox(width: 4),
                    Text('Day'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.view_week, size: 18),
                    SizedBox(width: 4),
                    Text('Week'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_view_month, size: 18),
                    SizedBox(width: 4),
                    Text('Month'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Consumer<ScheduleState>(
          builder: (context, scheduleState, child) {
            if (scheduleState.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (scheduleState.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'NO SCHEDULES FOUND',
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        scheduleState.clearError();
                        _loadUserSchedules();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                DayView(scheduleState: scheduleState),
                WeekView(scheduleState: scheduleState),
                MonthView(scheduleState: scheduleState),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddScheduleDialog,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    final scheduleState = context.read<ScheduleState>();
    final upcoming = scheduleState.getUpcomingSchedules();
    final overdue = scheduleState.getOverdueSchedules();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (overdue.isNotEmpty) ...[
                Text(
                  'Overdue (${overdue.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                ...overdue.take(3).map((schedule) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.warning, color: Colors.red[400]),
                  title: Text(schedule.title),
                  subtitle: Text('Due: ${schedule.formattedDate}'),
                )),
                if (overdue.length > 3)
                  Text('... and ${overdue.length - 3} more'),
                const SizedBox(height: 16),
              ],
              if (upcoming.isNotEmpty) ...[
                Text(
                  'Upcoming (${upcoming.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                ...upcoming.take(3).map((schedule) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.schedule, color: Colors.blue[400]),
                  title: Text(schedule.title),
                  subtitle: Text('${schedule.formattedDate} at ${schedule.formattedStartTime}'),
                )),
                if (upcoming.length > 3)
                  Text('... and ${upcoming.length - 3} more'),
              ],
              if (upcoming.isEmpty && overdue.isEmpty)
                const Text('No notifications'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _scheduleState.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    ).then((selectedDate) {
      if (selectedDate != null) {
        _scheduleState.setSelectedDate(selectedDate);
      }
    });
  }
}