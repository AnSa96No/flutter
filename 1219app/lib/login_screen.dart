// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   late String emailAddress;
//   late String password;

//   String? _errorMessage;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Firebase ログイン',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'メールアドレス',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'パスワード',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               if (_errorMessage != null)
//                 Text(
//                   _errorMessage!,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               const SizedBox(height: 10),
//               TextButton(
//                 onPressed: () async {
//                   emailAddress = _emailController.text.trim();
//                   password = _passwordController.text.trim();
//                   try {
//                     final credential =
//                         await FirebaseAuth.instance.signInWithEmailAndPassword(
//                       email: emailAddress,
//                       password: password,
//                     );
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const HomeScreen()),
//                     );
//                   } on FirebaseAuthException catch (e) {
//                     if (e.code == 'user-not-found') {
//                       print('No user found for that email.');
//                     } else if (e.code == 'wrong-password') {
//                       print('Wrong password provided for that user.');
//                     }
//                   }
//                 },
//                 child: Text('ログイン'),
//                 style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                 ),
//               ),
//               SizedBox(height: 10),
//               TextButton(
//                 onPressed: () {
//                   // パスワードを忘れた場合の処理
//                 },
//                 child: const Text('パスワードを忘れましたか？'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'chatroom_list_screen.dart'; // ChatRoomListScreenのインポート

class LoginScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _loginAndAddUser(BuildContext context) async {
    try {
      // Googleサインインを開始
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // ユーザーがサインインをキャンセルした場合
        return;
      }

      // Googleサインインから認証情報を取得
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // FirebaseでGoogleの認証情報を使用してサインイン
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Firestoreでユーザーが存在するか確認
        final userQuery = await _firestore
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .get();

        if (userQuery.docs.isEmpty) {
          // ユーザーが存在しない場合、新しいユーザーを追加
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'name': user.displayName ?? 'User',
            // 他の必要なフィールドを追加
          });

          print('新しいユーザーが追加されました: ${user.uid}');
        } else {
          print('ユーザーは既に存在します: ${user.uid}');
        }

        // フェードインアニメーションで画面遷移
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ChatRoomListScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = 0.0;
              const end = 1.0;
              const curve = Curves.easeIn;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var fadeAnimation = animation.drive(tween);

              return FadeTransition(
                opacity: fadeAnimation,
                child: child,
              );
            },
          ),
        );
      }
    } catch (e) {
      print('ログインエラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログインに失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _loginAndAddUser(context),
          child: Text('Googleでログイン'),
        ),
      ),
    );
  }
}
