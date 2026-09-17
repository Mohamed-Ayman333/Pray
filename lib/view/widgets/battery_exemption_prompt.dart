import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:provider/provider.dart';

import 'package:pray/controller/user_state_controller.dart';
import 'package:pray/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

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
          title: Text(l10n.batteryPromptTitle),
          content: Text(l10n.batteryPromptMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.batteryPromptLater),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await ph.Permission.ignoreBatteryOptimizations.request();
              },
              child: Text(l10n.batteryPromptAllow),
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
