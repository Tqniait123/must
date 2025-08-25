import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/app_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/enums/scroll_ux_option.dart';
import 'package:must_invest/core/extensions/is_logged_in.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/static/app_assets.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/adaptive_layout/custom_layout.dart';
import 'package:must_invest/core/utils/widgets/long_press_effect.dart';
import 'package:must_invest/core/widgets/scroll_options/index.dart';
import 'package:must_invest/features/explore/data/models/filter_model.dart';
import 'package:must_invest/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:must_invest/features/home/presentation/widgets/home_user_header_widget.dart';
import 'package:must_invest/features/home/presentation/widgets/my_points_card.dart';
import 'package:must_invest/features/home/presentation/widgets/timer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> with WidgetsBindingObserver, RouteAware {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isRemembered = true;
  late ExploreCubit _exploreCubit;
  Position? _currentPosition;
  final List<String> _homeLogs = [];
  Timer? _parkingCheckTimer;
  DateTime? _lastLoggedStartTime;

  // For different scroll options
  final ScrollUXOption _selectedScrollOption = ScrollUXOption.animatedHints;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    _loadNearestParkings(isFirstTime: false);
    // Called when coming back to this screen
    debugPrint("RETURNED TO HOME ✅");
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _exploreCubit = ExploreCubit(sl());

    _logHomeEvent("=== HOME USER SCREEN INITIALIZED ===");
    _logHomeEvent("Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}");
    _logHomeEvent("Screen initialization time: ${DateTime.now()}");

    // Load previous logs and start monitoring
    _loadHomeLogs();
    _checkParkingStatus();
    _loadNearestParkings(isFirstTime: true);

    // Start periodic checking for parking status changes
    _startParkingStatusMonitoring();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _logHomeEvent("HOME SCREEN DISPOSING");
    _saveHomeLogs();
    WidgetsBinding.instance.removeObserver(this);
    _parkingCheckTimer?.cancel();
    _exploreCubit.close();
    _searchController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    _logHomeEvent("HOME SCREEN: App lifecycle changed to $state at ${DateTime.now()}");

    if (state == AppLifecycleState.resumed) {
      _logHomeEvent("HOME SCREEN: App resumed - checking parking status");
      _checkParkingStatus();
    } else if (state == AppLifecycleState.paused) {
      _logHomeEvent("HOME SCREEN: App paused - saving logs");
      _saveHomeLogs();
    }
  }

  void _logHomeEvent(String event) {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
    final logEntry = "[$timestamp] HOME: $event";
    _homeLogs.add(logEntry);
    print("HOME_PARKING_LOG: $logEntry");

    // Keep only last 500 logs
    if (_homeLogs.length > 500) {
      _homeLogs.removeRange(0, _homeLogs.length - 500);
    }
  }

  Future<void> _loadHomeLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedLogs = prefs.getStringList('home_parking_logs') ?? [];
      _homeLogs.addAll(storedLogs);

      if (storedLogs.isNotEmpty) {
        _logHomeEvent("Loaded ${storedLogs.length} previous home logs");
      }
    } catch (e) {
      _logHomeEvent("ERROR loading home logs: $e");
    }
  }

  Future<void> _saveHomeLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('home_parking_logs', _homeLogs);
    } catch (e) {
      _logHomeEvent("ERROR saving home logs: $e");
    }
  }

  void _startParkingStatusMonitoring() {
    _parkingCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkParkingStatus();
    });
  }

  void _checkParkingStatus() {
    final user = context.user;
    final isInParking = user.inParking ?? false;
    final parkingStartTime = user.inParkingFrom;

    _logHomeEvent("Parking status check:");
    _logHomeEvent("  - inParking: $isInParking");
    _logHomeEvent("  - inParkingFrom: $parkingStartTime");
    _logHomeEvent("  - Current time: ${DateTime.now()}");

    if (isInParking) {
      if (parkingStartTime == null) {
        _logHomeEvent("CRITICAL: User is in parking but startTime is NULL!");
        _logHomeEvent("This will cause timer to use DateTime.now() as fallback");
      } else {
        final timeDiff = DateTime.now().difference(parkingStartTime);
        _logHomeEvent("  - Time since parking started: ${_formatDuration(timeDiff)}");

        // Check if startTime changed unexpectedly
        if (_lastLoggedStartTime != null && _lastLoggedStartTime != parkingStartTime) {
          _logHomeEvent("WARNING: Parking start time changed!");
          _logHomeEvent("  - Previous: $_lastLoggedStartTime");
          _logHomeEvent("  - Current: $parkingStartTime");
          _logHomeEvent("  - This could cause timer reset!");
        }

        _lastLoggedStartTime = parkingStartTime;

        // Check for suspiciously recent start times (potential resets)
        if (timeDiff.inMinutes < 1 && _homeLogs.any((log) => log.contains("Time since parking started:"))) {
          _logHomeEvent("SUSPICIOUS: Start time is very recent, possible reset!");
        }
      }
    } else {
      _logHomeEvent("User is not in parking - timer should not be displayed");
    }

    // Save logs every 10 checks (50 seconds) on Android, every 20 checks on iOS
    final saveInterval = Platform.isAndroid ? 10 : 20;
    if (_parkingCheckTimer?.tick != null && _parkingCheckTimer!.tick % saveInterval == 0) {
      _saveHomeLogs();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Future<void> _shareHomeLogs() async {
    try {
      _logHomeEvent("User requested to share HOME logs");

      final deviceInfo = [
        "=== HOME SCREEN DEVICE INFO ===",
        "Platform: ${Platform.operatingSystem}",
        "Platform Version: ${Platform.operatingSystemVersion}",
        "Current Time: ${DateTime.now()}",
        "User in parking: ${context.user.inParking ?? false}",
        "Parking start time: ${context.user.inParkingFrom}",
        "=== HOME LOGS ===",
      ];

      final allLogs = [...deviceInfo, ..._homeLogs];
      final logContent = allLogs.join('\n');

      // For now, just copy to clipboard and show snackbar
      // You can implement file sharing like in the timer widget
      await Clipboard.setData(ClipboardData(text: logContent));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Home logs copied to clipboard'), duration: Duration(seconds: 2)));
      }

      _logHomeEvent("Home logs copied to clipboard successfully");
    } catch (e) {
      _logHomeEvent("ERROR sharing home logs: $e");
    }
  }

  Future<void> _loadNearestParkings({bool isFirstTime = true}) async {
    try {
      _exploreCubit.getAllParkings(filter: FilterModel.mostPopular(), isFirstTime: isFirstTime);
    } catch (e) {
      _exploreCubit.getAllParkings(filter: FilterModel.mostPopular(), isFirstTime: isFirstTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.user;
    final isInParking = user.inParking ?? false;
    final parkingStartTime = user.inParkingFrom;

    // Log every rebuild to track when timer widget appears/disappears
    _logHomeEvent("HOME SCREEN BUILD:");
    _logHomeEvent("  - inParking: $isInParking");
    _logHomeEvent("  - startTime: $parkingStartTime");

    if (isInParking && parkingStartTime == null) {
      _logHomeEvent("BUILD WARNING: Will use DateTime.now() as fallback for null startTime");
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: _shareHomeLogs,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.home, color: Colors.white, size: 20),
      ),
      body: CustomLayout(
        withPadding: true,
        patternOffset: const Offset(-100, -200),
        spacerHeight: 35,
        topPadding: 70,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        upperContent: UserHomeHeaderWidget(searchController: _searchController),
        backgroundPatternAssetPath: AppImages.homePattern,
        children: [
          30.gap,
          Row(
            children: [
              Flexible(flex: 1, child: MyPointsCardMinimal()),
              if (isInParking) ...[
                SizedBox(width: 16),
                Flexible(
                  flex: 1,
                  child: Builder(
                    builder: (context) {
                      final effectiveStartTime = parkingStartTime ?? DateTime.now();

                      if (parkingStartTime == null) {
                        _logHomeEvent("CREATING TIMER with NULL startTime - using DateTime.now()");
                        _logHomeEvent("Fallback time: $effectiveStartTime");
                      } else {
                        _logHomeEvent("CREATING TIMER with startTime: $effectiveStartTime");
                      }

                      return ParkingTimerCard(startTime: effectiveStartTime);
                    },
                  ),
                ),
              ],
            ],
          ),
          32.gap,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(LocaleKeys.most_popular.tr(), style: context.bodyMedium.bold.s16.copyWith(color: AppColors.primary)),
              Text(
                LocaleKeys.see_more.tr(),
                style: context.bodyMedium.regular.s14.copyWith(color: AppColors.primary.withValues(alpha: 0.5)),
              ).withPressEffect(
                onTap: () {
                  context.push(Routes.explore);
                },
              ),
            ],
          ),

          // // Option Selector for Testing (Remove in production)
          // 16.gap,
          // ScrollUXSelector(
          //   selectedOption: _selectedScrollOption,
          //   onOptionSelected: (option) {
          //     setState(() {
          //       _selectedScrollOption = option;
          //     });
          //   },
          // ),
          16.gap,
          BlocProvider.value(
            value: _exploreCubit,
            child: BlocBuilder<ExploreCubit, ExploreState>(
              builder:
                  (context, state) => ScrollOptionFactory.create(
                    option: _selectedScrollOption,
                    state: state,
                    onRefresh: _loadNearestParkings,
                  ),
            ),
          ),
          30.gap,
        ],
      ),
    );
  }
}
