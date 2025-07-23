import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlertDetailsScreen extends StatelessWidget {
  final AlertModel alert;
  final Map<String, dynamic> data;
  const AlertDetailsScreen({
    super.key,
    required this.alert,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls = List<String>.from(data['imageUrls'] ?? []);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Details'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Status: ${alert.status}',
              style: const TextStyle(fontSize: 16, color: Colors.deepOrange),
            ),
            const SizedBox(height: 12),
            Text(
              'Description:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(alert.description),
            const SizedBox(height: 12),
            Text('Cause:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(alert.cause),
            const SizedBox(height: 12),
            Text(
              'Location:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(alert.location),
            const SizedBox(height: 12),
            if (alert.assignedEmployeeName != null)
              Text(
                'Assigned to: ${alert.assignedEmployeeName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 12),
            if (imageUrls.isNotEmpty) ...[
              const Text(
                'Images:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  itemBuilder: (context, idx) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrls[idx],
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (data['proofUrl'] != null ||
                data['proofDescription'] != null) ...[
              const Text(
                'Completion Proof:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (data['proofUrl'] != null)
                Image.network(data['proofUrl'], height: 120),
              if (data['proofDescription'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    data['proofDescription'],
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              const SizedBox(height: 12),
            ],
            Text('Created At: ${alert.createdAt.toLocal()}'),
            if (alert.completedAt != null)
              Text('Completed At: ${alert.completedAt!.toLocal()}'),
            if (alert.status == 'Done')
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Approve Completion'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('alerts')
                            .doc(data['id'] ?? alert.id)
                            .update({'status': 'Approved'});

                        // Create notifications for worker, customer, and department
                        final notifications = FirebaseFirestore.instance
                            .collection('notifications');
                        final now = DateTime.now();
                        final alertTitle = alert.title;
                        final workerId = data['assignedEmployeeId'];
                        final customerId = data['creatorId'];
                        final departmentId = data['departmentId'];
                        // Worker notification
                        if (workerId != null) {
                          await notifications.add({
                            'userId': workerId,
                            'title': 'Alert Approved',
                            'body':
                                'Your work on "$alertTitle" has been approved by the department.',
                            'timestamp': now,
                            'read': false,
                          });
                        }
                        // Customer notification
                        if (customerId != null) {
                          await notifications.add({
                            'userId': customerId,
                            'title': 'Alert Resolved',
                            'body':
                                'Your alert "$alertTitle" has been resolved and approved.',
                            'timestamp': now,
                            'read': false,
                          });
                        }
                        // Department notification (optional, confirmation)
                        if (departmentId != null) {
                          await notifications.add({
                            'userId': departmentId,
                            'title': 'Alert Approved',
                            'body': 'You approved "$alertTitle".',
                            'timestamp': now,
                            'read': false,
                          });
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Alert approved!')),
                          );
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
