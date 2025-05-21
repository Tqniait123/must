String handleResponseErrors(Map<String, dynamic> data) {
  String errorMessage = '';
  if (data['message'] != "Validation Error") {
    return data['message'];
  } else {
    if (data['errors'] != null) {
      // Iterate through the 'errors' map
      data['errors'].forEach((key, value) {
        // Check if the value is a list, then join the messages with '\n'
        if (value is List) {
          errorMessage += '* ${value.join('\n')}\n';
        }
      });
    }

    // Return the combined error message, trimming any trailing newlines
    return errorMessage.trim();
  }
}
