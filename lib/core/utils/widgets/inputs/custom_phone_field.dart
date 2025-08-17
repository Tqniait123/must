import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

// class CustomPhoneFormField extends StatefulWidget {
//   const CustomPhoneFormField({
//     super.key,
//     required this.controller,
//     this.selectedCode,
//     this.initialCountryCode,
//     this.onChangedCountryCode,
//     this.onChanged,
//     this.validator,
//     this.title,
//     this.hint,
//     this.fieldName,
//     this.shadow,
//     this.radius = 16,
//     this.margin = 16,
//     this.readonly = false,
//     this.disabled = false,
//     this.onTap,
//     this.backgroundColor,
//     this.hintColor,
//     this.gender = 'male',
//     this.isBordered,
//     this.waitTyping = false,
//     this.isRequired = false,
//     this.textAlign = TextAlign.start,
//     this.includeCountryCodeInValue = false,
//     this.popularCountries, // New parameter for custom popular countries
//   });

//   final TextEditingController controller;
//   final String? selectedCode;
//   final String? initialCountryCode;
//   final void Function(String code, String countryCode)? onChangedCountryCode;
//   final void Function(String)? onChanged;
//   final String? Function(String?)? validator;
//   final String? title;
//   final String? hint;
//   final String? fieldName;
//   final List<BoxShadow>? shadow;
//   final double radius;
//   final double margin;
//   final bool readonly;
//   final bool disabled;
//   final void Function()? onTap;
//   final Color? backgroundColor;
//   final Color? hintColor;
//   final String gender;
//   final bool? isBordered;
//   final bool waitTyping;
//   final bool isRequired;
//   final TextAlign textAlign;
//   final bool includeCountryCodeInValue;
//   final List<String>? popularCountries; // List of country codes for popular countries

//   @override
//   State<CustomPhoneFormField> createState() => _CustomPhoneFormFieldState();
// }

// // Simplified phone input formatter - focuses on length limits
// class PhoneNumberInputFormatter extends TextInputFormatter {
//   final Country countryData;

//   PhoneNumberInputFormatter({required this.countryData});

//   @override
//   TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
//     final newText = newValue.text;

//     if (newText.isEmpty) {
//       return newValue;
//     }

//     // Remove any non-digit characters
//     final digitsOnly = newText.replaceAll(RegExp(r'\D'), '');

//     // Apply reasonable length limit
//     final maxLength = _getMaxLengthForCountry(countryData.alpha2Code ?? 'EG');

//     if (digitsOnly.length > maxLength) {
//       return oldValue;
//     }

//     return TextEditingValue(text: digitsOnly, selection: TextSelection.collapsed(offset: digitsOnly.length));
//   }

//   int _getMaxLengthForCountry(String countryCode) {
//     const maxLengths = {
//       'EG': 10,
//       'SA': 9,
//       'AE': 9,
//       'KW': 8,
//       'BH': 8,
//       'QA': 8,
//       'OM': 8,
//       'LY': 9,
//       'JO': 9,
//       'LB': 8,
//       'SY': 9,
//       'IQ': 10,
//       'YE': 9,
//       'US': 10,
//       'CA': 10,
//       'GB': 11,
//       'FR': 10,
//       'DE': 11,
//       'IN': 10,
//       'CN': 11,
//       'JP': 11,
//     };
//     return maxLengths[countryCode] ?? 15;
//   }
// }

// class _CustomPhoneFormFieldState extends State<CustomPhoneFormField> {
//   Timer? _debounce;
//   String _currentCountryCode = '';
//   String _lastValidNumber = '';
//   bool _isUpdatingProgrammatically = false;
//   late PhoneNumberInputFormatter _inputFormatter;
//   bool _isValidPhone = true; // For async validation result
//   late List<Country> _countries;
//   late List<Country> _popularCountriesList;
//   late List<Country> _otherCountriesList;
//   late Country _currentCountry;

//   // Default popular countries - can be overridden via widget parameter
//   static const List<String> _defaultPopularCountries = [
//     'EG', // Egypt
//     'SA', // Saudi Arabia
//     'AE', // UAE
//     'US', // United States
//     'GB', // United Kingdom
//     'IN', // India
//     'CN', // China
//     'KW', // Kuwait
//     'QA', // Qatar
//     'BH', // Bahrain
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _countries = Countries.countryList.map((data) => Country.fromJson(data)).toList();
//     _initializeCountryLists();
//     _initializeCountryCode();
//     _updateInputFormatter();
//     _initializeController();
//   }

//   void _initializeCountryLists() {
//     final popularCodes = widget.popularCountries ?? _defaultPopularCountries;

//     // Create popular countries list
//     _popularCountriesList = [];
//     for (String code in popularCodes) {
//       final country = _countries.firstWhere((c) => c.alpha2Code == code, orElse: () => Country.fromJson({}));
//       if (country.alpha2Code != null) {
//         _popularCountriesList.add(country);
//       }
//     }

//     // Create other countries list (excluding popular ones)
//     final popularCountryCodes = _popularCountriesList.map((c) => c.alpha2Code).toSet();
//     _otherCountriesList = _countries.where((country) => !popularCountryCodes.contains(country.alpha2Code)).toList();
//   }

//   void _initializeCountryCode() {
//     if (widget.selectedCode?.isNotEmpty == true) {
//       _currentCountryCode = widget.selectedCode!;
//       _currentCountry = _getCountryDataByDialCode(_currentCountryCode) ?? _getDefaultCountry();
//     } else if (widget.initialCountryCode?.isNotEmpty == true) {
//       _currentCountry = _getCountryDataByCode(widget.initialCountryCode!) ?? _getDefaultCountry();
//       _currentCountryCode = _currentCountry.dialCode ?? '+20';
//     } else {
//       _currentCountry = _getDefaultCountry();
//       _currentCountryCode = _currentCountry.dialCode ?? '+20';
//     }
//   }

//   Country? _getCountryDataByCode(String countryCode) {
//     try {
//       return _countries.firstWhere((country) => country.alpha2Code == countryCode.toUpperCase());
//     } catch (e) {
//       debugPrint('Country code $countryCode not found: $e');
//       return null;
//     }
//   }

//   Country? _getCountryDataByDialCode(String dialCode) {
//     try {
//       return _countries.firstWhere((country) => country.dialCode == dialCode);
//     } catch (e) {
//       debugPrint('Dial code $dialCode not found: $e');
//       return null;
//     }
//   }

