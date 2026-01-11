import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isDeviceSecure = false;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkDeviceSecurity();
  }

  Future<void> _checkDeviceSecurity() async {
    try {
      _isDeviceSecure = await auth.isDeviceSupported();
    } catch (e) {
      _authorized = 'Error: Security check failed';
    }
    if (mounted) setState(() {});
  }

  Future<void> _authenticate() async {
    if (!_isDeviceSecure) {
      setState(() {
        _authorized = 'Error: No screen lock set';
      });
      _showSecuritySetupDialog();
      return;
    }

    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Checking...';
      });

      final authenticated = await auth.authenticate(
        localizedReason: 'Access your travel diary',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      setState(() {
        _isAuthenticating = false;
        _authorized = authenticated ? '✅ Authorized' : '❌ Not Authorized';
      });

      if (authenticated) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authorized = '❌ Error: ${e.message}';
      });
      if (e.code == 'NoCredential') {
        _showSecuritySetupDialog();
      }
    }
  }

  void _showSecuritySetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Required'),
        content: const Text(
          'Please set a screen lock (PIN/Password/Fingerprint) in device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticating) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fingerprint,
              size: 120,
              color: Colors.blue,
            ),
            const SizedBox(height: 32),
            Text(
              _authorized,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _authorized.startsWith('✅') ? Colors.green :
                _authorized.startsWith('❌') ? Colors.red :
                Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              icon: const Icon(Icons.fingerprint, size: 28),
              label: const Text(
                'Authenticate',
                style: TextStyle(fontSize: 18),
              ),
              onPressed: _isDeviceSecure ? _authenticate : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (!_isDeviceSecure) ...[
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '⚠️ Please enable screen lock in device settings',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}