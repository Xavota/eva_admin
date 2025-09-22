import 'package:mime/mime.dart';
//import 'package:drop_zone/drop_zone.dart';
//import 'dart:html' as html;
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:super_clipboard/super_clipboard.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

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


/*enum MyFileFormats {
  // Image
  kJpeg,
  kPng,
  kGif,
  kTiff,
  kWebp,
  kSvg,
  kBmp,
  kIco,
  kHeic,
  kHeif,

  // Video
  kMp4,
  kMov,
  kM4v,
  kAvi,
  kMpeg,
  kWebm,
  kOgg,
  kWmv,
  kFlv,
  kMkv,
  kTs,

  // Audio
  kMp3,
  kM4a,
  kOga,
  kAac,
  kWav,
  kOpus,
  kFlac,

  // Document
  kPdf,
  kDoc,
  kDocx,
  kEpub,
  kMd,
  kCsv,
  kXls,
  kXlsx,
  kPpt,
  kPptx,
  kRtf,
  kJson,

  // Archive
  kZip,
  kTar,
  kGzip,
  kBzip2,
  kXz,
  kRar,
  kJar,
  kSevenZip,
  kDmg,
  kIso,
  kDeb,
  kRpm,
  kApk,

  // Executable
  kExe,
  kMsi,
  kDll,

  kPlainTextFile,
  kHtmlFile,

  kWebUnknown,
}

class MyFormat {
  static const List<MyFileFormats> image = [
    MyFileFormats.kJpeg,
    MyFileFormats.kPng,
    MyFileFormats.kGif,
    MyFileFormats.kTiff,
    MyFileFormats.kWebp,
    MyFileFormats.kSvg,
    MyFileFormats.kBmp,
    MyFileFormats.kIco,
    MyFileFormats.kHeic,
    MyFileFormats.kHeif,
  ];
  static const List<MyFileFormats> video = [
    MyFileFormats.kMp4,
    MyFileFormats.kMov,
    MyFileFormats.kM4v,
    MyFileFormats.kAvi,
    MyFileFormats.kMpeg,
    MyFileFormats.kWebm,
    MyFileFormats.kOgg,
    MyFileFormats.kWmv,
    MyFileFormats.kFlv,
    MyFileFormats.kMkv,
    MyFileFormats.kTs,
  ];
  static const List<MyFileFormats> audio = [
    MyFileFormats.kMp3,
    MyFileFormats.kM4a,
    MyFileFormats.kOga,
    MyFileFormats.kAac,
    MyFileFormats.kWav,
    MyFileFormats.kOpus,
    MyFileFormats.kFlac,
  ];
  static const List<MyFileFormats> document = [
    MyFileFormats.kPdf,
    MyFileFormats.kDoc,
    MyFileFormats.kDocx,
    MyFileFormats.kEpub,
    MyFileFormats.kMd,
    MyFileFormats.kCsv,
    MyFileFormats.kXls,
    MyFileFormats.kXlsx,
    MyFileFormats.kPpt,
    MyFileFormats.kPptx,
    MyFileFormats.kRtf,
    MyFileFormats.kJson,
  ];
  static const List<MyFileFormats> archive = [
    MyFileFormats.kZip,
    MyFileFormats.kTar,
    MyFileFormats.kGzip,
    MyFileFormats.kBzip2,
    MyFileFormats.kXz,
    MyFileFormats.kRar,
    MyFileFormats.kJar,
    MyFileFormats.kSevenZip,
    MyFileFormats.kDmg,
    MyFileFormats.kIso,
    MyFileFormats.kDeb,
    MyFileFormats.kRpm,
    MyFileFormats.kApk,
  ];
  static const List<MyFileFormats> executable = [
    MyFileFormats.kExe,
    MyFileFormats.kMsi,
    MyFileFormats.kDll,
  ];
  static const List<MyFileFormats> plainText = [
    MyFileFormats.kPlainTextFile,
    MyFileFormats.kHtmlFile,
  ];
  static const List<MyFileFormats> unknown = [
    MyFileFormats.kWebUnknown,
  ];
}*/

class MyFileFormat {
  const MyFileFormat({required this.format, required this.type, required this.mimeTypes, required this.extensions});
  final SimpleFileFormat format;
  final FileType type;
  final List<String> mimeTypes;
  final List<String> extensions;
}

