// import 'dart:developer';

// import 'package:easy_localization/easy_localization.dart';
// import 'package:must_invest/config/routes/routes.dart';
// import 'package:must_invest/core/extensions/is_logged_in.dart';
// import 'package:must_invest/core/extensions/num_extension.dart';
// import 'package:must_invest/core/extensions/string_to_icon.dart';
// import 'package:must_invest/core/extensions/widget_extensions.dart';
// import 'package:must_invest/core/services/di.dart';
// import 'package:must_invest/core/services/location_service2.dart';
// import 'package:must_invest/core/static/icons.dart';
// import 'package:must_invest/core/theme/colors.dart';
// import 'package:must_invest/core/translations/locale_keys.g.dart';
// import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
// import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
// import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
// import 'package:must_invest/features/auth/presentation/cubit/update_location_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// Future<void> getAddressFromLatLng(LatLng position) async {
//   setState(() {
//     _isLoadingAddress = true;
//   });

//   final addressService = AddressService();
//   try {
//     final formattedAddress =
//         await addressService.getAddressFromLatLng(position);
//     setState(() {
//       _locationName = formattedAddress;
//       _isLoadingAddress = false;
//     });
//   } catch (e) {
//     log('Error getting address: ${e.toString()}');
//     setState(() {
//       _locationName = LocaleKeys.failed_to_get_location.tr();
//       _isLoadingAddress = false;
//     });
//   }
// }

// // Helper method to log all placemark details
// String _logPlacemarkDetails(Placemark place) {
//   return '''
//     name: ${place.name}
//     street: ${place.street}
//     thoroughfare: ${place.thoroughfare}
//     subThoroughfare: ${place.subThoroughfare}
//     locality: ${place.locality}
//     subLocality: ${place.subLocality}
//     administrativeArea: ${place.administrativeArea}
//     subAdministrativeArea: ${place.subAdministrativeArea}
//     postalCode: ${place.postalCode}
//     country: ${place.country}
//     ''';
// }

// // Format address for better readability
// String _formatLocationAddress(Placemark place, LatLng position) {
//   // Create different address formats based on available components
//   // Detailed format for when we have specific location data
//   if (_hasDetailedAddressData(place)) {
//     log('Using detailed address format');
//     return _createDetailedAddress(place);
//   }
//   // Area-based format when we have area data but not specific address
//   else if (_hasAreaData(place)) {
//     log('Using area-based address format');
//     return _createAreaBasedAddress(place);
//   }
//   // Basic fallback format
//   else {
//     log('Using basic fallback address format');
//     return _createBasicAddress(place, position);
//   }
// }

// // Check if we have detailed street-level data
// bool _hasDetailedAddressData(Placemark place) {
//   bool hasStreet = place.street != null && place.street!.isNotEmpty;
//   bool hasThoroughfare =
//       place.thoroughfare != null && place.thoroughfare!.isNotEmpty;
//   bool hasSubThoroughfare =
//       place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty;

//   bool result = hasStreet || hasThoroughfare || hasSubThoroughfare;
//   log('Has detailed street data: $result (street: $hasStreet, thoroughfare: $hasThoroughfare, subThoroughfare: $hasSubThoroughfare)');
//   return result;
// }

// // Check if we have area/locality data
// bool _hasAreaData(Placemark place) {
//   bool hasLocality = place.locality != null && place.locality!.isNotEmpty;
//   bool hasSubLocality =
//       place.subLocality != null && place.subLocality!.isNotEmpty;
//   bool hasAdminArea =
//       place.administrativeArea != null && place.administrativeArea!.isNotEmpty;
//   bool hasSubAdminArea = place.subAdministrativeArea != null &&
//       place.subAdministrativeArea!.isNotEmpty;

//   bool result =
//       hasLocality || hasSubLocality || hasAdminArea || hasSubAdminArea;
//   log('Has area data: $result (locality: $hasLocality, subLocality: $hasSubLocality, adminArea: $hasAdminArea, subAdminArea: $hasSubAdminArea)');
//   return result;
// }

