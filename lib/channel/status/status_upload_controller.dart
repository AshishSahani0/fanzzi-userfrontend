import 'package:flutter/material.dart';

class StatusUploadController extends ChangeNotifier {
  StatusUploadController._();
  static final StatusUploadController instance =
      StatusUploadController._();

  String? _channelId;
  bool _uploading = false;
  double _progress = 0;
  bool _failed = false;

  String? get channelId => _channelId;
  bool get uploading => _uploading;
  double get progress => _progress;
  bool get failed => _failed;

  bool isUploadingFor(String id) =>
      _uploading && _channelId == id;

  // ================= START =================

  void start(String channelId) {
    if (_uploading && _channelId == channelId) return;

    _channelId = channelId;
    _uploading = true;
    _progress = 0;
    _failed = false;

    notifyListeners();
  }

  // ================= UPDATE =================

  void update(double value) {
    final newValue = value.clamp(0.0, 1.0);

    if (newValue == _progress) return;

    _progress = newValue;
    notifyListeners();
  }

  // ================= SUCCESS =================

  void done() {
    if (!_uploading) return;

    _uploading = false;
    _progress = 1;
    notifyListeners();

    // optional smooth reset after small delay
    Future.delayed(const Duration(milliseconds: 400), () {
      reset();
    });
  }

  // ================= ERROR =================

  void fail() {
    _uploading = false;
    _failed = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () {
      reset();
    });
  }

  // ================= RESET =================

  void reset() {
    _channelId = null;
    _progress = 0;
    _uploading = false;
    _failed = false;
    notifyListeners();
  }
}