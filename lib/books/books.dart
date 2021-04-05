import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gobind/services/goodreads.dart';
import 'package:gobind/books/view_enum.dart';
import 'package:gobind/common/common.dart';
import 'package:gobind/common/common_const.dart';
import 'package:gobind/models/book_model.dart';
import 'package:gobind/styles/styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class Books extends StatefulWidget {
  @override
  _BooksState createState() => _BooksState();
}

class _BooksState extends State<Books> {
  PagingController<int, Book> _pagingController;
  List<Book> books;
  View view;
  String shelf;
  final shelves = {'Recent Reads': 'read', 'In My Bucket List': 'to-read'};
  Color titleColor;

  @override
  void initState() {
    view = View.list;
    shelf = shelves.keys.elementAt(0);
    initializePagingController();
    super.initState();
  }

  initializePagingController() {
    _pagingController = PagingController<int, Book>(
      firstPageKey: 1,
    );
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      await getBooks(page: pageKey, shelf: shelves[shelf]);
      final isLastPage = GoodReadsService().isLastPage(pageKey);
      if (isLastPage) {
        _pagingController.appendLastPage(books);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(books, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> getBooks({page = 1, shelf = 'read'}) async {
    books = await GoodReadsService().getBooks(pageNumber: page, shelf: shelf);
    return;
  }

  displayBooksList(Size size) {
    return PagedListView.separated(
        pagingController: _pagingController,
        padding: const EdgeInsets.all(8),
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        builderDelegate: PagedChildBuilderDelegate<Book>(
          itemBuilder: (context, book, index) => bookListItem(book),
          firstPageProgressIndicatorBuilder: (context) =>
              progressIndicator(context),
        ));
  }

  Widget bookListItem(Book book) {
    return GestureDetector(
      onTap: () async {
        await launch(book.goodreadsLink);
      },
      child: Container(
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(containerBorderRadius)),
        child: Row(
          children: [
            Container(
              height: 130,
              constraints: BoxConstraints(minWidth: 30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(containerBorderRadius),
                child: Hero(
                  tag: book.coverUrl,
                  child: CachedNetworkImage(
                    imageUrl: book.coverUrl,
                    placeholder: (context, url) =>
                        progressIndicator(context, color: Colors.grey),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                height: 130,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    getDetails('Title', book.title),
                    getDetails('Author', book.author),
                    getDetails(
                        'Avg Goodreads rating', book.averageRating + '/5'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getDetails(String key, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          '$key: ',
          style: Theme.of(context).textTheme.bodyText1,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Flexible(
          fit: FlexFit.loose,
          child: AutoSizeText(
            value,
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: Theme.of(context).textTheme.bodyText1.fontSize + 1),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  displayBooksGrid(Size size) {
    double width =
        size.width / 2 > coverMaxWidth ? size.width / 2 : coverMaxWidth;
    return PagedGridView(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          maxCrossAxisExtent: width,
          childAspectRatio: .53),
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Book>(
        itemBuilder: (context, book, index) => bookGridItem(book, width),
        firstPageProgressIndicatorBuilder: (context) =>
            progressIndicator(context),
      ),
    );
  }

  Widget bookGridItem(Book book, double width) {
    return GestureDetector(
      onTap: () async {
        await launch(book.goodreadsLink);
      },
      child: Column(
        children: [
          Container(
            width: width,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(containerBorderRadius),
                  topRight: Radius.circular(containerBorderRadius)),
              child: Hero(
                tag: book.coverUrl,
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  imageUrl: book.coverUrl,
                  placeholder: (context, url) =>
                      progressIndicator(context, color: Colors.grey),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
          ),
          Container(
            width: width,
            height: width / 9,
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(containerBorderRadius),
                  bottomLeft: Radius.circular(containerBorderRadius)),
            ),
            child: Center(
              child: AutoSizeText(
                book.title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontWeight: FontWeight.bold),
                minFontSize: 12,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getViewButton(View viewButton, Size size) {
    return Transform.scale(
      scale: view == viewButton ? 1.1 : 0.9,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(containerBorderRadius),
          boxShadow: [
            view == viewButton
                ? BoxShadow(
                    color: jet.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 1), // changes position of shadow
                  )
                : BoxShadow(),
          ],
        ),
        child: Center(
          child: IconButton(
            icon: Icon(
              viewButton == View.list ? Icons.list : Icons.grid_view,
              color: Theme.of(context).accentColor,
              size: size.width * size.height / 15000,
            ),
            onPressed: () {
              if (view != viewButton)
                setState(() {
                  view = viewButton;
                });
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).backgroundColor,
      statusBarColor: Theme.of(context).backgroundColor,
    ));
    titleColor = getTitleColor(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Theme.of(context).accentColor,
        appBar: AppBar(
          elevation: 1,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: titleColor.withOpacity(0.5),
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text(
            englishLanguage['books'],
            style: Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(color: titleColor),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // view controllers
            Container(
              color: Theme.of(context).backgroundColor,
              height: size.width * size.height / 5000,
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius:
                            BorderRadius.circular(containerBorderRadius)),
                    child: DropdownButton<String>(
                      value: shelf,
                      dropdownColor: Theme.of(context).backgroundColor,
                      icon: Icon(
                        Icons.arrow_drop_down,
                      ),
                      iconSize: 15,
                      elevation: 16,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(color: Theme.of(context).accentColor),
                      onChanged: (String newValue) {
                        setState(() {
                          shelf = newValue;
                          _pagingController.refresh();
                        });
                      },
                      items: shelves.keys
                          .toList()
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  getViewButton(View.list, size),
                  SizedBox(
                    width: 5,
                  ),
                  getViewButton(View.grid, size),
                ],
              ),
            ),
            // books display
            Expanded(
              child: view == View.list
                  ? displayBooksList(size)
                  : displayBooksGrid(size),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              color: Theme.of(context).backgroundColor,
              width: double.infinity,
              child: Center(
                child: Text(
                  englishLanguage['goodreadsMessage'],
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: Theme.of(context).accentColor,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300),
                ),
              ),
            )
          ],
        ));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
