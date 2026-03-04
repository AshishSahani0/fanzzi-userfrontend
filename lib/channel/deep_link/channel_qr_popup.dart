import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ChannelQrPopup {
  static void open(BuildContext context, String link) {
    final qrKey = GlobalKey(); // ✅ Needed for image export

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Title
                const Text(
                  "Channel QR Code",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ QR Code (Exportable)
                RepaintBoundary(
                  key: qrKey,
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: QrImageView(
                      data: link,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ✅ Invite Link Display
                Text(
                  link,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),

                const SizedBox(height: 20),

                // ✅ Buttons Row
                Row(
                  children: [
                    // ✅ Copy Button
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.copy),
                        label: const Text("Copy"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: link));

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Invite link copied ✅"),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ✅ Share Button
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text("Share"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context); 
                          Share.share("Join my channel: $link");
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ✅ Download QR Button (New)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text("Save to Gallery"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await _downloadQr(qrKey, context);
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // ✅ Close
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Download QR Image Function
 
  static Future<void> _downloadQr(
  GlobalKey key,
  BuildContext context,
) async {
  try {
    // ✅ Request Storage Permission
    if (await Permission.storage.request().isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission denied ❌")),
      );
      return;
    }

    // ✅ Capture QR Widget
    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final ui.Image image = await boundary.toImage(pixelRatio: 3);

    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    // ✅ Save to Downloads Folder (Android)
    final Directory downloadsDir =
        Directory("/storage/emulated/0/Download");

    final filePath =
        "${downloadsDir.path}/channel_qr_${DateTime.now().millisecondsSinceEpoch}.png";

    final file = File(filePath);

    await file.writeAsBytes(pngBytes);

    // ✅ Success Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ QR saved to Downloads\n$filePath"),
        duration: const Duration(seconds: 3),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Download failed ❌ $e")),
    );
  }
}


static Future<void> _shareQrAndLink(
  GlobalKey key,
  String link,
) async {
  try {
    // ✅ Capture QR Widget as Image
    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final ui.Image image = await boundary.toImage(pixelRatio: 3);

    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    final pngBytes = byteData!.buffer.asUint8List();

    // ✅ Save temporarily
    final tempDir = await getTemporaryDirectory();

    final file = File("${tempDir.path}/channel_qr.png");

    await file.writeAsBytes(pngBytes);

    // ✅ Share QR Image + Link Together
    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Join my channel using this link:\n$link",
    );
  } catch (e) {
    print("Share failed: $e");
  }
}


}
