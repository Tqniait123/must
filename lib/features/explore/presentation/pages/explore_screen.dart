import 'dart:developer';

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
import 'package:must_invest/core/utils/widgets/loading/loading_widget.dart';
import 'package:must_invest/features/explore/data/models/filter_model.dart';
import 'package:must_invest/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:must_invest/features/explore/presentation/widgets/filter_option_widget.dart';
import 'package:must_invest/features/home/presentation/widgets/parking_widget.dart';

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
    {'sortBy': SortBy.mostPopular, 'title': LocaleKeys.most_popular.tr()},
    {'sortBy': SortBy.mostWanted, 'title': LocaleKeys.most_wanted.tr()},
    {'sortBy': SortBy.nearest, 'title': LocaleKeys.nearst.tr  ()},
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

  // Apply current filter and search
  void _applyFilters() {
    final filter = _createFilterWithSearch();
    _exploreCubit.getAllParkings(filter: filter);
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationDialog(LocaleKeys.location_services_disabled.tr());
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationDialog(LocaleKeys.location_permissions_denied.tr());
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationDialog(LocaleKeys.location_permissions_permanently_denied.tr());
      return false;
    }

    return true;
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
          // Fallback to most popular if location fails
          _selectedSortBy = SortBy.mostPopular;
        });
        _applyFilters();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
        _isGettingLocation = false;
      });

      // Apply filters with new location
      _applyFilters();
    } catch (e) {
      setState(() {
        log(e.toString());
        _isGettingLocation = false;
        // Fallback to most popular if location fails
        _selectedSortBy = SortBy.mostPopular;
      });

      _showLocationDialog(LocaleKeys.failed_to_get_location.tr(args: [e.toString()]));
      _applyFilters();
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

    if (newSortBy == SortBy.nearest) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBackButton(),
                  Text(LocaleKeys.explore.tr(), style: context.titleLarge.copyWith()),
                  NotificationsButton(color: Color(0xffEAEAF3), iconColor: AppColors.primary),
                ],
              ),
              40.gap,
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
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (context, index) => 10.gap,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isNearest = filter['sortBy'] == SortBy.nearest;
                    final isSelected = _selectedSortBy == filter['sortBy'];

                    return GestureDetector(
                      onTap: () {
                        _onFilterChanged(filter['sortBy']);
                      },
                      child: Stack(
                        children: [
                          FilterOptionWidget(
                            title: filter['title'],
                            id: filter['sortBy'].index,
                            isSelected: isSelected,
                          ),
                          if (isNearest && isSelected && _isGettingLocation)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Show search indicator when searching
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
              Expanded(
                child: BlocProvider.value(
                  value: _exploreCubit,
                  child: BlocBuilder<ExploreCubit, ExploreState>(
                    builder: (BuildContext context, ExploreState state) {
                      if (state is ParkingsLoading) {
                        return LoadingWidget();
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

                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: false,
                          padding: EdgeInsets.zero,
                          itemCount: state.parkings.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return ParkingCard(parking: state.parkings[index]);
                          },
                        );
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
