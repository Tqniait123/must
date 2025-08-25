import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/features/offers/data/models/offer_model.dart';
import 'package:must_invest/features/offers/presentation/cubit/offers_cubit.dart';
import 'package:must_invest/features/offers/presentation/widgets/offer_widget.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final TextEditingController _searchController = TextEditingController();
  late OffersCubit _offersCubit;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _offersCubit = OffersCubit(sl());
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load all offers without any filters
    _offersCubit.getAllOffers();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();
    });

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final filter = OfferFilterModel.withName(_searchQuery);
      _offersCubit.getAllOffers(filter: filter, isFirstTime: false);
    } else {
      _offersCubit.getAllOffers(isFirstTime: false);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _offersCubit.getAllOffers(isFirstTime: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _offersCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Text(LocaleKeys.offers.tr(), style: context.titleLarge.copyWith()),
                  NotificationsButton(color: Color(0xffEAEAF3), iconColor: AppColors.primary),
                ],
              ),
              20.gap,

              // // Search Field
              // CustomTextFormField(
              //   controller: _searchController,
              //   backgroundColor: Color(0xffEAEAF3),
              //   hintColor: AppColors.primary.withValues(alpha: 0.4),
              //   isBordered: false,
              //   margin: 0,
              //   prefixIC: AppIcons.searchIc.icon(color: AppColors.primary.withValues(alpha: 0.4)),
              //   suffixIC: _searchQuery.isNotEmpty
              //       ? GestureDetector(
              //           onTap: _clearSearch,
              //           child: Icon(Icons.clear, color: AppColors.primary.withValues(alpha: 0.6)),
              //         )
              //       : null,
              //   hint: LocaleKeys.search_offers.tr(),
              //   waitTyping: true,
              //   onChanged: _onSearchChanged,
              // ),
              // 20.gap,

              // Search indicator when searching
              if (_searchQuery.isNotEmpty) ...[
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
                        LocaleKeys.searching_for_offers.tr(args: [_searchQuery]),
                        style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                20.gap,
              ],

              // Main Content
              Expanded(
                child: BlocProvider.value(
                  value: _offersCubit,
                  child: BlocBuilder<OffersCubit, OffersState>(
                    builder: (BuildContext context, OffersState state) {
                      if (state is OffersLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        );
                      } else if (state is OffersSuccess) {
                        if (state.offers.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_offer_outlined,
                                  size: 64,
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                ),
                                16.gap,
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? LocaleKeys.no_offers_found_for.tr(args: [_searchQuery])
                                      : LocaleKeys.no_offers_available.tr(),
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
                          itemCount: state.offers.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return OfferWidget(offer: state.offers[index]);
                          },
                        );
                      } else if (state is OffersError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 64, color: Colors.red.withValues(alpha: 0.3)),
                              16.gap,
                              Text(
                                LocaleKeys.error_loading_offers.tr(),
                                style: context.bodyLarge.copyWith(color: Colors.red.withValues(alpha: 0.6)),
                              ),
                              8.gap,
                              TextButton(onPressed: _loadInitialData, child: Text(LocaleKeys.retry.tr())),
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
