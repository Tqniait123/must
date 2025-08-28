import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/is_logged_in.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/congratulation_bototm_sheet.dart';
import 'package:must_invest/core/utils/dialogs/error_toast.dart';
import 'package:must_invest/core/utils/dialogs/toaster.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/features/offers/data/models/buy_offer_params.dart';
import 'package:must_invest/features/offers/data/models/offer_model.dart';
import 'package:must_invest/features/offers/presentation/cubit/cubit/buy_offer_cubit.dart';

class OfferWidget extends StatelessWidget {
  final Offer offer;
  final void Function(int offerId)? onCatchOffer;

  const OfferWidget({super.key, required this.offer, this.onCatchOffer});

  @override
  Widget build(BuildContext context) {
    final bool isExpiringSoon = offer.isExpiringSoon;

    return BlocProvider(
      create: (context) => BuyOfferCubit(sl()),
      child: BlocListener<BuyOfferCubit, BuyOfferState>(
        listener: (context, state) async {
          if (state is BuyOfferLoading) {
            Toaster.showLoading();
          } else if (state is BuyOfferSuccess) {
            Toaster.closeLoading();

            // Navigate to payment webview
            final isSuccess = await context.push(Routes.payment, extra: state.paymentModel.paymentUrl);

            if (isSuccess == true) {
              context.updateUserPoints(context.user.points + offer.points);
              CongratulationsBottomSheet.show(
                context,
                message: LocaleKeys.offer_purchased_successfully.tr(),
                points: offer.points,
                onContinue: () => context.go(Routes.homeUser),
              );
            } else {
              showErrorToast(context, LocaleKeys.payment_error.tr());
            }
          } else if (state is BuyOfferError) {
            Toaster.closeLoading();
            showErrorToast(context, state.message);
          }
        },
        child: Builder(
          builder:
              (innerContext) => GestureDetector(
                onTap: () => _showOfferDetails(innerContext),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isExpiringSoon ? Colors.amber.shade300 : Colors.grey.shade200,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header: Points and Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Points Highlight
                          Row(
                            children: [
                              Icon(Icons.stars_rounded, color: Colors.amber.shade600, size: 24),
                              6.gap,
                              Text(
                                '${offer.points} ${LocaleKeys.points.tr()}',
                                style: context.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          // Price
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${offer.price.toStringAsFixed(0)} ${LocaleKeys.egp.tr()}',
                              style: context.titleMedium.copyWith(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      10.gap,

                      // Offer Name
                      Text(
                        offer.name,
                        style: context.bodyLarge.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      8.gap,

                      // Brief Description
                      Text(
                        offer.brief,
                        style: context.bodyMedium.copyWith(color: Colors.grey.shade600, fontSize: 14, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      12.gap,

                      // Expiry and Dates
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Expiry Status
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isExpiringSoon ? Colors.amber.shade50 : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getStatusIcon(), color: _getStatusColor(), size: 14),
                                4.gap,
                                Text(
                                  _getExpiryText(context),
                                  style: context.bodySmall.copyWith(
                                    color: _getStatusColor(),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Expiry Date
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                LocaleKeys.expires.tr(),
                                style: context.bodySmall.copyWith(color: Colors.grey.shade500, fontSize: 12),
                              ),
                              2.gap,
                              Text(
                                _formatDate(offer.expiredAt, context),
                                style: context.bodySmall.copyWith(
                                  color: isExpiringSoon ? Colors.amber.shade700 : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  void _showOfferDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (bottomSheetContext) => BlocProvider.value(
            value: context.read<BuyOfferCubit>(),
            child: _OfferDetailsBottomSheet(offer: offer, onCatchOffer: onCatchOffer),
          ),
    );
  }

  IconData _getStatusIcon() {
    if (offer.isExpired) {
      return Icons.cancel_rounded;
    } else if (offer.isExpiringSoon) {
      return Icons.hourglass_top_rounded;
    } else if (offer.isUpcoming) {
      return Icons.schedule_rounded;
    } else {
      return Icons.check_circle_rounded;
    }
  }

  Color _getStatusColor() {
    if (offer.isExpired) {
      return Colors.red.shade700;
    } else if (offer.isExpiringSoon) {
      return Colors.amber.shade700;
    } else if (offer.isUpcoming) {
      return Colors.blue.shade700;
    } else {
      return Colors.green.shade700;
    }
  }

  String _getExpiryText(BuildContext context) {
    if (offer.isExpired) {
      return LocaleKeys.expired.tr();
    } else if (offer.isUpcoming) {
      final daysUntilStart = offer.startAt.difference(DateTime.now()).inDays;
      if (daysUntilStart == 0) {
        return LocaleKeys.starts_today.tr();
      } else if (daysUntilStart == 1) {
        return LocaleKeys.starts_tomorrow.tr();
      } else {
        return LocaleKeys.starts_in_days.tr(args: [daysUntilStart.toString()]);
      }
    }

    final difference = offer.timeUntilExpiry;

    if (difference.inDays == 0) {
      final hours = difference.inHours;
      if (hours <= 1) {
        return LocaleKeys.expires_soon.tr();
      }
      return LocaleKeys.expires_today.tr();
    } else if (difference.inDays <= 3) {
      return LocaleKeys.expires_in_days.tr(args: [difference.inDays.toString()]);
    } else {
      return LocaleKeys.active.tr();
    }
  }

  String _formatDate(DateTime date, BuildContext context) {
    final locale = context.locale.languageCode;

    // Use appropriate date format based on locale
    if (locale == 'ar') {
      // Arabic date format
      return DateFormat('EEE، d MMM yyyy', locale).format(date);
    } else {
      // English and other locales
      return DateFormat.yMMMEd(locale).format(date);
    }
  }
}

class _OfferDetailsBottomSheet extends StatelessWidget {
  final Offer offer;
  final void Function(int offerId)? onCatchOffer;

  const _OfferDetailsBottomSheet({required this.offer, this.onCatchOffer});

  @override
  Widget build(BuildContext context) {
    final bool isExpiringSoon = offer.isExpiringSoon;
    final bool canCatchOffer = !offer.isExpired && !offer.isUpcoming;

    return BlocBuilder<BuyOfferCubit, BuyOfferState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),

              // Minimal Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with points and offer name
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.amber.shade400, Colors.amber.shade600]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars_rounded, color: Colors.white, size: 20),
                              6.gap,
                              Text(
                                '${offer.points}',
                                style: context.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        12.gap,
                        Expanded(
                          child: Text(
                            offer.name,
                            style: context.titleMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    16.gap,

                    // Price and Status Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            '${offer.price.toStringAsFixed(0)} ${LocaleKeys.egp.tr()}',
                            style: context.bodyLarge.copyWith(color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                          ),
                        ),

                        // Status
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusBackgroundColor(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getStatusIcon(), color: _getStatusColor(), size: 14),
                              4.gap,
                              Text(
                                _getExpiryText(context),
                                style: context.bodySmall.copyWith(
                                  color: _getStatusColor(),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    16.gap,

                    // Expires date
                    Text(
                      '${LocaleKeys.expires.tr()}: ${_formatDate(offer.expiredAt, context)}',
                      style: context.bodyMedium.copyWith(
                        color: isExpiringSoon ? Colors.amber.shade700 : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    24.gap,
                  ],
                ),
              ),

              // Action button with CustomElevatedButton
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
                  ],
                ),
                child: SafeArea(
                  child: CustomElevatedButton(
                    title:
                        canCatchOffer
                            ? '${LocaleKeys.catch_this_offer.tr()} (${offer.points})'
                            : offer.isExpired
                            ? LocaleKeys.expired.tr()
                            : LocaleKeys.coming_soon.tr(),
                    icon: canCatchOffer ? Icons.stars_rounded : null,
                    textColor: Colors.white,
                    isDisabled: !canCatchOffer || state is BuyOfferLoading,
                    withShadow: canCatchOffer,
                    onPressed: canCatchOffer && state is! BuyOfferLoading ? () => _handlePurchase(context) : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handlePurchase(BuildContext context) {
    final buyOfferParams = BuyOfferParams(offerId: offer.id);
    context.read<BuyOfferCubit>().buyOffer(buyOfferParams);
    onCatchOffer?.call(offer.id);
    Navigator.pop(context); // Close bottom sheet before navigating
  }

  IconData _getStatusIcon() {
    if (offer.isExpired) {
      return Icons.cancel_rounded;
    } else if (offer.isExpiringSoon) {
      return Icons.hourglass_top_rounded;
    } else if (offer.isUpcoming) {
      return Icons.schedule_rounded;
    } else {
      return Icons.check_circle_rounded;
    }
  }

  Color _getStatusColor() {
    if (offer.isExpired) {
      return Colors.red.shade700;
    } else if (offer.isExpiringSoon) {
      return Colors.amber.shade700;
    } else if (offer.isUpcoming) {
      return Colors.blue.shade700;
    } else {
      return Colors.green.shade700;
    }
  }

  Color _getStatusBackgroundColor() {
    if (offer.isExpired) {
      return Colors.red.shade50;
    } else if (offer.isExpiringSoon) {
      return Colors.amber.shade50;
    } else if (offer.isUpcoming) {
      return Colors.blue.shade50;
    } else {
      return Colors.green.shade50;
    }
  }

  String _getExpiryText(BuildContext context) {
    if (offer.isExpired) {
      return LocaleKeys.expired.tr();
    } else if (offer.isUpcoming) {
      final daysUntilStart = offer.startAt.difference(DateTime.now()).inDays;
      if (daysUntilStart == 0) {
        return LocaleKeys.starts_today.tr();
      } else if (daysUntilStart == 1) {
        return LocaleKeys.starts_tomorrow.tr();
      } else {
        return LocaleKeys.starts_in_days.tr(args: [daysUntilStart.toString()]);
      }
    }

    final difference = offer.timeUntilExpiry;

    if (difference.inDays == 0) {
      final hours = difference.inHours;
      if (hours <= 1) {
        return LocaleKeys.expires_soon.tr();
      }
      return LocaleKeys.expires_today.tr();
    } else if (difference.inDays <= 3) {
      return LocaleKeys.expires_in_days.tr(args: [difference.inDays.toString()]);
    } else {
      return LocaleKeys.active.tr();
    }
  }

  String _formatDate(DateTime date, BuildContext context) {
    final locale = context.locale.languageCode;

    if (locale == 'ar') {
      return DateFormat('EEE، d MMM yyyy', locale).format(date);
    } else {
      return DateFormat.yMMMEd(locale).format(date);
    }
  }
}
