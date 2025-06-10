import 'package:mime/mime.dart';
import 'package:drop_zone/drop_zone.dart';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

//import 'package:flutter_dropzone/flutter_dropzone.dart';

import 'package:file_picker/file_picker.dart';

import 'package:blix_essentials/blix_essentials.dart';

const int _kilo = 1024;
const int _mega = _kilo * 1024;
const int _giga = _mega * 1024;
const int _tera = _giga * 1024;

class FileSize {
  const FileSize({
    int bytes = 0,
    int kilobytes = 0,
    int megabytes = 0,
    int gigabytes = 0,
    int terabytes = 0,
  }) :  bytes     = (bytes % _kilo),
        kilobytes = ((bytes ~/ _kilo) % _kilo) + (kilobytes % _kilo),
        megabytes = ((bytes ~/ _mega) % _kilo) + ((kilobytes ~/ _kilo) % _kilo) + (megabytes % _kilo),
        gigabytes = ((bytes ~/ _giga) % _kilo) + ((kilobytes ~/ _mega) % _kilo) + ((megabytes ~/ _kilo) % _kilo) + (gigabytes % _kilo),
        terabytes = ((bytes ~/ _tera) % _kilo) + ((kilobytes ~/ _giga) % _kilo) + ((megabytes ~/ _mega) % _kilo) + ((gigabytes ~/ _kilo) % _kilo) + (terabytes % _kilo);

  final int bytes;
  final int kilobytes;
  final int megabytes;
  final int gigabytes;
  final int terabytes;

  int getBytes() {
    return bytes + kilobytes * _kilo + megabytes * _mega + gigabytes * _giga + terabytes * _tera;
  }
}

class FileUploadWidget extends StatefulWidget {
  const FileUploadWidget({
    super.key,
    this.hintText = "Drag and drop your PDF file here",
    this.maxFileSize = const FileSize(megabytes: 10),
    this.uploadButtonText = "Browse PDF File",
    required this.onFileSelected,
    this.onError,
  });

  final String hintText;
  final FileSize maxFileSize;

  final String uploadButtonText;

  final void Function(String name, Uint8List data, String mimeType) onFileSelected;
  final void Function(String error)? onError;

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  //late DropzoneViewController _controller;
  String _dropZoneMessage = "";
  //bool _highlighted = false;

  @override
  void initState() {
    super.initState();
    _dropZoneMessage = widget.hintText;
  }

  void _handleFile(String name, Uint8List data, String mime) {
    if (!name.toLowerCase().endsWith('.pdf')) {
      widget.onError?.call('Only PDF files are allowed.');
      return;
    }
    if (data.lengthInBytes > widget.maxFileSize.getBytes()) {
      widget.onError?.call('File exceeds 10MB limit.');
      return;
    }
    widget.onFileSelected(name, data, mime);
    setState(() => _dropZoneMessage = 'File "$name" selected');
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final name = file.name;
      final data = file.bytes!;

      if (data.length > widget.maxFileSize.getBytes()) {
        widget.onError?.call('size');
        return;
      }

      final guessedMime = lookupMimeType(name, headerBytes: data);
      if (guessedMime == null || guessedMime != 'application/pdf') {
        widget.onError?.call('type');
        return;
      }

      _handleFile(name, data, guessedMime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (kIsWeb)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 200.0,
                  child: DropZone(
                    onDrop: (files) async {
                      if (files == null) return;

                      for (final file in files) {
                        //final name = await _controller.getFilename(file);
                        final name = file.name;
                        //final mime = await _controller.getFileMIME(ev);
                        final mime = file.type;
                        //final size = await _controller.getFileSize(ev);
                        final size = file.size;

                        if (mime != 'application/pdf') {
                          widget.onError?.call('type');
                          return;
                        }
                        if (size > widget.maxFileSize.getBytes()) {
                          widget.onError?.call('size');
                          return;
                        }

                        //final data = await _controller.getFileData(ev);

                        final reader = html.FileReader();
                        reader.readAsArrayBuffer(file);
                        reader.onLoadEnd.listen((event) {
                          final data = reader.result as Uint8List;

                          // Now you have name, mime, size, and data
                          Debug.log('Name: $name', overrideColor: Colors.white);
                          Debug.log('MIME type: $mime', overrideColor: Colors.white);
                          Debug.log('Size: $size bytes', overrideColor: Colors.white);
                          Debug.log('Data length: ${data.lengthInBytes} bytes', overrideColor: Colors.white);

                          _handleFile(name, data, mime);
                        });
                      }
                    },
                    child: SizedBox.expand(),
                  ),
                ),
              ),
            ],
          ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              //color: _highlighted ? Colors.blueAccent : Colors.grey,
              color: Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf, size: 48, color: Colors.redAccent),
              const SizedBox(height: 10),
              Text(_dropZoneMessage),
              const SizedBox(height: 5),
              ElevatedButton.icon(
                icon: const Icon(Icons.folder_open),
                label: Text(widget.uploadButtonText),
                onPressed: _pickFile,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
