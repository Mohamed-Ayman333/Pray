import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:provider/provider.dart';

import 'package:pray/controller/user_state_controller.dart';

/// One-shot prompt asking the user to exempt the app from battery
/// optimizations, so scheduled prayer notifications aren't delayed or
/// silently dropped by Android's Doze / OEM task killers.
///
/// Must be mounted below the [ChangeNotifierProvider] for
/// [UserStateController] (i.e. inside [MainShell]) because it reads the
/// persisted `hasPromptedBatteryExemption` flag from the controller.
class BatteryExemptionPrompt extends StatefulWidget {
  const BatteryExemptionPrompt({super.key, required this.child});

  final Widget child;

  @override
  State<BatteryExemptionPrompt> createState() => _BatteryExemptionPromptState();
}

class _BatteryExemptionPromptState extends State<BatteryExemptionPrompt>
    with WidgetsBindingObserver {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrompt());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _maybePrompt() async {
    if (_checked || !Platform.isAndroid || !mounted) return;
    _checked = true;

    final controller = context.read<UserStateController>();

    if (controller.currentUserState.hasPromptedBatteryExemption) {
      debugPrint('[battery] prompt already shown previously');
      return;
    }

    try {
      final status = await ph.Permission.ignoreBatteryOptimizations.status;
      if (status.isGranted) {
        debugPrint('[battery] already exempted');
        await controller.markBatteryExemptionPrompted();
        return;
      }

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          title: const Text('Keep reminders on time'),
          content: const Text(
            'Android sometimes delays or silences notifications when the '
            'app is in the background. To make sure you receive prayer '
            'reminders on time, allow this app to ignore battery '
            'optimizations.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Later'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await ph.Permission.ignoreBatteryOptimizations.request();
              },
              child: const Text('Allow'),
            ),
          ],
        ),
      );

      await controller.markBatteryExemptionPrompted();
      debugPrint('[battery] persisted hasPromptedBatteryExemption=true');
    } catch (e) {
      debugPrint('[battery] check failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}