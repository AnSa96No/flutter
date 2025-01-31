import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentDetailScreen extends StatelessWidget {
  final String departmentId;
  final Map<String, dynamic> departmentData;

  const DepartmentDetailScreen({
    super.key,
    required this.departmentId,
    required this.departmentData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(departmentData['name'] ?? '部門詳細')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('部門名: ${departmentData['name'] ?? 'なし'}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('責任者: ${departmentData['manager'] ?? '未定'}'),
            const SizedBox(height: 16),
            const Text('関連タスク:'),
            const SizedBox(height: 8),

            // Firestore から関連タスクを取得
            if (departmentData['taskIds'] != null &&
                departmentData['taskIds'].isNotEmpty)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('tasks')
                      .where(FieldPath.documentId,
                          whereIn: departmentData['taskIds'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text('関連タスクがありません');
                    }

                    // タスクのリストを表示
                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        return ListTile(
                          title: Text(doc['title']),
                          subtitle: Text(doc['description']),
                        );
                      }).toList(),
                    );
                  },
                ),
              )
            else
              const Text('関連タスクがありません'),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class DepartmentDetailScreen extends StatelessWidget {
//   final String departmentId;
//   final Map<String, dynamic> departmentData;

//   const DepartmentDetailScreen({
//     super.key,
//     required this.departmentId,
//     required this.departmentData,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(departmentData['name'] ?? '部門詳細')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('部門名: ${departmentData['name'] ?? 'なし'}',
//                 style:
//                     const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 16),
//             Text('責任者: ${departmentData['manager'] ?? '未定'}'),
//             const SizedBox(height: 16),
//             const Text('関連タスク:'),
//             const SizedBox(height: 8),

//             // Firestore から関連タスクを取得
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('tasks')
//                     .where(FieldPath.documentId, //エラー
//                         whereIn: departmentData['taskIds'] ?? [])
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(child: Text('関連タスクがありません'));
//                   }

//                   final tasks = snapshot.data!.docs;

//                   return ListView.builder(
//                     itemCount: tasks.length,
//                     itemBuilder: (context, index) {
//                       final taskData =
//                           tasks[index].data() as Map<String, dynamic>;

//                       return ListTile(
//                         title: Text(taskData['name'] ?? 'タスク名なし'),
//                         subtitle: Text('締切日: ${taskData['dueDate'] ?? '未定'}'),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
