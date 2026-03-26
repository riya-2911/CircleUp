import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/post_provider.dart';
import 'dart:io';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;

  final List<Widget> _pages = const [
    _MomentsPage(),
    _MatchesPage(),
    _DiscoverPage(),
    _ConnectionsPage(),
    _YouPage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTabPressed(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF2E5BFF);
    const inactiveColor = Color(0xFF94A3B8);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: _pages[_selectedIndex],
      bottomNavigationBar: SizedBox(
        height: 118 + bottomInset,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                height: 82 + bottomInset,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 22,
              child: Center(
                child: Container(
                  width: 82,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _LabeledNavButton(
                    icon: Icons.auto_awesome,
                    label: 'MOMENTS',
                    selected: _selectedIndex == 0,
                    selectedColor: activeColor,
                    unselectedColor: inactiveColor,
                    onTap: () => _onTabPressed(0),
                  ),
                  _LabeledNavButton(
                    icon: Icons.favorite,
                    label: 'MATCHES',
                    selected: _selectedIndex == 1,
                    selectedColor: activeColor,
                    unselectedColor: inactiveColor,
                    onTap: () => _onTabPressed(1),
                  ),
                  const SizedBox(width: 76),
                  _LabeledNavButton(
                    icon: Icons.groups,
                    label: 'CONNECTIONS',
                    selected: _selectedIndex == 3,
                    selectedColor: activeColor,
                    unselectedColor: inactiveColor,
                    onTap: () => _onTabPressed(3),
                  ),
                  _LabeledNavButton(
                    icon: Icons.person,
                    label: 'YOU',
                    selected: _selectedIndex == 4,
                    selectedColor: activeColor,
                    unselectedColor: inactiveColor,
                    onTap: () => _onTabPressed(4),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: _CenterNavItem(
                  selected: _selectedIndex == 2,
                  onTap: () => _onTabPressed(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledNavButton extends StatelessWidget {
  const _LabeledNavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 74,
        height: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterNavItem extends StatelessWidget {
  const _CenterNavItem({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF2E5BFF), Color(0xFF5B2EFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4E43F5).withOpacity(selected ? 0.5 : 0.32),
              blurRadius: selected ? 22 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.wifi_tethering, color: Colors.white, size: 24),
      ),
    );
  }
}

class _MomentsPage extends StatelessWidget {
  const _MomentsPage();

  @override
  Widget build(BuildContext context) {
    return const _BlankTabPage(title: 'Moments Page');
  }
}

class _MatchesPage extends StatelessWidget {
  const _MatchesPage();

  @override
  Widget build(BuildContext context) {
    return const _BlankTabPage(title: 'Matches Page');
  }
}

class _DiscoverPage extends StatelessWidget {
  const _DiscoverPage();

  @override
  Widget build(BuildContext context) {
    return const _BlankTabPage(title: 'Discover Page');
  }
}

class _ConnectionsPage extends StatelessWidget {
  const _ConnectionsPage();

  @override
  Widget build(BuildContext context) {
    return const _BlankTabPage(title: 'Connections Page');
  }
}

class _YouPage extends StatefulWidget {
  const _YouPage();

  @override
  State<_YouPage> createState() => _YouPageState();
}

class _YouPageState extends State<_YouPage> {
  final TextEditingController _postController = TextEditingController();
  int _selectedProfileTab = 0;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _publishPost() async {
    final content = _postController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something before posting.')),
      );
      return;
    }

    final profileProvider = context.read<ProfileProvider>();
    final authorName = profileProvider.hasProfile
        ? profileProvider.fullName
        : 'CircleUp User';

    await context.read<PostProvider>().addPost(
          authorName: authorName,
          content: content,
        );

    _postController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post published.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileProvider, PostProvider>(
      builder: (context, profileProvider, postProvider, _) {
        if (!profileProvider.hasProfile) {
          return const Center(
            child: Text(
              'No Profile Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          );
        }

        final profile = profileProvider.profile!;
        final posts = postProvider.posts;
        const primaryBlue = Color(0xFF5B46FF);
        final roleIntent = profile.interests.isNotEmpty
          ? 'Currently: ${profile.interests.first}'
          : 'Currently: Networking';

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
          child: Column(
            children: [
              Row(
                children: const [
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  Icon(Icons.settings, color: Color(0xFF7C83A1), size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: profile.photoPath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.file(
                                File(profile.photoPath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person_outline,
                              size: 50,
                              color: Color(0xFFA5B4FC),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile.fullName,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.collegeOrProfession,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.age} • ${profile.gender} • ${profile.personality}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile.city,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetric('1.2k', 'CONNECTIONS'),
                        _buildMetric('84', 'MATCHES'),
                        _buildMetric('${posts.length}', 'POSTS'),
                        _buildMetric('12', 'MUTUAL'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF2F4FF), Color(0xFFE9F4FF)],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: primaryBlue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            roleIntent,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Looking for like-minded people nearby right now.',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.interests.map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5FB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      interest,
                      style: const TextStyle(
                        color: Color(0xFF545B7A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Share Profile',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _profileTabButton(
                        label: 'Posts',
                        icon: Icons.article_outlined,
                        selected: _selectedProfileTab == 0,
                        onTap: () => setState(() => _selectedProfileTab = 0),
                      ),
                    ),
                    Expanded(
                      child: _profileTabButton(
                        label: 'Grid',
                        icon: Icons.grid_view_rounded,
                        selected: _selectedProfileTab == 1,
                        onTap: () => setState(() => _selectedProfileTab = 1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (_selectedProfileTab == 0) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _postController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Share a new post with your Circle...',
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: _publishPost,
                          icon: const Icon(Icons.send_rounded),
                          label: const Text('Post'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (posts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'No posts yet. Create your first post.',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  )
                else
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFFE0E7FF),
                                  child: Text(
                                    post.authorName.characters.first,
                                    style: const TextStyle(
                                      color: Color(0xFF4338CA),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post.authorName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      Text(
                                        _timeAgo(post.createdAt),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('Connect'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              post.content,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.35,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ] else ...[
                if (posts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'No posts to show in grid yet.',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  )
                else
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _timeAgo(post.createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                post.content,
                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _profileTabButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4338CA) : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4338CA).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : const Color(0xFF4B5563),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF4B5563),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4338CA),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 0.5,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BlankTabPage extends StatelessWidget {
  const _BlankTabPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }
}