import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portfolio_app/services/goodreads.dart';
import 'package:portfolio_app/books/view_enum.dart';
import 'package:portfolio_app/common/common.dart';
import 'package:portfolio_app/common/common_const.dart';
import 'package:portfolio_app/models/book_model.dart';
import 'package:portfolio_app/styles/styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class Books extends StatefulWidget {
  const Books({super.key});

  @override
  BooksState createState() => BooksState();
}

class BooksState extends State<Books> {
  final ScrollController _scrollController = ScrollController();
  final List<Book> _books = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  bool _hasReachedMax = false;
  int _currentPage = 1;
  dynamic _error;

  late ViewType view;
  late String shelf;
  final Map<String, String> shelves = {
    'Recent Reads': 'read',
    'In My Bucket List': 'to-read'
  };
  Color? titleColor;

  @override
  void initState() {
    super.initState();
    view = ViewType.list;
    shelf = shelves.keys.first;
    _isLoading = true;
    _fetchBooks();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_isFetchingMore &&
        !_hasReachedMax &&
        _scrollController.position.extentAfter < 500) {
      _fetchBooks(page: _currentPage + 1);
    }
  }

  Future<void> _fetchBooks({int page = 1}) async {
    if (_isFetchingMore || (page == 1 && _isLoading && _books.isNotEmpty)) return;

    setState(() {
      if (page == 1) {
        _isLoading = true;
        _error = null;
      } else {
        _isFetchingMore = true;
      }
    });

    try {
      final newItems = await GoodReadsService()
          .getBooks(pageNumber: page, shelf: shelves[shelf] ?? 'read');
      final isLastPage = GoodReadsService().isLastPage(page);

      if (!mounted) return;

      setState(() {
        if (page == 1) {
          _books.clear();
        }
        _books.addAll(newItems);
        _currentPage = page;
        _hasReachedMax = isLastPage;

        if (page == 1) {
          _isLoading = false;
        } else {
          _isFetchingMore = false;
        }
      });
    } catch (error) {
       if (!mounted) return;
       setState(() {
        _error = error;
        if (page == 1) {
          _isLoading = false;
        } else {
          _isFetchingMore = false;
        }
      });
    }
  }

  Future<void> _refreshBooks() async {
    if (!mounted) return;
    setState(() {
      _books.clear();
      _currentPage = 1;
      _hasReachedMax = false;
      _error = null;
    });
    await _fetchBooks();
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(child: progressIndicator(context)),
    );
  }

  Widget _buildErrorWidget() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading books.', style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 8),
            Text('$_error', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error.withAlpha(204))), // 0.8 opacity
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshBooks,
              child: const Text('Retry'),
            )
          ],
        ),
      ),
    );
  }

  Widget buildBookListContainer(Size size) {
    if (_isLoading && _books.isEmpty) {
      return _buildLoadingIndicator();
    } else if (_error != null && _books.isEmpty) {
      return _buildErrorWidget();
    } else if (_books.isEmpty) {
      return const Center(child: Text('No books found.'));
    } else {
      return view == ViewType.list
          ? displayBooksList(size)
          : displayBooksGrid(size);
    }
  }

  Widget displayBooksList(Size size) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: _books.length + (_isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _books.length) {
          return _buildLoadingIndicator();
        }
        final book = _books[index];
        return bookListItem(book);
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }

  Widget bookListItem(Book book) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(book.goodreadsLink);
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open link: ${book.goodreadsLink}')),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(containerBorderRadius)),
        child: Row(
          children: [
            SizedBox(
              height: 130,
              width: 90,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(containerBorderRadius),
                child: Hero(
                  tag: 'book_list_${book.goodreadsLink}',
                  child: CachedNetworkImage(
                    imageUrl: book.coverUrl,
                    placeholder: (context, url) => progressIndicator(context, color: Colors.grey),
                    errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
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
                    getDetails('Avg Rating', '${book.averageRating}/5'),
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bodyMediumStyle = textTheme.bodyMedium;
    final bodyMediumBoldStyle = bodyMediumStyle?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: (bodyMediumStyle?.fontSize ?? 14) + 1, 
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          '$key: ',
          style: bodyMediumStyle,
          maxLines: 1,
          minFontSize: 10,
          overflow: TextOverflow.ellipsis,
        ),
        Flexible(
          child: AutoSizeText(
            value,
            style: bodyMediumBoldStyle,
            minFontSize: 11,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget displayBooksGrid(Size size) {
    double maxExtentWidth = size.width / 2 > coverMaxWidth ? size.width / 2 : coverMaxWidth;
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(10),
      itemCount: _books.length + (_isFetchingMore ? 1 : 0),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          maxCrossAxisExtent: maxExtentWidth,
          childAspectRatio: .53
      ),
      itemBuilder: (context, index) {
        if (index == _books.length) {
          return _buildLoadingIndicator();
        }
        final book = _books[index];
        return bookGridItem(book, maxExtentWidth);
      },
    );
  }

  Widget bookGridItem(Book book, double width) {
    final double textContainerHeight = width / 9;
    final double imageHeight = (width / 0.53) - textContainerHeight;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(book.goodreadsLink);
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open link: ${book.goodreadsLink}')),
            );
          }
        }
      },
      child: Column(
        children: [
          SizedBox(
            width: width,
            height: imageHeight.clamp(50.0, 500.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(containerBorderRadius),
                  topRight: Radius.circular(containerBorderRadius)),
              child: Hero(
                tag: 'book_grid_${book.goodreadsLink}',
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: book.coverUrl,
                  placeholder: (context, url) => progressIndicator(context, color: Colors.grey),
                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          ),
          Container(
            width: width,
            height: textContainerHeight.clamp(20.0, 60.0),
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(containerBorderRadius),
                  bottomLeft: Radius.circular(containerBorderRadius)),
            ),
            child: Center(
              child: AutoSizeText(
                book.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold) ??
                    const TextStyle(fontWeight: FontWeight.bold),
                minFontSize: 10,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getViewButton(ViewType viewButton, Size size) {
    double iconSize = (size.width * size.height / 15000).clamp(18.0, 36.0);
    final theme = Theme.of(context);
    final bool isActive = view == viewButton;
    final shadowColor = theme.brightness == Brightness.dark
        ? Colors.white.withAlpha(26) // ~0.1 opacity
        : Colors.black.withAlpha(51); // ~0.2 opacity

    return Transform.scale(
      scale: isActive ? 1.1 : 0.9,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(containerBorderRadius),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: shadowColor,
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              )
          ],
        ),
        child: IconButton(
          icon: Icon(
            viewButton == ViewType.list
                ? Icons.list_rounded
                : Icons.grid_view_rounded,
            color: theme.colorScheme.secondary,
            size: iconSize,
          ),
          tooltip: viewButton == ViewType.list ? 'List View' : 'Grid View',
          onPressed: () {
            if (view != viewButton) {
              setState(() {
                view = viewButton;
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    titleColor = getTitleColor(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: theme.colorScheme.surface,
      statusBarColor: theme.colorScheme.surface,
      statusBarIconBrightness: theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      systemNavigationBarIconBrightness: theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
    ));

    Size size = MediaQuery.of(context).size;
    double controllerHeight = (size.width * size.height / 5000).clamp(50.0, 80.0);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, 
      appBar: AppBar(
        elevation: 1,
        foregroundColor: titleColor,
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          englishLanguage['books'] ?? 'Books',
          style: theme.textTheme.titleMedium?.copyWith(color: titleColor),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.surface,
            height: controllerHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: shelf,
                  dropdownColor: theme.colorScheme.surface,
                  icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.secondary),
                  iconSize: 24,
                  elevation: 4,
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.secondary),
                  underline: const SizedBox.shrink(),
                  onChanged: (String? newValue) {
                    if (newValue != null && newValue != shelf) {
                      setState(() {
                        shelf = newValue;
                        _refreshBooks();
                      });
                    }
                  },
                  items: shelves.keys
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const Spacer(),
                getViewButton(ViewType.list, size),
                const SizedBox(width: 8),
                getViewButton(ViewType.grid, size),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshBooks,
              child: buildBookListContainer(size),
            ),
          ),
          Container(
            color: theme.colorScheme.surface.withAlpha(204), // ~0.8 opacity
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                // Removed ?? '' based on dead_null_aware_expression warning
                getKeyValue(englishLanguage, 'goodreadsMessage'), 
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(179), // ~0.7 opacity
                    fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}
