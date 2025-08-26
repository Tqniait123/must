import 'dart:developer';
import 'dart:math' hide log;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/string_to_icon.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/core/utils/widgets/long_press_effect.dart';
import 'package:must_invest/features/explore/data/models/filter_model.dart';
import 'package:must_invest/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:must_invest/features/explore/presentation/widgets/ai_filter_widget.dart';
import 'package:must_invest/features/explore/presentation/widgets/ai_thinking_widget.dart';
import 'package:must_invest/features/explore/presentation/widgets/filter_option_widget.dart';
import 'package:must_invest/features/home/presentation/widgets/parking_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  SortBy _selectedSortBy = SortBy.mostPopular;
  late ExploreCubit _exploreCubit;
  Position? _currentPosition;
  bool _isGettingLocation = false;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _filters = [
    {'sortBy': SortBy.all, 'title': LocaleKeys.all.tr()},
    {'sortBy': SortBy.mostPopular, 'title': LocaleKeys.most_popular.tr()},
    {'sortBy': SortBy.mostWanted, 'title': LocaleKeys.most_wanted.tr()},
    {'sortBy': SortBy.nearest, 'title': LocaleKeys.nearst.tr()},
  ];

  @override
  void initState() {
    super.initState();
    _exploreCubit = ExploreCubit(sl());
    _loadInitialData();
  }

  void _loadInitialData() {
    // Start with most popular to avoid location permission on app start
    final initialFilter = FilterModel.mostPopular();
    _exploreCubit.getAllParkings(filter: initialFilter);
  }

  // Create filter with current search query
  FilterModel _createFilterWithSearch() {
    final baseFilter = _createCurrentFilter();

    // If there's a search query, add it to the filter
    if (_searchQuery.isNotEmpty) {
      return FilterModel(
        sortBy: baseFilter.sortBy,
        lat: baseFilter.lat,
        lng: baseFilter.lng,
        byUserCity: baseFilter.byUserCity,
        name: _searchQuery, // Add search query as name filter
      );
    }

    return baseFilter;
  }

  // Create filter based on current sort selection
  FilterModel _createCurrentFilter() {
    switch (_selectedSortBy) {
      case SortBy.all:
        return FilterModel.all();
      case SortBy.nearest:
        if (_currentPosition != null) {
          return FilterModel.nearest(lat: _currentPosition!.latitude, lng: _currentPosition!.longitude);
        } else {
          // Fallback to most popular if no location
          return FilterModel.mostPopular();
        }
      case SortBy.mostPopular:
        return FilterModel.mostPopular();
      case SortBy.mostWanted:
        return FilterModel.mostWanted();
    }
  }

  // Apply current filter and search with AI thinking simulation ONLY for nearest
  void _applyFilters() {
    final filter = _createFilterWithSearch();

    // Only show AI thinking effect and loading delay for nearest sorting
    if (_selectedSortBy == SortBy.nearest) {
      // Set loading state immediately for AI thinking effect (if not already set)
      if (_exploreCubit.state is! ParkingsLoading) {
        _exploreCubit.setLoadingState();
      }

      // Generate random delay between 5-10 seconds for nearest filter
      final random = Random();
      final delaySeconds = 5 + random.nextInt(6); // 5-10 seconds
      final delayMilliseconds = delaySeconds * 1000;

      // Add loading delay for nearest filter
      Future.delayed(Duration(milliseconds: delayMilliseconds), () {
        if (mounted) {
          _exploreCubit.getAllParkings(filter: filter);
        }
      });
    } else {
      // For other filters, apply immediately without loading delay
      _exploreCubit.getAllParkings(filter: filter);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        setState(() {
          _isGettingLocation = false;
          _selectedSortBy = SortBy.mostPopular;
        });
        _applyFilters();
        return;
      }

      // Remove the AI thinking delay from here since it's now handled in _applyFilters
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
        _isGettingLocation = false;
      });

      _applyFilters(); // This will handle the AI thinking delay
    } catch (e) {
      setState(() {
        log(e.toString());
        _isGettingLocation = false;
        _selectedSortBy = SortBy.mostPopular;
      });

      _showLocationDialog(LocaleKeys.failed_to_get_location.tr(args: [e.toString()]));
      _applyFilters();
    }
  }

  Future<bool> _checkLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDialog();
      return false;
    }

    // Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        _showPermissionDialog(
          title: LocaleKeys.location_permission_required.tr(),
          message: LocaleKeys.location_permission_denied_message.tr(),
          showSettings: false,
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission denied forever, show settings dialog
      _showPermissionDialog(
        title: LocaleKeys.location_permission_required.tr(),
        message: LocaleKeys.location_permission_permanently_denied_message.tr(),
        showSettings: true,
      );
      return false;
    }

    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.location_services_disabled.tr()),
            content: Text(LocaleKeys.location_services_disabled_message.tr()),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(LocaleKeys.cancel.tr())),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Geolocator.openLocationSettings();
                },
                child: Text(LocaleKeys.open_settings.tr()),
              ),
            ],
          ),
    );
  }

  void _showPermissionDialog({required String title, required String message, required bool showSettings}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(LocaleKeys.cancel.tr())),
              if (showSettings)
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _openAppSettings();
                  },
                  child: Text(LocaleKeys.open_settings.tr()),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _getCurrentLocation(); // Try again
                  },
                  child: Text(LocaleKeys.try_again.tr()),
                ),
            ],
          ),
    );
  }

  Future<void> _openAppSettings() async {
    final opened = await openAppSettings();
    if (!opened) {
      // Fallback to Geolocator's app settings
      await Geolocator.openAppSettings();
    }
  }

  void _showLocationDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.location_error.tr()),
            content: Text(message),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(LocaleKeys.ok.tr()))],
          ),
    );
  }

  void _onFilterChanged(SortBy newSortBy) {
    setState(() {
      _selectedSortBy = newSortBy;
    });

    // Show AI thinking immediately for nearest
    if (newSortBy == SortBy.nearest) {
      _exploreCubit.setLoadingState(); // Set loading state immediately
      _getCurrentLocation();
    } else {
      _applyFilters();
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();
    });

    // Apply filters with new search query
    _applyFilters();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _exploreCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(Routes.maps);
        },
        backgroundColor: AppColors.primary,
        child: Icon(Icons.my_location_rounded, color: AppColors.white),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              10.gap,
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBackButton(),
                  Text(LocaleKeys.explore.tr(), style: context.titleLarge.copyWith()),
                  NotificationsButton(color: Color(0xffEAEAF3), iconColor: AppColors.primary),
                ],
              ),
              20.gap,

              // Search Field
              CustomTextFormField(
                controller: _searchController,
                backgroundColor: Color(0xffEAEAF3),
                hintColor: AppColors.primary.withValues(alpha: 0.4),
                isBordered: false,
                margin: 0,
                prefixIC: AppIcons.searchIc.icon(color: AppColors.primary.withValues(alpha: 0.4)),
                suffixIC:
                    _searchQuery.isNotEmpty
                        ? GestureDetector(
                          onTap: _clearSearch,
                          child: Icon(Icons.clear, color: AppColors.primary.withValues(alpha: 0.6)),
                        )
                        : null,
                hint: LocaleKeys.search.tr(),
                waitTyping: true,
                onChanged: _onSearchChanged,
              ),
              20.gap,

              // Filter Options
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  clipBehavior: Clip.none,
                  separatorBuilder: (context, index) => 10.gap,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isNearest = filter['sortBy'] == SortBy.nearest;
                    final isSelected = _selectedSortBy == filter['sortBy'];
                    final isAIThinking = isNearest && isSelected && _isGettingLocation;

                    return isNearest
                        ? AIFilterOptionWidget(
                          title: filter['title'],
                          id: filter['sortBy'].index,
                          isSelected: isSelected,
                          isAIThinking: isAIThinking,
                          onTap: () {
                            _onFilterChanged(filter['sortBy']);
                          },
                        )
                        : FilterOptionWidget(
                          title: filter['title'],
                          id: filter['sortBy'].index,
                          isSelected: isSelected,
                        ).withPressEffect(
                          onTap: () {
                            _onFilterChanged(filter['sortBy']);
                          },
                        );
                  },
                ),
              ),

              // Search indicator when searching
              if (_searchQuery.isNotEmpty) ...[
                10.gap,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, size: 16, color: AppColors.primary),
                      4.gap,
                      Text(
                        LocaleKeys.searching_for.tr(args: [_searchQuery]),
                        style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],

              // Main Content with AI Thinking Animation ONLY for nearest
              Expanded(
                child: BlocProvider.value(
                  value: _exploreCubit,
                  child: BlocBuilder<ExploreCubit, ExploreState>(
                    builder: (BuildContext context, ExploreState state) {
                      if (state is ParkingsLoading) {
                        // Use AI Thinking Widget ONLY when nearest is selected
                        if (_selectedSortBy == SortBy.nearest) {
                          return AIThinkingWidget(
                            searchQuery: _searchQuery,
                            isNearestSelected: true,
                            // items: Parking.getFakeHistoryParkings().map((x) => x.nameEn).toList(),
                          );
                        } else {
                          // Use regular loading indicator for other filters
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          );
                        }
                      } else if (state is ParkingsSuccess) {
                        if (state.parkings.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
                                16.gap,
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? LocaleKeys.no_parking_found_for.tr(args: [_searchQuery])
                                      : LocaleKeys.no_parking_available.tr(),
                                  style: context.bodyLarge.copyWith(color: AppColors.primary.withValues(alpha: 0.6)),
                                  textAlign: TextAlign.center,
                                ),
                                if (_searchQuery.isNotEmpty) ...[
                                  8.gap,
                                  TextButton(onPressed: _clearSearch, child: Text(LocaleKeys.clear_search.tr())),
                                ],
                              ],
                            ),
                          );
                        }

                        // Add smooth transition only after AI thinking completes (for nearest)
                        // or show results immediately for other filters
                        Widget resultsList = ListView.separated(
                          key: ValueKey('parking_list'),
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: false,
                          padding: EdgeInsets.zero,
                          itemCount: state.parkings.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return ParkingCard(parking: state.parkings[index]);
                          },
                        );

                        // Only add smooth transition animation for nearest filter
                        if (_selectedSortBy == SortBy.nearest) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 800),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.3),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                                  child: child,
                                ),
                              );
                            },
                            child: resultsList,
                          );
                        } else {
                          // Show results immediately for other filters
                          return resultsList;
                        }
                      } else if (state is ParkingsError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 64, color: Colors.red.withValues(alpha: 0.3)),
                              16.gap,
                              Text(
                                LocaleKeys.error_loading_parkings.tr(),
                                style: context.bodyLarge.copyWith(color: Colors.red.withValues(alpha: 0.6)),
                              ),
                              8.gap,
                              TextButton(onPressed: _applyFilters, child: Text(LocaleKeys.retry.tr())),
                            ],
                          ),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ).paddingHorizontal(20),
      ),
    );
  }
}