//   Country _getDefaultCountry() {
//     return _countries.firstWhere((country) => country.alpha2Code == 'EG', orElse: () => _countries.first);
//   }

//   @override
//   void didUpdateWidget(CustomPhoneFormField oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     // Re-initialize country lists if popular countries changed
//     if (oldWidget.popularCountries != widget.popularCountries) {
//       _initializeCountryLists();
//     }

//     bool shouldUpdate = false;

//     if (oldWidget.selectedCode != widget.selectedCode && widget.selectedCode?.isNotEmpty == true) {
//       _currentCountryCode = widget.selectedCode!;
//       _currentCountry = _getCountryDataByDialCode(_currentCountryCode) ?? _getDefaultCountry();
//       shouldUpdate = true;
//     }

//     if (oldWidget.initialCountryCode != widget.initialCountryCode && widget.initialCountryCode?.isNotEmpty == true) {
//       final countryData = _getCountryDataByCode(widget.initialCountryCode!);
//       if (countryData != null) {
//         _currentCountry = countryData;
//         _currentCountryCode = countryData.dialCode ?? '+20';
//         shouldUpdate = true;
//       }
//     }

//     if (shouldUpdate) {
//       setState(() {
//         _updateInputFormatter();
//       });
//     }

//     if (oldWidget.controller != widget.controller) {
//       _initializeController();
//     }
//   }

//   void _updateInputFormatter() {
//     _inputFormatter = PhoneNumberInputFormatter(countryData: _currentCountry);
//   }

//   void _initializeController() {
//     if (widget.controller.text.isNotEmpty) {
//       _parseExistingPhoneNumber();
//     }
//   }

//   void _parseExistingPhoneNumber() {
//     try {
//       final text = widget.controller.text;
//       if (text.isNotEmpty) {
//         final parts = _extractCountryCodeAndNumber(text);
//         if (parts != null) {
//           _currentCountryCode = parts['countryCode']!;
//           _updateInputFormatter();
//           _isUpdatingProgrammatically = true;
//           widget.controller.text = parts['number']!;
//           _isUpdatingProgrammatically = false;
//         }
//       }
//     } catch (e) {
//       debugPrint('Error parsing phone number: $e');
//     }
//   }

//   Map<String, String>? _extractCountryCodeAndNumber(String fullNumber) {
//     try {
//       final sortedCountries =
//           _countries.toList()..sort((a, b) => (b.dialCode?.length ?? 0).compareTo(a.dialCode?.length ?? 0));

//       for (final country in sortedCountries) {
//         final dialCode = country.dialCode ?? '';
//         if (dialCode.isNotEmpty && fullNumber.startsWith(dialCode)) {
//           final number = fullNumber.substring(dialCode.length);
//           return {'countryCode': dialCode, 'number': number};
//         }
//       }
//       return null;
//     } catch (e) {
//       debugPrint('Error extracting country code and number: $e');
//       return null;
//     }
//   }

//   // Async validation using libphonenumber
//   Future<void> _validatePhoneNumberAsync(String phoneNumber) async {
//     if (phoneNumber.isEmpty) {
//       setState(() => _isValidPhone = true);
//       return;
//     }

//     try {
//       final isoCode = _currentCountry.alpha2Code ?? 'EG';
//       final fullNumber = _currentCountryCode + phoneNumber;

//       debugPrint('Validating phone: $fullNumber for country: $isoCode');
//       debugPrint('Phone number length: ${phoneNumber.length}');

//       final isValid = CountryUtils.validatePhoneNumber(phoneNumber, _currentCountryCode);

//       debugPrint('Phone validation result: $isValid');

//       if (mounted) {
//         setState(() => _isValidPhone = isValid ?? false);
//       }
//     } catch (e) {
//       debugPrint('Error in async validation: $e');
//       if (mounted) {
//         // For Saudi Arabia, 9 digits is valid, for most others 7-15 is reasonable
//         final isLengthValid = phoneNumber.length >= 7 && phoneNumber.length <= 15;
//         setState(() => _isValidPhone = isLengthValid);
//       }
//     }
//   }

//   // Replace your _syncValidator function with this improved version

//   // Replace your _syncValidator function with this improved version

//   String? _syncValidator(String? value) {
//     try {
//       if (widget.isRequired && (value?.isEmpty ?? true)) {
//         return LocaleKeys.this_field_is_required.tr();
//       }

//       if (value?.isNotEmpty == true) {
//         final phoneNumber = value!.trim();
//         final countryCode = _currentCountry.alpha2Code ?? 'EG';

//         // Get country-specific validation rules
//         final validationRules = _getPhoneValidationRules(countryCode);

//         // Check minimum length
//         if (phoneNumber.length < (validationRules['minLength'] ?? 7)) {
//           return LocaleKeys.invalid_phone_number_format.tr();
//         }

//         // Check maximum length
//         if (phoneNumber.length > (validationRules['maxLength'] ?? 15)) {
//           return LocaleKeys.invalid_phone_number_format.tr();
//         }

//         // Check if it contains only digits
//         if (!RegExp(r'^\d+$').hasMatch(phoneNumber)) {
//           return LocaleKeys.invalid_phone_number_format.tr();
//         }

//         // Country-specific validation patterns
//         if (!_isValidPhoneForCountry(phoneNumber, countryCode)) {
//           return LocaleKeys.invalid_phone_number_format.tr();
//         }

//         // Only show async validation result if it has been processed
//         // and the field is not currently being typed in
//         if (!_isValidPhone && phoneNumber.length >= (validationRules['minLength'] ?? 7)) {
//           return LocaleKeys.invalid_phone_number_format.tr();
//         }
//       }

//       if (widget.validator != null && value != null) {
//         final fullNumber = widget.includeCountryCodeInValue ? '$_currentCountryCode$value' : value;
//         return widget.validator!(fullNumber);
//       }

//       return null;
//     } catch (e) {
//       debugPrint('Error in validator: $e');
//       return LocaleKeys.invalid_phone_number_format.tr();
//     }
//   }

