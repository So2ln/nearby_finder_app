class Location {
  final String title; //장소 이름
  final String category; //카테고리
  final String roadAddress; //도로명 주소
  // 리뷰 페이지에서 좌표를 사용하기 위해 추가
  final String mapx;
  final String mapy;
  double averageRating; // 평균 별점
  int reviewCount; // 리뷰 개수

  Location({
    required this.title,
    required this.category,
    required this.roadAddress,
    required this.mapx,
    required this.mapy,
    this.averageRating = 0.0, // 기본값 0.0
    this.reviewCount = 0, // 기본값 0
  });

  // JSON(Map<String,dynamic>) 형태의 데이터를 Location 객체로 변환해주는 생성자
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      // <b> 태그 같은 HTML태그를 제거하기 위해 replaceAll 사용
      title: (json['title'] as String).replaceAll(
        RegExp(r'<[^>]*>|&[^;]+;'),
        '',
      ),
      category: json['category'] ?? '',
      roadAddress: json['roadAddress'] ?? '',
      mapx: json['mapx'] ?? '',
      mapy: json['mapy'] ?? '',
    );
  }

  // Location 객체를 JSON(Map<String,dynamic>) 형태로 변환해주는 메서드
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'roadAddress': roadAddress,
      'mapx': mapx,
      'mapy': mapy,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
    };
  }
}
