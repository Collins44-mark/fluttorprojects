import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/alert_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// Make sure to add firebase_storage to your pubspec.yaml:
// dependencies:
//   firebase_storage: ^11.0.0
import 'package:firebase_storage/firebase_storage.dart';
import 'employee_profile_screen.dart';
import 'alert_details_screen.dart';
import '../../main.dart';

class EmployeeDashboard extends StatefulWidget {
  final UserModel user;
  const EmployeeDashboard({super.key, required this.user});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Active', 'History'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<String?> _pickAndUploadProof(
    BuildContext context,
    String alertId,
  ) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return null;
    final file = File(pickedFile.path);
    final storageRef = FirebaseStorage.instance.ref().child(
      'alert_proofs/$alertId/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final uploadTask = await storageRef.putFile(file);
    final url = await uploadTask.ref.getDownloadURL();
    return url;
  }

  Query _getQuery() {
    final base = FirebaseFirestore.instance
        .collection('alerts')
        .where('assignedEmployeeId', isEqualTo: widget.user.uid)
        .orderBy('createdAt', descending: true);
    final tab = _tabController.index;
    if (tab == 1) {
      // Active: Assigned or In Progress
      return base.where('status', whereIn: ['Assigned', 'In Progress']);
    } else if (tab == 2) {
      // History: Completed, Approved, Done
      return base.where('status', whereIn: ['Completed', 'Approved', 'Done']);
    }
    // All
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          onTap: (_) => setState(() {}),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EmployeeProfileScreen(user: widget.user),
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(_tabs.length, (tabIdx) {
          return StreamBuilder<QuerySnapshot>(
            stream: _getQuery().snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                print('Firestore error:  ${snapshot.error}');
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
                    tabIdx == 0
                        ? 'No assigned alerts yet.'
                        : tabIdx == 1
                        ? 'No active alerts.'
                        : 'No alert history.',
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
                  final status = data['status'] ?? 'Assigned';
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(0.95)
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
                          Icons.assignment,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      title: Text(
                        alert.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 18,
                            ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          if (data['proofUrl'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  data['proofUrl'],
                                  height: 80,
                                ),
                              ),
                            ),
                          Text(
                            'Status:  ${status}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.primary,
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
                          if (value == 'accept') {
                            await FirebaseFirestore.instance
                                .collection('alerts')
                                .doc(docs[index].id)
                                .update({'status': 'In Progress'});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Alert accepted.')),
                            );
                          } else if (value == 'proof') {
                            final url = await widget.user is UserModel
                                ? await (context
                                      .findAncestorStateOfType<
                                        _EmployeeDashboardState
                                      >()
                                      ?._pickAndUploadProof(
                                        context,
                                        docs[index].id,
                                      ))
                                : null;
                            if (url != null) {
                              await FirebaseFirestore.instance
                                  .collection('alerts')
                                  .doc(docs[index].id)
                                  .update({'proofUrl': url});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Proof uploaded.'),
                                ),
                              );
                            }
                          } else if (value == 'complete') {
                            if (data['proofUrl'] == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please provide proof before marking as completed.',
                                  ),
                                ),
                              );
                              return;
                            }
                            await FirebaseFirestore.instance
                                .collection('alerts')
                                .doc(docs[index].id)
                                .update({'status': 'Completed'});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Marked as completed. Awaiting approval.',
                                ),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) {
                          if (status == 'Assigned') {
                            return [
                              const PopupMenuItem(
                                value: 'accept',
                                child: Text('Accept'),
                              ),
                            ];
                          } else if (status == 'In Progress') {
                            return [
                              const PopupMenuItem(
                                value: 'proof',
                                child: Text('Provide Proof'),
                              ),
                              const PopupMenuItem(
                                value: 'complete',
                                child: Text('Mark as Completed'),
                              ),
                            ];
                          } else {
                            return [];
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        }),
      ),
    );
  }
}
