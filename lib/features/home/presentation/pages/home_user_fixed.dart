import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/app_router.dart';
import 'package:must_invest/config/routes/routes.dart';
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
import 'package:must_invest/core/widgets/empty_error_states.dart';
import 'package:must_invest/core/widgets/shimmer_card.dart';
import 'package:must_invest/features/explore/data/models/filter_model.dart';
import 'package:must_invest/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:must_invest/features/home/presentation/widgets/home_user_header_widget.dart';
import 'package:must_invest/features/home/presentation/widgets/my_points_card.dart';
import 'package:must_invest/features/home/presentation/widgets/parking_widget.dart';
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

  // For scroll control
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    _loadNearestParkings(isFirstTime: false);
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

    _loadHomeLogs();
    _checkParkingStatus();
    _loadNearestParkings(isFirstTime: true);
    _startParkingStatusMonitoring();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _logHomeEvent("HOME SCREEN DISPOSING");
    _saveHomeLogs();
    WidgetsBinding.instance.removeObserver(this);
    _parkingCheckTimer?.cancel();
    _scrollController.dispose();
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
    bool isInParking = false;
    DateTime? parkingStartTime;

    // Check if user is logged in before accessing user
    if (context.isLoggedIn) {
      final user = context.user;
      isInParking = user.inParking ?? false;
      parkingStartTime = user.inParkingFrom;
    } else {
      _logHomeEvent("CHECK PARKING: User is not logged in, skipping user-specific checks");
    }

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

        if (_lastLoggedStartTime != null && _lastLoggedStartTime != parkingStartTime) {
          _logHomeEvent("WARNING: Parking start time changed!");
          _logHomeEvent("  - Previous: $_lastLoggedStartTime");
          _logHomeEvent("  - Current: $parkingStartTime");
          _logHomeEvent("  - This could cause timer reset!");
        }

        _lastLoggedStartTime = parkingStartTime;

        if (timeDiff.inMinutes < 1 && _homeLogs.any((log) => log.contains("Time since parking started:"))) {
          _logHomeEvent("SUSPICIOUS: Start time is very recent, possible reset!");
        }
      }
    } else {
      _logHomeEvent("User is not in parking - timer should not be displayed");
    }

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
      ];

      // Only include user-specific info if logged in
      if (context.isLoggedIn) {
        final user = context.user;
        deviceInfo.add("User in parking: ${user.inParking ?? false}");
        deviceInfo.add("Parking start time: ${user.inParkingFrom}");
      } else {
        deviceInfo.add("User in parking: Not logged in");
        deviceInfo.add("Parking start time: Not logged in");
      }
      deviceInfo.add("=== HOME LOGS ===");

      final allLogs = [...deviceInfo, ..._homeLogs];
      final logContent = allLogs.join('\n');

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

  // Build compact cards for collapsed state
  Widget _buildCompactCards({required bool isInParking, required DateTime? parkingStartTime}) {
    if (!context.isLoggedIn) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Row(
        children: [
          // Compact Points Card
          Expanded(
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2, offset: const Offset(0, 1)),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.stars, color: AppColors.primary, size: 14),
                  6.gap,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Points",
                          style: context.bodySmall.copyWith(fontSize: 9, color: AppColors.primary.withOpacity(0.6)),
                        ),
                        Text(
                          context.isLoggedIn ? context.user.points.toString() : "0",
                          style: context.bodyMedium.bold.copyWith(fontSize: 11, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isInParking) ...[
            8.gap,
            // Compact Timer Card
            Expanded(
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 2, offset: const Offset(0, 1)),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: AppColors.white, size: 14),
                    6.gap,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Parking",
                            style: context.bodySmall.copyWith(fontSize: 9, color: AppColors.white.withOpacity(0.8)),
                          ),
                          StreamBuilder<DateTime>(
                            stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                            builder: (context, snapshot) {
                              final now = snapshot.data ?? DateTime.now();
                              final effectiveStartTime = parkingStartTime ?? now;
                              final duration = now.difference(effectiveStartTime);
                              return Text(
                                _formatDuration(duration),
                                style: context.bodyMedium.bold.copyWith(fontSize: 11, color: AppColors.white),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Build "Most Popular" section
  Widget _buildMostPopularSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.primary.withOpacity(0.1), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            LocaleKeys.most_popular.tr(),
            style: context.bodyMedium.bold.s16.copyWith(color: AppColors.primary),
          ),
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
    );
  }

  // Build expanded cards for initial view
  Widget _buildExpandedCards({required bool isInParking, required DateTime? parkingStartTime}) {
    if (!context.isLoggedIn) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Fix: Prevent stretching
        children: [
          // Points Card - Fixed height
          Expanded(
            child: SizedBox(
              height: 150, // Fixed height to prevent stretching
              child: MyPointsCardMinimal(),
            ),
          ),
          if (isInParking) ...[
            const SizedBox(width: 16),
            // Timer Card - Fixed height
            Expanded(
              child: SizedBox(
                height: 150, // Fixed height to match points card
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
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isInParking = false;
    DateTime? parkingStartTime;

    // Check if user is logged in before accessing user
    if (context.isLoggedIn) {
      final user = context.user;
      isInParking = user.inParking ?? false;
      parkingStartTime = user.inParkingFrom;
    } else {
      _logHomeEvent("BUILD: User is not logged in, skipping user-specific data");
    }

    _logHomeEvent("HOME SCREEN BUILD:");
    _logHomeEvent("  - inParking: $isInParking");
    _logHomeEvent("  - startTime: $parkingStartTime");

    if (isInParking && parkingStartTime == null) {
      _logHomeEvent("BUILD WARNING: Will use DateTime.now() as fallback for null startTime");
    }

    return Scaffold(
      body: CustomLayout(
        withPadding: true,
        patternOffset: const Offset(-100, -200),
        spacerHeight: 35,
        topPadding: 70,
        contentPadding: EdgeInsets.zero,
        scrollType: ScrollType.nonScrollable,
        upperContent: UserHomeHeaderWidget(searchController: _searchController),
        backgroundPatternAssetPath: AppImages.homePattern,
        children: [
          Expanded(
            child: BlocProvider.value(
              value: _exploreCubit,
              child: BlocBuilder<ExploreCubit, ExploreState>(
                builder: (context, state) {
                  return CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // SliverAppBar with flexible space
                      SliverAppBar(
                        backgroundColor: AppColors.white,
                        elevation: 0,
                        expandedHeight: context.isLoggedIn ? 200 : 60,
                        collapsedHeight: context.isLoggedIn ? 100 : 60,
                        pinned: true,
                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            final currentHeight = constraints.biggest.height;
                            final expandedHeight = context.isLoggedIn ? 200.0 : 60.0;
                            final collapsedHeight = context.isLoggedIn ? 100.0 : 60.0;
                            
                            // Calculate collapse ratio
                            final collapseRatio = ((expandedHeight - currentHeight) / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);
                            final isCollapsed = collapseRatio > 0.6;

                            return FlexibleSpaceBar(
                              collapseMode: CollapseMode.pin,
                              background: Container(
                                color: AppColors.white,
                                padding: const EdgeInsets.only(top: 30, bottom: 16),
                                child: context.isLoggedIn
                                    ? _buildExpandedCards(
                                        isInParking: isInParking,
                                        parkingStartTime: parkingStartTime,
                                      )
                                    : null,
                              ),
                              // Show collapsed content at the bottom when collapsed
                              title: isCollapsed && context.isLoggedIn
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildCompactCards(
                                          isInParking: isInParking,
                                          parkingStartTime: parkingStartTime,
                                        ),
                                        _buildMostPopularSection(),
                                      ],
                                    )
                                  : !context.isLoggedIn
                                      ? _buildMostPopularSection()
                                      : null,
                              titlePadding: EdgeInsets.zero,
                              centerTitle: false,
                            );
                          },
                        ),
                      ),
                      
                      // Show "Most Popular" section when expanded (for logged in users)
                      if (context.isLoggedIn)
                        SliverToBoxAdapter(
                          child: _buildMostPopularSection(),
                        ),
                      
                      // Show "Most Popular" section for non-logged-in users
                      if (!context.isLoggedIn)
                        const SliverToBoxAdapter(child: SizedBox.shrink()),

                      // Parking list
                      _buildParkingList(state),

                      // Bottom spacing
                      SliverToBoxAdapter(child: 30.gap),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingList(ExploreState state) {
    if (state is ParkingsLoading) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          // Fix Issue 1: Replace ListView with Column to avoid nested scrolling
          child: Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index == 2 ? 0 : 16),
                child: const ShimmerCard(),
              ),
            ),
          ),
        ),
      );
    }

    if (state is! ParkingsSuccess || (state).parkings.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: EmptyStateWidget()),
      );
    }

    final parkings = (state).parkings;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: EdgeInsets.only(left: 24, right: 24, bottom: index == parkings.length - 1 ? 0 : 16),
            child: ParkingCard(parking: parkings[index]),
          );
        },
        childCount: parkings.length,
      ),
    );
  }
}
