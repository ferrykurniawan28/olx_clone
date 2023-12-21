class PostItem {
  // String? postId;
  String postId, username, email, title, description, address, phoneNumber;
  int price;
  DateTime posteddate;
  List<String> imageUrl;

  PostItem({
    required this.postId,
    required this.username,
    required this.email,
    required this.title,
    required this.price,
    required this.posteddate,
    required this.description,
    required this.address,
    required this.phoneNumber,
    required this.imageUrl,
  });
}
