import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/is_logged_in.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/string_to_icon.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/core/utils/widgets/long_press_effect.dart';
import 'package:must_invest/features/explore/data/models/parking.dart';
import 'package:must_invest/features/explore/presentation/widgets/custom_clipper.dart';

class ParkingDetailsScreen extends StatefulWidget {
  final Parking parking;
  const ParkingDetailsScreen({super.key, required this.parking});

  @override
  State<ParkingDetailsScreen> createState() => _ParkingDetailsScreenState();
}

class _ParkingDetailsScreenState extends State<ParkingDetailsScreen> {
  String _currentMainImage = '';
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.parking.gallery.gallery.isNotEmpty) {
      _currentMainImage = widget.parking.gallery.gallery.first.image;
    } else {
      _currentMainImage = ''; // Set default empty state
    }
  }

  Future<void> _selectImageFromParkingGallery(String image, int index) async {
    setState(() {
      _currentMainImage = image;
      _currentImageIndex = index;
    });
  }

  void _showImageGallery() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => FullScreenGallery(
              images: widget.parking.gallery.gallery.map((e) => e.image).toList(),
              initialIndex: _currentImageIndex,
            ),
      ),
    );
  }

  String get _parkingName {
    return context.locale.languageCode == 'ar' ? widget.parking.nameAr : widget.parking.nameEn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBackButton(),
                  Text(LocaleKeys.details.tr(), style: context.titleLarge.copyWith()),
                  NotificationsButton(color: Color(0xffEAEAF3), iconColor: AppColors.primary),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    22.gap,

                    // Main Image with Gallery Button
                    if (widget.parking.gallery.gallery.isNotEmpty) ...[
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            switchInCurve: Curves.easeInOut,
                            switchOutCurve: Curves.easeInOut,
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(
                                    begin: 0.95,
                                    end: 1.0,
                                  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                                  child: child,
                                ),
                              );
                            },
                            child: GestureDetector(
                              onTap: _showImageGallery,
                              child: Hero(
                                key: ValueKey<String>(_currentMainImage),
                                tag: '${widget.parking.id}-${widget.parking.mainImage}',
                                child: ClipPath(
                                  clipper: CurveCustomClipper(),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 250,
                                    child: Stack(
                                      children: [
                                        Image.network(
                                          _currentMainImage,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 250,
                                        ),
                                        // Gallery indicator
                                        Positioned(
                                          top: 16,
                                          right: 16,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.photo_library, color: Colors.white, size: 16),
                                                SizedBox(width: 4),
                                                Text(
                                                  '${_currentImageIndex + 1}/${widget.parking.gallery.gallery.length}',
                                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -20,
                            child: FloatingActionButton(
                              onPressed: () {
                                context.checkVerifiedAndGuestOrDo(
                                  () => context.push(Routes.routing, extra: widget.parking),
                                );
                              },
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.my_location_rounded, color: AppColors.white),
                            ),
                          ),
                        ],
                      ),

                      30.gap,

                      // Thumbnail Gallery
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.parking.gallery.gallery.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final image = widget.parking.gallery.gallery[index].image;
                              final isSelected = _currentMainImage == image;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: AnimatedOpacity(
                                    opacity: isSelected ? 1 : 0.7,
                                    duration: const Duration(milliseconds: 300),
                                    child: Image.network(image, width: 129, height: 80, fit: BoxFit.cover),
                                  ),
                                ).withPressEffect(onTap: () => _selectImageFromParkingGallery(image, index)),
                              );
                            },
                          ),
                        ),
                      ),

                      30.gap,
                    ],

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Parking Name & Tags
                          Row(
                            children: [
                              Expanded(child: Text(_parkingName, style: context.titleLarge.copyWith())),
                              // Tags
                              Row(
                                children: [
                                  if (widget.parking.mostPopular)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      margin: EdgeInsets.only(left: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.star_rounded, color: AppColors.primary, size: 12),
                                          SizedBox(width: 2),
                                          Text(
                                            LocaleKeys.mostPopular.tr(),
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (widget.parking.mostWanted)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      margin: EdgeInsets.only(left: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.local_fire_department_rounded, color: AppColors.primary, size: 12),
                                          SizedBox(width: 2),
                                          Text(
                                            LocaleKeys.mostWanted.tr(),
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),

                          10.gap,

                          // Address
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: AppColors.primary.withValues(alpha: 0.7),
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.parking.address,
                                  style: context.bodyMedium.s12.regular.copyWith(
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          20.gap,

                          // Parking Details Grid
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LocaleKeys.parkingDetails.tr(),
                                  style: context.titleMedium.copyWith(fontWeight: FontWeight.w600),
                                ),
                                16.gap,

                                // Available Details Row
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    // Price
                                    CustomDetailsInfo(
                                      title: '${widget.parking.pricePerHour} ${LocaleKeys.pointsPerHour.tr()}',
                                      icon: AppIcons.outlinedPriceIc,
                                      iconColor: Colors.amber[900],
                                    ),

                                    // Rating
                                    CustomDetailsInfo(
                                      title: '${widget.parking.userVisits} ${LocaleKeys.visitsByYou.tr()}',
                                      icon: AppIcons.outlinedClockIc,
                                      fullWidth: false,
                                      iconColor: Colors.blue[800],
                                    ),
                                  ],
                                ),

                                12.gap,

                                // User Visits
                              ],
                            ),
                          ),

                          // // Missing Data Notice
                          // 20.gap,
                          // Container(
                          //   padding: EdgeInsets.all(12),
                          //   decoration: BoxDecoration(
                          //     color: AppColors.primary.withOpacity(0.1),
                          //     borderRadius: BorderRadius.circular(12),
                          //     border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          //   ),
                          //   child: Row(
                          //     children: [
                          //       Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                          //       SizedBox(width: 8),
                          //       Expanded(
                          //         child: Text(
                          //           LocaleKeys.distanceTimeNotAvailable.tr(),
                          //           style: TextStyle(
                          //             color: AppColors.primary,
                          //             fontSize: 12,
                          //             fontWeight: FontWeight.w500,
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          20.gap,

                          // Description
                          if (widget.parking.aboutParking != null) ...[
                            Text(
                              LocaleKeys.aboutThisParking.tr(),
                              style: context.titleMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                            8.gap,
                            Text(
                              widget.parking.aboutParking!,
                              style: context.bodyMedium.s14.regular.copyWith(
                                color: AppColors.black.withValues(alpha: 0.7),
                                height: 1.5,
                              ),
                            ),
                            20.gap,
                          ],
                        ],
                      ),
                    ),

                    30.gap, // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenGallery({super.key, required this.images, required this.initialIndex});

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image Gallery
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Hero(
                    tag: 'gallery-${widget.images[index]}',
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              );
            },
          ),

          // Top Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                  ),

                  // Image Counter
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '${_currentIndex + 1} ${LocaleKeys.of.tr()} ${widget.images.length}',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Thumbnail Bar
          if (widget.images.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: widget.images.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentIndex;

                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AnimatedOpacity(
                            opacity: isSelected ? 1.0 : 0.6,
                            duration: Duration(milliseconds: 300),
                            child: Image.network(widget.images[index], width: 60, height: 80, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomDetailsInfo extends StatelessWidget {
  final String title;
  final String? icon;
  final bool fullWidth;
  final Color? iconColor;

  const CustomDetailsInfo({super.key, required this.title, this.icon, this.fullWidth = false, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      // constraints: fullWidth ? null : const BoxConstraints(minWidth: 100, maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyAF.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!.icon(color: iconColor ?? AppColors.primary, height: 16),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.grey81),
            ),
          ),
        ],
      ),
    );
  }
}
