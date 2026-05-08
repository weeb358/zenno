import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class LibraryDetailsScreen extends StatelessWidget {
  const LibraryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: GamingAppBar(title: 'LIBRARY DETAILS'),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 10,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kSteamDark,
                      border: Border.all(color: kSteamMed, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statItem('42', 'Total Games', kSteamAccent),
                        Container(width: 1, height: 40, color: kSteamMed),
                        _statItem('156', 'Hours Played', kSteamGreen),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SteamSectionHeader('Recent Games'),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kSteamDark,
                            border: Border.all(color: kSteamMed, width: 1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Game Title ${index + 1}',
                                style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.w700, color: kSteamText),
                              ),
                              Text(
                                '${(index + 1) * 10}h played',
                                style: GoogleFonts.rajdhani(fontSize: 12, color: kSteamGreen, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.rajdhani(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.rajdhani(fontSize: 12, color: kSteamSubtext)),
      ],
    );
  }
}
