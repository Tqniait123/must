import 'package:flutter/material.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/notifications/data/models/notification_model.dart';

class Constants {
  static const String photosPath = 'assets/images/';
  // static const String fontFamily = 'Poppins';
  static const String fontFamilyEN = 'Poppins';
  static const String fontFamilyAR = 'Almarai';
  static const String allTopic = 'all';
  static const String logo = 'assets/images/logo.png';
  static GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();
  static const String placeholderImage =
      'https://static.vecteezy.com/system/resources/thumbnails/004/511/281/small_2x/default-avatar-photo-placeholder-profile-picture-vector.jpg';
  static List<BoxShadow> shadow = [
    BoxShadow(
      offset: const Offset(0, 11),
      blurRadius: 23,
      color: Colors.black.withValues(alpha: 0.1),
    ),
    BoxShadow(
      offset: const Offset(0, 42),
      blurRadius: 42,
      color: Colors.black.withValues(alpha: 0.09),
    ),
    BoxShadow(
      offset: const Offset(0, 95),
      blurRadius: 57,
      color: Colors.black.withValues(alpha: 0.05),
    ),
    BoxShadow(
      offset: const Offset(0, 169),
      blurRadius: 67,
      color: Colors.black.withValues(alpha: 0.01),
    ),
    BoxShadow(
      offset: const Offset(0, 264),
      blurRadius: 74,
      color: Colors.black.withValues(alpha: 0),
    ),
  ];

  static List<String> labsImages = [
    'https://img.freepik.com/free-vector/flat-design-graphic-designer-template_23-2150511816.jpg?semt=ais_hybrid&w=740',
    'https://t4.ftcdn.net/jpg/02/20/80/69/360_F_220806920_yaO2aiemo2jVZY5h9StnixrVrRqylFsa.jpg',
    'https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto,q_auto,f_auto/gigs/240569216/original/8591e8024f0539f58a72d813f952075f9751c4bc/do-any-graphic-design-you-need-337b.jpg',
    // 'https://static.wixstatic.com/media/886c02_7031d8777189492ea1bb3bf5b7bf8bcf~mv2.png/v1/fill/w_1306,h_695,al_c/886c02_7031d8777189492ea1bb3bf5b7bf8bcf~mv2.png',
    // 'https://resalalab.com/wp-content/uploads/2023/01/resala-logo3-left.png',
    // 'https://medicareeg.com/wp-content/uploads/2022/08/%D9%85%D8%B9%D8%A7%D9%85%D9%84-%D8%A7%D9%84%D9%86%D9%8A%D9%84-%D9%84%D9%84%D8%A7%D8%B4%D8%B9%D8%A9-%D9%88%D8%A7%D9%84%D8%AA%D8%AD%D8%A7%D9%84%D9%8A%D9%84.png',
  ];

  static List<NotificationModel> fakeNotifications = [
    NotificationModel(
      id: '1',
      title: 'طلب سحب',
      description: 'سحب رصيد من المحفظة',

      date: '2025-05-07',
    ),
    NotificationModel(
      id: '2',
      title: 'إيداع رصيد',
      description: 'تم شحن المحفظة عن طريق فودافون كاش',

      date: '2025-05-06',
    ),
    NotificationModel(
      id: '3',
      title: 'طلب سحب',
      description: 'فشل في سحب الرصيد',
      date: '2025-05-05',
    ),
    NotificationModel(
      id: '4',
      title: 'إيداع رصيد',
      description: 'إيداع عن طريق البنك',
      date: '2025-05-04',
    ),
    NotificationModel(
      id: '5',
      title: 'طلب سحب',
      description: 'تم سحب الرصيد بنجاح',
      date: '2025-05-03',
    ),
  ];

  static String placeholderProfileImage =
      'https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D';

