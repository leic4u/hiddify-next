import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/features/common/common.dart';
import 'package:hiddify/features/settings/widgets/theme_mode_switch_button.dart';
import 'package:hiddify/services/auto_start_service.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GeneralSettingTiles extends HookConsumerWidget {
  const GeneralSettingTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final theme = ref.watch(themeProvider);

    return Column(
      children: [
        const LocalePrefTile(),
        EnableAnalyticsPrefTile(
          onChanged: (value) async {
            await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(t.settings.general.enableAnalytics),
                  content: Text(t.settings.requiresRestartMsg),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(true),
                      child: Text(
                        MaterialLocalizations.of(context).okButtonLabel,
                      ),
                    ),
                  ],
                );
              },
            );
            return ref.read(enableAnalyticsProvider.notifier).update(value);
          },
        ),
        ListTile(
          title: Text(t.settings.general.themeMode),
          subtitle: Text(
            switch (theme.mode) {
              ThemeMode.system => t.settings.general.themeModes.system,
              ThemeMode.light => t.settings.general.themeModes.light,
              ThemeMode.dark => t.settings.general.themeModes.dark,
            },
          ),
          trailing: ThemeModeSwitch(
            themeMode: theme.mode,
            onChanged: ref.read(themeModeNotifierProvider.notifier).update,
          ),
          leading: const Icon(Icons.light_mode),
          onTap: () async {
            await ref.read(themeModeNotifierProvider.notifier).update(
                  Theme.of(context).brightness == Brightness.light
                      ? ThemeMode.dark
                      : ThemeMode.light,
                );
          },
        ),
        SwitchListTile(
          title: Text(t.settings.general.trueBlack),
          value: theme.trueBlack,
          onChanged: ref.read(trueBlackThemeNotifierProvider.notifier).update,
        ),
        if (PlatformUtils.isDesktop) ...[
          SwitchListTile(
            title: Text(t.settings.general.autoStart),
            value: ref.watch(autoStartServiceProvider).asData!.value,
            onChanged: (value) async {
              if (value) {
                await ref.read(autoStartServiceProvider.notifier).enable();
              } else {
                await ref.read(autoStartServiceProvider.notifier).disable();
              }
            },
          ),
          SwitchListTile(
            title: Text(t.settings.general.silentStart),
            value: ref.watch(silentStartNotifierProvider),
            onChanged: (value) async {
              await ref
                  .read(silentStartNotifierProvider.notifier)
                  .update(value);
            },
          ),
        ],
      ],
    );
  }
}
