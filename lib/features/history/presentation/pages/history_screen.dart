import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/string_to_icon.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/features/history/data/models/history_model.dart';
import 'package:must_invest/features/history/presentation/cubit/history_cubit.dart';
import 'package:must_invest/features/history/presentation/cubit/history_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final TextEditingController _searchController;
  late final HistoryCubit _historyCubit;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _historyCubit = HistoryCubit.get(context);

    // Load history data when screen initializes
    _historyCubit.getAllHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xffF4F4FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            39.gap,
            _buildSearchAndFilter(),
            16.gap,
            Expanded(
              child: BlocBuilder<HistoryCubit, HistoryState>(
                builder: (context, state) {
                  return _buildBody(state);
                },
              ),
            ),
          ],
        ).paddingHorizontal(24),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomBackButton(),
        Text(LocaleKeys.history.tr(), style: context.titleLarge.copyWith()),
        NotificationsButton(color: Color(0xffEAEAF3), iconColor: AppColors.primary),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: CustomTextFormField(
            hint: LocaleKeys.search.tr(),
            margin: 0,
            isBordered: false,
            backgroundColor: Color(0xffEAEAF3),
            prefixIC: AppIcons.searchIc.icon(color: AppColors.primary),
            hintColor: AppColors.primary.withValues(alpha: 0.4),
            controller: _searchController,
            onChanged: (value) {
              // TODO: Implement search functionality
              // You might want to add a search method to your cubit
            },
          ),
        ),
        7.gap,
        CustomIconButton(
          height: 50,
          width: 50,
          iconAsset: AppIcons.filterIc,
          color: Color(0xffEAEAF3),
          iconColor: AppColors.primary,
          onPressed: () {
            // TODO: Implement filter functionality
          },
        ),
      ],
    );
  }

  Widget _buildBody(HistoryState state) {
    if (state is HistoryLoading) {
      return _buildLoadingState();
    } else if (state is HistoryError) {
      return _buildErrorState(state.message);
    } else if (state is HistorySuccess) {
      return _buildSuccessState(state.data);
    } else {
      return _buildInitialState();
    }
  }

  Widget _buildLoadingState() {
    return Center(child: CircularProgressIndicator(color: AppColors.primary));
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error illustration container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.shade100, width: 2),
              ),
              child: Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade400),
            ),

            24.gap,

            // // Error title
            // Text(
            //   LocaleKeys.somethingWentWrong.tr(), // "Something went wrong"
            //   style: context.headlineSmall?.copyWith(
            //     fontWeight: FontWeight.w600,
            //     color: Colors.grey.shade800,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            12.gap,

            // Error message
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                errorMessage,
                style: context.bodyMedium.copyWith(color: Colors.grey.shade600, height: 1.4),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            32.gap,

            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Secondary action (optional)
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(LocaleKeys.back.tr()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),

                16.gap,

                // Primary retry action
                OutlinedButton.icon(
                  onPressed: () => _historyCubit.getAllHistory(),
                  icon: Icon(Icons.refresh_rounded, size: 18),
                  label: Text(LocaleKeys.try_again.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    // elevation: 2,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),

            // // Optional: Help text
            // 24.gap,
            // TextButton(
            //   onPressed: () {
            //     // Navigate to help/support page
            //   },
            //   child: Text(
            //     LocaleKeys.needHelp.tr(),
            //     style: context.bodySmall?.copyWith(
            //       color: Colors.grey.shade500,
            //       decoration: TextDecoration.underline,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(List<HistoryModel> parkingList) {
    if (parkingList.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _historyCubit.getAllHistory(),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: parkingList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return null;

          // return ParkingCard(parking:);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          16.gap,
          Text(
            LocaleKeys.no_history_found.tr(), // Assuming you have this key
            style: context.bodyLarge.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(child: CircularProgressIndicator(color: AppColors.primary));
  }
}