class MyFormats {
  static List<MyFileFormat> image = [
    jpeg, png, gif, tiff, webp, svg, bmp, ico, heic, heif,
  ];
  static List<MyFileFormat> video = [
    mp4, mov, m4v, avi, mpeg, webm, ogg, wmv, flv, mkv, ts,
  ];
  static List<MyFileFormat> audio = [
    mp3, m4a, oga, aac, wav, opus, flac,
  ];
  static List<MyFileFormat> document = [
    pdf, doc, docx, epub, md, csv, xls, xlsx, ppt, pptx, rtf, json,
  ];
  static List<MyFileFormat> archive = [
    zip, tar, gzip, bzip2, xz, rar, jar, sevenZip, dmg, iso, deb, rpm, apk,
  ];
  static List<MyFileFormat> executable = [
    exe, msi, dll,
  ];
  static List<MyFileFormat> plainText = [
    plainTextFile, htmlFile,
  ];


  // Image
  static MyFileFormat jpeg = MyFileFormat(format: Formats.jpeg, type: FileType.image, mimeTypes: Formats.jpeg.mimeTypes!, extensions: ["jpeg", "jpg"]);
  static MyFileFormat png = MyFileFormat(format: Formats.png, type: FileType.image, mimeTypes: Formats.png.mimeTypes!, extensions: ["png"]);
  static MyFileFormat gif = MyFileFormat(format: Formats.gif, type: FileType.image, mimeTypes: Formats.gif.mimeTypes!, extensions: ["gif"]);
  static MyFileFormat tiff = MyFileFormat(format: Formats.tiff, type: FileType.image, mimeTypes: ['image/tiff'], extensions: ["tif", "tiff"]);
  static MyFileFormat webp = MyFileFormat(format: Formats.webp, type: FileType.image, mimeTypes: Formats.webp.mimeTypes!, extensions: ["webp"]);
  static MyFileFormat svg = MyFileFormat(format: Formats.svg, type: FileType.image, mimeTypes: Formats.svg.mimeTypes!, extensions: ["svg"]);
  static MyFileFormat bmp = MyFileFormat(format: Formats.bmp, type: FileType.image, mimeTypes: Formats.bmp.mimeTypes!, extensions: ["bmp"]);
  static MyFileFormat ico = MyFileFormat(format: Formats.ico, type: FileType.image, mimeTypes: Formats.ico.mimeTypes!, extensions: ["ico"]);
  static MyFileFormat heic = MyFileFormat(format: Formats.heic, type: FileType.image, mimeTypes: Formats.heic.mimeTypes!, extensions: ["heic"]);
  static MyFileFormat heif = MyFileFormat(format: Formats.heif, type: FileType.image, mimeTypes: Formats.heif.mimeTypes!, extensions: ["heif"]);

  // Video
  static MyFileFormat mp4 = MyFileFormat(format: Formats.mp4, type: FileType.video, mimeTypes: Formats.mp4.mimeTypes!, extensions: ["mp4"]);
  static MyFileFormat mov = MyFileFormat(format: Formats.mov, type: FileType.video, mimeTypes: Formats.mov.mimeTypes!, extensions: ["mov"]);
  static MyFileFormat m4v = MyFileFormat(format: Formats.m4v, type: FileType.video, mimeTypes: Formats.m4v.mimeTypes!, extensions: ["m4v"]);
  static MyFileFormat avi = MyFileFormat(format: Formats.avi, type: FileType.video, mimeTypes: Formats.avi.mimeTypes!, extensions: ["avi"]);
  static MyFileFormat mpeg = MyFileFormat(format: Formats.mpeg, type: FileType.video, mimeTypes: Formats.mpeg.mimeTypes!, extensions: ["mpg", "mpeg"]);
  static MyFileFormat webm = MyFileFormat(format: Formats.webm, type: FileType.video, mimeTypes: Formats.webm.mimeTypes!, extensions: ["webm"]);
  static MyFileFormat ogg = MyFileFormat(format: Formats.ogg, type: FileType.video, mimeTypes: Formats.ogg.mimeTypes!, extensions: ["ogg", "ogv"]);
  static MyFileFormat wmv = MyFileFormat(format: Formats.wmv, type: FileType.video, mimeTypes: Formats.wmv.mimeTypes!, extensions: ["wmv"]);
  static MyFileFormat flv = MyFileFormat(format: Formats.flv, type: FileType.video, mimeTypes: Formats.flv.mimeTypes!, extensions: ["flv"]);
  static MyFileFormat mkv = MyFileFormat(format: Formats.mkv, type: FileType.video, mimeTypes: Formats.mkv.mimeTypes!, extensions: ["mkv"]);
  static MyFileFormat ts = MyFileFormat(format: Formats.ts, type: FileType.video, mimeTypes: Formats.ts.mimeTypes!, extensions: ["ts"]);

