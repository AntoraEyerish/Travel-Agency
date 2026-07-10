import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

// ─── Keys for SharedPreferences ────────────────────────────────────────────────
const _kPushNotif   = 'settings_push_notif';
const _kEmailUpdates = 'settings_email_updates';
const _kDarkMode    = 'settings_dark_mode';
const _kLanguage    = 'settings_language';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();

  // Preference state
  bool _pushNotifications = true;
  bool _emailUpdates      = true;
  bool _darkMode          = true;
  String _selectedLanguage = 'English';
  bool _isProcessing = false;
  bool _prefsLoaded  = false;

  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _pushNotifications  = prefs.getBool(_kPushNotif)    ?? true;
        _emailUpdates       = prefs.getBool(_kEmailUpdates) ?? true;
        _darkMode           = prefs.getBool(_kDarkMode)     ?? true;
        _selectedLanguage   = prefs.getString(_kLanguage)   ?? 'English';
        _prefsLoaded        = true;
      });
    }
  }

  Future<void> _setPref(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool)   await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);
  }

  // ── Password Reset ────────────────────────────────────────────────────────

  Future<void> _resetPassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return;

    setState(() => _isProcessing = true);
    try {
      await _authService.sendPasswordResetEmail(user!.email!);
      if (mounted) {
        _showSuccessDialog(
          'Email Sent',
          'A password reset link was sent to ${user.email}. Check your inbox.',
        );
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Reset Failed', e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ── Delete account flow ───────────────────────────────────────────────────

  Future<void> _confirmDeleteAccount() async {
    // Step 1 – red warning dialog
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2642),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 26),
            SizedBox(width: 8),
            Text('Delete Account',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ],
        ),
        content: const Text(
          'This action is permanent and cannot be undone.\n\n'
          'All your bookings, saved places and profile data will be deleted. '
          'You will be asked to confirm your password on the next step.',
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Continue',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (proceed != true || !mounted) return;

    // Step 2 – password input dialog
    final password = await _askPassword();
    if (password == null || password.isEmpty) return;

    _deleteAccount(password);
  }

  Future<String?> _askPassword() {
    final ctrl        = TextEditingController();
    bool obscure      = true;
    bool hasText      = false;
    bool showError    = false;   // shown when user taps Delete with empty field
    String errorMsg   = '';

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {

          // Keep hasText in sync so the button activates as soon as a char is typed
          ctrl.addListener(() {
            final notEmpty = ctrl.text.trim().isNotEmpty;
            if (notEmpty != hasText) {
              setDialogState(() {
                hasText    = notEmpty;
                showError  = false; // clear error while typing
                errorMsg   = '';
              });
            }
          });

          void trySubmit() {
            if (ctrl.text.trim().isEmpty) {
              setDialogState(() {
                showError = true;
                errorMsg  = 'Password is required to delete your account.';
              });
              return;
            }
            Navigator.pop(ctx, ctrl.text);
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF1A2642),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.red, size: 22),
                SizedBox(width: 8),
                Text('Confirm Password',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your current password to verify your identity before deleting your account:',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  obscureText: obscure,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => trySubmit(),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF0A1628),
                    errorText: showError ? errorMsg : null,
                    errorStyle: const TextStyle(
                        color: Color(0xFFFF4B55), fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: showError
                              ? const Color(0xFFFF4B55)
                              : Colors.transparent,
                          width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: showError
                              ? const Color(0xFFFF4B55)
                              : Colors.blue,
                          width: 1.5),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Colors.white38, size: 20),
                    suffixIcon: IconButton(
                      tooltip: obscure ? 'Show password' : 'Hide password',
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white38,
                        size: 20,
                      ),
                      onPressed: () =>
                          setDialogState(() => obscure = !obscure),
                    ),
                  ),
                ),

                // Inline helper when field is empty and user tried to submit
                if (showError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Color(0xFFFF4B55), size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            errorMsg,
                            style: const TextStyle(
                                color: Color(0xFFFF4B55), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.grey)),
              ),
              // Button is visually disabled (greyed out) when field is empty
              ElevatedButton(
                onPressed: trySubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasText
                      ? Colors.red
                      : Colors.red.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Delete Account',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteAccount(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    setState(() => _isProcessing = true);
    try {
      // Re-authenticate first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      final uid = user.uid;

      // Delete Firestore data
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      // Delete bookings belonging to this user
      final bookingsSnap = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: uid)
          .get();
      for (final doc in bookingsSnap.docs) {
        await doc.reference.delete();
      }

      // Delete Firebase Auth account
      await user.delete();

      if (mounted) {
        _showSuccessDialog(
          'Account Deleted',
          'Your account has been deleted successfully.',
          onClose: () => Navigator.pushNamedAndRemoveUntil(
              context, '/login', (r) => false),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          _showErrorDialog('Wrong Password',
              'The password you entered is incorrect. Please try again.');
        } else if (e.code == 'requires-recent-login') {
          _showErrorDialog('Session Expired',
              'Please log out and log back in, then try again.');
        } else {
          _showErrorDialog('Deletion Failed', e.message ?? e.toString());
        }
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Deletion Failed', e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showSuccessDialog(String title, String message,
      {VoidCallback? onClose}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2642),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14, height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (onClose != null) onClose();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('OK',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2642),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFF4B55), size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Text(message,
            style: const TextStyle(
                color: Colors.grey, fontSize: 14, height: 1.5)),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF246AFE),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2642),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          _prefsLoaded
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                  children: [
                    // ── Preferences ─────────────────────────────────
                    _sectionHeader('Preferences'),
                    _switchTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      subtitle: 'Use the premium dark theme',
                      value: _darkMode,
                      onChanged: (v) {
                        setState(() => _darkMode = v);
                        _setPref(_kDarkMode, v);
                      },
                    ),
                    _languageTile(),
                    const SizedBox(height: 20),

                    // ── Notifications ────────────────────────────────
                    _sectionHeader('Notifications'),
                    _switchTile(
                      icon: Icons.notifications_none_outlined,
                      title: 'Push Notifications',
                      subtitle: 'Real-time updates on bookings',
                      value: _pushNotifications,
                      onChanged: (v) {
                        setState(() => _pushNotifications = v);
                        _setPref(_kPushNotif, v);
                      },
                    ),
                    _switchTile(
                      icon: Icons.mail_outline_rounded,
                      title: 'Email Updates',
                      subtitle: 'Receive booking confirmations by email',
                      value: _emailUpdates,
                      onChanged: (v) {
                        setState(() => _emailUpdates = v);
                        _setPref(_kEmailUpdates, v);
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Security ─────────────────────────────────────
                    _sectionHeader('Security & Privacy'),
                    _actionTile(
                      icon: Icons.lock_reset_outlined,
                      title: 'Change Password',
                      subtitle: 'Send a password reset link to your email',
                      color: Colors.blue,
                      onTap: _resetPassword,
                    ),
                    _actionTile(
                      icon: Icons.delete_forever_outlined,
                      title: 'Delete Account',
                      subtitle: 'Permanently delete all your data',
                      color: Colors.red,
                      onTap: _confirmDeleteAccount,
                    ),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.blue)),

          // Loading overlay
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.blue)),
            ),
        ],
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      );

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2642),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 22),
        ),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.blue,
        activeTrackColor: Colors.blue.withValues(alpha: 0.3),
        inactiveThumbColor: Colors.white30,
        inactiveTrackColor: Colors.black26,
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2642),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            color: Colors.white.withValues(alpha: 0.2), size: 14),
        onTap: onTap,
      ),
    );
  }

  Widget _languageTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2642),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.language_outlined, color: Colors.teal, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Language',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                Text('Select display language',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          DropdownButton<String>(
            value: _selectedLanguage,
            dropdownColor: const Color(0xFF1A2642),
            style: const TextStyle(
                color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 14),
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
            items: _languages
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedLanguage = v);
                _setPref(_kLanguage, v);
              }
            },
          ),
        ],
      ),
    );
  }
}
