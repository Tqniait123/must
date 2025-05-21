bool isValidPhone(String value) {
  // Regular expression to match valid phone formats
  final regex = RegExp(r'^(?:\+?2)?01[0-9]{9}$');

  // Validate the phone number
  return regex.hasMatch(value);
}
