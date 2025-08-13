import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'l10n/app_localizations.dart';

enum StatsPeriod { week, month, custom }

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with TickerProviderStateMixin {
  List<BarData> _data = [];
  StatsPeriod _selectedPeriod = StatsPeriod.week;
  DateTimeRange? _customDateRange;
  late TabController _tabController;
  late PageController _pageController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _onPeriodChanged(StatsPeriod.values[_tabController.index]);
      }
    });
    _fetchStatsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPeriodChanged(StatsPeriod period) {
    if (_selectedPeriod != period) {
      setState(() {
        _selectedPeriod = period;
      });
      _fetchStatsData();
    }
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF1A237E),
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _customDateRange) {
      setState(() {
        _customDateRange = picked;
        _selectedPeriod = StatsPeriod.custom;
        _tabController.animateTo(2);
      });
      _fetchStatsData();
    }
  }

  Future<void> _fetchStatsData() async {
    print("📊 전체 통계 데이터 가져오기 시작: $_selectedPeriod");

    setState(() {
      _isLoading = true;
    });

    try {
      // 기간 계산
      DateTime startDate;
      DateTime endDate = DateTime.now();

      switch (_selectedPeriod) {
        case StatsPeriod.week:
          startDate = DateTime.now().subtract(const Duration(days: 7));
          break;
        case StatsPeriod.month:
          startDate = DateTime.now().subtract(const Duration(days: 30));
          break;
        case StatsPeriod.custom:
          if (_customDateRange != null) {
            startDate = _customDateRange!.start;
            endDate = _customDateRange!.end;
          } else {
            startDate = DateTime.now().subtract(const Duration(days: 7));
          }
          break;
      }

      print(
          "🔍 쿼리 기간: ${DateFormat('yyyy-MM-dd').format(startDate)} ~ ${DateFormat('yyyy-MM-dd').format(endDate)}");

      // stats 컬렉션에서 데이터 가져오기 (인덱스 오류 방지를 위해 단순 쿼리 사용)
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('stats').get();

      print("📋 가져온 stats 문서 수: ${snapshot.docs.length}");

      // 기간 내 데이터만 필터링
      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final day = data['day'] as String?;
        if (day != null) {
          try {
            final date = DateTime.parse(day);
            return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                date.isBefore(endDate.add(const Duration(days: 1)));
          } catch (e) {
            print("날짜 파싱 오류: $day");
            return false;
          }
        }
        return false;
      }).toList();

      print("📋 기간 내 필터링된 문서 수: ${filteredDocs.length}");

      // 날짜별 데이터 처리
      List<BarData> tempData = [];

      if (_selectedPeriod == StatsPeriod.week) {
        // 최근 7일간의 데이터를 날짜별로 정리
        Map<String, int> dailyDetections = {};

        // stats 데이터에서 감지 수 추출
        for (var doc in filteredDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final day = data['day'] as String?;
          final detections = data['detections'] as int? ?? 0;

          if (day != null) {
            try {
              final date = DateTime.parse(day);
              final dayKey = DateFormat('E').format(date); // Mon, Tue, Wed...
              dailyDetections[dayKey] =
                  (dailyDetections[dayKey] ?? 0) + detections;
            } catch (e) {
              print("날짜 파싱 오류: $day");
            }
          }
        }

        // 최근 7일 생성
        for (int i = 6; i >= 0; i--) {
          final date = DateTime.now().subtract(Duration(days: i));
          final dayKey = DateFormat('E').format(date); // 요일
          final dateKey = DateFormat('MM/dd').format(date); // 날짜
          final localizedDay = _getLocalizedDayName(dayKey);
          final detections = dailyDetections[dayKey] ?? 0;
          tempData.add(BarData(
            day: '$localizedDay\n$dateKey', // 다국어 요일과 날짜를 함께 표시
            value: detections,
            detections: detections,
            date: date,
          ));
        }
      } else {
        // 월간 또는 커스텀 기간
        Map<String, int> dailyDetections = {};

        // stats 데이터에서 감지 수 추출
        for (var doc in filteredDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final day = data['day'] as String?;
          final detections = data['detections'] as int? ?? 0;

          if (day != null) {
            try {
              final date = DateTime.parse(day);
              final dayKey = DateFormat('MM/dd').format(date);
              dailyDetections[dayKey] =
                  (dailyDetections[dayKey] ?? 0) + detections;
            } catch (e) {
              print("날짜 파싱 오류: $day");
            }
          }
        }

        // 기간 내 모든 날짜 생성
        final daysDiff = endDate.difference(startDate).inDays;
        for (int i = 0; i <= daysDiff; i++) {
          final date = startDate.add(Duration(days: i));
          final dayKey = DateFormat('MM/dd').format(date);
          final detections = dailyDetections[dayKey] ?? 0;
          tempData.add(BarData(
            day: dayKey,
            value: detections,
            detections: detections,
            date: date,
          ));
        }
      }

      print("📊 생성된 차트 데이터: ${tempData.length}개");

      setState(() {
        _data = tempData;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ 통계 데이터 가져오기 오류: $e");
      setState(() {
        _data = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeYellow = Color(0xFFFCBF02);
    const themeBlue = Color(0xFF1A237E);
    const lightGray = Color(0xFFF5F6FA);

    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)?.statistics ?? '통계',
          style: const TextStyle(
            color: themeBlue,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: themeBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: themeBlue,
          indicatorWeight: 3,
          tabs: [
            Tab(text: AppLocalizations.of(context)?.weekly ?? '주간'),
            Tab(text: AppLocalizations.of(context)?.monthly ?? '월간'),
            Tab(text: AppLocalizations.of(context)?.periodSelection ?? '기간 선택'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 커스텀 기간 선택 버튼
          if (_selectedPeriod == StatsPeriod.custom)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _selectCustomDateRange,
                icon: const Icon(Icons.date_range),
                label: Text(
                  _customDateRange != null
                      ? '${DateFormat('MM/dd').format(_customDateRange!.start)} - ${DateFormat('MM/dd').format(_customDateRange!.end)}'
                      : AppLocalizations.of(context)?.selectPeriod ?? '기간 선택',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          // 로딩 또는 데이터 표시
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      _tabController.animateTo(index);
                      _onPeriodChanged(StatsPeriod.values[index]);
                    },
                    children: [
                      _buildStatsView(themeYellow, themeBlue),
                      _buildStatsView(themeYellow, themeBlue),
                      _buildStatsView(themeYellow, themeBlue),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsView(Color themeYellow, Color themeBlue) {
    if (_data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.noStatsData ?? '통계 데이터가 없습니다',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)?.noDataCollected ??
                  '아직 감지 데이터가 수집되지 않았습니다',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    int maxValue = _data.map((e) => e.value).fold(0, (a, b) => a > b ? a : b);
    if (maxValue == 0) maxValue = 1; // Division by zero 방지

    // 총 감지 수 계산
    int totalDetections = _data.fold(0, (sum, item) => sum + item.detections);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 요약 카드들
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  AppLocalizations.of(context)?.totalDetections ?? '총 감지',
                  totalDetections.toString(),
                  Icons.warning,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  AppLocalizations.of(context)?.period ?? '기간',
                  _getPeriodText(),
                  Icons.date_range,
                  themeBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 차트 제목
          Text(
            AppLocalizations.of(context)?.dailyDetectionCount ?? '일별 감지 횟수',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeBlue,
            ),
          ),
          const SizedBox(height: 16),

          // 차트
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // 차트
                Container(
                  height: 290, // 280에서 290으로 증가 (날짜 텍스트 높이 증가 고려)
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: IntrinsicHeight(
                      // 자동 높이 조정
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _data.map((bar) {
                          double barHeight = maxValue > 0
                              ? (bar.value / maxValue) * 140
                              : 0; // 높이 더 축소

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4), // 8에서 4로 축소
                            child: SizedBox(
                              width: 50, // 55에서 50으로 축소
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min, // 크기 최소화
                                children: [
                                  // 막대 위 숫자 표시 (조건부)
                                  SizedBox(
                                    height: 20, // 고정 높이로 overflow 방지
                                    child: bar.value > 0
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: themeBlue.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${bar.value}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: themeBlue,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 4),
                                  // 감지 막대
                                  Container(
                                    height: barHeight,
                                    width: 32,
                                    decoration: BoxDecoration(
                                      color: bar.value > 0
                                          ? themeYellow
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: bar.value > 0
                                          ? [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: bar.value > 0 && barHeight > 20
                                        ? Center(
                                            child: Text(
                                              '${bar.value}',
                                              style: const TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  // 날짜 표시
                                  SizedBox(
                                    height: 40, // 30에서 40으로 증가 (두 줄 텍스트)
                                    child: Center(
                                      child: Text(
                                        bar.day,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10, // 11에서 10으로 축소
                                          color: themeBlue,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodText() {
    final localizations = AppLocalizations.of(context);

    switch (_selectedPeriod) {
      case StatsPeriod.week:
        return localizations?.last7Days ?? '최근 7일';
      case StatsPeriod.month:
        return localizations?.last30Days ?? '최근 30일';
      case StatsPeriod.custom:
        if (_customDateRange != null) {
          final days =
              _customDateRange!.end.difference(_customDateRange!.start).inDays +
                  1;
          return '$days${localizations?.days ?? '일'}';
        }
        return localizations?.custom ?? '커스텀';
    }
  }

  String _getLocalizedDayName(String englishDay) {
    final localizations = AppLocalizations.of(context);

    switch (englishDay.toLowerCase()) {
      case 'mon':
        return localizations?.mon ?? '월';
      case 'tue':
        return localizations?.tue ?? '화';
      case 'wed':
        return localizations?.wed ?? '수';
      case 'thu':
        return localizations?.thu ?? '목';
      case 'fri':
        return localizations?.fri ?? '금';
      case 'sat':
        return localizations?.sat ?? '토';
      case 'sun':
        return localizations?.sun ?? '일';
      default:
        return englishDay;
    }
  }
}

class BarData {
  final String day;
  final int value;
  final int detections;
  final DateTime date;

  BarData({
    required this.day,
    required this.value,
    required this.detections,
    required this.date,
  });
}
