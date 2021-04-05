class Book {
  final String title;
  final String coverUrl;
  final String author;
  final String goodreadsLink;
  final String averageRating;

  Book(
      {this.title,
        this.coverUrl,
        this.author,
        this.averageRating,
        this.goodreadsLink});

  factory Book.fromMap(Map<String, dynamic> object) {
    return Book(
      title: object['title']['\$t'],
      coverUrl: object['image_url']['\$t'].toString().replaceAll('._SX98_', ''),
      author: object['authors']['author']['name']['\$t'],
      averageRating: object['average_rating']['\$t'],
      goodreadsLink: object['link']['\$t'],
    );
  }

  @override
  String toString() {
    return 'Book{title: $title, coverUrl: $coverUrl, author: $author, goodreadsLink: $goodreadsLink, averageRating: $averageRating}';
  }
}
