import 'package:material_ui/material_ui.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with SingleTickerProviderStateMixin {
  final Geocoding geocoding = Geocoding();
  double? latitude;
  double? longitude;

  String? street;
  String? city;
  String? stateName;
  String? country;
  String? postalCode;

  bool isLoading = false;
  String message = 'Press the button to get your precise GPS location';

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> getLocation() async {
    setState(() {
      isLoading = true;
      message = '';
    });

    try {
      // 1. Check whether GPS is enabled.
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Please enable GPS on your phone.');
      }

      // 2. Check location permission.
      LocationPermission permission = await Geolocator.checkPermission();

      // 3. Request permission if denied.
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        throw Exception(
          'Location permission permanently denied. Enable it in app settings.',
        );
      }

      // 4. Get current GPS position.
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      List<Placemark> placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw Exception('Address not found.');
      }

      final place = placemarks.first;

      // 6. Update screen.
      if (!mounted) return;

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;

        street = place.street;
        city = place.locality;
        stateName = place.administrativeArea;
        country = place.country;
        postalCode = place.postalCode;

        message = 'Location received successfully!';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        message = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = latitude != null && longitude != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GPS Location & Address',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero Icon Card
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 56,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Find My Location',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Retrieve real-time GPS coordinates and localized address information instantly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Action Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : getLocation,
                        icon: isLoading
                            ? const SizedBox.shrink()
                            : const Icon(Icons.my_location_rounded, size: 20),
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        label: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Get My Location',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Status Message feedback banner
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(message),
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: message.contains('successfully')
                              ? Colors.green.shade50
                              : message.contains('Press') || message.isEmpty
                                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                                  : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: message.contains('successfully')
                                ? Colors.green.shade200
                                : message.contains('Press') || message.isEmpty
                                    ? theme.dividerColor.withValues(alpha: 0.15)
                                    : Colors.red.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              message.contains('successfully')
                                  ? Icons.check_circle_outline_rounded
                                  : message.contains('Press')
                                      ? Icons.info_outline_rounded
                                      : Icons.error_outline_rounded,
                              color: message.contains('successfully')
                                  ? Colors.green
                                  : message.contains('Press')
                                      ? theme.colorScheme.primary
                                      : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                message,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: message.contains('successfully')
                                      ? Colors.green.shade800
                                      : message.contains('Press')
                                          ? theme.textTheme.bodyMedium?.color
                                          : Colors.red.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (hasData) ...[
                      const SizedBox(height: 32),

                      // Coordinates Section
                      buildSectionTitle(context, 'GPS Coordinates', Icons.explore_rounded),
                      const SizedBox(height: 8),
                      buildInfoTile(context, Icons.north_east_rounded, 'Latitude', latitude.toString()),
                      const SizedBox(height: 8),
                      buildInfoTile(context, Icons.east_rounded, 'Longitude', longitude.toString()),

                      const SizedBox(height: 24),

                      // Address Section
                      buildSectionTitle(context, 'Postal Address', Icons.home_rounded),
                      const SizedBox(height: 8),
                      buildInfoTile(context, Icons.signpost_rounded, 'Street', street),
                      const SizedBox(height: 8),
                      buildInfoTile(context, Icons.location_city_rounded, 'City', city),
                      const SizedBox(height: 8),
                      buildInfoTile(context, Icons.map_rounded, 'State', stateName),
                      const SizedBox(height: 8),
                      buildInfoTile(context, Icons.public_rounded, 'Country', country),
                      const SizedBox(height: 8),
                      buildInfoTile(context, Icons.markunread_mailbox_rounded, 'Postal Code', postalCode),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget buildInfoTile(
    BuildContext context,
    IconData icon,
    String title,
    String? value,
  ) {
    final theme = Theme.of(context);
    final isEmpty = value == null || value.isEmpty;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            isEmpty ? 'Not available' : value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isEmpty ? Colors.grey : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }
}