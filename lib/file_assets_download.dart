// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:permission_handler/permission_handler.dart';

import 'package:download_any_file/check_permission.dart';
import 'package:download_any_file/directory_path.dart';
import 'package:download_any_file/open_flutter_file.dart';

class FileAssetsDownload extends StatefulWidget {
  const FileAssetsDownload({super.key});

  @override
  State<FileAssetsDownload> createState() => _FileAssetsDownloadState();
}

class _FileAssetsDownloadState extends State<FileAssetsDownload> {
  bool isPermission = false;
  var checkAllPermissions = CheckPermission();

  checkPermission() async {
    var permission = await checkAllPermissions.isStoragePermission();
    if (permission) {
      setState(() {
        isPermission = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  var data = [
    {
      "id": "1",
      "title": "MicroG-Premium",
      "url": "assets/MicroG-Premium.apk"
    },
    {
      "id": "2",
      "title": "Zing_Apkpure",
      "url": "assets/Zing_Apkpure.apk"
    },
    {
      "id": "3",
      "title": "Vietmap",
      "url": "assets/Vietmap.apk"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isPermission
          ? ListView.builder(
              itemCount: data.length, // Chỉ có 1 file APK
              itemBuilder: (BuildContext context, int index) {
                return  TileList(
                  title: data[index]['title']!,
                  url: data[index]['url']!,
                );
              },
            )
          : TextButton(
              onPressed: () {
                checkPermission();
              },
              child: const Text("Permission issue"),
            ),
    );
  }
}

class TileList extends StatefulWidget {
  const TileList({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);
  final String title;
  final String url;

  @override
  State<TileList> createState() => _TileListState();
}

class _TileListState extends State<TileList> {
  bool fileExists = false;
  late String filePath;
  var getPathFile = DirectoryPath();

  startCopyFromAssets() async {
    try {
      var storePath = await getPathFile.getPath();
      filePath = '$storePath/${widget.title}.apk';

      // Đọc nội dung file APK từ assets
      ByteData data = await rootBundle.load(widget.url);
      List<int> bytes = data.buffer.asUint8List();

      // Ghi nội dung vào file trong thư mục lưu trữ
      await File(filePath).writeAsBytes(bytes);

      setState(() {
        fileExists = true;
      });
    } catch (e) {
      print('Error copying file: $e');
    }
  }

  checkFileExist() async {
    var storePath = await getPathFile.getPath();
    filePath = '$storePath/${widget.title}.apk';
    bool fileExistCheck = await File(filePath).exists();
    setState(() {
      fileExists = fileExistCheck;
    });
  }

  _openFile() async {
    PermissionStatus status = await Permission.storage.status;
    if (status.isDenied) {
      // Yêu cầu quyền nếu chưa được cấp
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      await openFile(filePath);
    }
  }

  @override
  void initState() {
    super.initState();
    checkFileExist(); // Copy file từ assets khi khởi tạo widget
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shadowColor: Colors.grey.shade100,
      child: ListTile(
        title: Text(widget.title),
        leading: IconButton(
          onPressed: () {
            fileExists ? _openFile() : null;
          },
          icon: fileExists
              ? const Icon(
                  Icons.window,
                  color: Colors.green,
                )
              : const Icon(Icons.close),
        ),
        trailing: IconButton(
          onPressed: () {
            //startCopyFromAssets();
            fileExists ? _openFile() : startCopyFromAssets();
          },
          icon: fileExists
              ? const Icon(
                  Icons.save,
                  color: Colors.green,
                )
              : const Icon(Icons.download),
        ),
      ),
    );
  }
}
