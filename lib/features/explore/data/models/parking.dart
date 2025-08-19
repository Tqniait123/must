class Parking {
  final int id;
  final String nameEn;
  final String nameAr;
  final Owner owner;
  final City city;
  final String address;
  final String lat;
  final String lng;
  final String pricePerHour; // Now in Points instead of EGP
  final String? aboutParking;
  final bool mostPopular; // Changed from String to bool
  final bool mostWanted; // Changed from String to bool
  final String status;
  final String mainImage;
  final Gallery gallery;
  final Gates gates;
  final Employers employers;
  final Floors floors;
  final String points;
  final bool isBusy;
  final int userVisits; // Added user visits count

  Parking({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.owner,
    required this.city,
    required this.address,
    required this.lat,
    required this.lng,
    required this.pricePerHour,
    this.aboutParking,
    required this.mostPopular,
    required this.mostWanted,
    required this.status,
    required this.mainImage,
    required this.gallery,
    required this.gates,
    required this.employers,
    required this.floors,
    required this.points,
    this.isBusy = false,
    required this.userVisits, // Required parameter
  });

  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['id'],
      nameEn: json['name (en)'],
      nameAr: json['name (ar)'],
      owner: Owner.fromJson(json['owner']),
      city: City.fromJson(json['city']),
      address: json['address'],
      lat: json['lat'],
      lng: json['lng'],
      pricePerHour: json['price / hour'], // Now represents points
      aboutParking: json['about parking'],
      mostPopular: json['most popular'] ?? false, // Now bool with default false
      mostWanted: json['most wanted'] ?? false, // Now bool with default false
      status: json['status'],
      mainImage: json['main image'],
      gallery: Gallery.fromJson(json['gallery']),
      gates: Gates.fromJson(json['gates']),
      employers: Employers.fromJson(json['employers']),
      floors: Floors.fromJson(json['floors']),
      points: json['points'],
      isBusy: json['busy'] ?? false,
      userVisits: json['user_visits'] ?? 0, // Default to 0 if not provided
    );
  }

  // Helper method to get location as a formatted string
  String get locationString => "$lat, $lng";

  static List<Parking> getFakeHistoryParkings() {
    return [
      Parking(
        id: 1,
        nameEn: "Central Park Garage",
        nameAr: "مرآب سنترال بارك",
        owner: Owner(
          id: 101,
          name: "John Smith",
          email: "john@example.com",
          phone: "+1234567890",
          city: City(id: 1, name: "New York"),
          image: "assets/images/owner1.jpg",
        ),
        city: City(id: 1, name: "New York"),
        address: "123 Main Street",
        lat: "40.7128",
        lng: "-74.0060",
        pricePerHour: "50", // Points instead of EGP
        aboutParking: "Modern parking facility in downtown",
        mostPopular: true, // Changed to bool
        mostWanted: false, // Changed to bool
        status: "Active",
        mainImage: "assets/images/parking1.jpg",
        gallery: Gallery(
          galleryCount: 2,
          gallery: [
            GalleryImage(image: "assets/images/gallery1.jpg"),
            GalleryImage(image: "assets/images/gallery2.jpg"),
          ],
        ),
        gates: Gates(
          entrancesCount: 2,
          entrance: [
            Gate(name: "Main Entrance", employer: "Available"),
            Gate(name: "Side Entrance", employer: "Available"),
          ],
          exitsCount: 2,
          exit: [Gate(name: "Main Exit", employer: "Available"), Gate(name: "Emergency Exit", employer: "Available")],
        ),
        employers: Employers(
          employersCount: 2,
          employers: [
            Employer(
              id: 1,
              name: "Mike Johnson",
              email: "mike@example.com",
              phone: "+1987654321",
              image: "assets/images/emp1.jpg",
              language: "English",
            ),
            Employer(
              id: 2,
              name: "Sarah Wilson",
              email: "sarah@example.com",
              phone: "+1122334455",
              image: "assets/images/emp2.jpg",
              language: "English",
            ),
          ],
        ),
        floors: Floors(
          floorsCount: 3,
          floors: [
            Floor(name: "Ground Floor", totalSpaces: 50, busy: true), // Changed to bool
            Floor(name: "First Floor", totalSpaces: 40, busy: false), // Changed to bool
            Floor(name: "Second Floor", totalSpaces: 30, busy: false), // Changed to bool
          ],
        ),
        points: "4.5",
        userVisits: 25, // Added user visits
      ),
      Parking(
        id: 2,
        nameEn: "Downtown Parking Complex",
        nameAr: "مجمع وقوف السيارات وسط المدينة",
        owner: Owner(
          id: 102,
          name: "David Brown",
          email: "david@example.com",
          phone: "+1234509876",
          city: City(id: 2, name: "Los Angeles"),
          image: "assets/images/owner2.jpg",
        ),
        city: City(id: 2, name: "Los Angeles"),
        address: "456 Broadway Ave",
        lat: "34.0522",
        lng: "-118.2437",
        pricePerHour: "65", // Points instead of EGP
        aboutParking: "Secure parking in the heart of downtown",
        mostPopular: false, // Changed to bool
        mostWanted: true, // Changed to bool
        status: "Active",
        mainImage: "assets/images/parking2.jpg",
        gallery: Gallery(
          galleryCount: 2,
          gallery: [
            GalleryImage(image: "assets/images/gallery3.jpg"),
            GalleryImage(image: "assets/images/gallery4.jpg"),
          ],
        ),
        gates: Gates(
          entrancesCount: 1,
          entrance: [Gate(name: "Main Entrance", employer: "Available")],
          exitsCount: 1,
          exit: [Gate(name: "Main Exit", employer: "Available")],
        ),
        employers: Employers(
          employersCount: 2,
          employers: [
            Employer(
              id: 3,
              name: "Tom Davis",
              email: "tom@example.com",
              phone: "+1567891234",
              image: "assets/images/emp3.jpg",
              language: "English",
            ),
            Employer(
              id: 4,
              name: "Lisa Anderson",
              email: "lisa@example.com",
              phone: "+1678912345",
              image: "assets/images/emp4.jpg",
              language: "English",
            ),
          ],
        ),
        floors: Floors(
          floorsCount: 2,
          floors: [
            Floor(name: "Level 1", totalSpaces: 60, busy: true), // Changed to bool
            Floor(name: "Level 2", totalSpaces: 40, busy: false), // Changed to bool
          ],
        ),
        points: "4.2",
        userVisits: 18, // Added user visits
      ),
    ];
  }
}

