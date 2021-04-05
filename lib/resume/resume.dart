import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gobind/common/common_const.dart';
import 'package:gobind/styles/styles.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:pdf/widgets.dart' as pw;

class Resume extends StatefulWidget {
  final BuildContext context;

  const Resume({Key key, this.context}) : super(key: key);

  @override
  _ResumeState createState() => _ResumeState();
}

class _ResumeState extends State<Resume> {
  final double gradientLinesHeight = 10;
  GlobalKey _globalKey;
  bool isDownloading;
  ScrollController _scrollController;
  double positionOfDownload;
  Size size;

  @override
  initState() {
    isDownloading = false;
    _globalKey = GlobalKey();
    getPermission();
    size = MediaQuery.of(widget.context).size;
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          positionOfDownload = size.width / 2 -
              15 +
              ((_scrollController.offset /
                  _scrollController.position.maxScrollExtent) * (size.width/2 - 40));
        });
      });
    super.initState();
  }

  getPermission() async {
    final status = await Permission.storage.status;
    if (status.isUndetermined) {
      await [
        Permission.storage,
      ].request();
    }
    // if (status.isGranted) {
    //   print('granted');
    //   return;
    // } else if (status.isUndetermined) {
    //   print('requesting');
    //   await Permission.storage.request();
    // }
    print(status);
  }

  Widget _gradientLine() {
    return SafeArea(
      child: Container(
        height: gradientLinesHeight,
        decoration: BoxDecoration(gradient: appGradient),
      ),
    );
  }

  List<Widget> _getDivider(BuildContext context, size) {
    return [
      SizedBox(
        height: size.height / 75,
      ),
      DottedLine(
        dashColor: Theme.of(context).accentColor,
      ),
      SizedBox(
        height: size.height / 75,
      ),
    ];
  }

  List<Widget> _getHeader(context, size) {
    return <Widget>[
      // name
      Container(
        child: AutoSizeText(
          full_name,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headline1
              .copyWith(color: Theme.of(context).accentColor),
          maxLines: 1,
        ),
      ),
      SizedBox(
        height: size.height / 75,
      ),
      AutoSizeText(
        address,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyText1,
        maxLines: 1,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlatButton.icon(
            icon: Icon(
              FontAwesomeIcons.envelope,
              color: Theme.of(context).accentColor,
              size: 20,
            ),
            label: Container(
              margin: EdgeInsets.only(left: 2),
              child: AutoSizeText(
                '$email',
                maxLines: 1,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontSize: 12),
              ),
            ),
            onPressed: () async {
              await launch('mailto:$email?subject=News&body=New%20plugin');
            },
          ),
          FlatButton.icon(
            icon: Icon(
              FontAwesomeIcons.phone,
              color: Theme.of(context).accentColor,
              size: 20,
            ),
            label: Container(
              margin: EdgeInsets.only(left: 2),
              child: AutoSizeText(
                '$phone',
                maxLines: 1,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontSize: 12),
              ),
            ),
            onPressed: () async {
              await launch('tel:$phone');
            },
          ),
        ],
      ),
    ];
  }

  List<Widget> getBody(BuildContext context, Size size) {
    return [
      ..._getDivider(context, size),
      ...getEducation(context, size),
      ..._getDivider(context, size),
      ...getSkills(context, size),
      ..._getDivider(context, size),
      ...getProjects(context, size),
      ..._getDivider(context, size),
      ...getAdditionalQualifications(context, size),
      ..._getDivider(context, size),
      ...getWorkHistory(context, size),
      ..._getDivider(context, size),
      ...getAdditionalInfo(context, size),
      ..._getDivider(context, size),
      ...getReferences(context, size),
    ];
  }

  List<Widget> getBodyHeading(context, heading, subHeading) {
    return [
      AutoSizeText(
        heading,
        maxLines: 2,
        style: Theme.of(context)
            .textTheme
            .subtitle1
            .copyWith(color: Theme.of(context).accentColor),
      ),
      AutoSizeText(
        subHeading,
        maxLines: 1,
        style: Theme.of(context)
            .textTheme
            .bodyText1
            .copyWith(fontStyle: FontStyle.italic),
      ),
    ];
  }

  List<Row> getBulletPoints(List<String> points, context,
      {List<String> headings}) {
    List<Row> returnList = [];
    points.forEach((element) {
      returnList.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            headings == null
                ? '\u2022'
                : headings.elementAt(points.indexOf(element)),
            maxLines: 2,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: Theme.of(context).accentColor),
          ),
          SizedBox(
            width: 5,
          ),
          Flexible(
            fit: FlexFit.loose,
            child: AutoSizeText(element,
                maxLines: 4, style: Theme.of(context).textTheme.bodyText1),
          )
        ],
      ));
    });
    return returnList;
  }

  List<Widget> getBodyFromMap(context, Map<String, String> content) {
    List<Widget> returnList = [];
    content.forEach((heading, body) {
      returnList.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: AutoSizeText(
                    heading,
                    maxLines: 2,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Theme.of(context).accentColor),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Flexible(flex: 3, child: getBulletPoints([body], context)[0]),
        ],
      ));
      returnList.add(SizedBox(
        height: 5,
      ));
    });
    return returnList;
  }

  List<Widget> getSection(
      {@required BuildContext context,
      @required Size size,
      String heading,
      Widget sidebarChild,
      @required List<Widget> mainBody}) {
    double sidePadding = 5;
    return [
      heading != null
          ? (Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: sidePadding),
              child: AutoSizeText(
                heading,
                style: Theme.of(context)
                    .textTheme
                    .headline2
                    .copyWith(color: Theme.of(context).accentColor),
                maxLines: 1,
              ),
            ))
          : SizedBox(),
      SizedBox(
        height: size.height / 75,
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: sidePadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
                flex: sidebarChild == null ? 0 : 1,
                child: sidebarChild ?? Container()),
            SizedBox(
              width: 5,
            ),
            Flexible(
              flex: 3,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: mainBody,
                ),
              ),
            )
          ],
        ),
      )
    ];
  }

  List<Widget> getEducation(BuildContext context, Size size) {
    return getSection(
        context: context,
        size: size,
        heading: englishLanguage['education'],
        sidebarChild: Container(
          alignment: Alignment.topLeft,
          child: AutoSizeText(
            'Jan 2019 - ${englishLanguage['present']}',
            maxLines: 2,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        mainBody: [
          ...getBodyHeading(
              context, englishLanguage['course'], englishLanguage['college']),
          ...getBulletPoints(educationPoints, context),
        ]);
  }

  List<Widget> getSkills(BuildContext context, Size size) {
    return getSection(
        context: context,
        size: size,
        heading: englishLanguage['skills'],
        sidebarChild: null,
        mainBody: [...getBodyFromMap(context, programRelatedSkills)]);
  }

  List<Widget> getProjects(BuildContext context, Size size) {
    return getSection(
        context: context,
        size: size,
        heading: englishLanguage['academicProjects'],
        sidebarChild: null,
        mainBody: [
          ...getBulletPoints(academicProjects, context),
        ]);
  }

  List<Widget> getAdditionalQualifications(BuildContext context, Size size) {
    return getSection(
        context: context,
        size: size,
        heading: englishLanguage['additionalQualifications'],
        sidebarChild: null,
        mainBody: [
          ...getBulletPoints(additionalQualifications, context),
        ]);
  }

  List<Widget> getWorkHistory(BuildContext context, Size size) {
    return [
      ...getSection(
          context: context,
          size: size,
          heading: englishLanguage['workHistory'],
          sidebarChild: Container(
            alignment: Alignment.topCenter,
            child: AutoSizeText(
              'Oct 2020 - Nov 2020',
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          mainBody: [
            ...getBodyHeading(
                context,
                'Full-Stack & Flutter Developer (Remote)',
                'Autoly Inc, Toronto, ON'),
            ...getBulletPoints(autolyPoints, context),
          ]),
      ...getSection(
          context: context,
          size: size,
          sidebarChild: Container(
            alignment: Alignment.topCenter,
            child: AutoSizeText(
              'April 2019 - ${englishLanguage['present']}',
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          mainBody: [
            ...getBodyHeading(
                context, 'Back Of The House', 'Red Lobster, Ottawa, ON'),
            ...getBulletPoints(redLobsterPoints, context),
          ])
    ];
  }

  List<Widget> getAdditionalInfo(BuildContext context, Size size) {
    return getSection(
        context: context,
        size: size,
        heading: englishLanguage['additionalInformation'],
        sidebarChild: null,
        mainBody: [
          Text(
            englishLanguage['additionalInfoText'],
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ]);
  }

  List<Widget> getReferences(BuildContext context, Size size) {
    return getSection(
        context: context,
        size: size,
        heading: englishLanguage['references'],
        sidebarChild: null,
        mainBody: [...getBodyFromMap(context, references)]);
  }

  _downloadPDF() async {
    setState(() {
      isDownloading = true;
    });
    try {
      final imageMap = await getImage();
      createPdf(imageMap);
      _notifyUser();
      if (DEBUG) print('saved');
    } catch (e) {
      if (DEBUG) print(e);
    }
    setState(() {
      isDownloading = false;
    });
  }

  Future<Uint8List> getImage() async {
    if (DEBUG) print('inside');
    RenderRepaintBoundary boundary =
        _globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List imageMap = byteData.buffer.asUint8List();
    return imageMap;
  }

  createPdf(Uint8List imageMap) async {
    final pdf = pw.Document();
    final image = PdfImage.file(
      pdf.document,
      bytes: imageMap,
    );
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.undefined,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.fitWidth),
          ); // Center
        }));

    File file = File(await getFilePath());
    await file.writeAsBytes(pdf.save());
  }

  Future<String> getFilePath() async {
    String path = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
    return '$path/resume.pdf';
  }

  _notifyUser() {
    showSnackbar();
    sendNotification();
  }

  showSnackbar() {
    Fluttertoast.showToast(
        msg: englishLanguage['successfulDownload'],
        timeInSecForIosWeb: 1,
        fontSize: 14.0);
  }

  sendNotification() {}

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).accentColor,
    ));
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // top gradient line
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: _gradientLine(),
          ),
          //bottom gradient line
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: _gradientLine(),
          ),
          // main body
          Positioned(
            bottom: gradientLinesHeight,
            top: gradientLinesHeight,
            right: 0,
            left: 0,
            child: SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: RepaintBoundary(
                  key: _globalKey,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        ..._getHeader(context, size),
                        ...getBody(context, size),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: positionOfDownload,
            child: Opacity(
              opacity: 0.9,
              child: Material(
                elevation:  1.0,
                color: !isDownloading
                    ? Theme.of(context).accentColor
                    : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(30),
                child: !isDownloading
                    ? IconButton(
                        icon: Icon(
                          FontAwesomeIcons.download,
                          color: pureWhite,
                          size: 20,
                        ),
                        onPressed: _downloadPDF,
                      )
                    : CircularProgressIndicator(),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
        .dispose();
    super.dispose();
  }
}
