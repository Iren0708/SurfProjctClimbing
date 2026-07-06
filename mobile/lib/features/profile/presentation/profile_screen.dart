import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vertical_mobile/app/router/app_routes.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';
import 'package:vertical_mobile/core/api/models/client_models.dart';
import 'package:vertical_mobile/core/widgets/loadable_placeholders.dart';
import 'package:vertical_mobile/core/widgets/state_container.dart';
import 'package:vertical_mobile/features/profile/domain/profile_messages.dart';
import 'package:vertical_mobile/features/profile/presentation/profile_notifier.dart';
import 'package:vertical_mobile/features/profile/presentation/profile_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    ref.listen(profileProvider, (previous, next) {
      if (next.actionSnack == null || !context.mounted) {
        return;
      }
      final snack = next.actionSnack!;
      notifier.clearSnack();
      if (snack == ProfileMessages.deletedSnack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(snack)),
        );
        context.go(AppRoutes.auth);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snack)),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(ProfileMessages.title),
      ),
      body: StateContainer<ClientDto>(
        state: profileState.profile,
        onRetry: notifier.loadProfile,
        loadingBuilder: (_) => const _ProfileSkeleton(),
        contentBuilder: (_, profile) => _ProfileContent(
          profile: profile,
          profileState: profileState,
          notifier: notifier,
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.profile,
    required this.profileState,
    required this.notifier,
  });

  final ClientDto profile;
  final ProfileState profileState;
  final ProfileNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final tokens = context.verticalTokens;
    final isEditing = profileState.editMode == ProfileEditMode.edit;
    final isSaving = profileState.saveState.isSubmitting;

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(ProfileMessages.nameLabel, style: Theme.of(context).textTheme.labelLarge),
          SizedBox(height: tokens.spacingXs),
          if (isEditing)
            TextFormField(
              initialValue: profileState.draftName,
              enabled: !isSaving,
              onChanged: notifier.updateDraftName,
              decoration: const InputDecoration(
                hintText: ProfileMessages.nameLabel,
              ),
            )
          else
            Text(
              profile.name ?? '—',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          SizedBox(height: tokens.spacingLg),
          Text(ProfileMessages.phoneLabel, style: Theme.of(context).textTheme.labelLarge),
          SizedBox(height: tokens.spacingXs),
          Text(profile.phone, style: Theme.of(context).textTheme.titleMedium),
          if (isEditing) ...[
            SizedBox(height: tokens.spacingXs),
            Text(
              ProfileMessages.phoneReadOnlyHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          SizedBox(height: tokens.spacingXl),
          if (isEditing) ...[
            ActionLoadableButton(
              label: ProfileMessages.saveAction,
              state: profileState.saveState,
              onPressed: isSaving
                  ? null
                  : () async {
                      final saved = await notifier.saveProfile();
                      if (saved) {
                        notifier.cancelEditing();
                      }
                    },
            ),
            SizedBox(height: tokens.spacingSm),
            OutlinedButton(
              onPressed: isSaving ? null : notifier.cancelEditing,
              child: const Text(ProfileMessages.cancelEditAction),
            ),
          ] else
            FilledButton(
              onPressed: notifier.startEditing,
              child: const Text(ProfileMessages.editAction),
            ),
          SizedBox(height: tokens.spacingXl),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(ProfileMessages.clubRules),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(ProfileMessages.support),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          Text(
            ProfileMessages.versionLabel,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: tokens.spacingXl),
          OutlinedButton(
            onPressed: isSaving ? null : () => _confirmLogout(context),
            child: const Text(ProfileMessages.logoutAction),
          ),
          SizedBox(height: tokens.spacingSm),
          TextButton(
            onPressed: isSaving ? null : () => _confirmDelete(context),
            child: Text(
              ProfileMessages.deleteAction,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(ProfileMessages.logoutTitle),
        content: const Text(ProfileMessages.logoutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(ProfileMessages.cancelEditAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(ProfileMessages.logoutConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await notifier.logout();
      if (context.mounted) {
        context.go(AppRoutes.auth);
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(ProfileMessages.deleteTitle),
        content: const Text(ProfileMessages.deleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(ProfileMessages.cancelEditAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(ProfileMessages.deleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await notifier.deleteAccount();
    }
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const LoadableSkeleton(itemCount: 3, itemHeight: 56);
  }
}
