const bool DEBUG = false;
const containerBorderRadius = 20.0;
const coverMaxWidth = 312.0;

const full_name = 'Gobindpreet S. Makkar';
const email = 'Gobindpreet9@gmail.com';
const phone = '+1-343-961-3035';
const address = '190 Woodridge Crescent, Ottawa, ON, K2B7S9';
const instagram = 'www.instagram.com/gobindpreet9/?hl=en';
const linkedIn = 'www.linkedin.com/in/gobindpreet-singh-makkar-0a1141155/';
const gitHub = 'www.github.com/Gobindpreet9';

const educationPoints = [
  'In Dean’s Honours List',
  'Received a  \$2500 one-time scholarship for highest GPA in international students',
  'Completed 4 semesters of the 6-semester course'
];

const programRelatedSkills = {
  'Programming Languages':
      'Java, C, C++, Python, Dart, Assembly language & Bash Scripting',
  'Web Development': 'HTML, CSS and JavaScript, PHP and React',
  'Machine Learning':
      'Naïve Bayes, K-means, SVM, Decision Trees & Random Forest, Regression models, Gradient descent, and SGD, scikit-learn',
  'Networking Basics':
      'OSI model, TCP/UDP transmission, subnetting and masking etc',
  'Operating Systems': 'Linux, Windows',
  'Database': 'PostgreSQL',
  'Version Control': 'Git, GitHub'
};

const academicProjects = [
  'Java: Program to print objects using 3D printer, a working calculator application using Java FX, basic client-server application using Swing',
  'Database: Designed database for a Soccer league, wrote queries for large databases to retrieve desired output',
  'C/C++: Created front end of compiler for PLATYPUS programming language in C, memory game created in C++ using SFML',
  'Web Development: Various projects such as Geography of Canada, Robo Project using react, Painting Portal using PHP, uploaded on http://gobindpreet9.com/',
  'Machine Learning: Projects such as Stock Prediction, Titanic Disaster Machine Learning, Decision Trees'
];

const additionalQualifications = [
  'Extremely adaptable to any situation',
  'Respectful of everyone’s opinion and beliefs',
  'Strong time management and problem-solving skills',
  'Fluent in  English, Hindi and Punjabi and Beginner in French'
];

const autolyPoints = [
  'Participating in development life cycle of the app',
  'Writing clean and well documented code',
  'Writing highly efficient code through use of appropriate data structures',
  'Preparing reliable resources through research to be used on app launch',
  'Detecting and fixing bugs'
];

const redLobsterPoints = [
  'Distributed food to team members and servers with efficiency in a high-volume environment to keep up with on-screen orders',
  'Maintain stations well stocked with supplies and spices for maximum productivity',
  'Trained, managed, and guided new employees, improving overall performance and productivity',
  'Communicate with team members to keep operations running smoothly without accidents'
];

const references = {
  'Anita Bhatia': 'CPA, Elections Canada\n613-261-2212',
  'Stephanie Duffy': 'Current Supervisor, Red Lobster\n778-239-651',
};

// App Language(s)
const Map<String, String> englishLanguage = {
  'aboutMe': 'About Me',
  'academicProjects': 'Academic Projects',
  'additionalInformation': 'Additional Information',
  'additionalInfoText':
      'Hobbies include reading books, soccer, working out and cooking. Was leader'
          ' of U-17 handball team of high school. Currently a member of software '
          'engineering club which aims to improve logical and analytical thinking '
          'required in the IT field. My projects can be found on my GitHub account -'
          ' https://github.com/Gobindpreet9. Available for a full-time co-op position'
          ' from Jan 2021 to Sept 2021. Also available for part-time upon short notice.',
  'additionalQualifications': 'Additional Qualifications',
  'art': 'Art',
  'artSuggestion': 'Any Art you would recommend',
  'books': 'Books',
  'bookSuggestion': 'A Book I should read',
  'booksBody':
      'I like to read books whenever I can, initially mostly for recreation'
          ' but now to learn more as well. Click to check my Goodreads library.',
  "checkMyResume": "Check Resume",
  'college': 'Algonquin College, Ottawa, ON',
  'contactMe': 'Contact',
  'course': 'Computer Engineering Technology',
  'education': 'Education',
  'email': 'Email',
  'exitWarning': 'Press back again to exit',
  'games': 'Games',
  'gameSuggestion': 'A Game I should play',
  'goodreadsMessage': 'Data retrieved from Goodreads.com',
  'inProgress': 'I am currently working on this',
  'main_bio': 'Currently studying Computer Engineering at Algonquin College. I am passionate'
      ' about technology and hope to learn more to make a difference. I provide great'
      ' attention to details and strive to achieve great results in whatever I do.'
      ' I also am a very open-minded person as a result of working with people from'
      ' different backgrounds as well as my affection for philosophy.',
  'moreAboutMe': 'More About Me',
  'movies': 'Movies',
  'movieSuggestion': 'A Movie I should see',
  'phone': 'Phone',
  'present': 'Present',
  'references': 'References',
  'skills': 'Program Related Skills',
  'signInError': 'Unable to sign in',
  'signInWithGoogle': 'Sign In With Google',
  'successfulDownload': 'File Saved To Downloads',
  'suggest': 'Suggest',
  'suggestions': 'Leave A Suggestion',
  'travel': 'Travel',
  'travelSuggestion': 'A Place I should travel to',
  'unauthorizedText': 'Hi, this is personal content, only meant for a few friends'
      ' and family. If you would like to ask for permission please '
      'log in and contact me. Thank you!',
  'workHistory': 'Work History'
};

// images
const intro_pic = 'assets/images/intro_pic.jpg';
const booksCover = 'assets/images/books.jpg';
const gamesCover = 'assets/images/games.jpg';
const moviesCover = 'assets/images/movies.jpg';
const artCover = 'assets/images/art.jpg';
const travelCover = 'assets/images/travel.jpg';
const sunIcon = 'assets/images/sun.png';
const sunDarkIcon = 'assets/images/sun-dark.png';
const inProgress = 'assets/images/in_progress.jpg';

String getKeyValue(Map<String, dynamic> map, String key) {
  return map.containsKey(key) ? map[key]?.toString() ?? '' : '';
}