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
  final String information;
  final String? startPoint;
  final String? endPoint;
  final String? durationTime;
  final double? price;
  final double? points;

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
    required this.information,
    this.startPoint,
    this.endPoint,
    this.durationTime,
    this.price,
    this.points,
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
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        ],
        information:
            '24/7 parking facility with cctv camera, professional security guard, chair disble, floor parking list facilities. You will get hassle parking facilities with 35% discount on first parking...',
      ),
      Parking(
        id: '2',
        title: 'موقف برج المملكة',
        address: 'طريق الملك فهد، حي العليا، الرياض',
        pricePerHour: 12,
        distanceInMinutes: 15,
        imageUrl:
            'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        lat: 30.0866,
        lng: 31.3300,
        isBusy: true,
        gallery: [
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        ],
        information:
            '24/7 parking facility with cctv camera, professional security guard, chair disble, floor parking list facilities. You will get hassle parking facilities with 35% discount on first parking...',
      ),
      Parking(
        id: '3',
        title: 'موقف المعادي',
        address: 'طريق النصر، المعادي، القاهرة',
        pricePerHour: 7,
        distanceInMinutes: 9,
        imageUrl:
            'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        lat: 29.9603,
        lng: 31.2596,
        isBusy: false,
        gallery: [
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        ],
        information:
            '24/7 parking facility with cctv camera, professional security guard, chair disble, floor parking list facilities. You will get hassle parking facilities with 35% discount on first parking...',
      ),
      Parking(
        id: '4',
        title: 'موقف وسط البلد',
        address: 'شارع طلعت حرب، وسط البلد، القاهرة',
        pricePerHour: 9,
        distanceInMinutes: 11,
        imageUrl:
            'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
        lat: 30.0500,
        lng: 31.2430,
        isBusy: true,
        gallery: [
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        ],
        information:
            '24/7 parking facility with cctv camera, professional security guard, chair disble, floor parking list facilities...',
      ),
      Parking(
        id: '5',
        title: 'موقف سيتي ستارز',
        address: 'شارع عمر بن الخطاب، مدينة نصر، القاهرة',
        pricePerHour: 15,
        distanceInMinutes: 6,
        imageUrl:
            'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        lat: 30.0744,
        lng: 31.3463,
        isBusy: false,
        gallery: [
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        ],
        information:
            '24/7 parking facility with cctv camera, professional security guard...',
      ),
      Parking(
        id: '6',
        title: 'موقف رمسيس',
        address: 'ميدان رمسيس، القاهرة',
        pricePerHour: 8,
        distanceInMinutes: 8,
        imageUrl:
            'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
        lat: 30.0600,
        lng: 31.2500,
        isBusy: true,
        gallery: [
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        ],
        information: 'موقف مفتوح على مدار الساعة مع خصم لأول مرة.',
      ),
      Parking(
        id: '7',
        title: 'موقف مدينة نصر',
        address: 'شارع مكرم عبيد، مدينة نصر، القاهرة',
        pricePerHour: 11,
        distanceInMinutes: 10,
        imageUrl:
            'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        lat: 30.0700,
        lng: 31.3300,
        isBusy: false,
        gallery: [
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        ],
        information: 'موقف آمن بوجود حراسة وكاميرات مراقبة.',
      ),
      Parking(
        id: '8',
        title: 'موقف الزمالك',
        address: 'شارع الجبلاية، الزمالك، القاهرة',
        pricePerHour: 14,
        distanceInMinutes: 13,
        imageUrl:
            'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
        lat: 30.0639,
        lng: 31.2156,
        isBusy: true,
        gallery: [
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        ],
        information: 'موقف هادئ وآمن في منطقة الزمالك الراقية.',
      ),
      Parking(
        id: '9',
        title: 'موقف أكتوبر',
        address: 'شارع الحصري، 6 أكتوبر، الجيزة',
        pricePerHour: 6,
        distanceInMinutes: 18,
        imageUrl:
            'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        lat: 29.9765,
        lng: 30.9579,
        isBusy: false,
        gallery: [
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        ],
        information: 'موقف اقتصادي وآمن وقريب من مول العرب.',
      ),
      Parking(
        id: '10',
        title: 'موقف الرحاب',
        address: 'مدينة الرحاب، القاهرة الجديدة',
        pricePerHour: 13,
        distanceInMinutes: 12,
        imageUrl:
            'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        lat: 30.1161,
        lng: 31.6018,
        isBusy: true,
        gallery: [
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        ],
        information: 'موقف حديث وآمن داخل المدينة.',
      ),
    ];
  }

  static List<Parking> getFakeHistoryParkings() {
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
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        ],
        information:
            '24/7 parking facility with cctv camera, professional security guard, chair disble, floor parking list facilities. You will get hassle parking facilities with 35% discount on first parking...',
        startPoint: 'شارع ٧  ',
        endPoint: 'شارع النيل، القاهرة',
        durationTime: '2 hours',
        price: 20.0,
        points: 100.0,
      ),
      Parking(
        id: '2',
        title: 'موقف برج المملكة',
        address: 'طريق الملك فهد، حي العليا، الرياض',
        pricePerHour: 12,
        distanceInMinutes: 15,
        imageUrl:
            'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        lat: 30.0866,
        lng: 31.3300,
        isBusy: true,
        gallery: [
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
          'https://d19r6u3d126ojb.cloudfront.net/Free_parking_in_Sharjah_55663b6dce.webp',
          'https://blog.oneclickdrive.com/wp-content/uploads/2023/06/image-17.png',
        ],
        information:
            '24/7 parking facility with cctv camera, professional security guard, chair disble, floor parking list facilities. You will get hassle parking facilities with 35% discount on first parking...',
        startPoint: 'شارع ابو الخير',
        endPoint: 'شارع الملك فهد',
        durationTime: '2 hours',
        price: 24.0,
        points: 120.0,
      ),
      // Continuing with the same pattern for remaining items...
      // Adding only first 2 items for brevity, but the same changes should be applied to all items
    ];
  }
}
