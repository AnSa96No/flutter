import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebRTCExample(),
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: P2PCommunication(),
//     );
//   }
// }

// class CameraSample extends StatefulWidget {
//   @override
//   _CameraSampleState createState() => _CameraSampleState();
// }

// class _CameraSampleState extends State<CameraSample> {
//   // late RTCVideoRenderer _renderer; // 映像を表示するためのレンダラー。
//   // MediaStream? _mediaStream; // カメラ映像用のメディアストリーム。

//   RTCPeerConnection? _peerConnection;
//   RTCDataChannel? _dataChannel;

//   final _textController = TextEditingController();
//   final _messages = <String>[]; // 受信メッセージを保存するリスト。

//   @override
//   void initState() {
//     super.initState();
//     _createPeerConnection(); // ピア接続の初期化。
//   }

//   @override
//   void dispose() {
//     _peerConnection?.close(); // ピア接続を閉じる。
//     _dataChannel?.close(); // データチャネルを閉じる。
//     _textController.dispose();
//     // _renderer.dispose(); // リソース解放。
//     // _mediaStream?.dispose(); // メディアストリームを解放。

//     super.dispose();
//   }

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   _initializeRenderer();
//   //   _getCameraStream(isFrontCamera: true); // 初期状態で前面カメラを使用。
//   // }

//   // /// RTCVideoRendererの初期化
//   // void _initializeRenderer() async {
//   //   _renderer = RTCVideoRenderer();
//   //   await _renderer.initialize(); // レンダラーの初期化。
//   // }

// // ピア接続の作成
//   Future<void> _createPeerConnection() async {
//     final configuration = {
//       'iceServers': [
//         {'urls': 'stun:stun.l.google.com:19302'}, // STUNサーバー設定
//       ],
//     };

//     final offerSdpConstraints = {
//       'mandatory': {},
//       'optional': [],
//     };

//     // ピア接続の作成
//     _peerConnection =
//         await createPeerConnection(configuration, offerSdpConstraints);

//     // データチャネルの作成
//     RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
//     dataChannelDict.ordered = true; // 順序保証
//     dataChannelDict.maxRetransmits = 30; // 再送回数の最大値
//     _dataChannel =
//         await _peerConnection!.createDataChannel('chat', dataChannelDict);

//     // データチャネルのイベントリスナー設定
//     _dataChannel!.onMessage = (RTCDataChannelMessage message) {
//       setState(() {
//         _messages.add('Received: ${message.text}');
//       });
//     };

//     _peerConnection!.onDataChannel = (RTCDataChannel channel) {
//       setState(() {
//         _dataChannel = channel;
//       });
//     };
//   }

// // メッセージの送信
//   void _sendMessage() {
//     if (_dataChannel != null && _textController.text.isNotEmpty) {
//       final message = _textController.text;
//       _dataChannel!.send(RTCDataChannelMessage(message));
//       setState(() {
//         _messages.add('Sent: $message');
//         print(message);
//         _textController.clear(); // テキストフィールドをクリア。
//       });
//     }
//   }

// // UIの構築
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Data Channel Sample'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 return ListTile(title: Text(_messages[index]));
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _textController,
//                     decoration: InputDecoration(hintText: 'Enter message'),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // // カメラ映像を取得する
//   // Future<void> _getCameraStream({required bool isFrontCamera}) async {
//   //   try {
//   //     // カメラデバイスの設定
//   //     final Map<String, dynamic> mediaConstraints = {
//   //       'audio': false,
//   //       'video': {
//   //         'facingMode': isFrontCamera ? 'user' : 'environment', // カメラの向き
//   //       },
//   //     };

//   //     //     // メディアストリームの取得
//   //     MediaStream stream =
//   //         await navigator.mediaDevices.getUserMedia(mediaConstraints);

//   //     // ストリームをレンダラーにバインド
//   //     setState(() {
//   //       _mediaStream = stream;
//   //       _renderer.srcObject = _mediaStream;
//   //     });
//   //   } catch (e) {
//   //     debugPrint('カメラの映像を取得できませんでした: $e');
//   //   }
//   // }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //     appBar: AppBar(
//   //       title: Text('カメラ映像取得サンプル'),
//   //       actions: [
//   //         IconButton(
//   //           icon: Icon(Icons.camera_front), // 前面カメラに切り替え
//   //           onPressed: () => _getCameraStream(isFrontCamera: true),
//   //         ),
//   //         IconButton(
//   //           icon: Icon(Icons.camera_rear), // 背面カメラに切り替え
//   //           onPressed: () => _getCameraStream(isFrontCamera: false),
//   //         ),
//   //       ],
//   //     ),
//   //     body: Center(
//   //       child: _renderer.textureId != null // 映像を表示
//   //           ? RTCVideoView(_renderer)
//   //           : Text('カメラを初期化中...'),
//   //     ),
//   //   );
//   // }
// }

class WebRTCSignaling {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RTCPeerConnection? _peerConnection;

  Future<void> createOffer(String callId) async {
    final callDoc = _firestore.collection('calls').doc(callId);
    final offerCandidates = callDoc.collection('offerCandidates');

    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate != null) {
        offerCandidates.add(candidate.toMap());
      }
    };

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    callDoc.set({
      'offer': {'sdp': offer.sdp, 'type': offer.type},
    });

    // リモートアンサーの監視
    callDoc.snapshots().listen((snapshot) async {
      if (snapshot.data() != null && snapshot.data()!['answer'] != null) {
        final answer = snapshot.data()!['answer'];
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(answer['sdp'], answer['type']),
        );
      }
    });
  }

  Future<void> createAnswer(String callId) async {
    final callDoc = _firestore.collection('calls').doc(callId);
    final answerCandidates = callDoc.collection('answerCandidates');

    final callData = (await callDoc.get()).data();

    if (callData == null || callData['offer'] == null) {
      throw Exception('No offer found');
    }

    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate != null) {
        answerCandidates.add(candidate.toMap());
      }
    };

    final offer = callData['offer'];
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );

    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    callDoc.update({
      'answer': {'sdp': answer.sdp, 'type': answer.type},
    });
  }
}

class WebRTCExample extends StatefulWidget {
  @override
  _WebRTCExampleState createState() => _WebRTCExampleState();
}

class _WebRTCExampleState extends State<WebRTCExample> {
  final TextEditingController _callIdController = TextEditingController();
  final WebRTCSignaling signaling = WebRTCSignaling();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('P2P with Firebase'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _callIdController,
              decoration: InputDecoration(
                labelText: 'Call ID',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final callId = _callIdController.text.trim();
              if (callId.isNotEmpty) {
                signaling.createOffer(callId);
              }
            },
            child: Text('Create Offer'),
          ),
          ElevatedButton(
            onPressed: () {
              final callId = _callIdController.text.trim();
              if (callId.isNotEmpty) {
                signaling.createAnswer(callId);
              }
            },
            child: Text('Create Answer'),
          ),
        ],
      ),
    );
  }
}
