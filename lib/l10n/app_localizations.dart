import 'package:flutter/material.dart';

abstract class AppLocalizations {
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ko'),
  ];

  // 인증 관련
  String get signIn;
  String get signUp;
  String get email;
  String get password;
  String get confirmPassword;
  String get forgotPassword;
  String get loginButton;
  String get registerButton;
  String get alreadyHaveAccount;
  String get dontHaveAccount;
  String get welcomeBack;
  String get createAccount;

  // 홈 페이지
  String get home;
  String get welcome;
  String get todaysStats;
  String get recentActivity;
  String get quickActions;
  String get viewAll;
  String get noRecentActivity;

  // 홈 페이지 추가 속성들
  String get scanPhoto;
  String get checkForMites;
  String get todaysDiagnoses;
  String get images;
  String get infected;

  // 스캔 페이지
  String get scan;
  String get scanBee;
  String get takePhoto;
  String get selectFromGallery;
  String get analyzing;
  String get scanResult;
  String get confidence;
  String get tryAgain;
  String get saveResult;

  // 지도 페이지
  String get map;
  String get beehiveLocations;
  String get myLocation;
  String get nearbyBeehives;
  String get distance;
  String get noBeehivesNearby;

  // 히스토리 페이지
  String get history;
  String get scanHistory;
  String get noHistory;
  String get date;
  String get result;
  String get deleteAll;
  String get delete;
  String get confirm;
  String get cancel;

  // 히스토리 페이지 추가 속성들
  String get myDiagnosisHistory;
  String get loginRequired;
  String get myHistoryEmpty;
  String get scanImages;
  String get mitesDetected;
  String get noMitesDetected;
  String get minutesAgo;
  String get hoursAgo;
  String get daysAgo;

  // 통계 페이지
  String get stats;
  String get statistics;
  String get totalScans;
  String get successfulScans;
  String get thisWeek;
  String get thisMonth;
  String get accuracy;
  String get averageConfidence;

  // 통계 페이지 추가 속성들
  String get weekly;
  String get monthly;
  String get periodSelection;
  String get selectPeriod;
  String get noStatsData;
  String get noDataCollected;
  String get totalDetections;
  String get period;
  String get dailyDetectionCount;
  String get last7Days;
  String get last30Days;
  String get days;
  String get custom;

  // 요일
  String get mon;
  String get tue;
  String get wed;
  String get thu;
  String get fri;
  String get sat;
  String get sun;

  // 설정 페이지
  String get settings;
  String get language;
  String get selectLanguage;
  String get english;
  String get korean;
  String get notifications;
  String get enableNotifications;
  String get about;
  String get version;
  String get privacyPolicy;
  String get termsOfService;
  String get logout;
  String get profile;
  String get editProfile;

  // 알림 페이지
  String get alerts;
  String get notifications_title;
  String get noAlerts;
  String get markAllRead;
  String get alertSettings;
  String get pushNotifications;
  String get emailNotifications;

  // 공통
  String get loading;
  String get error;
  String get retry;
  String get save;
  String get close;
  String get ok;
  String get yes;
  String get no;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ko'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'ko':
        return AppLocalizationsKo();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class AppLocalizationsEn extends AppLocalizations {
  @override
  String get signIn => 'Sign In';
  @override
  String get signUp => 'Sign Up';
  @override
  String get email => 'Email';
  @override
  String get password => 'Password';
  @override
  String get confirmPassword => 'Confirm Password';
  @override
  String get forgotPassword => 'Forgot Password?';
  @override
  String get loginButton => 'Login';
  @override
  String get registerButton => 'Register';
  @override
  String get alreadyHaveAccount => 'Already have an account?';
  @override
  String get dontHaveAccount => "Don't have an account?";
  @override
  String get welcomeBack => 'Welcome Back!';
  @override
  String get createAccount => 'Create Account';

  @override
  String get home => 'Home';
  @override
  String get welcome => 'Welcome';
  @override
  String get todaysStats => "Today's Stats";
  @override
  String get recentActivity => 'Recent Activity';
  @override
  String get quickActions => 'Quick Actions';
  @override
  String get viewAll => 'View All';
  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String get scanPhoto => 'SCAN PHOTO';
  @override
  String get checkForMites => 'Check for mites';
  @override
  String get todaysDiagnoses => "Today's Diagnoses";
  @override
  String get images => 'Images';
  @override
  String get infected => 'Infected';

  @override
  String get scan => 'Scan';
  @override
  String get scanBee => 'Scan Bee';
  @override
  String get takePhoto => 'Take Photo';
  @override
  String get selectFromGallery => 'Select from Gallery';
  @override
  String get analyzing => 'Analyzing...';
  @override
  String get scanResult => 'Scan Result';
  @override
  String get confidence => 'Confidence';
  @override
  String get tryAgain => 'Try Again';
  @override
  String get saveResult => 'Save Result';

  @override
  String get map => 'Map';
  @override
  String get beehiveLocations => 'Beehive Locations';
  @override
  String get myLocation => 'My Location';
  @override
  String get nearbyBeehives => 'Nearby Beehives';
  @override
  String get distance => 'Distance';
  @override
  String get noBeehivesNearby => 'No beehives nearby';

  @override
  String get history => 'History';
  @override
  String get scanHistory => 'Scan History';
  @override
  String get noHistory => 'No scan history';
  @override
  String get date => 'Date';
  @override
  String get result => 'Result';
  @override
  String get deleteAll => 'Delete All';
  @override
  String get delete => 'Delete';
  @override
  String get confirm => 'Confirm';
  @override
  String get cancel => 'Cancel';

  @override
  String get myDiagnosisHistory => 'My Diagnosis History';
  @override
  String get loginRequired => 'Login required';
  @override
  String get myHistoryEmpty => 'No history available';
  @override
  String get scanImages => 'Scan some images!';
  @override
  String get mitesDetected => 'Mites Detected';
  @override
  String get noMitesDetected => 'No Mites Detected';
  @override
  String get minutesAgo => 'min ago';
  @override
  String get hoursAgo => 'hours ago';
  @override
  String get daysAgo => 'days ago';

  @override
  String get stats => 'Stats';
  @override
  String get statistics => 'Statistics';
  @override
  String get totalScans => 'Total Scans';
  @override
  String get successfulScans => 'Successful Scans';
  @override
  String get thisWeek => 'This Week';
  @override
  String get thisMonth => 'This Month';
  @override
  String get accuracy => 'Accuracy';
  @override
  String get averageConfidence => 'Average Confidence';

  @override
  String get weekly => 'Weekly';
  @override
  String get monthly => 'Monthly';
  @override
  String get periodSelection => 'Period Selection';
  @override
  String get selectPeriod => 'Select Period';
  @override
  String get noStatsData => 'No statistics data available';
  @override
  String get noDataCollected => 'No data collected for this period';
  @override
  String get totalDetections => 'Total Detections';
  @override
  String get period => 'Period';
  @override
  String get dailyDetectionCount => 'Daily Detection Count';
  @override
  String get last7Days => 'Last 7 Days';
  @override
  String get last30Days => 'Last 30 Days';
  @override
  String get days => 'Days';
  @override
  String get custom => 'Custom';

  @override
  String get mon => 'Mon';
  @override
  String get tue => 'Tue';
  @override
  String get wed => 'Wed';
  @override
  String get thu => 'Thu';
  @override
  String get fri => 'Fri';
  @override
  String get sat => 'Sat';
  @override
  String get sun => 'Sun';

  @override
  String get settings => 'Settings';
  @override
  String get language => 'Language';
  @override
  String get selectLanguage => 'Select Language';
  @override
  String get english => 'English';
  @override
  String get korean => '한국어';
  @override
  String get notifications => 'Notifications';
  @override
  String get enableNotifications => 'Enable Notifications';
  @override
  String get about => 'About';
  @override
  String get version => 'Version';
  @override
  String get privacyPolicy => 'Privacy Policy';
  @override
  String get termsOfService => 'Terms of Service';
  @override
  String get logout => 'Logout';
  @override
  String get profile => 'Profile';
  @override
  String get editProfile => 'Edit Profile';

  @override
  String get alerts => 'Alerts';
  @override
  String get notifications_title => 'Notifications';
  @override
  String get noAlerts => 'No alerts';
  @override
  String get markAllRead => 'Mark All Read';
  @override
  String get alertSettings => 'Alert Settings';
  @override
  String get pushNotifications => 'Push Notifications';
  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get loading => 'Loading...';
  @override
  String get error => 'Error';
  @override
  String get retry => 'Retry';
  @override
  String get save => 'Save';
  @override
  String get close => 'Close';
  @override
  String get ok => 'OK';
  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';
}

