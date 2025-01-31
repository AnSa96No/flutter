import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'department_detail_screen.dart';
import 'department_create_screen.dart';

class DepartmentListScreen extends StatelessWidget {
  final String projectId;

  const DepartmentListScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('部門一覧')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DepartmentCreateScreen(projectId: projectId),
                ),
              );
            },
            child: const Text('部門を追加'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('departments')
                  .where('projectId', isEqualTo: projectId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('部門がありません'));
                }

                final departments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: departments.length,
                  itemBuilder: (context, index) {
                    final departmentDoc = departments[index];
                    final departmentData =
                        departmentDoc.data() as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        title: Text(departmentData['name'] ?? '部門名なし'),
                        subtitle:
                            Text('責任者: ${departmentData['manager'] ?? '未定'}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DepartmentDetailScreen(
                                departmentId: departmentDoc.id,
                                departmentData: departmentData,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