  // Audio
  static MyFileFormat mp3 = MyFileFormat(format: Formats.mp3, type: FileType.audio, mimeTypes: Formats.mp3.mimeTypes!, extensions: ["mp3"]);
  static MyFileFormat m4a = MyFileFormat(format: Formats.m4a, type: FileType.audio, mimeTypes: Formats.m4a.mimeTypes!, extensions: ["m4a"]);
  static MyFileFormat oga = MyFileFormat(format: Formats.oga, type: FileType.audio, mimeTypes: Formats.oga.mimeTypes!, extensions: ["oga"]);
  static MyFileFormat aac = MyFileFormat(format: Formats.aac, type: FileType.audio, mimeTypes: Formats.aac.mimeTypes!, extensions: ["aac"]);
  static MyFileFormat wav = MyFileFormat(format: Formats.wav, type: FileType.audio, mimeTypes: Formats.wav.mimeTypes!, extensions: ["wav"]);
  static MyFileFormat opus = MyFileFormat(format: Formats.opus, type: FileType.audio, mimeTypes: Formats.opus.mimeTypes!, extensions: ["opus"]);
  static MyFileFormat flac = MyFileFormat(format: Formats.flac, type: FileType.audio, mimeTypes: Formats.flac.mimeTypes!, extensions: ["flac"]);

  // Document
  static MyFileFormat pdf = MyFileFormat(format: Formats.pdf, type: FileType.custom, mimeTypes: Formats.pdf.mimeTypes!, extensions: ["pdf"]);
  static MyFileFormat doc = MyFileFormat(format: Formats.doc, type: FileType.custom, mimeTypes: Formats.doc.mimeTypes!, extensions: ["doc"]);
  static MyFileFormat docx = MyFileFormat(format: Formats.docx, type: FileType.custom, mimeTypes: Formats.docx.mimeTypes!, extensions: ["docx"]);
  static MyFileFormat epub = MyFileFormat(format: Formats.epub, type: FileType.custom, mimeTypes: Formats.epub.mimeTypes!, extensions: ["epub"]);
  static MyFileFormat md = MyFileFormat(format: Formats.md, type: FileType.custom, mimeTypes: Formats.md.mimeTypes!, extensions: ["md"]);
  static MyFileFormat csv = MyFileFormat(format: Formats.csv, type: FileType.custom, mimeTypes: Formats.csv.mimeTypes!, extensions: ["csv"]);
  static MyFileFormat xls = MyFileFormat(format: Formats.xls, type: FileType.custom, mimeTypes: Formats.xls.mimeTypes!, extensions: ["xls"]);
  static MyFileFormat xlsx = MyFileFormat(format: Formats.xlsx, type: FileType.custom, mimeTypes: Formats.xlsx.mimeTypes!, extensions: ["xlsx"]);
  static MyFileFormat ppt = MyFileFormat(format: Formats.ppt, type: FileType.custom, mimeTypes: Formats.ppt.mimeTypes!, extensions: ["ppt"]);
  static MyFileFormat pptx = MyFileFormat(format: Formats.pptx, type: FileType.custom, mimeTypes: Formats.pptx.mimeTypes!, extensions: ["pptx"]);
  static MyFileFormat rtf = MyFileFormat(format: Formats.rtf, type: FileType.custom, mimeTypes: Formats.rtf.mimeTypes!, extensions: ["rtf"]);
  static MyFileFormat json = MyFileFormat(format: Formats.json, type: FileType.custom, mimeTypes: Formats.json.mimeTypes!, extensions: ["json"]);