  static List<User> getRealisticFakeUsers() {
    return [
      User(
        id: 1,
        name: 'أحمد خالد',
        email: 'ahmed.khaled@gmail.com',
        phoneNumber: '01012345678',
        address: 'مدينة نصر، القاهرة',
        linkId: 'link-1',
        photo: null,
        isOnline: true,
        cars: [
          Car(id: '1-1', model: 'Hyundai Elantra', plateNumber: 'س ن ر 1234'),
        ],
      ),
      User(
        id: 2,
        name: 'ياسمين محمد',
        email: 'yasmin.mohamed@hotmail.com',
        phoneNumber: '01122334455',
        address: 'المعادي، القاهرة',
        linkId: 'link-2',
        photo: null,
        isOnline: false,
        cars: [
          Car(id: '2-1', model: 'Kia Sportage', plateNumber: 'م ل ي 4455'),
          Car(id: '2-2', model: 'Fiat Tipo', plateNumber: 'س د ن 8811'),
        ],
      ),
      User(
        id: 3,
        name: 'علي حسن',
        email: 'ali.hassan@gmail.com',
        phoneNumber: '01234567890',
        address: 'سموحة، الإسكندرية',
        linkId: 'link-3',
        photo: null,
        isOnline: true,
        cars: [
          Car(id: '3-1', model: 'Chevrolet Optra', plateNumber: 'ب و ج 6622'),
        ],
      ),
      User(
        id: 4,
        name: 'ندى عمرو',
        email: 'nada.amr@yahoo.com',
        phoneNumber: '01099988776',
        address: 'الهرم، الجيزة',
        linkId: 'link-4',
        photo: null,
        isOnline: false,
        cars: [
          Car(id: '4-1', model: 'Toyota Corolla', plateNumber: 'ع س ب 1100'),
        ],
      ),
      User(
        id: 5,
        name: 'محمد عبد الله',
        email: 'mo.abdullah@gmail.com',
        phoneNumber: '01555544433',
        address: 'وسط البلد، القاهرة',
        linkId: 'link-5',
        photo: null,
        isOnline: true,
        cars: [
          Car(id: '5-1', model: 'Nissan Sunny', plateNumber: 'ر ك م 7788'),
        ],
      ),
      User(
        id: 6,
        name: 'داليا سامي',
        email: 'dalia.samy@gmail.com',
        phoneNumber: '01055667788',
        address: 'مدينتي، القاهرة الجديدة',
        linkId: 'link-6',
        photo: null,
        isOnline: false,
        cars: [Car(id: '6-1', model: 'Honda Civic', plateNumber: 'ط و ف 3344')],
      ),
      User(
        id: 7,
        name: 'محمود السيد',
        email: 'mahmoud.elsayed@gmail.com',
        phoneNumber: '01234543210',
        address: 'شبرا، القاهرة',
        linkId: 'link-7',
        photo: null,
        isOnline: true,
        cars: [Car(id: '7-1', model: 'BMW 320i', plateNumber: 'ع ي ن 2020')],
      ),
      User(
        id: 8,
        name: 'فاطمة مصطفى',
        email: 'fatma.mustafa@gmail.com',
        phoneNumber: '01114141414',
        address: 'المنصورة، الدقهلية',
        linkId: 'link-8',
        photo: null,
        isOnline: false,
        cars: [
          Car(id: '8-1', model: 'Renault Logan', plateNumber: 'د ه م 6677'),
        ],
      ),
      User(
        id: 9,
        name: 'خالد إبراهيم',
        email: 'khaled.ibrahim@hotmail.com',
        phoneNumber: '01221212121',
        address: 'طنطا، الغربية',
        linkId: 'link-9',
        photo: null,
        isOnline: true,
        cars: [
          Car(id: '9-1', model: 'Mercedes C180', plateNumber: 'م ب ل 8899'),
          Car(id: '9-2', model: 'Jeep Compass', plateNumber: 'ش س ق 9090'),
        ],
      ),
      User(
        id: 10,
        name: 'آية مجدي',
        email: 'aya.magdy@gmail.com',
        phoneNumber: '01078787878',
        address: 'العصافرة، الإسكندرية',
        linkId: 'link-10',
        photo: null,
        isOnline: false,
        cars: [
          Car(id: '10-1', model: 'Peugeot 301', plateNumber: 'ف ط ب 5566'),
        ],
      ),
    ];
  }
}
