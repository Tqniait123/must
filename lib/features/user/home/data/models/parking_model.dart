class Parking {
  final String id;
  final String title;
  final String address;
  final double pricePerHour;
  final String imageUrl;
  final int distanceInMinutes;

  Parking({
    required this.id,
    required this.title,
    required this.address,
    required this.pricePerHour,
    required this.imageUrl,
    required this.distanceInMinutes,
  });

  // Fake list of parking spots in Arabic
  static List<Parking> getFakeArabicParkingList() {
    return [
      Parking(
        id: '1',
        title: 'موقف وسط المدينة',
        address: 'شارع الملك فهد، الرياض',
        pricePerHour: 7,
        imageUrl:
            'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
        distanceInMinutes: 7,
      ),
      Parking(
        id: '2',
        title: 'موقف برج المملكة',
        address: 'طريق الملك فهد، حي العليا، الرياض',
        pricePerHour: 12,
        imageUrl:
            'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        distanceInMinutes: 15,
      ),
      Parking(
        id: '3',
        title: 'موقف الفيصلية',
        address: 'شارع الأمير سلطان، الخبر',
        pricePerHour: 9,
        imageUrl:
            'https://parkplus-bkt-img.parkplus.io/production/team/public/FS_20241211153149659441.webp',
        distanceInMinutes: 5,
      ),
      Parking(
        id: '4',
        title: 'موقف المركز التجاري',
        address: 'شارع التحلية، جدة',
        pricePerHour: 8,
        imageUrl:
            'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        distanceInMinutes: 10,
      ),
      Parking(
        id: '5',
        title: 'موقف المدينة الطبية',
        address: 'طريق الملك عبدالله، الدمام',
        pricePerHour: 5,
        imageUrl:
            'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
        distanceInMinutes: 3,
      ),
    ];
  }
}
