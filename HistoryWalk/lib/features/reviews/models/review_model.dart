class Review {
  final String id;          // Unique ID (useful for database later)
  final String userName;    // Name of the reviewer
  final double rating;      // 1.0 to 5.0
  final String text;        // The actual review content
  //final String? avatarUrl;  // Optional: URL if you have images later

  // Constructor
  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.text,
    //this.avatarUrl,
  });
}