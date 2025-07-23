import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/alert_model.dart';
import 'package:badges/badges.dart' as badges;
// ignore: unused_import
import '../../main.dart';
import 'profile_screen.dart';
import 'alert_details_screen.dart';
import 'employee_profile_screen.dart';
import 'employee_management_screen.dart';

class DepartmentDashboard extends StatefulWidget {
  final UserModel user;
  const DepartmentDashboard({super.key, required this.user});

  @override
  State<DepartmentDashboard> createState() => _DepartmentDashboardState();
}

class _DepartmentDashboardState extends State<DepartmentDashboard> {
  int _selectedIndex = 0;

  void _showNotificationsDialog(BuildContext context) async {
    final notificationsRef = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: widget.user.uid)
        .orderBy('timestamp', descending: true);
    final snapshot = await notificationsRef.get();
    // Mark all as read
    for (var doc in snapshot.docs) {
      if (doc['read'] == false) {
        doc.reference.update({'read': true});
      }
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: snapshot.docs.isEmpty
              ? const Text('No notifications.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.docs.length,
                  itemBuilder: (context, idx) {
                    final notif = snapshot.docs[idx].data();
                    return ListTile(
                      leading: Icon(
                        notif['read'] == false
                            ? Icons.notifications_active
                            : Icons.notifications,
                        color: notif['read'] == false
                            ? Colors.deepOrange
                            : Colors.grey,
                      ),
                      title: Text(notif['title'] ?? ''),
                      subtitle: Text(notif['body'] ?? ''),
                      trailing: Text(
                        notif['timestamp'] != null
                            ? (notif['timestamp'] as Timestamp)
                                  .toDate()
                                  .toLocal()
                                  .toString()
                                  .substring(0, 16)
                            : '',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMessagesDialog(BuildContext context) async {
    final reviewsRef = FirebaseFirestore.instance
        .collection('reviews')
        .orderBy('timestamp', descending: true);
    final snapshot = await reviewsRef.get();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Reviews & Suggestions'),
        content: SizedBox(
          width: double.maxFinite,
          child: snapshot.docs.isEmpty
              ? const Text('No reviews or suggestions yet.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.docs.length,
                  itemBuilder: (context, idx) {
                    final review = snapshot.docs[idx].data();
                    return ListTile(
                      leading: const Icon(
                        Icons.message,
                        color: Colors.deepOrange,
                      ),
                      title: Text(review['username'] ?? 'User'),
                      subtitle: Text(review['review'] ?? ''),
                      trailing: Text(
                        review['timestamp'] != null
                            ? (review['timestamp'] as Timestamp)
                                  .toDate()
                                  .toLocal()
                                  .toString()
                                  .substring(0, 16)
                            : '',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('alerts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print('Firestore error: ${snapshot.error}');
          return Center(
            child: Text(
              'An error occurred. Please contact admin.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text(
              'No assigned alerts yet.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final alert = AlertModel.fromMap(data);
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surface.withOpacity(0.98)
                  : Theme.of(context).cardColor,
              child: ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepOrange,
                        Colors.purple,
                        Colors.lightBlueAccent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                title: Text(
                  alert.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.orange.shade200
                        : Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.87)
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (alert.assignedEmployeeName != null)
                      Text(
                        'Assigned to:  ${alert.assignedEmployeeName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.blue.shade200
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    Text(
                      'Status:  ${alert.status ?? "Pending"}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.greenAccent.shade200
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (data['proofUrl'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(data['proofUrl'], height: 80),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AlertDetailsScreen(alert: alert, data: data),
                    ),
                  );
                },
                trailing: PopupMenuButton<String>(
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (value) async {
                    if (value == 'assign') {
                      // Show dialog to select employee
                      final employeesSnapshot = await FirebaseFirestore.instance
                          .collection('employees')
                          .where('departmentId', isEqualTo: widget.user.uid)
                          .get();
                      final employees = employeesSnapshot.docs;
                      if (employees.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No employees available to assign.'),
                          ),
                        );
                        return;
                      }
                      String? selectedEmployeeId;
                      String? selectedEmployeeName;
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Assign to Employee'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: employees.length,
                                itemBuilder: (context, idx) {
                                  final emp = employees[idx].data();
                                  return RadioListTile<String>(
                                    value: employees[idx].id,
                                    groupValue: selectedEmployeeId,
                                    onChanged: (val) {
                                      selectedEmployeeId = val;
                                      selectedEmployeeName = emp['name'] ?? '';
                                      Navigator.of(context).pop();
                                    },
                                    title: Text(emp['name'] ?? ''),
                                    subtitle: Text(
                                      'Work ID:  ${emp['workId']}',
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                      if (selectedEmployeeId != null) {
                        await FirebaseFirestore.instance
                            .collection('alerts')
                            .doc(docs[index].id)
                            .update({
                              'assignedEmployeeId': selectedEmployeeId,
                              'assignedEmployeeName': selectedEmployeeName,
                              'status': 'Assigned',
                            });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Alert assigned to $selectedEmployeeName.',
                            ),
                          ),
                        );
                      }
                    } else if (value == 'done') {
                      // TODO: Mark as done and allow department to approve
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'assign',
                      child: Text('Assign to Employee'),
                    ),
                    const PopupMenuItem(
                      value: 'done',
                      child: Text('Mark as Done'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmployeeManagement() {
    return EmployeeManagementScreen(departmentId: widget.user.uid);
  }

  Widget _buildProfile() {
    return ProfileScreen(user: widget.user, showHeader: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEPARTMENT'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          // Notification Icon
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: widget.user.uid)
                .where('read', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              int unreadCount = snapshot.data?.docs.length ?? 0;
              return IconButton(
                icon: badges.Badge(
                  showBadge: unreadCount > 0,
                  badgeContent: Text(
                    unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  child: const Icon(Icons.notifications),
                ),
                onPressed: () => _showNotificationsDialog(context),
                tooltip: 'Notifications',
              );
            },
          ),
          // Messages Icon
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () => _showMessagesDialog(context),
            tooltip: 'User Reviews & Suggestions',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [_buildHome(), _buildEmployeeManagement(), _buildProfile()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.7),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Employees'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
