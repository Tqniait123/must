import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/app_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/is_logged_in.dart';
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
import 'package:must_invest/features/home/presentation/widgets/unified_parking_timer_card.dart';
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
  bool isCollapsed = false;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollHint = true;

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

    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final threshold = 100.0;
      final shouldShow = (maxScroll - currentScroll) > threshold;

      if (_showScrollHint != shouldShow) {
        setState(() {
          _showScrollHint = shouldShow;
        });
      }
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _logHomeEvent("HOME SCREEN DISPOSING");
    _saveHomeLogs();
    WidgetsBinding.instance.removeObserver(this);
    _parkingCheckTimer?.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _exploreCubit.close();
    _searchController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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

  @override
  Widget build(BuildContext context) {
    bool isInParking = false;
    DateTime? parkingStartTime;

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
        upperContent: UserHomeHeaderWidget(
          searchController: _searchController,
          onSearchChanged: (query) {
            _exploreCubit.getAllParkings(filter: FilterModel.withName(query));
          },
        ),
        backgroundPatternAssetPath: AppImages.homePattern,
        children: [
          Expanded(
            child: BlocProvider.value(
              value: _exploreCubit,
              child: BlocBuilder<ExploreCubit, ExploreState>(
                builder: (context, state) {
                  return Stack(
                    children: [
                      NestedScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        headerSliverBuilder:
                            (context, innerBoxIsScrolled) => [
                              SliverPersistentHeader(
                                pinned: true,
                                delegate: AdaptiveHeaderDelegate(
                                  minExtentValue:
                                      (!context.isLoggedIn)
                                          ? MediaQuery.of(context).size.height * 0.10
                                          : MediaQuery.of(context).size.height * 0.20,
                                  maxExtentValue:
                                      !context.isLoggedIn
                                          ? MediaQuery.of(context).size.height * 0.10
                                          : MediaQuery.of(context).size.height * 0.30,
                                  builder:
                                      (context, isExpanded) =>
                                          _buildHeader(context, isInParking, parkingStartTime, isExpanded: isExpanded),
                                ),
                              ),
                            ],
                        body: _buildParkingListWidget(state),
                      ),
                      _buildAnimatedScrollHint(state),
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

  Widget _buildAnimatedScrollHint(ExploreState state) {
    if (state is! ParkingsSuccess || state.parkings.isEmpty || state.parkings.length <= 2) {
      return const SizedBox.shrink();
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: _showScrollHint ? 40 : -60,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _showScrollHint ? 1.0 : 0.0,
        child: GestureDetector(
          onTap:
              () => _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
          child: const Center(child: AnimatedScrollHint()),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isInParking, DateTime? parkingStartTime, {required bool isExpanded}) {
    return Column(
      children: [
        if (context.isLoggedIn)
          Container(
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            padding: EdgeInsets.only(top: 30.h, bottom: 16.h),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: MyPointsCardMinimal(isCollapsed: !isExpanded, withAspectRatio: isInParking),
                    ),
                    if (isInParking) ...[
                      SizedBox(width: 16.w),
                      Expanded(
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
                            return UnifiedParkingTimerCard(startTime: effectiveStartTime, isCollapsed: !isExpanded);
                          },
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        MostPopularRowSection(context: context),
      ],
    );
  }

  Widget _buildParkingListWidget(ExploreState state) {
    if (state is ParkingsLoading) {
      return ShimmerLoadingWidget(isSliver: false);
    }

    if (state is! ParkingsSuccess || state.parkings.isEmpty) {
      return Padding(padding: EdgeInsets.symmetric(horizontal: 24.w), child: const EmptyStateWidget());
    }

    final parkings = state.parkings;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: parkings.length + 1,
      itemBuilder: (context, index) {
        if (index == parkings.length) {
          return SizedBox(height: 30.h);
        }
        return Padding(
          padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 16.h),
          child: ParkingCard(parking: parkings[index]),
        );
      },
    );
  }
}

class MostPopularRowSection extends StatelessWidget {
  const MostPopularRowSection({super.key, required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.primary.withOpacity(0.1), width: 1)),
      ),
      child: Row(
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
    );
  }
}

class AnimatedScrollHint extends StatefulWidget {
  const AnimatedScrollHint({super.key});

  @override
  State<AnimatedScrollHint> createState() => _AnimatedScrollHintState();
}

class _AnimatedScrollHintState extends State<AnimatedScrollHint> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _pulseController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOutSine));
    _pulseAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _bounceController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 12.r,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 1.r,
                  spreadRadius: 0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: _pulseAnimation.value * 0.25),
                        AppColors.primary.withValues(alpha: _pulseAnimation.value * 0.15),
                        AppColors.primary.withValues(alpha: _pulseAnimation.value * 0.08),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: _pulseAnimation.value * 0.4),
                      width: 0.8,
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 1.0],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShaderMask(
                          shaderCallback:
                              (bounds) => LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.9),
                                  AppColors.primary.withValues(alpha: 0.7),
                                ],
                              ).createShader(bounds),
                          child: Icon(Icons.keyboard_double_arrow_down, color: Colors.white, size: 18.r),
                        ),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

class AdaptiveHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minExtentValue;
  final double maxExtentValue;
  final Widget Function(BuildContext context, bool isExpanded) builder;

  AdaptiveHeaderDelegate({required this.minExtentValue, required this.maxExtentValue, required this.builder});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final percentage = shrinkOffset / (maxExtent - minExtent);
    final isExpanded = percentage < 0.7;
    return builder(context, isExpanded);
  }

  @override
  double get maxExtent => maxExtentValue;

  @override
  double get minExtent => minExtentValue;

  @override
  bool shouldRebuild(covariant AdaptiveHeaderDelegate oldDelegate) => true;
}
