class Parking {
  final String id;
  final String title;
  final String address;
  final double pricePerHour;
  final String imageUrl;
  final int distanceInMinutes;
  final double lat;
  final double lng;
  final bool isBusy;
  final List<String> gallery;

  Parking({
    required this.id,
    required this.title,
    required this.address,
    required this.pricePerHour,
    required this.imageUrl,
    required this.distanceInMinutes,
    required this.lat,
    required this.lng,
    required this.isBusy,
    required this.gallery,
  });

  static List<Parking> getFakeArabicParkingList() {
    return [
      Parking(
        id: '1',
        title: 'موقف كورنيش النيل',
        address: 'كورنيش النيل، القاهرة',
        pricePerHour: 10,

        distanceInMinutes: 7,

        imageUrl:
            'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',

        lat: 30.0444,
        lng: 31.2357,
        isBusy: false,
        gallery: [
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
        ],
      ),
      Parking(
        title: 'موقف برج المملكة',
        address: 'طريق الملك فهد، حي العليا، الرياض',
        pricePerHour: 12,
        imageUrl:
            'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        distanceInMinutes: 15,

        // imageUrl: 'https://images.unsplash.com/photo-1549924231-f129b911e442',
        // id: '2',
        // title: 'موقف مصر الجديدة',
        // address: 'شارع الثورة، مصر الجديدة، القاهرة',
        // pricePerHour: 8,

        // distanceInMinutes: 6,
        lat: 30.0866,
        lng: 31.3300,
        isBusy: true,
        gallery: [
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        ],
        id: '2',
      ),
      Parking(
        id: '3',
        title: 'موقف المعادي',
        address: 'طريق النصر، المعادي، القاهرة',
        pricePerHour: 7,
        imageUrl:
            'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        distanceInMinutes: 9,
        lat: 29.9603,
        lng: 31.2596,
        isBusy: false,
        gallery: [
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        ],
      ),
    ];
  }
}