class AppLocalizationsKo extends AppLocalizations {
  @override
  String get signIn => '로그인';
  @override
  String get signUp => '회원가입';
  @override
  String get email => '이메일';
  @override
  String get password => '비밀번호';
  @override
  String get confirmPassword => '비밀번호 확인';
  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';
  @override
  String get loginButton => '로그인';
  @override
  String get registerButton => '회원가입';
  @override
  String get alreadyHaveAccount => '이미 계정이 있으신가요?';
  @override
  String get dontHaveAccount => '계정이 없으신가요?';
  @override
  String get welcomeBack => '다시 오신 것을 환영합니다!';
  @override
  String get createAccount => '계정 만들기';

  @override
  String get home => '홈';
  @override
  String get welcome => '환영합니다';
  @override
  String get todaysStats => '오늘의 통계';
  @override
  String get recentActivity => '최근 활동';
  @override
  String get quickActions => '빠른 작업';
  @override
  String get viewAll => '모두 보기';
  @override
  String get noRecentActivity => '최근 활동이 없습니다';

  @override
  String get scanPhoto => '사진 스캔';
  @override
  String get checkForMites => '진드기 검사';
  @override
  String get todaysDiagnoses => '오늘의 진단';
  @override
  String get images => '이미지';
  @override
  String get infected => '감염됨';