//   // Add this helper method to get country-specific validation rules
//   Map<String, int> _getPhoneValidationRules(String countryCode) {
//     const validationRules = {
//       // Middle East & Africa
//       'EG': {'minLength': 10, 'maxLength': 10}, // Egypt: 10 digits
//       'SA': {'minLength': 9, 'maxLength': 9}, // Saudi Arabia: 9 digits
//       'AE': {'minLength': 9, 'maxLength': 9}, // UAE: 9 digits
//       'KW': {'minLength': 8, 'maxLength': 8}, // Kuwait: 8 digits
//       'BH': {'minLength': 8, 'maxLength': 8}, // Bahrain: 8 digits
//       'QA': {'minLength': 8, 'maxLength': 8}, // Qatar: 8 digits
//       'OM': {'minLength': 8, 'maxLength': 8}, // Oman: 8 digits
//       'LY': {'minLength': 9, 'maxLength': 9}, // Libya: 9 digits
//       'JO': {'minLength': 9, 'maxLength': 9}, // Jordan: 9 digits
//       'LB': {'minLength': 7, 'maxLength': 8}, // Lebanon: 7-8 digits
//       'SY': {'minLength': 9, 'maxLength': 9}, // Syria: 9 digits
//       'IQ': {'minLength': 10, 'maxLength': 10}, // Iraq: 10 digits
//       'YE': {'minLength': 9, 'maxLength': 9}, // Yemen: 9 digits
//       'MA': {'minLength': 9, 'maxLength': 9}, // Morocco: 9 digits
//       'DZ': {'minLength': 9, 'maxLength': 9}, // Algeria: 9 digits
//       'TN': {'minLength': 8, 'maxLength': 8}, // Tunisia: 8 digits
//       // North America
//       'US': {'minLength': 10, 'maxLength': 10}, // USA: 10 digits
//       'CA': {'minLength': 10, 'maxLength': 10}, // Canada: 10 digits
//       'MX': {'minLength': 10, 'maxLength': 10}, // Mexico: 10 digits
//       // Europe
//       'GB': {'minLength': 10, 'maxLength': 11}, // UK: 10-11 digits
//       'FR': {'minLength': 9, 'maxLength': 10}, // France: 9-10 digits
//       'DE': {'minLength': 10, 'maxLength': 12}, // Germany: 10-12 digits
//       'IT': {'minLength': 9, 'maxLength': 11}, // Italy: 9-11 digits
//       'ES': {'minLength': 9, 'maxLength': 9}, // Spain: 9 digits
//       'NL': {'minLength': 9, 'maxLength': 9}, // Netherlands: 9 digits
//       'BE': {'minLength': 9, 'maxLength': 9}, // Belgium: 9 digits
//       'CH': {'minLength': 9, 'maxLength': 9}, // Switzerland: 9 digits
//       'AT': {'minLength': 10, 'maxLength': 13}, // Austria: 10-13 digits
//       'SE': {'minLength': 9, 'maxLength': 9}, // Sweden: 9 digits
//       'NO': {'minLength': 8, 'maxLength': 8}, // Norway: 8 digits
//       'DK': {'minLength': 8, 'maxLength': 8}, // Denmark: 8 digits
//       'FI': {'minLength': 9, 'maxLength': 10}, // Finland: 9-10 digits
//       // Asia
//       'IN': {'minLength': 10, 'maxLength': 10}, // India: 10 digits
//       'CN': {'minLength': 11, 'maxLength': 11}, // China: 11 digits
//       'JP': {'minLength': 10, 'maxLength': 11}, // Japan: 10-11 digits
//       'KR': {'minLength': 10, 'maxLength': 11}, // South Korea: 10-11 digits
//       'TH': {'minLength': 9, 'maxLength': 9}, // Thailand: 9 digits
//       'VN': {'minLength': 9, 'maxLength': 10}, // Vietnam: 9-10 digits
//       'ID': {'minLength': 8, 'maxLength': 13}, // Indonesia: 8-13 digits
//       'MY': {'minLength': 9, 'maxLength': 10}, // Malaysia: 9-10 digits
//       'SG': {'minLength': 8, 'maxLength': 8}, // Singapore: 8 digits
//       'PH': {'minLength': 10, 'maxLength': 10}, // Philippines: 10 digits
//       'PK': {'minLength': 10, 'maxLength': 10}, // Pakistan: 10 digits
//       'BD': {'minLength': 10, 'maxLength': 10}, // Bangladesh: 10 digits
//       'LK': {'minLength': 9, 'maxLength': 9}, // Sri Lanka: 9 digits
//       // Oceania
//       'AU': {'minLength': 9, 'maxLength': 9}, // Australia: 9 digits
//       'NZ': {'minLength': 8, 'maxLength': 9}, // New Zealand: 8-9 digits
//       // South America
//       'BR': {'minLength': 10, 'maxLength': 11}, // Brazil: 10-11 digits
//       'AR': {'minLength': 10, 'maxLength': 10}, // Argentina: 10 digits
//       'CL': {'minLength': 8, 'maxLength': 9}, // Chile: 8-9 digits
//       'CO': {'minLength': 10, 'maxLength': 10}, // Colombia: 10 digits
//       'PE': {'minLength': 9, 'maxLength': 9}, // Peru: 9 digits
//       'VE': {'minLength': 10, 'maxLength': 11}, // Venezuela: 10-11 digits
//     };

//     return validationRules[countryCode] ?? {'minLength': 7, 'maxLength': 15}; // Default fallback
//   }

//   // Add this helper method for country-specific pattern validation
//   bool _isValidPhoneForCountry(String phoneNumber, String countryCode) {
//     // Country-specific validation patterns
//     switch (countryCode) {
//       case 'EG': // Egypt
//         // Egyptian mobile numbers: start with 1 and are 10 digits total
//         // Valid prefixes: 100, 101, 102, 106, 109, 110, 111, 112, 114, 115, 120, 122, 127, 128
//         return phoneNumber.length == 10 && phoneNumber.startsWith('1');

//       case 'SA': // Saudi Arabia
//         // Saudi mobile numbers: start with 5 and are 9 digits total
//         return phoneNumber.length == 9 && phoneNumber.startsWith('5');

//       case 'AE': // UAE
//         // UAE mobile numbers: start with 5 and are 9 digits total
//         return phoneNumber.length == 9 && phoneNumber.startsWith('5');

//       case 'KW': // Kuwait
//         // Kuwait mobile numbers: start with 5, 6, or 9 and are 8 digits total
//         return phoneNumber.length == 8 &&
//             (phoneNumber.startsWith('5') || phoneNumber.startsWith('6') || phoneNumber.startsWith('9'));

//       case 'QA': // Qatar
//         // Qatar mobile numbers: start with 3, 5, 6, or 7 and are 8 digits total
//         return phoneNumber.length == 8 &&
//             (phoneNumber.startsWith('3') ||
//                 phoneNumber.startsWith('5') ||
//                 phoneNumber.startsWith('6') ||
//                 phoneNumber.startsWith('7'));

