import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Unused imports removed: common.dart, styles.dart
import 'package:portfolio_app/common/common_const.dart'; // Keep if getKeyValue, englishLanguage etc. are needed
import 'package:portfolio_app/services/authentication.dart';

// Assuming common_const.dart provides these, otherwise define them
// import 'package:portfolio_app/styles/styles.dart'; // Needed if using pureWhite, whiteText etc. from there


class Unauthorized extends StatefulWidget {
  const Unauthorized({super.key});

  @override
  _UnauthorizedState createState() => _UnauthorizedState();
}

class _UnauthorizedState extends State<Unauthorized> {
  final pageFont = 'DancingScript'; // Consider getting from Theme
  bool? isLoggedIn; // Nullable to handle initial state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final args = ModalRoute.of(context)?.settings.arguments;
        setState(() {
          isLoggedIn = args is bool ? args : false; // Default to false
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context); // Get theme
    final Color appBarIconColor = theme.appBarTheme.iconTheme?.color ?? theme.colorScheme.onPrimary.withOpacity(0.8);
    final TextStyle? appBarTitleStyle = theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary, fontSize: 40, fontStyle: FontStyle.italic);
    final Color appBarBackgroundColor = theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary; // Use primary as fallback

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: appBarIconColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          getKeyValue(englishLanguage, 'aboutMe', 'About Me'), // Use helper with fallback
          textAlign: TextAlign.center,
          style: appBarTitleStyle,
        ),
        centerTitle: true,
        backgroundColor: appBarBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getKeyValue(englishLanguage, 'unauthorizedText', 'Unauthorized Access'), // Fallback
                    textAlign: TextAlign.center, // Center align text
                    style: theme.textTheme.titleMedium?.copyWith(fontFamily: pageFont),
                  ),
                  SizedBox(height: size.height / 40),
                  // Assuming getContactLinks is defined elsewhere or replace with direct Widgets
                  // Example: Displaying email/phone if available
                  if (getKeyValue(englishLanguage, 'email', '').isNotEmpty)
                     Padding(
                       padding: const EdgeInsets.symmetric(vertical: 4.0),
                       child: SelectableText(
                         getKeyValue(englishLanguage, 'email', ''),
                         style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary, fontFamily: pageFont),
                       ),
                     ),
                  if (getKeyValue(englishLanguage, 'phone', '').isNotEmpty)
                     Padding(
                       padding: const EdgeInsets.symmetric(vertical: 4.0),
                       child: SelectableText(
                         getKeyValue(englishLanguage, 'phone', ''),
                         style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary, fontFamily: pageFont),
                       ),
                     ),
                ],
              ),
            ),
            _buildSignInButton(theme), // Pass theme
          ],
        )),
      ),
    );
  }

  Widget _buildSignInButton(ThemeData theme) {
    if (isLoggedIn == null) {
      return const CircularProgressIndicator();
    } else if (isLoggedIn!) {
      return const SizedBox.shrink(); // Use SizedBox.shrink() for empty space
    } else {
      // Define colors/styles or get from theme
      const Color buttonTextColor = Colors.white;
      const double buttonRadius = 8.0; // Example radius
      // Define gradient or get from theme extensions/constants
       const LinearGradient buttonGradient = LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

      return Container(
        decoration: BoxDecoration(
          gradient: buttonGradient,
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        child: TextButton.icon(
          style: TextButton.styleFrom(
             padding: EdgeInsets.zero,
             minimumSize: const Size(170, 50), // Ensure minimum size
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
          ),
          icon: const Icon(FontAwesomeIcons.google, color: buttonTextColor, size: 18), // Adjust size
          label: Center(
                  child: Text(
                    getKeyValue(englishLanguage, 'signInWithGoogle', 'Sign In with Google'),
                    style: const TextStyle(color: buttonTextColor), // Use defined color
                  ),
                ),
          onPressed: () async {
            var user = await AuthService().signInWithGoogle();
            if (user != null) {
              if (mounted) {
                setState(() {
                  isLoggedIn = true;
                });
              }
            } else {
               if (mounted) { // Check mount before showing toast
                 Fluttertoast.showToast(
                    msg: getKeyValue(englishLanguage, 'signInError', 'Sign In Failed'),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    fontSize: 14.0);
               }
            }
          },
        ),
      );
    }
  }
}

// --- Placeholder/Helper Function (ensure defined or imported) ---
String getKeyValue(Map<String, dynamic> map, String key, [String defaultValue = '']) {
  return map[key]?.toString() ?? defaultValue;
}

// --- Placeholder Data (ensure defined, e.g., in common_const.dart) ---
const Map<String, dynamic> englishLanguage = {
  'aboutMe': 'About Me',
  'unauthorizedText': 'You need to sign in to view this content.',
  'email': 'contact@example.com',
  'phone': '123-456-7890',
  'signInWithGoogle': 'Sign in with Google',
  'signInError': 'Sign in failed. Please try again.',
};
