import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:splitbill_frontend/features/groups/data/models/user_search_result.dart';
import 'package:splitbill_frontend/features/groups/presentation/providers/user_search_provider.dart';
import 'package:splitbill_frontend/features/groups/presentation/providers/group_provider.dart';

class AddMemberDialog extends ConsumerStatefulWidget {
  const AddMemberDialog({super.key, required this.groupId});

  final int groupId;

  @override
  ConsumerState<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<AddMemberDialog> {
  final _searchController = TextEditingController();
  UserSearchResult? _selectedUser;
  bool _isAdding = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();

    final searchState = ref.watch(userSearchProvider(query));

    return AlertDialog(
      title: const Text('Add Member'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search users',
                hintText: 'Enter a name or email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {
                  _selectedUser = null;
                });
              },
            ),
            const SizedBox(height: 12),
            if (query.length < 2)
              const Text('Enter at least 2 characters to search.')
            else
              SizedBox(
                height: 200,
                child: searchState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text(error.toString(), textAlign: TextAlign.center),
                  ),
                  data: (users) {
                    if (users.isEmpty) {
                      return const Center(child: Text('No users found.'));
                    }

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final isSelected = _selectedUser?.id == user.id;

                        return ListTile(
                          selected: isSelected,
                          leading: const Icon(Icons.person),
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedUser = user;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isAdding ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedUser == null || _isAdding
              ? null
              : _addSelectedMember,
          child: _isAdding
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Member'),
        ),
      ],
    );
  }

  Future<void> _addSelectedMember() async {
    final user = _selectedUser;
    if (user == null) return;

    setState(() => _isAdding = true);

    try {
      await ref
          .read(groupRepositoryProvider)
          .addMember(groupId: widget.groupId, userId: user.id);

      if (!mounted) return;

      Navigator.of(context).pop(user);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));

      setState(() => _isAdding = false);
    }
  }
}
