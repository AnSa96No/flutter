import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'projectdatail_screen.dart';
import 'login_screen.dart';
import 'project_create_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(''), //ホーム画面
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                // サインアウト処理
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) {
                    return const LoginScreen();
                  }),
                );
              },
            ),
          ],
        ),
        // Firestore の projects コレクションをリアルタイムで監視
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('projects').snapshots(),
          builder: (context, snapshot) {
            // データ取得中はローディングインジケータを表示
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // エラー発生時の処理
            if (snapshot.hasError) {
              return const Center(
                child: Text('データの取得中にエラーが発生しました'),
              );
            }

            // データが空の場合の処理
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('プロジェクトがありません'),
              );
            }

            // Firestore から取得したドキュメントリスト
            final projects = snapshot.data!.docs;

            // リストビューでプロジェクトを表示
            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                final data =
                    project.data() as Map<String, dynamic>; // ドキュメントのデータを取得

                // description,date が null または空文字列の場合は「未定」と表示
                final description = (data['description'] == null ||
                        data['description'].toString().trim().isEmpty)
                    ? '説明がありません'
                    : data['description'];
                final date = (data['date'] == null ||
                        data['date'].toString().trim().isEmpty)
                    ? '日程未定'
                    : data['date'];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('${data['name'] ?? 'なし'}'), // プロジェクト名
                    subtitle: Text(description), // プロジェクト説明
                    trailing: Text(date), // プロジェクトの日程
                    onTap: () {
                      // リストアイテムをタップすると詳細画面に遷移
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetailScreen(
                            projectId: project.id, // プロジェクトIDを渡す
                            projectData: data, // プロジェクトのデータを渡す
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
        //イベント作成ボタン
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            //イベント作成画面に遷移
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return const ProjectScreen();
              }),
            );
          },
          child: const Icon(Icons.add),
        ));
  }
}
