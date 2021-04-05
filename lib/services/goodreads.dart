import 'package:http/http.dart' as http;
import 'package:gobind/common/common_const.dart';
import 'package:gobind/models/book_model.dart';
import 'package:xml2json/xml2json.dart';
import 'dart:convert';

class GoodReadsService {
  static final GoodReadsService _goodReadsAPI = GoodReadsService._internal();
  GoodReadsService._internal();

  final _key = 'enter key here';
  final url = 'www.goodreads.com';
  final _userId = 'enter user here';
  bool _isFirstRequest = true;
  int _numOfPages = 1;
  static Map<String, Map<int, List<Book>>> _booksMap = {};

  factory GoodReadsService() {
    return _goodReadsAPI;
  }

  Future<List<Book>> getBooks({int pageNumber = 1, String shelf = 'read'}) async {
    if (_isFirstRequest) {
      pageNumber = 1;
    } else {
      if(pageNumber < 1 || pageNumber > _numOfPages)
        return [];
      if (_booksMap.containsKey(shelf)) {
        if(_booksMap[shelf].containsKey(pageNumber)){
          if (_booksMap[shelf][pageNumber].isNotEmpty) {
            return _booksMap[shelf][pageNumber];
          }
        }
      }
    }
    List<Book> books = [];
    final List jsonBooksObject = await getJsonBooks(pageNumber, shelf);
    if(jsonBooksObject != null){
      jsonBooksObject.forEach((book) {
        books.add(Book.fromMap(book));
      });
      _booksMap[shelf] = {pageNumber: books};
    }
    if (DEBUG) print('Books array' + books.toString());
    return books;
  }

  getJsonBooks(int pageNumber, String shelf) async {
    final queryParameters = {
      'key': _key,
      'version': '2',
      'shelf': shelf,
      'page': '$pageNumber',
      'per_page': '10',
      'sort': 'date_added'
    };
    final uri = Uri.https('$url', '/review/list/$_userId.xml', queryParameters);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final xml2Json = Xml2Json();
      xml2Json.parse(response.body);
      final jsonObj = json.decode(xml2Json.toGData());
      if (DEBUG) print('Goodreads response - ${jsonObj['GoodreadsResponse']}');
      // store number of pages if it is first request
      if (_isFirstRequest) {
        _numOfPages =
            int.parse(jsonObj['GoodreadsResponse']['books']['numpages']);
        _isFirstRequest = false;
      }
      return jsonObj['GoodreadsResponse']['books']['book'];
    } else {
      if (DEBUG)
        print('Goodreads request failed with status: ${response.statusCode}.');
      return [];
    }
  }

  isLastPage(int currentPage) {
    return currentPage == _numOfPages;
  }
}
