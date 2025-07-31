class Location {
  final String title; //장소 이름
  final String category; //카테고리
  final String roadAddress; //도로명 주소

  Location({
    required this.title,
    required this.category,
    required this.roadAddress,
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
    );
  }
}
