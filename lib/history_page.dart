import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'l10n/app_localizations.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
  }

  /// 시간을 사람이 이해하기 쉬운 '몇 분 전', '몇 시간 전' 형식으로 반환
  String _formatTimeAgo(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final localizations = AppLocalizations.of(context);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}${localizations?.minutesAgo ?? 'min ago'}';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}${localizations?.hoursAgo ?? 'hours ago'}';
    } else {
      return '${diff.inDays}${localizations?.daysAgo ?? 'days ago'}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)?.myDiagnosisHistory ??
              'My Diagnosis History',
          style: const TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildMyHistoryList(),
    );
  }

  Widget _buildMyHistoryList() {
    print("🔄 내 히스토리 리스트 빌드");

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        final currentUser = userSnapshot.data;
        print("👤 현재 사용자 상태: ${currentUser?.uid}");

        // 로그인하지 않은 경우
        if (currentUser == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)?.loginRequired ?? '로그인이 필요합니다',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // 내 데이터만 가져오는 쿼리
        Query query = FirebaseFirestore.instance
            .collection('diagnoses')
            .where('userId', isEqualTo: currentUser.uid)
            .orderBy('timestamp', descending: true);

        print("🔍 내 데이터 쿼리: userId=${currentUser.uid}");

        return StreamBuilder<QuerySnapshot>(
          stream: query.snapshots(),
          builder: (context, snapshot) {
            print(
                "📊 쿼리 상태: hasData=${snapshot.hasData}, hasError=${snapshot.hasError}");

            if (snapshot.hasError) {
              print("❌ 쿼리 오류: ${snapshot.error}");

              // Firebase 인덱스 관련 에러인지 확인
              String errorMessage = snapshot.error.toString();
              if (errorMessage.contains('index') ||
                  errorMessage.contains('composite')) {
                print("🔍 Firebase 인덱스 문제 감지, 단순 쿼리로 재시도");
                // 인덱스 없이 단순 쿼리 시도
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('diagnoses')
                      .where('userId', isEqualTo: currentUser.uid)
                      .snapshots(),
                  builder: (context, retrySnapshot) {
                    if (retrySnapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error,
                                size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Firebase 설정 오류:\n${retrySnapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!retrySnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = retrySnapshot.data!.docs;
                    // 클라이언트 사이드에서 정렬
                    docs.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aTime = aData['timestamp'] as Timestamp?;
                      final bTime = bData['timestamp'] as Timestamp?;
                      if (aTime == null || bTime == null) return 0;
                      return bTime.compareTo(aTime);
                    });

                    print("📋 단순 쿼리로 문서 수: ${docs.length}");

                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)?.myHistoryEmpty ??
                                  '내 히스토리가 없습니다',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey),
                            ),
                            Text(
                              AppLocalizations.of(context)?.scanImages ??
                                  '이미지를 스캔해보세요!',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return _buildHistoryListView(docs);
                  },
                );
              }

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading history:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.red),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final documents = snapshot.data!.docs;
            print("📋 문서 수: ${documents.length}");

            if (documents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)?.myHistoryEmpty ??
                          '내 히스토리가 없습니다',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Text(
                      AppLocalizations.of(context)?.scanImages ??
                          '이미지를 스캔해보세요!',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            return _buildHistoryListView(documents);
          },
        );
      },
    );
  }

  Widget _buildHistoryListView(List<QueryDocumentSnapshot> documents) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        final data = doc.data() as Map<String, dynamic>;

        // Firestore Timestamp → DateTime 변환
        DateTime date;
        if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
          date = (data['timestamp'] as Timestamp).toDate();
        } else {
          date = DateTime.now();
        }
        final formattedDate = DateFormat('MMMM dd, yyyy').format(date);

        // 감염 상태 파악 및 문자열 변환
        final infectionStr =
            data['infection']?.toString().toLowerCase() ?? 'unknown';
        final localizations = AppLocalizations.of(context);
        final status =
            (infectionStr == 'yes' || infectionStr == 'mites detected')
                ? (localizations?.mitesDetected ?? 'Mites Detected')
                : (localizations?.noMitesDetected ?? 'No Mites Detected');

        // 이미지 경로 (Firestore에 URL 있으면 네트워크 이미지, 없으면 기본 이미지)
        final imagePath = data['image'] ?? 'assets/profile_pic.png';

        final timeAgo = _formatTimeAgo(date, context);

        final bool isDetected = status == 'Mites Detected';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imagePath.toString().startsWith('http')
                    ? Image.network(
                        imagePath,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        imagePath,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDetected
                            ? const Color(0xFF1A237E)
                            : Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                timeAgo,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