//       case 'BH': // Bahrain
//         // Bahrain mobile numbers: start with 3 and are 8 digits total
//         return phoneNumber.length == 8 && phoneNumber.startsWith('3');

//       case 'OM': // Oman
//         // Oman mobile numbers: start with 9 and are 8 digits total
//         return phoneNumber.length == 8 && phoneNumber.startsWith('9');

//       case 'JO': // Jordan
//         // Jordan mobile numbers: start with 7 and are 9 digits total
//         return phoneNumber.length == 9 && phoneNumber.startsWith('7');

//       case 'LB': // Lebanon
//         // Lebanon mobile numbers: start with 3, 7, or 8
//         return (phoneNumber.length >= 7 && phoneNumber.length <= 8) &&
//             (phoneNumber.startsWith('3') || phoneNumber.startsWith('7') || phoneNumber.startsWith('8'));

//       case 'US': // USA
//       case 'CA': // Canada
//         // North American numbers: 10 digits, area code can't start with 0 or 1
//         return phoneNumber.length == 10 && !phoneNumber.startsWith('0') && !phoneNumber.startsWith('1');

//       case 'GB': // United Kingdom
//         // UK mobile numbers: start with 7 and are 10-11 digits total
//         return (phoneNumber.length >= 10 && phoneNumber.length <= 11) && phoneNumber.startsWith('7');

//       case 'IN': // India
//         // Indian mobile numbers: start with 6, 7, 8, or 9 and are 10 digits total
//         return phoneNumber.length == 10 &&
//             (phoneNumber.startsWith('6') ||
//                 phoneNumber.startsWith('7') ||
//                 phoneNumber.startsWith('8') ||
//                 phoneNumber.startsWith('9'));

//       case 'CN': // China
//         // Chinese mobile numbers: start with 1 and are 11 digits total
//         return phoneNumber.length == 11 && phoneNumber.startsWith('1');

//       case 'JP': // Japan
//         // Japanese mobile numbers: start with 70, 80, or 90
//         return (phoneNumber.length >= 10 && phoneNumber.length <= 11) &&
//             (phoneNumber.startsWith('70') || phoneNumber.startsWith('80') || phoneNumber.startsWith('90'));

//       case 'AU': // Australia
//         // Australian mobile numbers: start with 4 and are 9 digits total
//         return phoneNumber.length == 9 && phoneNumber.startsWith('4');

//       case 'BR': // Brazil
//         // Brazilian mobile numbers: start with 9 for most regions
//         return (phoneNumber.length >= 10 && phoneNumber.length <= 11) &&
//             (phoneNumber.startsWith('9') || phoneNumber.startsWith('8') || phoneNumber.startsWith('7'));

//       default:
//         // For countries without specific patterns, just check basic length
//         final rules = _getPhoneValidationRules(countryCode);
//         return phoneNumber.length >= rules['minLength']! && phoneNumber.length <= rules['maxLength']!;
//     }
//   }

//   int _getMinLengthForCountry(String countryCode) {
//     const minLengths = {
//       'EG': 10,
//       'SA': 9,
//       'AE': 9,
//       'KW': 8,
//       'BH': 8,
//       'QA': 8,
//       'OM': 8,
//       'LY': 9,
//       'JO': 9,
//       'LB': 8,
//       'SY': 9,
//       'IQ': 10,
//       'YE': 9,
//       'US': 10,
//       'CA': 10,
//       'GB': 10,
//       'FR': 9,
//       'DE': 10,
//       'IN': 10,
//       'CN': 10,
//       'JP': 10,
//     };
//     return minLengths[countryCode] ?? 7;
//   }

//   int _getMaxLengthForCountry(String countryCode) {
//     const maxLengths = {
//       'EG': 10,
//       'SA': 9,
//       'AE': 9,
//       'KW': 8,
//       'BH': 8,
//       'QA': 8,
//       'OM': 8,
//       'LY': 9,
//       'JO': 9,
//       'LB': 8,
//       'SY': 9,
//       'IQ': 10,
//       'YE': 9,
//       'US': 10,
//       'CA': 10,
//       'GB': 11,
//       'FR': 10,
//       'DE': 11,
//       'IN': 10,
//       'CN': 11,
//       'JP': 11,
//     };
//     return maxLengths[countryCode] ?? 15;
//   }

