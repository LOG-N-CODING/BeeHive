import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:AIAPIS/constants.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final CollectionReference _alertsRef =
      FirebaseFirestore.instance.collection('alerts');

  Future<void> _refreshAlerts() async {
    setState(() {});
  }

  Future<void> _markAsRead(DocumentSnapshot doc) async {
    await _alertsRef.doc(doc.id).update({'read': true});
  }

  Future<void> _deleteAlert(DocumentSnapshot doc) async {
    await _alertsRef.doc(doc.id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Alerts & Notifications',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkBlue,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAlerts,
        child: StreamBuilder<QuerySnapshot>(
          stream: _alertsRef.orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading alerts.'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(child: Text('No alerts at the moment.'));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>?;

                final alertText = data?['message'] ?? 'Unknown alert';
                final timestamp = data?['timestamp'];
                final isRead = data?['read'] ?? false;
                final severity = data?['severity'] ?? 'normal';

                String timeString = '';
                if (timestamp != null && timestamp is Timestamp) {
                  timeString = timestamp.toDate().toString();
                }

                Color iconColor;
                switch (severity.toLowerCase()) {
                  case 'high':
                    iconColor = Colors.red;
                    break;
                  case 'medium':
                    iconColor = Colors.orange;
                    break;
                  default:
                    iconColor = darkBlue;
                }

                return Dismissible(
                  key: Key(doc.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red.withOpacity(0.8),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _deleteAlert(doc);
                  },
                  child: ListTile(
                    leading: Icon(Icons.warning, color: iconColor),
                    title: Text(
                      alertText,
                      style: TextStyle(
                        fontWeight:
                            isRead ? FontWeight.normal : FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    subtitle: Text('Time: $timeString',
                        style: const TextStyle(color: Colors.black54)),
                    trailing: isRead
                        ? null
                        : TextButton(
                            onPressed: () => _markAsRead(doc),
                            child: const Text('Mark as Read'),
                          ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
