import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../profile/controllers/profile_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<ProfileController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF09090F),
      body: Stack(
        children: [
          
          Positioned.fill(child: _buildBackground(size)),

          
          Positioned.fill(
            child: Row(
              children: [
                
                Expanded(
                  flex: 5,
                  child: _buildBrandingPanel(),
                ),
                
                Expanded(
                  flex: 4,
                  child: _buildLoginPanel(pc),
                ),
              ],
            ),
          ),

          
          Positioned(
            bottom: 24, left: 0, right: 0,
            child: Center(
              child: Text(
                'ARTVERSE  ◆  STUDIO EDITION  ◆  2026',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.06),
                  fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildBackground(Size size) {
    return Stack(
      fit: StackFit.expand,
      children: [
        
        Image.asset(
          'assets/images/branding/background_studio.png',
          fit: BoxFit.cover,
        ),

        
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.45),
          ),
        ),
        
        
        
        Positioned(
          top: -size.height * 0.3, left: -size.width * 0.15,
          child: Container(
            width: size.width * 0.6, height: size.width * 0.6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                Color(0x1500C4FF), Color(0x0000C4FF), Colors.transparent,
              ], stops: [0, 0.5, 1]),
            ),
          ),
        ),
        
        Positioned(
          bottom: -size.height * 0.2, right: -size.width * 0.1,
          child: Container(
            width: size.width * 0.5, height: size.width * 0.5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                Color(0x10A855F7), Color(0x05A855F7), Colors.transparent,
              ], stops: [0, 0.5, 1]),
            ),
          ),
        ),
        
        Positioned(
          left: size.width * 5 / 9 - 1, top: 0, bottom: 0,
          child: Container(
            width: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x20FFFFFF), Colors.transparent],
              ),
            ),
          ),
        ),
        
        Positioned.fill(
          child: Opacity(
            opacity: 0.025,
            child: CustomPaint(painter: _GrainPainter()),
          ),
        ),
      ],
    );
  }

  
  
  
  Widget _buildBrandingPanel() {
    return Stack(
      children: [
        
        
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 36),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
              
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/branding/app_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('ARTVERSE', style: GoogleFonts.plusJakartaSans(
                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 4)),
                ],
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),

              const SizedBox(height: 24),

              
              Text('Where', style: GoogleFonts.cinzel(color: Colors.white,
                fontSize: 42, fontWeight: FontWeight.w300, letterSpacing: -1, height: 1.05,
                shadows: [Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 10)]),
              ).animate().fadeIn(delay: 100.ms, duration: 700.ms).slideY(begin: 0.2, end: 0),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00E0FF), Color(0xFFC084FC)],
                ).createShader(bounds),
                child: Text('Imagination', style: GoogleFonts.cinzel(color: Colors.white,
                  fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1, height: 1.1,
                  shadows: [Shadow(color: const Color(0xFFA855F7).withValues(alpha: 0.5), blurRadius: 20)]),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 700.ms).slideY(begin: 0.2, end: 0),
              Text('Becomes Legacy.', style: GoogleFonts.cinzel(color: Colors.white,
                fontSize: 42, fontWeight: FontWeight.w300, letterSpacing: -1, height: 1.05,
                shadows: [Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 10)]),
              ).animate().fadeIn(delay: 300.ms, duration: 700.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 12),

              Text(
                'The creative studio suite for artists,\ndesigners, and digital visionaries.',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13, height: 1.55, fontWeight: FontWeight.w400,
                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)]),
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

              const SizedBox(height: 20),

              
              ...[
                (Icons.palette_rounded,        'Professional Creative Studio'),
                (Icons.storefront_rounded,     'Marketplace & NFT Exchange'),
                (Icons.emoji_events_rounded,   'Live Challenges & Leaderboards'),
                (Icons.cloud_sync_rounded,     'Cloud Sync & Collaboration'),
              ].asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: const Color(0xFF00C4FF).withValues(alpha: 0.08),
                        border: Border.all(color: const Color(0xFF00C4FF).withValues(alpha: 0.15)),
                      ),
                      child: Icon(e.value.$1, color: const Color(0xFF00C4FF).withValues(alpha: 0.6), size: 12),
                    ),
                    const SizedBox(width: 10),
                    Text(e.value.$2, style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ).animate(delay: Duration(milliseconds: 500 + 80 * e.key))
                    .fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0),
              )),

              const Spacer(),

              
              Row(
                children: [
                  _statBadge('50K+', 'ARTISTS'),
                  const SizedBox(width: 20),
                  _statBadge('200K+', 'ARTWORKS'),
                  const SizedBox(width: 20),
                  _statBadge('4.9★', 'RATING'),
                ],
                ).animate().fadeIn(delay: 800.ms, duration: 500.ms),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _statBadge(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFF00C4FF), Color(0xFFA855F7)],
          ).createShader(b),
          child: Text(value, style: GoogleFonts.lexend(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
        ),
        Text(label, style: GoogleFonts.plusJakartaSans(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ],
    );
  }

  
  
  
  Widget _buildLoginPanel(ProfileController pc) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            border: Border(left: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 0.5)),
          ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              Text(
                'Welcome back',
                style: GoogleFonts.cinzel(
                  color: Colors.white, fontSize: 32, fontWeight: FontWeight.w400, letterSpacing: -0.5),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.15, end: 0),

              const SizedBox(height: 8),

              Text(
                'Sign in to access your creative workspace.',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.w400),
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

              const SizedBox(height: 48),

              
              Obx(() {
                final loading = pc.isLoading.value;
                return GestureDetector(
                  onTap: loading ? null : pc.signInWithGoogle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: loading ? null : const LinearGradient(
                        colors: [Color(0xFF00C4FF), Color(0xFF7C3AED)],
                        begin: Alignment.centerLeft, end: Alignment.centerRight,
                      ),
                      color: loading ? Colors.white.withValues(alpha: 0.04) : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: loading ? null : [
                        const BoxShadow(color: Color(0x3000C4FF), blurRadius: 24, offset: Offset(0, 8)),
                      ],
                      border: Border.all(color: Colors.white.withValues(alpha: loading ? 0.06 : 0.0)),
                    ),
                    child: loading
                        ? const Center(child: SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38)))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/branding/google_logo_studio.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'Đăng nhập với Google',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                  ),
                );
              }).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              
              Row(
                children: [
                  Expanded(child: Container(height: 0.5, color: Colors.white.withValues(alpha: 0.08))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or'.toUpperCase(), style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ),
                  Expanded(child: Container(height: 0.5, color: Colors.white.withValues(alpha: 0.08))),
                ],
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 16),

              
              GestureDetector(
                onTap: () => Get.offAllNamed<void>('/layout'),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    color: Colors.white.withValues(alpha: 0.03),
                  ),
                  child: Text(
                    'EXPLORE AS GUEST  →',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  ),
                ),
              ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 48),

              
              Text(
                'By signing in you agree to our Terms of Service\nand Privacy Policy.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11, height: 1.6, fontWeight: FontWeight.w400),
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    ),
    ),
    );
  }
}


class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final rng = math.Random(7);
    for (int i = 0; i < 4000; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        rng.nextDouble() * 0.7, paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