  // Archive
  static MyFileFormat zip = MyFileFormat(format: Formats.zip, type: FileType.custom, mimeTypes: Formats.zip.mimeTypes!, extensions: ["zip"]);
  static MyFileFormat tar = MyFileFormat(format: Formats.tar, type: FileType.custom, mimeTypes: Formats.tar.mimeTypes!, extensions: ["tar"]);
  static MyFileFormat gzip = MyFileFormat(format: Formats.gzip, type: FileType.custom, mimeTypes: Formats.gzip.mimeTypes!, extensions: ["gz"]);
  static MyFileFormat bzip2 = MyFileFormat(format: Formats.bzip2, type: FileType.custom, mimeTypes: Formats.bzip2.mimeTypes!, extensions: ["bz2"]);
  static MyFileFormat xz = MyFileFormat(format: Formats.xz, type: FileType.custom, mimeTypes: Formats.xz.mimeTypes!, extensions: ["xz"]);
  static MyFileFormat rar = MyFileFormat(format: Formats.rar, type: FileType.custom, mimeTypes: Formats.rar.mimeTypes!, extensions: ["rar"]);
  static MyFileFormat jar = MyFileFormat(format: Formats.jar, type: FileType.custom, mimeTypes: Formats.jar.mimeTypes!, extensions: ["jar"]);
  static MyFileFormat sevenZip = MyFileFormat(format: Formats.sevenZip, type: FileType.custom, mimeTypes: Formats.sevenZip.mimeTypes!, extensions: ["7z"]);
  static MyFileFormat dmg = MyFileFormat(format: Formats.dmg, type: FileType.custom, mimeTypes: Formats.dmg.mimeTypes!, extensions: ["dmg"]);
  static MyFileFormat iso = MyFileFormat(format: Formats.iso, type: FileType.custom, mimeTypes: Formats.iso.mimeTypes!, extensions: ["iso"]);
  static MyFileFormat deb = MyFileFormat(format: Formats.deb, type: FileType.custom, mimeTypes: Formats.deb.mimeTypes!, extensions: ["deb"]);
  static MyFileFormat rpm = MyFileFormat(format: Formats.rpm, type: FileType.custom, mimeTypes: Formats.rpm.mimeTypes!, extensions: ["rpm"]);
  static MyFileFormat apk = MyFileFormat(format: Formats.apk, type: FileType.custom, mimeTypes: Formats.apk.mimeTypes!, extensions: ["apk"]);

  // Executable
  static MyFileFormat exe = MyFileFormat(format: Formats.exe, type: FileType.custom, mimeTypes: Formats.exe.mimeTypes!, extensions: ["exe"]);
  static MyFileFormat msi = MyFileFormat(format: Formats.msi, type: FileType.custom, mimeTypes: Formats.msi.mimeTypes!, extensions: ["msi"]);
  static MyFileFormat dll = MyFileFormat(format: Formats.dll, type: FileType.custom, mimeTypes: Formats.dll.mimeTypes!, extensions: ["dll"]);

  // Plain Text
  static MyFileFormat plainTextFile = MyFileFormat(format: Formats.plainTextFile, type: FileType.custom, mimeTypes: Formats.plainTextFile.mimeTypes!, extensions: ["txt"]);
  static MyFileFormat htmlFile = MyFileFormat(format: Formats.htmlFile, type: FileType.custom, mimeTypes: Formats.htmlFile.mimeTypes!, extensions: ["html", "htm"]);
}


class FileUploadWidget extends StatefulWidget {
  const FileUploadWidget({
    super.key,
    this.instanceIndex,
    this.height = 200.0,
    this.hintText = "Drag and drop your files here",
    this.maxFileSize = const FileSize(megabytes: 10),
    this.icon = LucideIcons.folder_up,
    this.iconSize = 48.0,
    this.iconColor = Colors.redAccent,
    this.uploadButtonText = "Browse Files",
    this.allowMultiple = false,
    this.allowedFormats,
    this.fileNameController,
    this.onFileSelected,
    this.onError,
    this.getFileSelectedMessage,
  });

  final int? instanceIndex;

  final double height;

  final String hintText;
  final FileSize maxFileSize;

