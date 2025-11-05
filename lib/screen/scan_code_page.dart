import 'package:flutter/material.dart';
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({
    super.key,
    required this.allowDecimal,
    required this.minDigits,
  });

  final bool allowDecimal;
  final int minDigits;

  @override
  State<StatefulWidget> createState() => ScanCodePageState();
}

class ScanCodePageState extends State<ScanCodePage> {
  bool _torch = false;

  // Stabilizzazione
  String? _stable;
  int _hits = 0;
  static const int _needSameFrames = 1;

  void _onText(String raw) {
    print("chiamata _onText");

    var code = _extractNumeric(
      raw,
      allowDecimal: widget.allowDecimal,
      minDigits: widget.minDigits,
    );
    print("code: $code");

    if (code == null) {
      _stable = null;
      _hits = 0;
      return;
    }

    if (code == _stable) {
      _hits++;
    } else {
      _stable = code;
      _hits = 1;
    }

    print("_hits $_hits mounted $mounted");

    if (_hits >= _needSameFrames && mounted) {
      print("torno indietro");
      Future.delayed(Duration.zero, () {
        Navigator.pop(context, code);
      });
    }
  }

  /// Estrae la “migliore” parte numerica dal testo OCR.
  /// - OTP spezzati (es. "1 2 3 4 5 6"): prende e unisce le cifre
  /// - Decimali/euro: se allowDecimal=true, normalizza in formato "1234.50"
  /// - Altrimenti sceglie la sequenza di cifre più lunga (>= minDigits)
  String? _extractNumeric(
    String raw, {
    required bool allowDecimal,
    required int minDigits,
  }) {
    final text = raw.replaceAll('\n', ' ');

    // 1) OTP con separatori (spazi, trattini, punti sottili)
    final otpMatch = RegExp(r'(?:\d[ \t\-\.\u00A0]?){5,}\d').firstMatch(text);
    if (otpMatch != null) {
      final digits = otpMatch.group(0)!.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= minDigits) return digits;
    }

    // 3) Sequenze di sole cifre: prendi la più lunga (>= minDigits)
    final ints =
        RegExp(r'\d+')
            .allMatches(text)
            .map((m) => m.group(0)!)
            .where((s) => s.length >= minDigits)
            .toList();
    if (ints.isEmpty) return null;
    ints.sort((a, b) => b.length.compareTo(a.length));
    return ints.first;
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan di lettura codice'),
        actions: [
          IconButton(
            icon: Icon(_torch ? Icons.flash_on : Icons.flash_off),
            onPressed: () => setState(() => _torch = !_torch),
          ),
        ],
      ),
      body: ScalableOCR(
        torchOn: _torch,
        cameraSelection: 0,
        lockCamera: true,
        paintboxCustom:
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4.0
              ..color = const Color.fromARGB(153, 102, 160, 241),
        boxLeftOff: 4,
        boxBottomOff: 2.7,
        boxRightOff: 4,
        boxTopOff: 2.7,
        boxHeight: h / 2,
        getRawData: (_) {},
        getScannedText: _onText,
      ),
    );
  }
}
