import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DepartmentCreateScreen extends StatefulWidget {
  final String projectId;

  const DepartmentCreateScreen({super.key, required this.projectId});

  @override
  _DepartmentCreateScreenState createState() => _DepartmentCreateScreenState();
}

class _DepartmentCreateScreenState extends State<DepartmentCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _managerController = TextEditingController();
  final Uuid _uuid = Uuid();

  Future<void> _createDepartment() async {
    if (_nameController.text.trim().isEmpty ||
        _managerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('部門名と責任者を入力してください')),
      );
      return;
    }

    final String departmentId = _uuid.v4();

    await FirebaseFirestore.instance
        .collection('departments')
        .doc(departmentId)
        .set({
      'projectId': widget.projectId,
      'name': _nameController.text.trim(),
      'manager': _managerController.text.trim(),
      'taskIds': [],
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('部門作成')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '部門名')),
            const SizedBox(height: 16),
            TextField(
                controller: _managerController,
                decoration: const InputDecoration(labelText: '責任者')),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _createDepartment, child: const Text('追加')),
          ],
        ),
      ),
    );
  }
}