//   void _showCountryPicker() {
//     if (widget.disabled || widget.readonly) return;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder:
//           (context) => Container(
//             height: MediaQuery.of(context).size.height * 0.7,
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
//             ),
//             child: Column(
//               children: [
//                 Container(
//                   margin: const EdgeInsets.only(top: 8),
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2)),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Text(
//                     LocaleKeys.select_country.tr(),
//                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
//                   ),
//                 ),
//                 Divider(color: Colors.grey[300], height: 1),
//                 Expanded(
//                   child: CustomScrollView(
//                     slivers: [
//                       // Popular Countries Section
//                       if (_popularCountriesList.isNotEmpty) ...[
//                         SliverToBoxAdapter(
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                             color: Colors.grey[50],
//                             child: Row(
//                               children: [
//                                 Icon(Icons.star, color: Colors.amber, size: 16),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'Popular Countries',
//                                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         SliverList(
//                           delegate: SliverChildBuilderDelegate((context, index) {
//                             final country = _popularCountriesList[index];
//                             final isSelected = country.dialCode == _currentCountryCode;

//                             return Column(
//                               children: [
//                                 _buildCountryListTile(country, isSelected),
//                                 if (index < _popularCountriesList.length - 1)
//                                   Divider(color: Colors.grey[200], height: 1, indent: 60, endIndent: 16),
//                               ],
//                             );
//                           }, childCount: _popularCountriesList.length),
//                         ),
//                         // Divider between popular and other countries
//                         SliverToBoxAdapter(child: Container(height: 8, color: Colors.grey[100])),
//                         SliverToBoxAdapter(
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                             color: Colors.grey[50],
//                             child: Row(
//                               children: [
//                                 Icon(Icons.public, color: Colors.grey[600], size: 16),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'All Countries',
//                                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                       // All Other Countries Section
//                       SliverList(
//                         delegate: SliverChildBuilderDelegate((context, index) {
//                           final country = _otherCountriesList[index];
//                           final isSelected = country.dialCode == _currentCountryCode;

//                           return Column(
//                             children: [
//                               _buildCountryListTile(country, isSelected),
//                               if (index < _otherCountriesList.length - 1)
//                                 Divider(color: Colors.grey[200], height: 1, indent: 60, endIndent: 16),
//                             ],
//                           );
//                         }, childCount: _otherCountriesList.length),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//     );
//   }

//   Widget _buildCountryListTile(Country country, bool isSelected) {
//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//       leading: Text(_getFlagEmoji(country.alpha2Code ?? ''), style: const TextStyle(fontSize: 24)),
//       title: Text(
//         country.nameTranslations?[context.locale.toString()] ?? country.alpha2Code ?? 'Unknown',
//         style: TextStyle(
//           color: isSelected ? Theme.of(context).primaryColor : Colors.black,
//           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//         ),
//       ),
//       subtitle: Text('Code: ${country.alpha2Code}', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
//       trailing: Text(
//         country.dialCode ?? '',
//         style: TextStyle(
//           color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
//           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//         ),
//       ),
//       selected: isSelected,
//       selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
//       onTap: () {
//         Navigator.pop(context);
//         _handleCountryChanged(country);
//       },
//     );
//   }

//   String _getFlagEmoji(String countryCode) {
//     // Convert country code to flag emoji
//     if (countryCode.length != 2) return '🏳️';

//     final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
//     final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;

//     return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
//   }

//   void _handleCountryChanged(Country country) {
//     try {
//       final dialCode = country.dialCode ?? '';
//       final countryCode = country.alpha2Code ?? '';

//       if (_currentCountryCode != dialCode) {
//         setState(() {
//           _currentCountry = country;
//           _currentCountryCode = dialCode;
//           _updateInputFormatter();
//           _isValidPhone = true; // Reset validation state
//         });

//         widget.controller.clear();
//         widget.onChangedCountryCode?.call(dialCode, countryCode);
//         _lastValidNumber = '';
//       }
//     } catch (e) {
//       debugPrint('Error handling country change: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     super.dispose();
//   }

//   void _onChangedDebounced(String value) {
//     _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 1000), () {
//       if (mounted && !_isUpdatingProgrammatically) {
//         _handlePhoneChange(value);
//         _validatePhoneNumberAsync(value); // Async validation
//       }
//     });
//   }

//   void _onChangedInstant(String value) {
//     if (!_isUpdatingProgrammatically && mounted) {
//       _handlePhoneChange(value);
//       // Trigger async validation after a short delay
//       Timer(const Duration(milliseconds: 500), () {
//         _validatePhoneNumberAsync(value);
//       });
//     }
//   }

//   void _handlePhoneChange(String value) {
//     try {
//       if (widget.onChanged != null) {
//         final phoneValue = widget.includeCountryCodeInValue ? '$_currentCountryCode$value' : value;

//         if (phoneValue != _lastValidNumber) {
//           _lastValidNumber = phoneValue;
//           debugPrint('Phone number changed: $phoneValue (raw: $value, country: ${_currentCountry.alpha2Code})');
//           widget.onChanged!(phoneValue);
//         }
//       }
//     } catch (e) {
//       debugPrint('Error handling phone change: $e');
//     }
//   }

//   String _getPlaceholderText() {
//     // Since the new country model doesn't have placeholder, use a simple format
//     return widget.hint ?? 'Enter phone number';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (widget.title != null) ...[
//           Text(
//             widget.title!,
//             style: Theme.of(
//               context,
//             ).textTheme.labelMedium?.copyWith(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w400),
//           ),
//           const SizedBox(height: 8),
//         ],
//         Container(
//           margin: EdgeInsets.symmetric(horizontal: widget.margin),
//           child: Directionality(
//             textDirection: TextDirection.ltr,
//             child: TextFormField(
//               controller: widget.controller,
//               enabled: !widget.disabled,
//               readOnly: widget.readonly,
//               textAlign: widget.textAlign,
//               style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
//               validator: _syncValidator, // Use synchronous validator
//               autovalidateMode: AutovalidateMode.onUserInteraction,
//               keyboardType: TextInputType.phone,
//               textInputAction: TextInputAction.next,
//               inputFormatters: [FilteringTextInputFormatter.digitsOnly, _inputFormatter],
//               onChanged: widget.waitTyping ? _onChangedDebounced : _onChangedInstant,
//               onTap: widget.onTap,
//               decoration: InputDecoration(
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(
//                     width: 1,
//                     color: (widget.isBordered ?? true) ? Theme.of(context).primaryColor : Colors.transparent,
//                   ),
//                   borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(
//                     width: 1,
//                     color: (widget.isBordered ?? true) ? Colors.grey[300]! : Colors.transparent,
//                   ),
//                   borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(width: 1, color: Colors.red),
//                   borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
//                 ),
//                 focusedErrorBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(width: 1, color: Colors.red),
//                   borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
//                 ),
//                 filled: true,
//                 fillColor: widget.backgroundColor ?? (widget.disabled ? Colors.grey[100] : Colors.white),
//                 border: OutlineInputBorder(
//                   borderSide: BorderSide.none,
//                   borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
//                 ),
//                 errorMaxLines: 3,
//                 hintText: _getPlaceholderText(),
//                 hintStyle: TextStyle(color: widget.hintColor ?? Colors.grey[400], fontSize: 14),
//                 errorStyle: const TextStyle(fontSize: 14),
//                 prefixIcon: GestureDetector(
//                   onTap: _showCountryPicker,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(_getFlagEmoji(_currentCountry.alpha2Code ?? ''), style: const TextStyle(fontSize: 20)),
//                         const SizedBox(width: 8),
//                         Text(
//                           _currentCountry.dialCode ?? '',
//                           style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
//                         ),
//                         if (!widget.disabled && !widget.readonly) ...[
//                           const SizedBox(width: 4),
//                           Icon(Icons.arrow_drop_down, color: Colors.grey[700], size: 24),
//                         ],
//                         Container(
//                           height: 20,
//                           width: 1,
//                           color: Colors.grey[300],
//                           margin: const EdgeInsets.only(left: 8),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 prefixIconConstraints: const BoxConstraints(minWidth: 0),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

class CustomPhoneFormField extends StatefulWidget {
  const CustomPhoneFormField({
    super.key,
    required this.controller,
    this.selectedCode, // Made nullable
    this.initialCountryCode, // New parameter for country code like 'EG', 'KSA', etc.
    this.onChangedCountryCode,
    this.onChanged,
    this.validator,
    this.title,
    this.hint,
    this.fieldName,
    this.shadow,
    this.radius = 16,
    this.margin = 16,
    this.readonly = false,
    this.disabled = false,
    this.onTap,
    this.backgroundColor,
    this.hintColor,
    this.gender = 'male',
    this.isBordered,
    this.waitTyping = false,
    this.isRequired = false,
    this.textAlign = TextAlign.start,
    this.includeCountryCodeInValue = false,
  });

  final TextEditingController controller;
  final String? selectedCode; // Made nullable
  final String? initialCountryCode; // New parameter for country code (e.g., 'EG', 'KSA')
  final void Function(String code, String countryCode)? onChangedCountryCode;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final String? title;
  final String? hint;
  final String? fieldName;
  final List<BoxShadow>? shadow;
  final double radius;
  final double margin;
  final bool readonly;
  final bool disabled;
  final void Function()? onTap;
  final Color? backgroundColor;
  final Color? hintColor;
  final String gender;
  final bool? isBordered;
  final bool waitTyping;
  final bool isRequired;
  final TextAlign textAlign;
  final bool includeCountryCodeInValue;

  @override
  State<CustomPhoneFormField> createState() => _CustomPhoneFormFieldState();
}

// Custom TextInputFormatter to prevent invalid phone number input
class PhoneNumberInputFormatter extends TextInputFormatter {
  final Map<String, dynamic> countryData;

  PhoneNumberInputFormatter({required this.countryData});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;
    final countryCode = countryData['code'] as String;

    // If text is empty, allow it
    if (newText.isEmpty) {
      return newValue;
    }

    // Remove any non-digit characters first
    final digitsOnly = newText.replaceAll(RegExp(r'\D'), '');

    // Apply country-specific rules
    String validatedText = _validateByCountry(digitsOnly, countryCode);

    // If the validated text is different from what user typed, prevent the change
    if (validatedText != digitsOnly) {
      return oldValue;
    }

    return TextEditingValue(text: validatedText, selection: TextSelection.collapsed(offset: validatedText.length));
  }

  String _validateByCountry(String digitsOnly, String countryCode) {
    switch (countryCode) {
      case 'EG': // Egypt: must start with 1, format: 1XXXXXXXXX (10 digits total)
        if (digitsOnly.isNotEmpty && !digitsOnly.startsWith('1')) {
          return digitsOnly.substring(0, digitsOnly.length - 1); // Remove last invalid digit
        }
        if (digitsOnly.length > 10) {
          return digitsOnly.substring(0, 10); // Limit to 10 digits
        }
        // Additional validation for second digit (must be 0, 1, 2, or 5)
        if (digitsOnly.length >= 2) {
          final secondDigit = digitsOnly[1];
          if (!['0', '1', '2', '5'].contains(secondDigit)) {
            return digitsOnly.substring(0, 1); // Keep only first digit
          }
        }
        break;

      case 'LY': // Libya: must start with 9, format: 9X-XXXXXXX
        if (digitsOnly.isNotEmpty && !digitsOnly.startsWith('9')) {
          return digitsOnly.substring(0, digitsOnly.length - 1);
        }
        if (digitsOnly.length > 9) {
          return digitsOnly.substring(0, 9);
        }
        // Second digit must be between 1-5
        if (digitsOnly.length >= 2) {
          final secondDigit = int.tryParse(digitsOnly[1]) ?? 0;
          if (secondDigit < 1 || secondDigit > 5) {
            return digitsOnly.substring(0, 1);
          }
        }
        break;

      case 'KSA': // Saudi Arabia: must start with 5, format: 5XXXXXXXX
        if (digitsOnly.isNotEmpty && !digitsOnly.startsWith('5')) {
          return digitsOnly.substring(0, digitsOnly.length - 1);
        }
        if (digitsOnly.length > 9) {
          return digitsOnly.substring(0, 9);
        }
        break;

      case 'AE': // UAE: must start with 5, second digit 0 or 5, format: 5X-XXXXXXX
        if (digitsOnly.isNotEmpty && !digitsOnly.startsWith('5')) {
          return digitsOnly.substring(0, digitsOnly.length - 1);
        }
        if (digitsOnly.length > 9) {
          return digitsOnly.substring(0, 9);
        }
        if (digitsOnly.length >= 2) {
          final secondDigit = digitsOnly[1];
          if (!['0', '5'].contains(secondDigit)) {
            return digitsOnly.substring(0, 1);
          }
        }
        break;

      case 'KW': // Kuwait: must start with 6 or 9, format: X-XXXXXXX
        if (digitsOnly.isNotEmpty && !['6', '9'].contains(digitsOnly[0])) {
          return digitsOnly.substring(0, digitsOnly.length - 1);
        }
        if (digitsOnly.length > 8) {
          return digitsOnly.substring(0, 8);
        }
        break;

      case 'BH': // Bahrain: must start with 3, second digit 2-9, format: 3X-XXXXXXX
        if (digitsOnly.isNotEmpty && !digitsOnly.startsWith('3')) {
          return digitsOnly.substring(0, digitsOnly.length - 1);
        }
        if (digitsOnly.length > 8) {
          return digitsOnly.substring(0, 8);
        }
        if (digitsOnly.length >= 2) {
          final secondDigit = int.tryParse(digitsOnly[1]) ?? 0;
          if (secondDigit < 2 || secondDigit > 9) {
            return digitsOnly.substring(0, 1);
          }
        }
        break;

      case 'QA': // Qatar: must start with 5 or 6, format: XX-XXXXXX
        if (digitsOnly.isNotEmpty && !['5', '6'].contains(digitsOnly[0])) {
          return digitsOnly.substring(0, digitsOnly.length - 1);
        }
        if (digitsOnly.length > 8) {
          return digitsOnly.substring(0, 8);
        }
        break;

      case 'OM': // Oman: must start with 7 or 9, format: XX-XXXXXX
        if (digitsOnly.isNotEmpty && !['7', '9'].contains(digitsOnly[0])) {
          return digitsOnly.substring(0, digitsOnly.length - 1);
        }
        if (digitsOnly.length > 8) {
          return digitsOnly.substring(0, 8);
        }
        break;

      default:
        // For unknown countries, just limit to reasonable length
        if (digitsOnly.length > 15) {
          return digitsOnly.substring(0, 15);
        }
        break;
    }

    return digitsOnly;
  }
}

class _CustomPhoneFormFieldState extends State<CustomPhoneFormField> {
  Timer? _debounce;
  String _currentCountryCode = '';
  String _lastValidNumber = '';
  bool _isUpdatingProgrammatically = false;
  late PhoneNumberInputFormatter _inputFormatter;

  // Supported countries from backend configuration
  static Map<String, Map<String, dynamic>> get _supportedCountries => {
    // 'LY': {
    //   'code': 'LY',
    //   'key': '218',
    //   'dialCode': '+218',
    //   'name': LocaleKeys.country_libya.tr(),
    //   'flag': '🇱🇾',
    //   'all_keys': ['+218', '218', '00218', '0'],
    //   'regex': r"^(?:(\+|00)?218|0)?(9[1-5])(\d{7})$",
    //   'placeholder': LocaleKeys.phone_placeholder_libya.tr(),
    //   'format': LocaleKeys.phone_format_libya.tr(),
    // },
    'EG': {
      'code': 'EG',
      'key': '20',
      'dialCode': '+20',
      'name': LocaleKeys.country_egypt.tr(),
      'flag': '🇪🇬',
      'all_keys': ['+20', '20', '0', '0020'],
      'regex': r"^(?:(\+)?20|0)?(1[0125])(\d{8})$",
      'placeholder': LocaleKeys.phone_placeholder_egypt.tr(),
      'format': LocaleKeys.phone_format_egypt.tr(),
    },
    'KSA': {
      'code': 'KSA',
      'key': '966',
      'dialCode': '+966',
      'name': LocaleKeys.country_saudi_arabia.tr(),
      'flag': '🇸🇦',
      'all_keys': ['+966', '00966', '966', '0'],
      'regex': r"^(?:(\+|00)?966|0)?(5)(\d{8})$",
      'placeholder': LocaleKeys.phone_placeholder_saudi_arabia.tr(),
      'format': LocaleKeys.phone_format_saudi_arabia.tr(),
    },
    'AE': {
      'code': 'AE',
      'key': '971',
      'dialCode': '+971',
      'name': LocaleKeys.country_uae.tr(),
      'flag': '🇦🇪',
      'all_keys': ['+971', '00971', '971', '0'],
      'regex': r"^(?:(\+|00)?971|0)?(5[05])(\d{7})$",
      'placeholder': LocaleKeys.phone_placeholder_uae.tr(),
      'format': LocaleKeys.phone_format_uae.tr(),
    },
    'KW': {
      'code': 'KW',
      'key': '965',
      'dialCode': '+965',
      'name': LocaleKeys.country_kuwait.tr(),
      'flag': '🇰🇼',
      'all_keys': ['+965', '00965', '965', '0'],
      'regex': r"^(?:(\+|00)?965|0)?([6|9])(\d{7})$",
      'placeholder': LocaleKeys.phone_placeholder_kuwait.tr(),
      'format': LocaleKeys.phone_format_kuwait.tr(),
    },
    'BH': {
      'code': 'BH',
      'key': '973',
      'dialCode': '+973',
      'name': LocaleKeys.country_bahrain.tr(),
      'flag': '🇧🇭',
      'all_keys': ['+973', '00973', '973', '0'],
      'regex': r"^(?:(\+|00)?973|0)?(3[2-9])(\d{7})$",
      'placeholder': LocaleKeys.phone_placeholder_bahrain.tr(),
      'format': LocaleKeys.phone_format_bahrain.tr(),
    },
    'QA': {
      'code': 'QA',
      'key': '974',
      'dialCode': '+974',
      'name': LocaleKeys.country_qatar.tr(),
      'flag': '🇶🇦',
      'all_keys': ['+974', '00974', '974', '0'],
      'regex': r"^(?:(\+|00)?974|0)?([5|6]\d{1})(\d{6})$",
      'placeholder': LocaleKeys.phone_placeholder_qatar.tr(),
      'format': LocaleKeys.phone_format_qatar.tr(),
    },
    'OM': {
      'code': 'OM',
      'key': '968',
      'dialCode': '+968',
      'name': LocaleKeys.country_oman.tr(),
      'flag': '🇴🇲',
      'all_keys': ['+968', '00968', '968', '0'],
      'regex': r"^(?:(\+|00)?968|0)?([7|9]\d{1})(\d{6})$",
      'placeholder': LocaleKeys.phone_placeholder_oman.tr(),
      'format': LocaleKeys.phone_format_oman.tr(),
    },
  };

  @override
  void initState() {
    super.initState();
    _initializeCountryCode();
    _updateInputFormatter();
    _initializeController();
  }

  void _initializeCountryCode() {
    // Priority: selectedCode -> initialCountryCode -> default to Egypt
    if (widget.selectedCode != null && widget.selectedCode!.isNotEmpty) {
      _currentCountryCode = widget.selectedCode!;
    } else if (widget.initialCountryCode != null && widget.initialCountryCode!.isNotEmpty) {
      // Convert country code like 'EG' to dial code like '+20'
      final countryData = _getCountryDataByCode(widget.initialCountryCode!);
      if (countryData != null) {
        _currentCountryCode = countryData['dialCode'] as String;
      } else {
        // Fallback to Egypt if country code not found
        _currentCountryCode = '+20';
      }
    } else {
      // Default to Egypt
      _currentCountryCode = '+20';
    }
  }

  Map<String, dynamic>? _getCountryDataByCode(String countryCode) {
    try {
      return _supportedCountries.values.firstWhere((country) => country['code'] == countryCode.toUpperCase());
    } catch (e) {
      return null;
    }
  }

  @override
  void didUpdateWidget(CustomPhoneFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle selectedCode changes
    if (oldWidget.selectedCode != widget.selectedCode) {
      if (widget.selectedCode != null && widget.selectedCode!.isNotEmpty) {
        setState(() {
          _currentCountryCode = widget.selectedCode!;
          _updateInputFormatter();
        });
      }
    }

    // Handle initialCountryCode changes
    if (oldWidget.initialCountryCode != widget.initialCountryCode) {
      if (widget.initialCountryCode != null && widget.initialCountryCode!.isNotEmpty) {
        final countryData = _getCountryDataByCode(widget.initialCountryCode!);
        if (countryData != null) {
          setState(() {
            _currentCountryCode = countryData['dialCode'] as String;
            _updateInputFormatter();
          });
        }
      }
    }

    if (oldWidget.controller != widget.controller) {
      _initializeController();
    }
  }

  void _updateInputFormatter() {
    final countryData = _getCurrentCountryData();
    _inputFormatter = PhoneNumberInputFormatter(countryData: countryData);
  }

  void _initializeController() {
    if (widget.controller.text.isNotEmpty) {
      _parseExistingPhoneNumber();
    }
  }

  void _parseExistingPhoneNumber() {
    try {
      final text = widget.controller.text;
      if (text.isNotEmpty) {
        final parts = _extractCountryCodeAndNumber(text);
        if (parts != null) {
          _currentCountryCode = parts['countryCode'] ?? _currentCountryCode;
          _updateInputFormatter();
          _isUpdatingProgrammatically = true;
          widget.controller.text = parts['number'] ?? '';
          _isUpdatingProgrammatically = false;
        }
      }
    } catch (e) {
      log('Error parsing phone number: $e');
      // Keep the initialized country code
    }
  }

  Map<String, String>? _extractCountryCodeAndNumber(String fullNumber) {
    try {
      for (final country in _supportedCountries.values) {
        final dialCode = country['dialCode'] as String;
        final allKeys = country['all_keys'] as List<String>;

        for (final key in allKeys) {
          if (fullNumber.startsWith(key)) {
            final number = fullNumber.substring(key.length);
            return {'countryCode': dialCode, 'number': number};
          }
        }
      }
      return null;
    } catch (e) {
      log('Error extracting country code and number: $e');
      return null;
    }
  }

  bool _validatePhoneNumber(String phoneNumber, String countryCode) {
    try {
      final country = _supportedCountries.values.firstWhere(
        (c) => c['dialCode'] == countryCode,
        orElse: () => <String, dynamic>{},
      );

      if (country.isEmpty) return false;

      final regex = RegExp(country['regex'] as String);
      final fullNumber = countryCode.replaceAll('+', '') + phoneNumber;

      return regex.hasMatch(fullNumber);
    } catch (e) {
      log('Error validating phone number: $e');
      return false;
    }
  }

  Map<String, dynamic> _getCurrentCountryData() {
    return _supportedCountries.values.firstWhere(
      (country) => country['dialCode'] == _currentCountryCode,
      orElse: () => _supportedCountries['EG']!,
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2)),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    LocaleKeys.select_country.tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),

                // Divider
                Divider(color: Colors.grey[700], height: 1),

                // Countries list
                Expanded(
                  child: ListView.separated(
                    itemCount: _supportedCountries.length,
                    separatorBuilder:
                        (context, index) => Divider(color: Colors.grey[700], height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final country = _supportedCountries.values.elementAt(index);
                      final isSelected = country['dialCode'] == _currentCountryCode;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        leading: Text(country['flag'] as String, style: const TextStyle(fontSize: 24)),
                        title: Text(
                          country['name'] as String,
                          style: TextStyle(
                            color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          'Format: ${country['format']}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        trailing: Text(
                          country['dialCode'] as String,
                          style: TextStyle(
                            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        onTap: () {
                          Navigator.pop(context);
                          _handleCountryChanged(country);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _handleCountryChanged(Map<String, dynamic> country) {
    try {
      final dialCode = country['dialCode'] as String;
      final countryCode = country['code'] as String;

      if (_currentCountryCode != dialCode) {
        setState(() {
          _currentCountryCode = dialCode;
          _updateInputFormatter();
        });

        // Clear the controller when country changes to prevent invalid format
        widget.controller.clear();

        widget.onChangedCountryCode?.call(dialCode, countryCode);
        _lastValidNumber = '';
      }
    } catch (e) {
      log('Error handling country change: $e');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChangedDebounced(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      if (mounted && !_isUpdatingProgrammatically) {
        _handlePhoneChange(value);
      }
    });
  }

  void _onChangedInstant(String value) {
    if (!_isUpdatingProgrammatically && mounted) {
      _handlePhoneChange(value);
    }
  }

  void _handlePhoneChange(String value) {
    try {
      if (widget.onChanged != null) {
        final phoneValue = widget.includeCountryCodeInValue ? '$_currentCountryCode$value' : value;

        if (phoneValue != _lastValidNumber) {
          _lastValidNumber = phoneValue;
          widget.onChanged!(phoneValue);
        }
      }
    } catch (e) {
      log('Error handling phone change: $e');
    }
  }

  String? _compositeValidator(String? value) {
    try {
      if (widget.isRequired && (value == null || value.isEmpty)) {
        return LocaleKeys.this_field_is_required.tr();
      }

      if (value != null && value.isNotEmpty) {
        final isValid = _validatePhoneNumber(value, _currentCountryCode);
        if (!isValid) {
          return LocaleKeys.invalid_phone_number_format.tr();
        }
      }

      if (widget.validator != null && value != null) {
        final fullNumber = widget.includeCountryCodeInValue ? '$_currentCountryCode$value' : value;
        return widget.validator!(fullNumber);
      }

      return null;
    } catch (e) {
      log('Error in validator: $e');
      return LocaleKeys.invalid_phone_number_format.tr();
    }
  }

  String _getPlaceholderText() {
    final country = _getCurrentCountryData();
    return country['placeholder'] as String? ?? widget.hint ?? 'Enter phone number';
  }

  @override
  Widget build(BuildContext context) {
    final currentCountry = _getCurrentCountryData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          margin: EdgeInsets.symmetric(horizontal: widget.margin),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: TextFormField(
              controller: widget.controller,
              enabled: !widget.disabled,
              readOnly: widget.readonly,
              textAlign: widget.textAlign,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
              validator: _compositeValidator,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, _inputFormatter],
              onChanged: (value) {
                if (widget.waitTyping) {
                  _onChangedDebounced(value);
                } else {
                  _onChangedInstant(value);
                }
              },
              onTap: widget.onTap,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: (widget.isBordered ?? true) ? Theme.of(context).primaryColor : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: (widget.isBordered ?? true) ? AppColors.borderColor : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 1, color: Colors.red),
                  borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 1, color: Colors.red),
                  borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
                ),
                filled: true,
                fillColor:
                    widget.backgroundColor ??
                    (widget.disabled ? const Color(0xff000000).withOpacity(0.2) : AppColors.white),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.5,
                    color: (widget.isBordered ?? true) ? Colors.transparent : Colors.blue,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
                ),
                errorMaxLines: 3,
                hintText: _getPlaceholderText(),
                hintStyle: TextStyle(color: widget.hintColor ?? Colors.grey[400], fontSize: 14),
                errorStyle: const TextStyle(fontSize: 14),

                // Custom prefix with country selector
                prefixIcon: GestureDetector(
                  onTap: widget.disabled || widget.readonly ? null : _showCountryPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(currentCountry['flag'] as String, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          currentCountry['dialCode'] as String,
                          style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        if (!widget.disabled && !widget.readonly) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, color: Colors.grey[700], size: 24),
                        ],
                        Container(
                          height: 20,
                          width: 1,
                          color: Colors.grey[600],
                          margin: const EdgeInsets.only(left: 8),
                        ),
                      ],
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
