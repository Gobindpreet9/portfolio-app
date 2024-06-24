import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portfolio_app/common/common_const.dart';
import 'package:portfolio_app/models/suggestion_model.dart';
import 'package:portfolio_app/services/authentication.dart';
import 'package:portfolio_app/services/firestore.dart';
import 'package:portfolio_app/styles/styles.dart';

class AboutMe extends StatefulWidget {
  @override
  _AboutMeState createState() => _AboutMeState();
}

class _AboutMeState extends State<AboutMe> with SingleTickerProviderStateMixin {
  List<String> headingsList = [
    getKeyValue(englishLanguage, 'books'),
    getKeyValue(englishLanguage, 'games'),
    getKeyValue(englishLanguage, 'movies'),
    getKeyValue(englishLanguage, 'art'),
    getKeyValue(englishLanguage, 'travel')
  ];

  List<String> tabCovers = [
    booksCover,
    gamesCover,
    moviesCover,
    artCover,
    travelCover
  ];
  List<String> bodyText = [
    getKeyValue(englishLanguage, 'booksBody'),
    getKeyValue(englishLanguage, 'inProgress'),
    getKeyValue(englishLanguage, 'inProgress'),
    getKeyValue(englishLanguage, 'inProgress'),
    getKeyValue(englishLanguage, 'inProgress'),
  ];

  late Color headingsColor;

  late Color titleColor;

  late TabController _tabController;

  late TextEditingController _dialogController;

  final bodyFont = 'DancingScript';

  @override
  initState() {
    _tabController =
        new TabController(vsync: this, length: headingsList.length);
    _dialogController = new TextEditingController();
    super.initState();
  }

  String getPath() {
    switch (headingsList[_tabController.index]) {
      case 'Books':
        return '/books';
      case 'Games':
        return '/books';
      case 'Movies':
        return '/books';
      case 'Art':
        return '/books';
      case 'Travel':
        return '/books';
    }
    return '/inProgress'; // TODO: replace it by not found 404
  }

  List<Widget> getTabHeadings() {
    List<Text> returnList = [];
    headingsList.forEach((element) {
      returnList.add(Text(
        element,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            !.copyWith(color: headingsColor, fontSize: 20),
        textAlign: TextAlign.center,
      ));
    });
    return returnList;
  }

  List<Widget> getTabBody(size) {
    List<Widget> returnList = [];
    for (var element in headingsList) {
      returnList.add(Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(containerBorderRadius),
              child: Image(
                image: AssetImage(tabCovers[headingsList.indexOf(element)]),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: jet.withOpacity(0.35),
              borderRadius: BorderRadius.circular(containerBorderRadius),
            ),
          ),
          Container(
            width: size.width * 0.7 > 500 ? 500 : size.width * 0.7,
            child: Text(
              bodyText[headingsList.indexOf(element)],
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontFamily: bodyFont, color: pureWhite),
            ),
          )
        ],
      ));
    }
    return returnList;
  }

  _showDialog() async {
    await showDialog<String>(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            backgroundColor: Theme.of(context)!.colorScheme.surface,
            contentPadding: const EdgeInsets.all(16.0),
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                        labelText: englishLanguage['suggest'],
                        labelStyle: Theme.of(context).textTheme.titleSmall,
                        hintText: getHintText(),
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            !.copyWith(color: Colors.grey)),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              TextButton(
                  child: const Text('SUBMIT'),
                  onPressed: () {
                    FirestoreService().sendSuggestion(Suggestion(
                        AuthService().currentUser().displayName!,
                        _dialogController.text,
                        Timestamp.now().millisecondsSinceEpoch as String));
                    Navigator.pop(context);
                  })
            ],
          ),
        );
      },
    );
  }

  getHintText() {
    switch (headingsList[_tabController.index]) {
      case 'Books':
        return englishLanguage['bookSuggestion'];
      case 'Games':
        return englishLanguage['gameSuggestion'];
      case 'Movies':
        return englishLanguage['movieSuggestion'];
      case 'Art':
        return englishLanguage['artSuggestion'];
      case 'Travel':
        return englishLanguage['travelSuggestion'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    headingsColor = getHeadingsColor(context);
    titleColor = getTitleColor(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).colorScheme.surface,
      statusBarColor: Theme.of(context).colorScheme.surface,
    ));
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: titleColor.withOpacity(0.5),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          getKeyValue(englishLanguage, 'aboutMe'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: titleColor, fontSize: 40, fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height / 40,
            ),
            TabBar(
              tabs: getTabHeadings(),
              controller: _tabController,
              isScrollable: true,
            ),
            SizedBox(
              height: size.height / 40,
            ),
            Center(
              child: Container(
                height: size.height * .70 > size.width * .80
                    ? size.height * .70
                    : size.width * .80,
                padding: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(containerBorderRadius)),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, getPath());
                  },
                  child: TabBarView(
                    controller: _tabController,
                    children: getTabBody(size),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height / 40,
            ),
            TextButton(
              onPressed: _showDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: size.width,
                height: 50,
                decoration: BoxDecoration(
                  color: headingsColor,
                  borderRadius: BorderRadius.circular(containerBorderRadius),
                ),
                child: Center(
                  child: Text(
                    getKeyValue(englishLanguage, 'suggestions'),
                    style: whiteText.copyWith(letterSpacing: 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dialogController.dispose();
    super.dispose();
  }
}
