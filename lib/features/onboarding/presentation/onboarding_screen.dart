import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Extract colors from design
    const indigoPrimary = Color(0xFF4F46E5);
    const indigo50 = Color(0xFFEEF2FF); // Approximate for indigo-50
    const purple400 = Color(0xFFC084FC); // Approximate for purple-400
    const gray900 = Color(0xFF111827); // gray-900
    const gray500 = Color(0xFF6B7280); // gray-500
    const gray400 = Color(0xFF9CA3AF); // gray-400
    const gray300 = Color(0xFFD1D5DB); // gray-300

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              indigo50, // indigo-50/50 (approx)
              Colors.white,
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top Navigation / Skip
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => context.go('/login'),
                                style: TextButton.styleFrom(
                                  foregroundColor: gray400,
                                  textStyle: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: Text(l10n.skip),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Main Content Area
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 3D Illustration Area
                            SizedBox(
                              width: 320,
                              height: 320,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Background Glow/Blob
                                  Positioned(
                                    child: Container(
                                      width: 256,
                                      height: 256,
                                      decoration: BoxDecoration(
                                        color: indigoPrimary.withValues(
                                            alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                        .animate(
                                          onPlay: (controller) =>
                                              controller.repeat(reverse: true),
                                        )
                                        .scale(
                                          begin: const Offset(0.8, 0.8),
                                          end: const Offset(1.2, 1.2),
                                          duration: 2.seconds,
                                          curve: Curves.easeInOut,
                                        ),
                                  ),
                                  Positioned(
                                    child: Container(
                                      width: 224,
                                      height: 224,
                                      decoration: BoxDecoration(
                                        color: purple400.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                        .animate(
                                          delay: 1.seconds,
                                          onPlay: (controller) =>
                                              controller.repeat(reverse: true),
                                        )
                                        .scale(
                                          begin: const Offset(0.8, 0.8),
                                          end: const Offset(1.2, 1.2),
                                          duration: 2.seconds,
                                          curve: Curves.easeInOut,
                                        ),
                                  ),

                                  // 3D Image
                                  Container(
                                    width: 256,
                                    height: 256,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: indigoPrimary.withValues(
                                              alpha: 0.2),
                                          blurRadius: 40,
                                          offset: const Offset(0, 20),
                                        ),
                                      ],
                                      image: const DecorationImage(
                                        image: NetworkImage(
                                          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                      .animate(
                                        onPlay: (controller) =>
                                            controller.repeat(reverse: true),
                                      )
                                      .moveY(
                                        begin: 0,
                                        end: -20,
                                        duration: 3.seconds,
                                        curve: Curves.easeInOut,
                                      ),

                                  // Floating Elements
                                  Positioned(
                                    right: -16,
                                    top: 40,
                                    child: _buildFloatingIcon(
                                      icon: Icons.auto_awesome,
                                      color: indigoPrimary,
                                      delay: 0.ms,
                                    ),
                                  ),
                                  Positioned(
                                    left: -8,
                                    bottom: 40,
                                    child: _buildFloatingIcon(
                                      icon: Icons.code,
                                      color: Colors.purple,
                                      delay: 1000.ms,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Text Content
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Column(
                                children: [
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: GoogleFonts.inter(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        color: gray900,
                                        height: 1.2,
                                        letterSpacing: -0.5,
                                      ),
                                      children: [
                                        TextSpan(
                                            text:
                                                '${l10n.aiPoweredResumeCreation.split('\n')[0]}\n'),
                                        TextSpan(
                                          text: l10n.aiPoweredResumeCreation
                                              .split('\n')[1],
                                          style: const TextStyle(
                                              color: indigoPrimary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.onboardingDescription,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: gray500,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                                  .animate()
                                  .fadeIn(duration: 800.ms)
                                  .moveY(begin: 20, end: 0),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Bottom Controls
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                          child: Column(
                            children: [
                              // Carousel Indicators
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: indigoPrimary,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: gray300,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: gray300,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Primary Action Button
                              Container(
                                width: double.infinity,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          indigoPrimary.withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () => context.go('/login'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: indigoPrimary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Stack(
                                    children: [
                                      // Shimmer Effect (Simplified)
                                      Positioned.fill(
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.white
                                                        .withValues(alpha: 0.1),
                                                    Colors.transparent,
                                                  ],
                                                  stops: const [0.0, 0.5, 1.0],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                ),
                                              ),
                                            )
                                                .animate(
                                                  onPlay: (controller) =>
                                                      controller.repeat(),
                                                )
                                                .moveX(
                                                  begin: -constraints.maxWidth,
                                                  end: constraints.maxWidth,
                                                  duration: 1.5.seconds,
                                                );
                                          },
                                        ),
                                      ),
                                      Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              l10n.getStarted,
                                              style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.arrow_forward,
                                                size: 20),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Login Link
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${l10n.alreadyHaveAccount} ',
                                    style: GoogleFonts.inter(
                                      color: gray500,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.go('/login'),
                                    child: Text(
                                      l10n.logIn,
                                      style: GoogleFonts.inter(
                                        color: indigoPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingIcon({
    required IconData icon,
    required Color color,
    required Duration delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 24),
    )
        .animate(
          delay: delay,
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .moveY(
          begin: 0,
          end: -10,
          duration: 3.seconds,
          curve: Curves.easeInOut,
        );
  }
}
