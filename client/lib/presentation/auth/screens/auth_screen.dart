import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:client/core/config/env_config.dart';
import 'package:client/presentation/auth/providers/auth_provider.dart';
import 'package:client/presentation/core/providers/audio_provider.dart';
import 'package:client/presentation/core/utils/responsive_layout.dart';
import 'package:client/presentation/core/utils/splode_snackbar.dart';
import 'package:client/presentation/core/widgets/auth_button.dart';
import 'package:client/presentation/core/widgets/responsive_content_container.dart';

/// The login/signup screen shown when the app first launches.
///
/// Uses a warm charcoal + amber aesthetic. No functionality yet — purely UI.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  String? _loadingAction;
  static const _bgDark = Color(0xFF111111);
  static const _amber = Color(0xFFD4A44C);
  static const _amberLight = Color(0xFFE8C87A);
  static const _cream = Color(0xFFF5F0E8);

  @override
  void initState() {
    super.initState();
    // Start background music when the app launches and reaches this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(audioProvider).playMenuMusic();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          // Warm ambient glow — top-left
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _amber.withValues(alpha: 0.12),
                    _amber.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Warm ambient glow — bottom-right
          Positioned(
            bottom: -140,
            right: -60,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _amber.withValues(alpha: 0.08),
                    _amber.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    child: ResponsiveContentContainer(
                      maxWidth: SplodeBreakpoints.maxFormWidth,
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: context.isShortScreen ? 20.0 : 50.0,
                          ),

                          // Logo mark — a simple decorative accent
                          Container(
                            width: context.isShortScreen ? 48.0 : 64.0,
                            height: context.isShortScreen ? 48.0 : 64.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _amber.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: context.isShortScreen ? 18.0 : 24.0,
                                height: context.isShortScreen ? 18.0 : 24.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _amber.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: context.isShortScreen ? 16.0 : 28.0,
                          ),

                          // Title
                          Text(
                            'SPLODE.IO',
                            style: GoogleFonts.outfit(
                              fontSize: context.isShortScreen ? 34.0 : 44.0,
                              fontWeight: FontWeight.w700,
                              color: _cream,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'CHAIN REACTION ARENA',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 4,
                              color: _amberLight.withValues(alpha: 0.6),
                            ),
                          ),

                          SizedBox(
                            height: context.isShortScreen ? 24.0 : 48.0,
                          ),

                          // Divider line
                          Container(
                            width: 40,
                            height: 1.5,
                            color: _amber.withValues(alpha: 0.3),
                          ),

                          SizedBox(
                            height: context.isShortScreen ? 24.0 : 40.0,
                          ),

                        // Auth Buttons
                        Column(
                          children: [
                            AuthButton(
                              text: 'Play as Guest',
                              icon: const Icon(Icons.person_outline_rounded),
                              style: AuthButtonStyle.primary,
                              isLoading: _loadingAction == 'guest',
                              onPressed: () async {
                                if (_loadingAction != null) return;
                                setState(() => _loadingAction = 'guest');
                                try {
                                  await ref
                                      .read(authLogicProvider)
                                      .signInAnonymously();
                                } catch (e) {
                                  if (context.mounted) {
                                    setState(() => _loadingAction = null);
                                    SplodeSnackbar.show(
                                      context: context,
                                      message: 'Error signing in: $e',
                                      type: SnackbarType.error,
                                    );
                                  }
                                }
                              },
                            ),
                            SizedBox(
                              height: context.isShortScreen ? 20.0 : 28.0,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: _amber.withValues(alpha: 0.2),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'OR CONTINUE WITH',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                      color: _amberLight.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: _amber.withValues(alpha: 0.2),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: context.isShortScreen ? 20.0 : 28.0,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: AuthButton(
                                    text: 'Google',
                                    icon: Image.asset(
                                      'assets/icons/google.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                    style: AuthButtonStyle.secondary,
                                    isLoading: _loadingAction == 'google',
                                    onPressed: () async {
                                      if (_loadingAction != null) return;
                                      setState(() => _loadingAction = 'google');
                                      try {
                                        await ref
                                            .read(authLogicProvider)
                                            .signInWithGoogle(
                                              webClientId:
                                                  EnvConfig.googleWebClientId,
                                            );
                                      } catch (e) {
                                        if (context.mounted) {
                                          setState(() => _loadingAction = null);
                                          SplodeSnackbar.show(
                                            context: context,
                                            message: 'Google Sign-In failed: $e',
                                            type: SnackbarType.error,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: AuthButton(
                                    text: 'Email',
                                    icon: const Icon(Icons.email_outlined),
                                    style: AuthButtonStyle.outline,
                                    onPressed: () {
                                      if (_loadingAction != null) return;
                                      SplodeSnackbar.show(
                                        context: context,
                                        message: 'Email login coming soon!',
                                        type: SnackbarType.info,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(
                          height: context.isShortScreen ? 20.0 : 36.0,
                        ),

                        // Footer
                        Text(
                          'By continuing, you agree to our',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Terms of Service',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: _amberLight.withValues(alpha: 0.5),
                                    decoration: TextDecoration.underline,
                                    decorationColor: _amberLight.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                '  &  ',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Privacy Policy',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: _amberLight.withValues(alpha: 0.5),
                                    decoration: TextDecoration.underline,
                                    decorationColor: _amberLight.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text(
                          'v0.1.0 (build 3)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: _amberLight.withValues(alpha: 0.6),
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),

              // Mute Button
                Positioned(
                  top: 16,
                  right: 16,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final audioCtrl = ref.watch(audioProvider);
                      return IconButton(
                        icon: Icon(
                          audioCtrl.isMuted
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        onPressed: () {
                          ref.read(audioProvider.notifier).toggleMute();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
