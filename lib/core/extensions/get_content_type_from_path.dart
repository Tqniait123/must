String getContentTypeFromImagePath(String imagePath) {
  String fileExtension = imagePath.split('.').last.toLowerCase();

  if (fileExtension == 'jpeg' || fileExtension == 'jpg') {
    // Return content type for JPEG images
    return 'image/jpeg';
  } else if (fileExtension == 'png') {
    // Return content type for PNG images
    return 'image/png';
  } else {
    // Unsupported file format
    throw UnsupportedError('Unsupported image format');
  }
}
