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

  final List<Map<String, dynamic>> _filters = [
    {'sortBy': SortBy.nearest, 'title': LocaleKeys.nearst.tr()},
    {'sortBy': SortBy.mostPopular, 'title': LocaleKeys.most_popular.tr()},
    {'sortBy': SortBy.mostWanted, 'title': LocaleKeys.most_wanted.tr()},
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

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationDialog('Location services are disabled. Please enable location services.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationDialog('Location permissions are denied. Please grant location access.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationDialog('Location permissions are permanently denied. Please enable them in settings.');
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
        _exploreCubit.getAllParkings(filter: FilterModel.mostPopular());
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

      // Create filter with actual user location
      final filter = FilterModel.nearest(lat: position.latitude, lng: position.longitude);

      _exploreCubit.getAllParkings(filter: filter);
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
        // Fallback to most popular if location fails
        _selectedSortBy = SortBy.mostPopular;
      });

      _showLocationDialog('Failed to get location: ${e.toString()}');
      _exploreCubit.getAllParkings(filter: FilterModel.mostPopular());
    }
  }

  void _showLocationDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Location Error'),
            content: Text(message),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('OK'))],
          ),
    );
  }

  void _onFilterChanged(SortBy newSortBy) {
    setState(() {
      _selectedSortBy = newSortBy;
    });

    switch (newSortBy) {
      case SortBy.nearest:
        _getCurrentLocation();
        break;
      case SortBy.mostPopular:
        _exploreCubit.getAllParkings(filter: FilterModel.mostPopular());
        break;
      case SortBy.mostWanted:
        _exploreCubit.getAllParkings(filter: FilterModel.mostWanted());
        break;
    }
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
                hint: LocaleKeys.search.tr(),
                onChanged: (value) {
                  // TODO: Implement search functionality
                  // You can add debouncing here and call the API with search term
                },
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
              Expanded(
                child: BlocProvider.value(
                  value: _exploreCubit,
                  child: BlocBuilder<ExploreCubit, ExploreState>(
                    builder: (BuildContext context, ExploreState state) {
                      if (state is ParkingsLoading) {
                        return LoadingWidget();
                      } else if (state is ParkingsSuccess) {
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