  final IconData icon;
  final double iconSize;
  final Color iconColor;

  final String uploadButtonText;

  final bool allowMultiple;

  final List<MyFileFormat>? allowedFormats;

  final TextEditingController? fileNameController;

  final void Function(String name, Uint8List data, String mimeType)? onFileSelected;
  final void Function(String error)? onError;
  final String? Function(String fileName)? getFileSelectedMessage;

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  //late DropzoneViewController _controller;
  String _dropZoneMessage = "";
  //bool _highlighted = false;

  static final Map<int, List<int>> _instances = {};
  int? widgetInstance;

  late final TextEditingController _fileNameController;

  void _fileNameChanged() {
    if (_fileNameController.text.isEmpty) {
      _dropZoneMessage = widget.hintText;
    }
    else {
      _dropZoneMessage = widget.getFileSelectedMessage?.call(_fileNameController.text)??
          'File "${widget.hintText}" selected';
    }

    setState(() {});
  }

  List<String>? _getAllowedExtensions() {
    return widget.allowedFormats?.fold<List<String>>([], (i, e) => i..addAll(e.extensions));
  }

  List<String>? _getAllowedMimeTypes() {
    return widget.allowedFormats?.fold<List<String>>([], (i, e) => i..addAll(e.mimeTypes));
  }

  List<DataFormat> _getFormats() {
    return widget.allowedFormats?.fold<List<DataFormat>>([], (i, e) => i..add(e.format))?? Formats.standardFormats;
  }

  FileType _getFileType() {
    return widget.allowedFormats?.fold<FileType?>(null, (i, e) => i == null ? e.type : (i == e.type ? i : FileType.custom))?? FileType.any;
  }

  @override
  void initState() {
    super.initState();

    _fileNameController = widget.fileNameController?? TextEditingController();

    if (widget.instanceIndex != null) {
      if (!_instances.containsKey(widget.instanceIndex!)) {
        _instances[widget.instanceIndex!] = [];
      }
      widgetInstance = _instances[widget.instanceIndex!]!.length;
      _instances[widget.instanceIndex!]!.add(widgetInstance!);
      Debug.log("FILE SELECTOR INIT STATE [${widget.instanceIndex}][$widgetInstance]", overrideColor: Colors.deepPurple);
    }
    _dropZoneMessage = widget.hintText;

    _fileNameController.addListener(_fileNameChanged);
  }

  void _handleFile(String name, Uint8List data, String mime) {
    final exts = _getAllowedExtensions();
    if (exts != null && !exts.any((e) => name.toLowerCase().endsWith(".${e.toLowerCase()}"))) {
      widget.onError?.call('type');
      return;
    }
    if (data.lengthInBytes > widget.maxFileSize.getBytes()) {
      widget.onError?.call('size');
      return;
    }
    widget.onFileSelected?.call(name, data, mime);
    _fileNameController.text = name;
    //setState(() => _dropZoneMessage = 'File "$name" selected');
  }

