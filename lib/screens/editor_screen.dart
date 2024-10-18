import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // 追加

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  EditorScreenState createState() => EditorScreenState();
}

class EditorScreenState extends State<EditorScreen> {
  FleatherController? _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _loadDocument().then((document) {
      setState(() {
        _controller = FleatherController(document: document);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveDocument(context),
          ),
        ],
      ),
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (Platform.isAndroid || Platform.isIOS)
                  FleatherToolbar.basic(controller: _controller!),
                const Divider(),
                Expanded(
                  child: GestureDetector(
                    onTapUp: (details) {
                      _handleTap(details);
                    },
                    child: FleatherEditor(
                      padding: const EdgeInsets.all(16),
                      controller: _controller!,
                      focusNode: _focusNode,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<ParchmentDocument> _loadDocument() async {
    final file = File(Directory.systemTemp.path + "/quick_start.json");

    if (await file.exists()) {
      final contents = await file.readAsString();
      return ParchmentDocument.fromJson(jsonDecode(contents));
    }
    final Delta delta = Delta()..insert("Fleather Quick Start\n");
    return ParchmentDocument.fromDelta(delta);
  }

  void _saveDocument(BuildContext context) {
    final contents = jsonEncode(_controller!.document);
    final file = File('${Directory.systemTemp.path}/quick_start.json');
    file.writeAsString(contents).then(
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved.')),
        );
      },
    );
  }

  // タップイベントを処理する
  void _handleTap(TapUpDetails details) {
    final selection = _controller!.selection;
    final selectedText = _getSelectedText(selection);

    final Uri? url = _extractUrl(selectedText);
    if (url != null) {
      _launchUrl(url);
    }
  }

  // 選択されたテキストを取得
  String _getSelectedText(TextSelection selection) {
    final start = selection.start;
    final end = selection.end;
    final plainText = _controller!.document.toPlainText();
    return plainText.substring(start, end);
  }

  // URLを抽出するメソッド
  Uri? _extractUrl(String text) {
    final urlPattern = RegExp(
      r'(https?:\/\/[^\s]+)',
      caseSensitive: false,
    );
    final match = urlPattern.firstMatch(text);
    if (match != null) {
      return Uri.tryParse(match.group(0)!);
    }
    return null;
  }

  // 外部ブラウザでURLを開く
  Future<void> _launchUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch URL')),
      );
    }
  }
}