  @override
  String get scan => '스캔';
  @override
  String get scanBee => '벌 스캔';
  @override
  String get takePhoto => '사진 촬영';
  @override
  String get selectFromGallery => '갤러리에서 선택';
  @override
  String get analyzing => '분석 중...';
  @override
  String get scanResult => '스캔 결과';
  @override
  String get confidence => '신뢰도';
  @override
  String get tryAgain => '다시 시도';
  @override
  String get saveResult => '결과 저장';

  @override
  String get map => '지도';
  @override
  String get beehiveLocations => '벌집 위치';
  @override
  String get myLocation => '내 위치';
  @override
  String get nearbyBeehives => '근처 벌집';
  @override
  String get distance => '거리';
  @override
  String get noBeehivesNearby => '근처에 벌집이 없습니다';

  @override
  String get history => '히스토리';
  @override
  String get scanHistory => '스캔 히스토리';
  @override
  String get noHistory => '스캔 기록이 없습니다';
  @override
  String get date => '날짜';
  @override
  String get result => '결과';
  @override
  String get deleteAll => '모두 삭제';
  @override
  String get delete => '삭제';
  @override
  String get confirm => '확인';
  @override
  String get cancel => '취소';

  @override
  String get myDiagnosisHistory => '내 진단 히스토리';
  @override
  String get loginRequired => '로그인이 필요합니다';
  @override
  String get myHistoryEmpty => '내 히스토리가 없습니다';
  @override
  String get scanImages => '이미지를 스캔해보세요!';
  @override
  String get mitesDetected => 'Mites Detected';
  @override
  String get noMitesDetected => 'No Mites Detected';
  @override
  String get minutesAgo => '분 전';
  @override
  String get hoursAgo => '시간 전';
  @override
  String get daysAgo => '일 전';

  @override
  String get stats => '통계';
  @override
  String get statistics => '통계';
  @override
  String get totalScans => '총 스캔 수';
  @override
  String get successfulScans => '성공한 스캔';
  @override
  String get thisWeek => '이번 주';
  @override
  String get thisMonth => '이번 달';
  @override
  String get accuracy => '정확도';
  @override
  String get averageConfidence => '평균 신뢰도';

  @override
  String get weekly => '주간';
  @override
  String get monthly => '월간';
  @override
  String get periodSelection => '기간 선택';
  @override
  String get selectPeriod => '기간 선택';
  @override
  String get noStatsData => '통계 데이터가 없습니다';
  @override
  String get noDataCollected => '이 기간에 대한 데이터가 수집되지 않았습니다';
  @override
  String get totalDetections => '총 감지';
  @override
  String get period => '기간';
  @override
  String get dailyDetectionCount => '일일 감지 수';
  @override
  String get last7Days => '최근 7일';
  @override
  String get last30Days => '최근 30일';
  @override
  String get days => '일';
  @override
  String get custom => '커스텀';

  @override
  String get mon => '월';
  @override
  String get tue => '화';
  @override
  String get wed => '수';
  @override
  String get thu => '목';
  @override
  String get fri => '금';
  @override
  String get sat => '토';
  @override
  String get sun => '일';

  @override
  String get settings => '설정';
  @override
  String get language => '언어';
  @override
  String get selectLanguage => '언어 선택';
  @override
  String get english => 'English';
  @override
  String get korean => '한국어';
  @override
  String get notifications => '알림';
  @override
  String get enableNotifications => '알림 활성화';
  @override
  String get about => '정보';
  @override
  String get version => '버전';
  @override
  String get privacyPolicy => '개인정보 처리방침';
  @override
  String get termsOfService => '서비스 약관';
  @override
  String get logout => '로그아웃';
  @override
  String get profile => '프로필';
  @override
  String get editProfile => '프로필 편집';

  @override
  String get alerts => '알림';
  @override
  String get notifications_title => '알림';
  @override
  String get noAlerts => '알림이 없습니다';
  @override
  String get markAllRead => '모두 읽음 처리';
  @override
  String get alertSettings => '알림 설정';
  @override
  String get pushNotifications => '푸시 알림';
  @override
  String get emailNotifications => '이메일 알림';

  @override
  String get loading => '로딩 중...';
  @override
  String get error => '오류';
  @override
  String get retry => '다시 시도';
  @override
  String get save => '저장';
  @override
  String get close => '닫기';
  @override
  String get ok => '확인';
  @override
  String get yes => '예';
  @override
  String get no => '아니오';
}
