import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;

class MapPage extends StatefulWidget {
  final double? targetLat;
  final double? targetLng;
  final String? targetName;

  const MapPage({
    super.key,
    this.targetLat,
    this.targetLng,
    this.targetName,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late final MapController _mapController;
  LatLng? _userPosition;
  LatLng? _targetPosition;
  bool _loading = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _init();
  }

  @override
  void didUpdateWidget(MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Quand une nouvelle activité est sélectionnée depuis l'accueil
    if (widget.targetLat != oldWidget.targetLat ||
        widget.targetLng != oldWidget.targetLng) {
      _applyTarget();
    }
  }

  Future<void> _init() async {
    await _getUserLocation();
    _applyTarget();
    setState(() => _loading = false);
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _userPosition = LatLng(pos.latitude, pos.longitude);
      });
    } catch (_) {
      // Position par défaut : Abidjan centre
      setState(() {
        _userPosition = const LatLng(5.3489, -4.0712);
      });
    }
  }

  void _applyTarget() {
    if (widget.targetLat != null && widget.targetLng != null) {
      setState(() {
        _targetPosition = LatLng(widget.targetLat!, widget.targetLng!);
      });
      // Animer la caméra vers la cible
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _animatedMove(_targetPosition!, 15.0);
        }
      });
    } else if (_userPosition != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _animatedMove(_userPosition!, 14.0);
        }
      });
    }
  }

  void _animatedMove(LatLng dest, double zoom) {
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: dest.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: dest.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: zoom,
    );

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final animation =
        CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    controller.forward();
  }

  void _centerOnUser() {
    if (_userPosition != null) {
      _animatedMove(_userPosition!, 15.0);
    }
  }

  Future<void> _openItinerary() async {
    if (_targetPosition == null) return;
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${_targetPosition!.latitude},${_targetPosition!.longitude}'
      '&travelmode=driving',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;

    final initialCenter = _targetPosition ??
        _userPosition ??
        const LatLng(5.3489, -4.0712);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // ── CARTE ──
            _loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: const Color(0xFFD85A30),
                    ),
                  )
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: initialCenter,
                      initialZoom: 14.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      // Tuiles OpenStreetMap
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.gotime.app',
                        maxZoom: 19,
                      ),

                      // Marqueur position utilisateur
                      if (_userPosition != null)
                        MarkerLayer(markers: [
                          Marker(
                            point: _userPosition!,
                            width: 48,
                            height: 48,
                            child: AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (context, child) => Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 48 * _pulseAnim.value,
                                    height: 48 * _pulseAnim.value,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF6C63FF)
                                          .withOpacity(0.25),
                                    ),
                                  ),
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF6C63FF),
                                      border: Border.all(
                                          color: Colors.white, width: 2.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF6C63FF)
                                              .withOpacity(0.4),
                                          blurRadius: 8,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),

                      // Marqueur activité cible
                      if (_targetPosition != null)
                        MarkerLayer(markers: [
                          Marker(
                            point: _targetPosition!,
                            width: 60,
                            height: 70,
                            alignment: Alignment.topCenter,
                            child: Column(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD85A30),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFD85A30)
                                            .withOpacity(0.5),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.place_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                CustomPaint(
                                  size: const Size(14, 10),
                                  painter: _TrianglePainter(
                                      color: const Color(0xFFD85A30)),
                                ),
                              ],
                            ),
                          ),
                        ]),
                    ],
                  ),

            // ── HEADER ──
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isDark
                          ? Colors.black.withOpacity(0.7)
                          : Colors.white.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withOpacity(0.6)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8)
                        ],
                      ),
                      child: Icon(Icons.map_outlined,
                          color: const Color(0xFFD85A30), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _targetPosition != null
                            ? (widget.targetName ?? 'Activité')
                            : 'Ma position',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── BOUTONS DROITE ──
            Positioned(
              right: 16,
              bottom: _targetPosition != null ? 160 : 100,
              child: Column(
                children: [
                  // Centrer sur moi
                  _MapButton(
                    icon: Icons.my_location_rounded,
                    color: const Color(0xFF6C63FF),
                    onTap: _centerOnUser,
                    tooltip: 'Ma position',
                  ),
                  const SizedBox(height: 10),
                  // Zoom +
                  _MapButton(
                    icon: Icons.add,
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    iconColor: textColor,
                    onTap: () => _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Zoom -
                  _MapButton(
                    icon: Icons.remove,
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    iconColor: textColor,
                    onTap: () => _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    ),
                  ),
                ],
              ),
            ),

            // ── FICHE ACTIVITÉ (bottom sheet fixe) ──
            if (_targetPosition != null)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Indicateur
                      Center(
                        child: Container(
                          width: 36, height: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD85A30).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.place_rounded,
                                color: Color(0xFFD85A30), size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.targetName ?? 'Activité',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${_targetPosition!.latitude.toStringAsFixed(4)}, '
                                  '${_targetPosition!.longitude.toStringAsFixed(4)}',
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Bouton itinéraire
                      GestureDetector(
                        onTap: _openItinerary,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD85A30), Color(0xFFFF8C5A)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD85A30).withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.directions_car_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Lancer l\'itinéraire',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── AUCUNE CIBLE : message centré ──
            if (_targetPosition == null && !_loading)
              Positioned(
                bottom: 30, left: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12)
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('👆', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Appuie sur une activité depuis l\'accueil pour voir sa position ici',
                          style: TextStyle(
                              color: textColor.withOpacity(0.7), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Bouton rond sur la carte ──
class _MapButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? iconColor;
  final VoidCallback onTap;
  final String? tooltip;

  const _MapButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.iconColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Icon(icon,
            color: iconColor ?? Colors.white, size: 20),
      ),
    );
  }
}

// ── Triangle sous le marqueur ──
class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

@override
void paint(Canvas canvas, Size size) {
  final trianglePaint = Paint()..color = color;
  final trianglePath = ui.Path()
    ..moveTo(0, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width / 2, size.height)
    ..close();
  canvas.drawPath(trianglePath, trianglePaint);
}
  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}