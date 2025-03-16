import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/map/view/tracking_map.dart';
import 'package:socieaty/features/map/view/tracking_map_simulation.dart';
import 'package:socieaty/env.dart';

class MapTestScreen extends StatelessWidget {
  const MapTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Map Route Testing'),
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Route Tracking Test',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppPallete.primaryColor,
                      ),
                ),
              ),
              const Text(
                'Test route tracking functionality with simulation and pre-defined locations.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Interactive simulation banner
              _buildSimulationCard(context),
              const SizedBox(height: 16),

              // Main content sections in a card-based layout
              _buildSectionCard(
                'Features',
                Column(
                  children: [
                    _buildFeatureBox([
                      'Auto re-routing when 20+ meters off-route',
                      'Route progress tracking with completed segments',
                      'API call tracking with performance metrics',
                      'Interactive simulation with deviation control',
                    ]),
                    const SizedBox(height: 12),
                    _buildApiInfoSection(context),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildSectionCard(
                'Test Routes',
                Column(
                  children: [
                    _buildTestButton(
                      context,
                      'Jakarta Route',
                      'Central Jakarta area (500m distance)',
                      const LatLng(-6.180110, 106.863036),
                      const LatLng(-6.175110, 106.865036),
                      'Test Restaurant Jakarta',
                      'Jl. Test Restaurant, Jakarta Pusat',
                    ),
                    const SizedBox(height: 12),
                    _buildTestButton(
                      context,
                      'Bandung Route',
                      'City center area (1km distance)',
                      const LatLng(-6.914744, 107.609810),
                      const LatLng(-6.905744, 107.613810),
                      'Bandung Restaurant',
                      'Jl. Test Restaurant, Bandung',
                    ),
                    const SizedBox(height: 12),
                    _buildTestButton(
                      context,
                      'Surabaya Route',
                      'City center area (800m distance)',
                      const LatLng(-7.257472, 112.745028),
                      const LatLng(-7.262472, 112.750028),
                      'Surabaya Restaurant',
                      'Jl. Test Restaurant, Surabaya',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildSectionCard(
                'API Information',
                Column(
                  children: [
                    _buildInfoBox('For the route tracking to work properly:', [
                      'A valid Google Maps API key with billing enabled',
                      'Directions API must be enabled in your Google Cloud Console',
                      'API key must be configured in env.dart file',
                      'Check console logs for detailed error messages',
                    ]),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'API Key: ${Env.googleApiKey.isNotEmpty ? "${Env.googleApiKey.substring(0, 4)}...${Env.googleApiKey.substring(Env.googleApiKey.length - 4)}" : "Not found"}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Card layout for each main section
  Widget _buildSectionCard(String title, Widget content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(title),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppPallete.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSimulationCard(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _launchSimulation(context),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Interactive Simulation',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Test re-routing, progress tracking, and monitor API performance',
                          style: TextStyle(
                            color: Colors.white.withAlpha(220),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _launchSimulation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TrackingMapSimulation(
          startLocation: LatLng(-6.180110, 106.863036),
          targetLocation: LatLng(-6.175110, 106.865036),
          targetName: "Jakarta Restaurant Simulation",
        ),
      ),
    );
  }

  Widget _buildApiInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPallete.primaryColor.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPallete.primaryColor.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppPallete.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Using flutter_polyline_points",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "This implementation uses flutter_polyline_points package to efficiently decode route information from the Google Maps Directions API.",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showApiKeyInfo(context),
              icon: const Icon(Icons.help_outline, size: 16),
              label: const Text("Bantuan API"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBox(List<String> features) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, List<String> points) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...points.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(point, style: const TextStyle(fontSize: 14))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTestButton(
    BuildContext context,
    String title,
    String subtitle,
    LatLng customerLocation,
    LatLng targetLocation,
    String targetName,
    String targetAddress,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TrackingMap(
                  customerLocation: customerLocation,
                  targetLocation: targetLocation,
                  targetName: targetName,
                  targetAddress: targetAddress,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppPallete.primaryColor.withAlpha(30),
                  child: const Icon(Icons.map, color: AppPallete.primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showApiKeyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengaturan Google Maps API'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Untuk rute yang berfungsi baik, diperlukan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('1. Kunci API Google Maps yang valid dengan penagihan diaktifkan'),
              SizedBox(height: 4),
              Text('2. API Directions diaktifkan untuk proyek Anda'),
              SizedBox(height: 4),
              Text('3. Kunci API dikonfigurasi dalam file env.dart'),
              SizedBox(height: 12),
              Text(
                'Masalah API Umum:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Pembatasan kunci API (pastikan itu mengizinkan API Directions)'),
              SizedBox(height: 4),
              Text('• Penagihan tidak diaktifkan pada akun Google Cloud'),
              SizedBox(height: 4),
              Text('• Kuota harian terlampaui'),
              SizedBox(height: 12),
              Text(
                'Tips Optimasi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Lacak panggilan API untuk mengidentifikasi kemungkinan bottleneck'),
              SizedBox(height: 4),
              Text('• Pertimbangkan penghitungan ulang rute yang lebih jarang'),
              SizedBox(height: 4),
              Text('• Cache hasil untuk rute serupa bila sesuai'),
              SizedBox(height: 12),
              Text(
                'Check simulation logs for detailed performance metrics.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