  void _pickFile() async {
    final type = _getFileType();
    final exts = type == FileType.custom ? _getAllowedExtensions() : null;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: _getFileType(),
      allowedExtensions: exts,
      withData: true,
      allowMultiple: widget.allowMultiple,
    );
    if (result != null && result.files.isNotEmpty) {
      for (final file in result.files) {
        final name = file.name;
        final data = file.bytes!;

        if (data.length > widget.maxFileSize.getBytes()) {
          widget.onError?.call('size');
          return;
        }

        final guessedMime = lookupMimeType(name, headerBytes: data);
        final mimes = _getAllowedMimeTypes();
        if (guessedMime == null || (mimes != null && !mimes.any((e) => guessedMime == e))) {
          widget.onError?.call('type');
          return;
        }

        _handleFile(name, data, guessedMime);
      }
    }
  }

  @override
  void dispose() {
    if (widget.instanceIndex != null &&
        _instances.containsKey(widget.instanceIndex!)) {
      if (_instances[widget.instanceIndex!]!.contains(widgetInstance)) {
        _instances[widget.instanceIndex!]!.remove(widgetInstance);
      }
      if (_instances[widget.instanceIndex!]!.isEmpty) {
        _instances.remove(widget.instanceIndex!);
      }
    }
    _fileNameController.removeListener(_fileNameChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formats = widget.allowedFormats == null ? Formats.standardFormats : _getFormats();

    return Stack(
      children: [
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
          height: widget.height,
        ),
        if (kIsWeb)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: widget.height,
                  child: DropRegion(
                    // Accepts common formats; works on Web too.
                    formats: formats, // includes file drops
                    hitTestBehavior: HitTestBehavior.opaque,
                    renderObjectType: RenderObjectType.box,
                    onDropOver: (event) {
                      // Indicate we accept copy operations.
                      return event.session.allowedOperations.contains(DropOperation.copy)
                          ? DropOperation.copy
                          : DropOperation.none;
                    },
                    onDropEnter: (_) {
                      Debug.log("DropEnter");
                    },
                    onPerformDrop: (event) async {
                      // On Web, files are only readable during onPerformDrop.
                      // Handle each dropped item (stop early if !allowMultiple).
                      final items = event.session.items;
                      for (final item in items) {
                        final reader = item.dataReader;
                        if (reader == null) continue;

                        bool handled = false;
                        for (final f in formats) {
                          if (!reader.canProvide(f)) continue;

                          reader.getFile(f as SimpleFileFormat, (file) async {
                            final name = file.fileName ?? 'file';
                            final mime = f.mimeTypes;
                            final mimes = _getAllowedMimeTypes();

                            // Enforce allowed types
                            if (mime == null || (mimes != null && !mime.any((e) => mimes.contains(e)))) {
                              widget.onError?.call('type');
                              return;
                            }

                            // You can either stream to your server OR read fully into memory:
                            //final stream = file.getStream(); // send chunks to server if you prefer
                            final data = await file.readAll(); // Uint8List

                            if (data.lengthInBytes > widget.maxFileSize.getBytes()) {
                              widget.onError?.call('size');
                              return;
                            }

                            _handleFile(name, data, mime[0]);
                          }, onError: (_) => widget.onError?.call('read'));

                          handled = true;
                          break;
                        }

                        if (!handled) {
                          widget.onError?.call('unsupported');
                        }

                        if (!widget.allowMultiple) break;
                      }
                    },
                    child: SizedBox.expand(), // your visual drop target
                  ),
                  /*DropZone(
                    onDrop: (files) async {
                      if (files == null) return;
                      if (widget.instanceIndex == null ||
                          _instances.keys.last != widget.instanceIndex!) {
                        return;
                      }

                      //Debug.log("Files count: ${files.length}", overrideColor: Colors.green);

                      for (final file in files) {
                        //final name = await _controller.getFilename(file);
                        final name = file.name;
                        //final mime = await _controller.getFileMIME(ev);
                        final mime = file.type;
                        //final size = await _controller.getFileSize(ev);
                        final size = file.size;

                        if (widget.allowedTypes != null && !widget.allowedTypes!.any((e) => mime == e)) {
                          widget.onError?.call('type');
                          continue;
                        }
                        if (size > widget.maxFileSize.getBytes()) {
                          widget.onError?.call('size');
                          continue;
                        }

                        //final data = await _controller.getFileData(ev);

                        final reader = html.FileReader();
                        reader.readAsArrayBuffer(file);
                        reader.onLoadEnd.listen((event) {
                          final data = reader.result as Uint8List;

                          // Now you have name, mime, size, and data
                          //Debug.log('Name: $name', overrideColor: Colors.white);
                          //Debug.log('MIME type: $mime', overrideColor: Colors.white);
                          //Debug.log('Size: $size bytes', overrideColor: Colors.white);
                          //Debug.log('Data length: ${data.lengthInBytes} bytes', overrideColor: Colors.white);

                          _handleFile(name, data, mime);
                        });

                        if (!widget.allowMultiple) break;
                      }
                    },
                    child: SizedBox.expand(),
                  ),*/
                ),
              ),
            ],
          ),
        SizedBox(
          height: widget.height,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: widget.iconSize, color: widget.iconColor),
                  const SizedBox(height: 10),
                  Text(_dropZoneMessage, textAlign: TextAlign.center,),
                  const SizedBox(height: 5),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.folder_open),
                    label: Text(widget.uploadButtonText),
                    onPressed: _pickFile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