class Owner {
  final int id;
  final String name;
  final String email;
  final String phone;
  final City city;
  final String image;

  Owner({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.image,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      city: City.fromJson(json['city']),
      image: json['image'],
    );
  }
}

class City {
  final int id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(id: json['id'], name: json['name']);
  }
}

class Gallery {
  final int galleryCount;
  final List<GalleryImage> gallery;

  Gallery({required this.galleryCount, required this.gallery});

  factory Gallery.fromJson(Map<String, dynamic> json) {
    return Gallery(
      galleryCount: json['gallery count'],
      gallery: (json['gallery'] as List).map((e) => GalleryImage.fromJson(e)).toList(),
    );
  }
}

class GalleryImage {
  final String image;

  GalleryImage({required this.image});

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(image: json['image']);
  }
}

class Gates {
  final int entrancesCount;
  final List<Gate> entrance;
  final int exitsCount;
  final List<Gate> exit;

  Gates({required this.entrancesCount, required this.entrance, required this.exitsCount, required this.exit});

  factory Gates.fromJson(Map<String, dynamic> json) {
    return Gates(
      entrancesCount: json['entrances count'],
      entrance: (json['entrance'] as List).map((e) => Gate.fromJson(e)).toList(),
      exitsCount: json['exits count'],
      exit: (json['exit'] as List).map((e) => Gate.fromJson(e)).toList(),
    );
  }
}

class Gate {
  final String name;
  final dynamic employer; // Can be String or Employer object

  Gate({required this.name, required this.employer});

  factory Gate.fromJson(Map<String, dynamic> json) {
    return Gate(
      name: json['name'],
      employer: json['employer'] is Map ? Employer.fromJson(json['employer']) : json['employer'],
    );
  }
}

class Employers {
  final int employersCount;
  final List<Employer> employers;

  Employers({required this.employersCount, required this.employers});

  factory Employers.fromJson(Map<String, dynamic> json) {
    return Employers(
      employersCount: json['employers count'],
      employers: (json['employers'] as List).map((e) => Employer.fromJson(e)).toList(),
    );
  }
}

class Employer {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String image;
  final dynamic language;

  Employer({this.id, required this.name, required this.email, required this.phone, required this.image, this.language});

  factory Employer.fromJson(Map<String, dynamic> json) {
    return Employer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      image: json['image'],
      language: json['language'],
    );
  }
}

class Floors {
  final int floorsCount;
  final List<Floor> floors;

  Floors({required this.floorsCount, required this.floors});

  factory Floors.fromJson(Map<String, dynamic> json) {
    return Floors(
      floorsCount: json['floors count'],
      floors: (json['floors'] as List).map((e) => Floor.fromJson(e)).toList(),
    );
  }
}

class Floor {
  final String name;
  final int totalSpaces;
  final bool busy; // Changed from String to bool

  Floor({required this.name, required this.totalSpaces, required this.busy});

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      name: json['name'],
      totalSpaces: json['total spaces'],
      busy: json['busy'] ?? false, // Now bool with default false
    );
  }
}
