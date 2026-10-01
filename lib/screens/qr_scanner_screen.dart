import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with TickerProviderStateMixin {
  final MobileScannerController scannerController =
  MobileScannerController();

  bool isScanned = false;
  bool isFlashOn = false;

  late AnimationController scanAnimationController;
  late AnimationController entranceAnimationController;
  late AnimationController pulseAnimationController;

  late Animation<double> scanLineAnimation;
  late Animation<double> entranceAnimation;
  late Animation<double> pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animated scanner beam.
    scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    scanLineAnimation = CurvedAnimation(
      parent: scanAnimationController,
      curve: Curves.easeInOut,
    );

    // Screen entrance animation.
    entranceAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    entranceAnimation = CurvedAnimation(
      parent: entranceAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Subtle scanner pulse.
    pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    pulseAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    entranceAnimationController.forward();
  }

  @override
  void dispose() {
    scanAnimationController.dispose();
    entranceAnimationController.dispose();
    pulseAnimationController.dispose();
    scannerController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // SCAN HANDLING
  // ------------------------------------------------------------

  void handleScan(String value) {
    if (isScanned) return;

    if (value.isEmpty) return;

    isScanned = true;

    final Uri? uri = Uri.tryParse(value);

    // UPI QR
    if (uri != null &&
        uri.scheme.toLowerCase() == 'upi' &&
        uri.host.toLowerCase() == 'pay') {
      final String? amount = uri.queryParameters['am'];
      final String? merchantName = uri.queryParameters['pn'];
      final String? upiId = uri.queryParameters['pa'];
      final String? currency = uri.queryParameters['cu'];

      Navigator.pop(
        context,
        {
          'type': 'upi',
          'amount': amount,
          'merchantName': merchantName,
          'upiId': upiId,
          'currency': currency,
          'rawValue': value,
        },
      );

      return;
    }

    // Normal barcode
    Navigator.pop(
      context,
      {
        'type': 'barcode',
        'rawValue': value,
      },
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // RupeeLens green accent.
    final Color accent = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ------------------------------------------------------
          // CAMERA
          // ------------------------------------------------------

          MobileScanner(
            controller: scannerController,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final String? value = barcode.rawValue;

                if (value == null || value.isEmpty) {
                  continue;
                }

                debugPrint('BARCODE TYPE: ${barcode.type}');
                debugPrint('BARCODE VALUE: $value');

                handleScan(value);
                break;
              }
            },
          ),

          // ------------------------------------------------------
          // CAMERA DARKENING
          // ------------------------------------------------------

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.78),
                  Colors.black.withValues(alpha: 0.18),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.18),
                  Colors.black.withValues(alpha: 0.88),
                ],
                stops: const [
                  0.0,
                  0.20,
                  0.48,
                  0.72,
                  1.0,
                ],
              ),
            ),
          ),

          // ------------------------------------------------------
          // SUBTLE GREEN AMBIENT GLOW
          // ------------------------------------------------------

          IgnorePointer(
            child: AnimatedBuilder(
              animation: pulseAnimation,
              builder: (context, child) {
                return Center(
                  child: Container(
                    width: 330 * pulseAnimation.value,
                    height: 330 * pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.10),
                          blurRadius: 90,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ------------------------------------------------------
          // TOP HEADER
          // ------------------------------------------------------

          SafeArea(
            child: AnimatedBuilder(
              animation: entranceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    -25 * (1 - entranceAnimation.value),
                  ),
                  child: Opacity(
                    opacity: entranceAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  14,
                  18,
                  0,
                ),
                child: Row(
                  children: [
                    _glassButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),

                    const Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Scan & Track',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Capture your expense instantly',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _glassButton(
                      icon: isFlashOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      active: isFlashOn,
                      activeColor: accent,
                      onTap: () async {
                        await scannerController.toggleTorch();

                        if (!mounted) return;

                        setState(() {
                          isFlashOn = !isFlashOn;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ------------------------------------------------------
          // SCANNER
          // ------------------------------------------------------

          Center(
            child: AnimatedBuilder(
              animation: entranceAnimation,
              builder: (context, child) {
                final double scale =
                    0.88 + (0.12 * entranceAnimation.value);

                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: entranceAnimation.value,
                    child: child,
                  ),
                );
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double scannerSize =
                  constraints.maxWidth < 380 ? 255 : 290;

                  return SizedBox(
                    width: scannerSize,
                    height: scannerSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Outer subtle glow.
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: pulseAnimation,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(34),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.withValues(
                                        alpha:
                                        0.12 * pulseAnimation.value,
                                      ),
                                      blurRadius: 40,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // Soft inner glass background.
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(34),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 2,
                                sigmaY: 2,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(34),
                                  border: Border.all(
                                    color: Colors.white.withValues(
                                      alpha: 0.08,
                                    ),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Scanner corners.
                        _premiumCorner(
                          alignment: Alignment.topLeft,
                          color: accent,
                        ),

                        _premiumCorner(
                          alignment: Alignment.topRight,
                          color: accent,
                          rotation: 1,
                        ),

                        _premiumCorner(
                          alignment: Alignment.bottomRight,
                          color: accent,
                          rotation: 2,
                        ),

                        _premiumCorner(
                          alignment: Alignment.bottomLeft,
                          color: accent,
                          rotation: 3,
                        ),

                        // Animated scanning beam.
                        AnimatedBuilder(
                          animation: scanLineAnimation,
                          builder: (context, child) {
                            final double top =
                                22 +
                                    ((scannerSize - 44) *
                                        scanLineAnimation.value);

                            return Positioned(
                              left: 20,
                              right: 20,
                              top: top,
                              child: Column(
                                children: [
                                  Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          accent.withValues(alpha: 0.3),
                                          accent,
                                          accent.withValues(alpha: 0.3),
                                          Colors.transparent,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accent.withValues(
                                            alpha: 0.75,
                                          ),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Small center scanning indicator.
                        Center(
                          child: AnimatedBuilder(
                            animation: pulseAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 9 * pulseAnimation.value,
                                height: 9 * pulseAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.withValues(
                                        alpha: 0.8,
                                      ),
                                      blurRadius: 15,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // ------------------------------------------------------
          // SCAN LABEL
          // ------------------------------------------------------

          Positioned(
            left: 24,
            right: 24,
            bottom: 195,
            child: AnimatedBuilder(
              animation: entranceAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: entranceAnimation.value,
                  child: child,
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.8),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'READY TO SCAN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Position the QR code or barcode\ninside the frame',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------------------------
          // BOTTOM GLASS PANEL
          // ------------------------------------------------------

          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: SafeArea(
              top: false,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 18,
                    sigmaY: 18,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.48),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.13),
                      ),
                    ),
                    child: Row(
                      children: [
                        // QR icon.
                        _bottomMode(
                          icon: Icons.qr_code_2_rounded,
                          title: 'QR',
                          subtitle: 'UPI',
                          accent: accent,
                        ),

                        Container(
                          height: 38,
                          width: 1,
                          color: Colors.white.withValues(alpha: 0.10),
                        ),

                        // Barcode icon.
                        _bottomMode(
                          icon: Icons.view_week_rounded,
                          title: 'Barcode',
                          subtitle: 'Products',
                          accent: accent,
                        ),

                        const Spacer(),

                        // Camera switch.
                        GestureDetector(
                          onTap: () {
                            scannerController.switchCamera();
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.09),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.flip_camera_android_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // GLASS BUTTON
  // ------------------------------------------------------------

  Widget _glassButton({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
    Color? activeColor,
  }) {
    final Color color = activeColor ?? Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: active
                  ? color.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: active
                    ? color.withValues(alpha: 0.38)
                    : Colors.white.withValues(alpha: 0.13),
              ),
            ),
            child: Icon(
              icon,
              color: active ? color : Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PREMIUM CORNER
  // ------------------------------------------------------------

  Widget _premiumCorner({
    required Alignment alignment,
    required Color color,
    int rotation = 0,
  }) {
    return Align(
      alignment: alignment,
      child: Transform.rotate(
        angle: rotation * 1.5708,
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: color,
                width: 4,
              ),
              left: BorderSide(
                color: color,
                width: 4,
              ),
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM MODE ITEM
  // ------------------------------------------------------------

  Widget _bottomMode({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: accent,
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(width: 15),
      ],
    );
  }
}