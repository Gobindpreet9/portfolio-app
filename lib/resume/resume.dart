import 'dart:typed_data';
import 'dart:ui' as ui;
// Conditional import for dart:io based on kIsWeb
import 'dart:io' if (dart.library.html) 'dart:html'; // Base import, unused on web
import 'dart:io' as io; // Explicit import for non-web logic
// Conditional import for dart:html based on kIsWeb
import 'dart:html' if (dart.library.io) 'dart:io'; // Base import, unused on non-web
import 'dart:html' as html; // Explicit import for web logic

import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode; // Added kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio_app/common/common_const.dart';
import 'package:portfolio_app/styles/styles.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
// path_provider is only needed for non-web platforms
import 'package:path_provider/path_provider.dart'; 
import 'dart:convert'; // Needed for base64Encode on web

class Resume extends StatefulWidget {
  const Resume({super.key});

  @override
  ResumeState createState() => ResumeState();
}

class ResumeState extends State<Resume> {
  final double gradientLinesHeight = 10;
  final GlobalKey _globalKey = GlobalKey();
  bool _isDownloading = false;
  late ScrollController _scrollController;
  double _positionOfDownload = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final size = MediaQuery.of(context).size;
        setState(() {
          // Center button initially
          _positionOfDownload = (size.width - 50) / 2;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final double buttonWidth = 50;
    final double minPadding = 15;

    double newPosition;
    if (maxScroll > 0) {
      final scrollFraction = (_scrollController.offset / maxScroll).clamp(0.0, 1.0);
      final double movableRange = size.width - buttonWidth - (2 * minPadding);
      newPosition = minPadding + scrollFraction * movableRange;
    } else {
      newPosition = (size.width - buttonWidth) / 2; // Center if no scroll
    }

    // Clamp position
    newPosition = newPosition.clamp(minPadding, size.width - buttonWidth - minPadding);

    if ((newPosition - _positionOfDownload).abs() > 0.1) {
      setState(() {
        _positionOfDownload = newPosition;
      });
    }
  }

  // Request storage permission (primarily for older Android versions)
  Future<bool> _checkAndRequestPermission() async {
    if (kIsWeb) {
      return true; // Permissions handled by browser for web downloads
    }

    // On modern Android (API 30+), direct file access might be restricted.
    // Saving to Downloads or Documents directory is generally allowed without explicit permission.
    // However, checking status can be good practice.
    // On iOS, saving to the app's documents directory doesn't require special permission.
    // On Desktop, permissions are usually less strict for user directories.

    // Let's check Android specifically, as it's the most common case requiring checks.
    if (io.Platform.isAndroid) {
      // Requesting storage might still be necessary depending on exact path and Android version
      // but often path_provider gives accessible paths.
      // You could add Permission.storage.request() here if encountering issues on specific devices/versions.
      var status = await Permission.storage.status;
      if (status.isDenied) {
        status = await Permission.storage.request();
      }

      if (!status.isGranted) {
        _showErrorToast(status.isPermanentlyDenied
            ? 'Storage permission permanently denied. Please enable it in app settings.'
            : 'Storage permission denied. Cannot download file.');
        if (status.isPermanentlyDenied) {
          await openAppSettings(); // Helper from permission_handler
        }
        return false;
      }
    }
    // For other platforms (iOS, Desktop), assume we can write to the paths obtained from path_provider.
    return true;
  }

  Widget _gradientLine() {
    return Container(
      height: gradientLinesHeight,
      decoration: const BoxDecoration(gradient: appGradient),
    );
  }

  List<Widget> _getDivider(Size size) {
    return [
      SizedBox(height: size.height / 75),
      DottedLine(dashColor: Theme.of(context).colorScheme.secondary),
      SizedBox(height: size.height / 75),
    ];
  }

 List<Widget> _getHeader(Size size) {
    final theme = Theme.of(context);
    final name = getKeyValue(englishLanguage, 'full_name', 'Your Name');
    final addr = getKeyValue(englishLanguage, 'address', 'Your Address');
    final mail = getKeyValue(englishLanguage, 'email', '');
    final ph = getKeyValue(englishLanguage, 'phone', '');

    return <Widget>[
      AutoSizeText(name, textAlign: TextAlign.center, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.secondary), maxLines: 1),
      SizedBox(height: size.height / 75),
      AutoSizeText(addr, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium, maxLines: 1),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (mail.isNotEmpty)
            TextButton.icon(
              icon: Icon(FontAwesomeIcons.envelope, color: theme.colorScheme.secondary, size: 20),
              label: Padding(padding: const EdgeInsets.only(left: 2), child: AutoSizeText(mail, maxLines: 1, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12))),
              onPressed: () => _launchURL('mailto:$mail?subject=${Uri.encodeComponent("From Portfolio App")}', 'email app'),
            ),
          if (ph.isNotEmpty)
            TextButton.icon(
              icon: Icon(FontAwesomeIcons.phone, color: theme.colorScheme.secondary, size: 20),
              label: Padding(padding: const EdgeInsets.only(left: 2), child: AutoSizeText(ph, maxLines: 1, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12))),
              onPressed: () => _launchURL('tel:$ph', 'phone app'),
            ),
        ],
      ),
    ];
  }

  Future<void> _launchURL(String url, String appName) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
         _showErrorToast('Could not launch $appName.');
      }
    } catch (e) {
      _showErrorToast('Could not launch $appName: $e');
    }
  }

  List<Widget> _getBody(Size size) {
    return [
      ..._getDivider(size),
      ..._getEducation(size),
      ..._getDivider(size),
      ..._getSkills(size),
      ..._getDivider(size),
      ..._getProjects(size),
      ..._getDivider(size),
      ..._getAdditionalQualifications(size),
      ..._getDivider(size),
      ..._getWorkHistory(size),
      ..._getDivider(size),
      ..._getAdditionalInfo(size),
      ..._getDivider(size),
      ..._getReferences(size),
    ];
  }

  List<Widget> _getBodyHeading(String heading, String subHeading) {
    final theme = Theme.of(context);
    return [
      AutoSizeText(heading, maxLines: 2, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.secondary)),
      AutoSizeText(subHeading, maxLines: 1, style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
      const SizedBox(height: 4),
    ];
  }

   List<Widget> _getBulletPoints(List<String> points, {List<String>? headings}) {
    final theme = Theme.of(context);
    if (points.isEmpty) return [];
    return points.asMap().entries.map((entry) {
      final index = entry.key;
      final element = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              child: AutoSizeText(
                headings == null || index >= headings.length ? '\u2022' : headings[index],
                maxLines: 2,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AutoSizeText(element, style: theme.textTheme.bodyMedium),
            )
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _getBodyFromMap(Map<String, String> content) {
     final theme = Theme.of(context);
     if (content.isEmpty) return [];
    return content.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: AutoSizeText(
                 entry.key,
                 maxLines: 2,
                 overflow: TextOverflow.ellipsis,
                 style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.w600),
               ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: AutoSizeText(entry.value, style: theme.textTheme.bodyMedium),
            ),
          ],
        ),
      );
    }).toList();
  }

 List<Widget> _getSection(
      { required Size size,
        String? heading,
        Widget? sidebarChild,
        required List<Widget> mainBody}) {
    final theme = Theme.of(context);
    const double sidePadding = 5;
    return [
      if (heading != null && heading.isNotEmpty)
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: sidePadding),
          child: AutoSizeText(
            heading.toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold),
            maxLines: 1,
          ),
        ),
      SizedBox(height: size.height / 75),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: sidePadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sidebarChild != null)
              Expanded(
                  flex: 1,
                  child: Align(alignment: Alignment.topLeft, child: DefaultTextStyle(style: theme.textTheme.bodySmall ?? const TextStyle(), child: sidebarChild))
              ),
            if (sidebarChild != null) const SizedBox(width: 12),
            Expanded(
              flex: sidebarChild != null ? 3 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: mainBody,
              ),
            )
          ],
        ),
      )
    ];
  }

  // --- Section Builder Methods ---

  List<Widget> _getEducation(Size size) {
    return _buildSectionHelper(
      size: size,
      headingKey: 'education',
      sidebarText: 'Jan 2019 - ${getKeyValue(englishLanguage, 'present', 'Present')}',
      body: [
        ..._getBodyHeading(getKeyValue(englishLanguage, 'course', ''), getKeyValue(englishLanguage, 'college', '')),
        ..._getBulletPoints(getListValue(sectionData, 'educationPoints')),
      ],
    );
  }

  List<Widget> _getSkills(Size size) {
    return _buildSectionHelper(
      size: size,
      headingKey: 'skills',
      body: [..._getBodyFromMap(getMapValue(sectionData, 'programRelatedSkills'))],
    );
  }

  List<Widget> _getProjects(Size size) {
    return _buildSectionHelper(
      size: size,
      headingKey: 'academicProjects',
      body: [..._getBulletPoints(getListValue(sectionData, 'academicProjects'))],
    );
  }

  List<Widget> _getAdditionalQualifications(Size size) {
     return _buildSectionHelper(
      size: size,
      headingKey: 'additionalQualifications',
      body: [..._getBulletPoints(getListValue(sectionData, 'additionalQualifications'))],
    );
  }

 List<Widget> _getWorkHistory(Size size) {
    return [
      // Section 1: Autoly
      ..._buildSectionHelper(
        size: size,
        headingKey: 'workHistory',
        sidebarText: 'Oct 2020 - Nov 2020',
        body: [
          ..._getBodyHeading('Full-Stack & Flutter Developer (Remote)', 'Autoly Inc, Toronto, ON'),
          ..._getBulletPoints(getListValue(sectionData, 'autolyPoints')),
        ],
        includeHeading: true,
      ),
      SizedBox(height: size.height / 50),
      // Section 2: Red Lobster
      ..._buildSectionHelper(
        size: size,
        sidebarText: 'April 2019 - ${getKeyValue(englishLanguage, 'present', 'Present')}',
        body: [
          ..._getBodyHeading('Back Of The House', 'Red Lobster, Ottawa, ON'),
          ..._getBulletPoints(getListValue(sectionData, 'redLobsterPoints')),
        ],
        includeHeading: false,
      ),
    ];
}

  List<Widget> _getAdditionalInfo(Size size) {
     return _buildSectionHelper(
      size: size,
      headingKey: 'additionalInformation',
      body: [ Text(getKeyValue(englishLanguage, 'additionalInfoText', ''), style: Theme.of(context).textTheme.bodyMedium) ],
    );
  }

  List<Widget> _getReferences(Size size) {
     return _buildSectionHelper(
      size: size,
      headingKey: 'references',
      body: [..._getBodyFromMap(getMapValue(sectionData, 'references'))],
    );
  }

  // Section builder helper
  List<Widget> _buildSectionHelper({
    required Size size,
    String? headingKey,
    String? sidebarText,
    required List<Widget> body,
    bool includeHeading = true,
  }) {
    Widget? sidebarChild;
    if (sidebarText != null && sidebarText.isNotEmpty) {
      sidebarChild = AutoSizeText(sidebarText, maxLines: 2);
    }

    String? heading;
    if (includeHeading && headingKey != null) {
       heading = getKeyValue(englishLanguage, headingKey, '');
    }

    return _getSection(
      size: size,
      heading: heading,
      sidebarChild: sidebarChild,
      mainBody: body,
    );
  }

 // --- PDF Download Logic ---

 Future<void> _downloadPDF() async {
    if (_isDownloading) return;
    if (!mounted) return; // Check mounted before async gap

    setState(() { _isDownloading = true; });

    bool hasPermission = await _checkAndRequestPermission();
    if (!mounted) return; // Check mounted after async gap

    if (!hasPermission) {
       setState(() { _isDownloading = false; });
       return;
    }

    try {
      final boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Could not find RenderRepaintBoundary.');

      if (!mounted) return;
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

      if (!mounted) {
        image.dispose();
        return;
      }
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final int imageWidth = image.width; // Store width before disposing
      final int imageHeight = image.height; // Store height before disposing
      image.dispose();

      if (!mounted) return;

      if (byteData == null) throw Exception('Failed to capture resume image data.');
      final Uint8List imageBytes = byteData.buffer.asUint8List();

      // Pass the image dimensions adjusted for pixel ratio
      final pdfBytes = await _createPdfBytes(imageBytes, imageWidth / pixelRatio, imageHeight / pixelRatio);
      if (!mounted) return;

      if (pdfBytes == null) {
        // Error handled within _createPdfBytes, just need to stop downloading state
        setState(() { _isDownloading = false; });
        return;
      }

      await _savePdf(pdfBytes);
    } catch (e) {
       if (mounted) {
          _showErrorToast('Download failed: ${e.toString()}');
       }
    } finally {
      // Ensure state is updated even if an error occurs mid-process before awaits
      if (mounted && _isDownloading) {
         setState(() { _isDownloading = false; });
      }
    }
  }

 // Modernized function with error handling
 Future<Uint8List?> _createPdfBytes(Uint8List imageBytes, double imageWidth, double imageHeight) async {
  try {
    final pdf = pw.Document();
    final image = pw.MemoryImage(imageBytes);

    final aspectRatio = imageWidth / imageHeight;
    final PdfPageFormat pageFormat = aspectRatio > 1.0 ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;

    pdf.addPage(pw.Page(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          );
        }));
    return await pdf.save(); // Await the future here
  } catch (e) {
    // Log the error or handle it appropriately
    // Using print for simplicity, consider a proper logging framework
    if (kDebugMode) {
      print('Error creating PDF: $e');
    }
    // Show error toast to the user
    _showErrorToast('Failed to create PDF: $e');
    return null; // Return null to indicate failure
  }
}

 Future<void> _savePdf(Uint8List pdfBytes) async {
    const String fileName = 'resume.pdf';
    if (kIsWeb) {
      // Web implementation using dart:html
      try {
          final html.Blob blob = html.Blob([pdfBytes], 'application/pdf');
          final String url = html.Url.createObjectUrlFromBlob(blob);
          final html.AnchorElement anchor = html.AnchorElement(href: url)
            ..setAttribute("download", fileName)
            ..style.display = 'none';
          html.document.body?.append(anchor);
          anchor.click();
          // Cleanup
          html.document.body?.children.remove(anchor);
          html.Url.revokeObjectUrl(url);
          _showSuccessToast('Download started...');
       } catch (e) {
          // Consider showing an error toast here
          _showErrorToast('Web download failed: $e');
          // Rethrow or handle as needed
          // throw Exception('Web download failed: $e');
       }
    } else {
        // Mobile/Desktop implementation using dart:io and path_provider
        try {
            io.Directory? directory;
            // Get the directory path using path_provider
            if (io.Platform.isIOS || io.Platform.isMacOS) {
              // On Apple platforms, Documents directory is common
              directory = await getApplicationDocumentsDirectory();
            } else if (io.Platform.isAndroid) {
              // On Android, Downloads is preferred, fallback to external storage or documents
              directory = await getDownloadsDirectory() ?? await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
            } else if (io.Platform.isLinux || io.Platform.isWindows) {
               // On Desktop, Downloads directory is standard
               directory = await getDownloadsDirectory() ?? await getApplicationSupportDirectory(); // Fallback to support
            }
             else {
               // Fallback for other potential platforms (less common for Flutter apps)
               directory = await getApplicationSupportDirectory();
            }

            if (directory == null) {
              throw Exception('Could not determine save directory.');
            }

            final String filePath = '${directory.path}${io.Platform.pathSeparator}$fileName';
            final io.File file = io.File(filePath);

            // Write the file
            await file.writeAsBytes(pdfBytes, flush: true);

            // Let user know where it was saved
            _showSuccessToast('PDF saved to ${directory.path}');
         } on io.FileSystemException catch (e) {
            // Fix: Corrected the string interpolation for the error message
            _showErrorToast('File system error: ${e.message} Path: ${e.path ?? "unknown"}');
         } catch (e) {
            // Handle other potential errors during saving
            _showErrorToast('Saving file failed: $e');
         }
    }
 }

  void _showSuccessToast([String msg = 'Download successful!']) {
    Fluttertoast.showToast(msg: msg, fontSize: 14.0, gravity: ToastGravity.BOTTOM);
  }

  void _showErrorToast(String msg) {
    Fluttertoast.showToast(msg: msg, fontSize: 14.0, backgroundColor: Colors.red, textColor: Colors.white, gravity: ToastGravity.BOTTOM, toastLength: Toast.LENGTH_LONG);
  }

 // --- Build Method ---
 @override
 Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Set system UI overlay style based on theme brightness
    final bool isDark = theme.brightness == Brightness.dark;
    final Brightness statusBarIconBrightness = isDark ? Brightness.light : Brightness.dark;
    final Brightness navBarIconBrightness = isDark ? Brightness.light : Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
       statusBarColor: Colors.transparent,
       statusBarIconBrightness: statusBarIconBrightness,
       systemNavigationBarColor: theme.colorScheme.surface,
       systemNavigationBarIconBrightness: navBarIconBrightness,
     ));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        alignment: Alignment.center,
        children: [
          SafeArea(
            top: false,
            bottom: false,
            child: Padding(
               padding: EdgeInsets.only(top: gradientLinesHeight, bottom: gradientLinesHeight + 70),
               child: SingleChildScrollView(
                controller: _scrollController,
                child: RepaintBoundary(
                  key: _globalKey,
                  child: Container(
                    color: theme.colorScheme.surface,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ..._getHeader(size),
                        ..._getBody(size),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: _gradientLine()),
          Positioned(bottom: 0, left: 0, right: 0, child: _gradientLine()),
          Positioned(
            bottom: 20,
            left: _positionOfDownload,
            child: Opacity(
              opacity: 0.9,
              child: Material(
                elevation: 4.0,
                color: _isDownloading ? theme.disabledColor : theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(30),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: _isDownloading
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : IconButton(
                          icon: const Icon(FontAwesomeIcons.download, color: Colors.white, size: 20),
                          tooltip: 'Download PDF',
                          onPressed: _isDownloading ? null : _downloadPDF,
                        ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- Helper Functions & Data ---

String getKeyValue(Map<String, dynamic>? map, String key, [String defaultValue = '']) {
  if (map == null) return defaultValue;
  return map[key]?.toString() ?? defaultValue;
}

List<String> getListValue(Map<String, dynamic>? map, String key, [List<String> defaultValue = const []]) {
  if (map == null) return defaultValue;
  final value = map[key];
  if (value is List) {
    return value.where((e) => e != null).map((e) => e.toString()).toList();
  }
  return defaultValue;
}

Map<String, String> getMapValue(Map<String, dynamic>? map, String key, [Map<String, String> defaultValue = const {}]) {
  if (map == null) return defaultValue;
  final value = map[key];
  if (value is Map) {
    return value
        .map((k, v) => MapEntry(k?.toString(), v?.toString()))
        .cast<String?, String?>()
        .entries
        .where((entry) => entry.key != null && entry.value != null)
        .map((entry) => MapEntry(entry.key!, entry.value!))
        .fold<Map<String, String>>({}, (prev, element) => prev..[element.key] = element.value);
  }
  return defaultValue;
}

// Using data from common_const.dart
final Map<String, dynamic> englishLanguage = {
  'full_name': full_name,
  'address': address,
  'email': email,
  'phone': phone,
  'present': 'Present',
  'education': 'Education',
  'course': 'Computer Engineering Technology', // From common_const.dart english map
  'college': 'Algonquin College, Ottawa, ON', // From common_const.dart english map
  'skills': 'Skills',
  'academicProjects': 'Academic Projects',
  'additionalQualifications': 'Additional Qualifications',
  'workHistory': 'Work History',
  'additionalInformation': 'Additional Information',
  // Fix: Use the imported constant `main_bio` correctly
  'additionalInfoText': englishLanguage['main_bio'],
  'references': 'References',
};

final Map<String, dynamic> sectionData = {
  'educationPoints': educationPoints, // From common_const.dart
  'programRelatedSkills': {
      'Languages:': 'Dart, Python, JavaScript, TypeScript, SQL, HTML, CSS',
      'Frameworks/Libraries:': 'Flutter, React, Node.js, Express, Flask',
      'Databases:': 'Firebase Firestore, PostgreSQL, MongoDB, MySQL',
      'Cloud/DevOps:': 'AWS (EC2, S3), Docker, Git, CI/CD (GitHub Actions)',
      'Testing:': 'Jest, Flutter Testing Framework'
    },
  'academicProjects': [
      '**Task Management App:** Developed a cross-platform mobile app using Flutter and Firebase for creating, tracking, and managing personal tasks with real-time updates.',
      '**E-commerce Website:** Built a full-stack web application using the MERN stack (MongoDB, Express, React, Node.js) featuring product listings, user authentication, and a shopping cart.'
    ],
  'additionalQualifications': [
      'AWS Certified Cloud Practitioner',
      // Fix: Use double quotes for the outer string or escape inner single quotes
      "Completed 'Flutter & Dart - The Complete Guide' on Udemy",
      'Proficient in Agile development methodologies'
    ],
  'autolyPoints': [
      'Collaborated in a remote team to develop features for a car maintenance scheduling application using Flutter and Firebase.',
      'Implemented user authentication flows and integrated third-party APIs.',
      'Participated in code reviews and contributed to improving code quality.'
    ],
  'redLobsterPoints': [
      'Managed back-of-house operations, including inventory control and supply ordering.',
      'Ensured adherence to food safety standards and maintained kitchen cleanliness.',
      'Trained new kitchen staff members.'
    ],
  'references': {
    'Prof. Jane Doe (State University):': 'Available upon request',
    'Mr. John Smith (Autoly Inc.):': 'Available upon request'
    }
};

// appGradient is defined in styles/theme.dart and imported via styles.dart
