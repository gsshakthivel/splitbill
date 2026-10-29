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

  static const _primary = Color(0xFF176B55);
  static const _text = Color(0xFF172B25);
  static const _muted = Color(0xFF75817C);
  static const _border = Color(0xFFE6ECE8);
  static const _background = Color(0xFFF6F8F7);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final searchState = ref.watch(userSearchProvider(query));

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 460,
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 22, 16, 22),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF176B55), Color(0xFF27876B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 13),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add a member',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Find someone to join your group.',
                            style: TextStyle(
                              color: Color(0xFFD9EEE6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: _isAdding
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Search users',
                        style: TextStyle(
                          color: _text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 9),
                      TextField(
                        controller: _searchController,
                        enabled: !_isAdding,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Enter a name or email',
                          hintStyle: const TextStyle(
                            color: Color(0xFFA0AAA5),
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: _muted,
                          ),
                          suffixIcon: query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _selectedUser = null;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: _muted,
                                    size: 19,
                                  ),
                                ),
                          filled: true,
                          fillColor: _background,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: _border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: _border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: _primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (_) {
                          setState(() {
                            _selectedUser = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_selectedUser != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF7F2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFC9E5D8)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _primary,
                                child: Text(
                                  _initials(_selectedUser!.name),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Selected member',
                                      style: TextStyle(
                                        color: _primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      _selectedUser!.name,
                                      style: const TextStyle(
                                        color: _text,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _selectedUser!.email,
                                      style: const TextStyle(
                                        color: _muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.check_circle_rounded,
                                color: _primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Search results',
                              style: TextStyle(
                                color: _text,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (query.length >= 2)
                            const Text(
                              'Select one member',
                              style: TextStyle(color: _muted, fontSize: 11),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: query.length < 2
                            ? const _SearchHint()
                            : searchState.when(
                                loading: () => const Center(
                                  child: CircularProgressIndicator(
                                    color: _primary,
                                  ),
                                ),
                                error: (error, stackTrace) => Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      error.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFFB5473C),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                data: (users) {
                                  if (users.isEmpty) {
                                    return const _NoUsersFound();
                                  }

                                  return ListView.separated(
                                    itemCount: users.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(height: 6),
                                    itemBuilder: (context, index) {
                                      final user = users[index];
                                      final isSelected =
                                          _selectedUser?.id == user.id;

                                      return Material(
                                        color: isSelected
                                            ? const Color(0xFFEFF7F2)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(13),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            13,
                                          ),
                                          onTap: _isAdding
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _selectedUser = user;
                                                  });
                                                },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                              border: Border.all(
                                                color: isSelected
                                                    ? const Color(0xFFC9E5D8)
                                                    : _border,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor: isSelected
                                                      ? _primary
                                                      : const Color(0xFFE7F3EE),
                                                  child: Text(
                                                    _initials(user.name),
                                                    style: TextStyle(
                                                      color: isSelected
                                                          ? Colors.white
                                                          : _primary,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 11),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        user.name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          color: _text,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        user.email,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          color: _muted,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Icon(
                                                  isSelected
                                                      ? Icons
                                                            .check_circle_rounded
                                                      : Icons
                                                            .radio_button_unchecked,
                                                  color: isSelected
                                                      ? _primary
                                                      : _muted,
                                                  size: 21,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: _border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isAdding
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _text,
                          side: const BorderSide(color: _border),
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedUser == null || _isAdding
                            ? null
                            : _addSelectedMember,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _primary.withValues(
                            alpha: 0.4,
                          ),
                          minimumSize: const Size(0, 48),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: _isAdding
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Add Member',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) return '?';

    final parts = trimmed.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
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

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.manage_search_rounded,
              size: 32,
              color: Color(0xFF75817C),
            ),
            SizedBox(height: 8),
            Text(
              'Enter at least 2 characters to search.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF75817C), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoUsersFound extends StatelessWidget {
  const _NoUsersFound();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 32,
              color: Color(0xFF75817C),
            ),
            SizedBox(height: 8),
            Text(
              'No users found.',
              style: TextStyle(
                color: Color(0xFF172B25),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Try searching with another name or email.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF75817C), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