// // Create a detailed street-level address
// String _createDetailedAddress(Placemark place) {
//   List<String> addressParts = [];
//   log('Creating detailed address');

//   // Start with the most specific details
//   if (place.street != null && place.street!.isNotEmpty) {
//     log('Adding street: ${place.street}');
//     addressParts.add(place.street!);
//   } else if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
//     String thoroughfare = place.thoroughfare!;
//     if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
//       thoroughfare = "${place.subThoroughfare} $thoroughfare";
//       log('Adding combined thoroughfare: $thoroughfare');
//     } else {
//       log('Adding thoroughfare: $thoroughfare');
//     }
//     addressParts.add(thoroughfare);
//   }

//   // Add neighborhood or district information
//   if (place.subLocality != null && place.subLocality!.isNotEmpty) {
//     log('Adding subLocality: ${place.subLocality}');
//     addressParts.add(place.subLocality!);
//   }

//   // Add city/locality
//   if (place.locality != null && place.locality!.isNotEmpty) {
//     log('Adding locality: ${place.locality}');
//     addressParts.add(place.locality!);
//   }

//   // Add regional information if needed
//   if ((addressParts.length < 2) &&
//       place.administrativeArea != null &&
//       place.administrativeArea!.isNotEmpty) {
//     log('Adding administrative area: ${place.administrativeArea}');
//     addressParts.add(place.administrativeArea!);
//   }

//   // Add country only if we have very little information
//   if (addressParts.length < 2 &&
//       place.country != null &&
//       place.country!.isNotEmpty) {
//     log('Adding country: ${place.country}');
//     addressParts.add(place.country!);
//   }

//   String result = addressParts.join(', ');
//   log('Final detailed address: $result');
//   return result;
// }

// // Create an area-based address when street data is missing
// String _createAreaBasedAddress(Placemark place) {
//   List<String> addressParts = [];
//   log('Creating area-based address');

//   // Start with district/neighborhood
//   if (place.subLocality != null && place.subLocality!.isNotEmpty) {
//     log('Adding subLocality: ${place.subLocality}');
//     addressParts.add(place.subLocality!);
//   }

//   // Add city
//   if (place.locality != null && place.locality!.isNotEmpty) {
//     log('Adding locality: ${place.locality}');
//     addressParts.add(place.locality!);
//   } else if (place.subAdministrativeArea != null &&
//       place.subAdministrativeArea!.isNotEmpty) {
//     log('Adding subAdministrativeArea: ${place.subAdministrativeArea}');
//     addressParts.add(place.subAdministrativeArea!);
//   }

//   // Add state/province
//   if (place.administrativeArea != null &&
//       place.administrativeArea!.isNotEmpty) {
//     log('Adding administrative area: ${place.administrativeArea}');
//     addressParts.add(place.administrativeArea!);
//   }

//   // Add country
//   if ((addressParts.length < 2) &&
//       place.country != null &&
//       place.country!.isNotEmpty) {
//     log('Adding country: ${place.country}');
//     addressParts.add(place.country!);
//   }

//   String result = addressParts.join(', ');
//   log('Final area-based address: $result');
//   return result;
// }

// // Create a basic address as fallback
// String _createBasicAddress(Placemark place, LatLng position) {
//   log('Creating basic address');

//   // Try to use the name first
//   if (place.name != null &&
//       place.name!.isNotEmpty &&
//       place.name != "Unnamed Road") {
//     log('Using place name: ${place.name}');
//     return place.name!;
//   }

//   // Try postal code with country
//   if (place.postalCode != null && place.postalCode!.isNotEmpty) {
//     String address = place.postalCode!;
//     if (place.country != null && place.country!.isNotEmpty) {
//       address += ", ${place.country}";
//       log('Using postal code with country: $address');
//     } else {
//       log('Using postal code: $address');
//     }
//     return address;
//   }

//   // Last resort - just use country or coordinates
//   if (place.country != null && place.country!.isNotEmpty) {
//     log('Using country as fallback: ${place.country}');
//     return place.country!;
//   } else {
//     String coords =
//         "${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}";
//     log('Using coordinates as last resort: $coords');
//     return coords;
//   }
// }
