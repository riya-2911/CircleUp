import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/live_user_model.dart';
import '../../models/user_post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connections_provider.dart';
import '../../providers/intent_provider.dart';
import '../../providers/live_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/profile_provider.dart';
import 'intenselectionpage.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 4);
    
    // Initialize providers asynchronously without blocking UI
    Future.microtask(() async {
      if (!mounted) return;
      try {
        context.read<AuthProvider>().checkLoginStatus();
        context.read<IntentProvider>().loadSavedIntent();
        context.read<ProfileProvider>().loadProfile();
        context.read<PostProvider>().loadPosts();
        context.read<LiveProvider>().startRealtime();
      } catch (e) {
        debugPrint('Provider initialization error: $e');
      }
    });
  }

  void _openConnectionsTab() {
    if (!mounted) return;
    setState(() => _selectedIndex = 3);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _FeedPage(),
      const _MatchesPage(),
      _DiscoverPage(onOpenConnections: _openConnectionsTab),
      const _ConnectionsPage(),
      const _ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Matches'),
          NavigationDestination(icon: Icon(Icons.public), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Connections'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _FeedPage extends StatefulWidget {
  const _FeedPage();

  @override
  State<_FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<_FeedPage> {
  final TextEditingController _postController = TextEditingController();

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _submitPost(BuildContext context) async {
    final content = _postController.text.trim();
    if (content.isEmpty) return;

    final profileProvider = context.read<ProfileProvider>();
    final postProvider = context.read<PostProvider>();
    final profile = profileProvider.profile;
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete profile first.')),
      );
      return;
    }

    await postProvider.addPost(
      userId: profile.userId,
      authorName: profile.fullName,
      content: content,
    );

    if (!mounted) return;
    _postController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PostProvider, ProfileProvider>(
      builder: (context, postProvider, profileProvider, _) {
        final currentUserId = profileProvider.profile?.userId ?? '';
        final posts = postProvider.posts;

        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Row(
                  children: [
                    const Text(
                      'Circle Feed',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const IntentSelectionPage()),
                        );
                      },
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _postController,
                        decoration: InputDecoration(
                          hintText: 'Share what\'s happening...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        minLines: 1,
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () => _submitPost(context),
                      child: const Text('Post'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: posts.isEmpty
                    ? const Center(
                        child: Text(
                          'No posts yet. Share your first update.',
                          style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                        itemCount: posts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return _PostCard(post: post, currentUserId: currentUserId);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.currentUserId});

  final UserPostModel post;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final postProvider = context.read<PostProvider>();
    final isLikedByCurrentUser = post.isLikedBy(currentUserId);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatPostDateTime(post.createdAt),
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.content, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: currentUserId.isEmpty
                    ? null
                    : () => postProvider.toggleLike(post.id, currentUserId),
                icon: Icon(
                  isLikedByCurrentUser ? Icons.favorite : Icons.favorite_border,
                  color: isLikedByCurrentUser ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
                ),
                label: Text('${post.likesCount}'),
              ),
              TextButton.icon(
                onPressed: () => postProvider.toggleComment(post.id),
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text('${post.commentsCount}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPostDateTime(DateTime time) {
    const monthNames = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = time.day.toString().padLeft(2, '0');
    final month = monthNames[time.month - 1];
    final year = time.year;
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$day $month $year - $hour12:$minute $period';
  }
}

class _MatchesPage extends StatelessWidget {
  const _MatchesPage();

  int _calculateMatchScore(List<String> myTags, List<String> theirTags) {
    if (myTags.isEmpty || theirTags.isEmpty) return 65;
    final overlap = myTags.toSet().intersection(theirTags.toSet()).length;
    final percentage = (overlap / theirTags.length * 100).round();
    return percentage.clamp(50, 99);
  }

  String _getIntentTag(List<String> tags) {
    if (tags.isEmpty) return 'Network';
    final tag = tags.first.toLowerCase();
    if (tag.contains('startup')) return 'STARTUP';
    if (tag.contains('study')) return 'STUDY';
    if (tag.contains('fitness')) return 'FITNESS';
    if (tag.contains('food')) return 'FOOD';
    if (tag.contains('hobby')) return 'HOBBY';
    return 'Network';
  }

  Color _getIntentColor(String tag) {
    switch (tag) {
      case 'STARTUP':
        return const Color(0xFF7C3AED);
      case 'STUDY':
        return const Color(0xFF3B82F6);
      case 'FITNESS':
        return const Color(0xFF10B981);
      case 'FOOD':
        return const Color(0xFFF59E0B);
      case 'HOBBY':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileProvider, ConnectionsProvider>(
      builder: (context, profileProvider, connectionsProvider, _) {
        if (!profileProvider.hasProfile) {
          return const Center(child: Text('Complete profile first'));
        }

        final profile = profileProvider.profile!;
        connectionsProvider.ensureForUser(
          userId: profile.userId,
          userName: profile.fullName,
        );

        final requests = connectionsProvider.incomingRequests;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Matches',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 16),
                if (requests.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No pending requests.',
                        style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                else
                  ...List.generate(requests.length, (index) {
                    final req = requests[index];
                    final matchScore = _calculateMatchScore(profile.interests, req.senderTags);
                    final intentTag = _getIntentTag(req.senderTags);
                    final intentColor = _getIntentColor(intentTag);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with profile and intent tag
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  child: Text(
                                    req.senderName.isEmpty
                                        ? '?'
                                        : req.senderName[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        req.senderName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '✓ ${req.senderAge}km away',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: intentColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    intentTag,
                                    style: TextStyle(
                                      color: intentColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Match score
                            Row(
                              children: [
                                Text(
                                  '$matchScore%',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'MATCH SCORE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0x1010B981),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.check_circle, size: 12, color: Color(0xFF10B981)),
                                      SizedBox(width: 4),
                                      Text(
                                        'Same Intent',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Message
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '"${req.senderTags.join(', ')}"',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => connectionsProvider.rejectRequest(req),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF3F4F6),
                                      foregroundColor: const Color(0xFF374151),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text(
                                      'Decline',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => connectionsProvider.acceptRequest(req),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text(
                                      'Accept Request',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DiscoverPage extends StatefulWidget {
  const _DiscoverPage({required this.onOpenConnections});

  final VoidCallback onOpenConnections;

  @override
  State<_DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<_DiscoverPage> {
  String? _selectedUserId;
  GoogleMapController? _mapController;
  bool _cameraAligned = false;
  int _lastFocusedUserCount = 0;

  static const CameraPosition _defaultCamera = CameraPosition(
    target: LatLng(19.0760, 72.8777),
    zoom: 12,
  );

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  int _matchPercent(LiveUserModel user, ProfileProvider profileProvider) {
    final myInterests = profileProvider.interests.map((e) => e.toLowerCase().trim()).toSet();
    final userTags = user.tags.map((e) => e.toLowerCase().trim()).toSet();
    if (myInterests.isEmpty || userTags.isEmpty) {
      return 72;
    }
    final overlap = myInterests.intersection(userTags).length;
    final ratio = overlap / userTags.length;
    return (70 + (ratio * 30)).round().clamp(70, 96);
  }

  Future<void> _focusCameraOnUsers({
    required List<LiveUserModel> users,
    required double? myLat,
    required double? myLng,
  }) async {
    if (_mapController == null || users.isEmpty) return;

    if (users.length == 1) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(users.first.latitude, users.first.longitude), 16),
      );
      return;
    }

    var minLat = users.first.latitude;
    var maxLat = users.first.latitude;
    var minLng = users.first.longitude;
    var maxLng = users.first.longitude;

    for (final user in users.skip(1)) {
      if (user.latitude < minLat) minLat = user.latitude;
      if (user.latitude > maxLat) maxLat = user.latitude;
      if (user.longitude < minLng) minLng = user.longitude;
      if (user.longitude > maxLng) maxLng = user.longitude;
    }

    if (myLat != null && myLng != null) {
      if (myLat < minLat) minLat = myLat;
      if (myLat > maxLat) maxLat = myLat;
      if (myLng < minLng) minLng = myLng;
      if (myLng > maxLng) maxLng = myLng;
    }

    const pad = 0.005;
    final bounds = LatLngBounds(
      southwest: LatLng(minLat - pad, minLng - pad),
      northeast: LatLng(maxLat + pad, maxLng + pad),
    );

    await _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LiveProvider, ProfileProvider>(
      builder: (context, liveProvider, profileProvider, _) {
        const nearbyRadiusKm = 25.0;
        final allUsers = liveProvider.allUsers;
        final myUserId = profileProvider.profile?.userId;

        final myLat = liveProvider.myLatitude;
        final myLng = liveProvider.myLongitude;
        final hasMyLocation = myLat != null && myLng != null;

        final nearbyUsers = hasMyLocation
            ? allUsers.where((user) {
                if (myUserId != null && user.userId == myUserId) return true;
                final distanceMeters = Geolocator.distanceBetween(
                  myLat!,
                  myLng!,
                  user.latitude,
                  user.longitude,
                );
                return distanceMeters <= nearbyRadiusKm * 1000;
              }).toList()
            : <LiveUserModel>[];

        final users = allUsers;
        final cameraTargetUsers = nearbyUsers.isNotEmpty ? nearbyUsers : users;

        LiveUserModel? selectedUser;
        for (final user in users) {
          if (user.userId == _selectedUserId) {
            selectedUser = user;
            break;
          }
        }

        final markers = users
            .map(
              (user) => Marker(
                markerId: MarkerId(user.userId),
                position: LatLng(user.latitude, user.longitude),
                consumeTapEvents: true,
                infoWindow: InfoWindow.noText,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  (myUserId != null && user.userId == myUserId)
                      ? BitmapDescriptor.hueAzure
                      : BitmapDescriptor.hueRed,
                ),
                onTap: () => setState(() => _selectedUserId = user.userId),
              ),
            )
            .toSet();

        final circles = users
            .map(
              (user) {
                final isSelf = myUserId != null && user.userId == myUserId;
                final color = isSelf ? const Color(0xFF2E5BFF) : const Color(0xFFEF4444);
                return Circle(
                  circleId: CircleId('dot_${user.userId}'),
                  center: LatLng(user.latitude, user.longitude),
                  radius: isSelf ? 36 : 26,
                  fillColor: color.withOpacity(0.32),
                  strokeColor: color,
                  strokeWidth: isSelf ? 4 : 3,
                );
              },
            )
            .toSet();

        if (_mapController != null &&
            cameraTargetUsers.isNotEmpty &&
            (!_cameraAligned || _lastFocusedUserCount != cameraTargetUsers.length)) {
          _cameraAligned = true;
          _lastFocusedUserCount = cameraTargetUsers.length;
          _focusCameraOnUsers(users: cameraTargetUsers, myLat: myLat, myLng: myLng);
        }

        return SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: selectedUser != null ? () => setState(() => _selectedUserId = null) : null,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF2E5BFF),
                        child: Icon(Icons.hub_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'CircleUp',
                        style: TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.notifications, color: Color(0xFF6B7280)),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_alt_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${nearbyUsers.length} nearby - ${users.length} total users',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 96),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: users.isEmpty
                                ? const ColoredBox(
                                    color: Color(0xFFE5E7EB),
                                    child: Center(
                                      child: Text(
                                        'No user location found yet.\nAsk users to allow location and go live.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFF4B5563),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                : GoogleMap(
                                    initialCameraPosition: _defaultCamera,
                                    mapType: MapType.normal,
                                    myLocationEnabled: hasMyLocation,
                                    myLocationButtonEnabled: true,
                                    zoomControlsEnabled: true,
                                    markers: markers,
                                    circles: circles,
                                    onTap: (_) {
                                      if (_selectedUserId != null) {
                                        setState(() => _selectedUserId = null);
                                      }
                                    },
                                    onMapCreated: (controller) {
                                      _mapController = controller;
                                      if (cameraTargetUsers.isNotEmpty) {
                                        _cameraAligned = true;
                                        _lastFocusedUserCount = cameraTargetUsers.length;
                                        _focusCameraOnUsers(
                                          users: cameraTargetUsers,
                                          myLat: myLat,
                                          myLng: myLng,
                                        );
                                      } else if (!_cameraAligned && hasMyLocation) {
                                        _cameraAligned = true;
                                        controller.animateCamera(
                                          CameraUpdate.newLatLngZoom(LatLng(myLat, myLng), 14),
                                        );
                                      }
                                    },
                                  ),
                          ),
                        ),
                      ),
                      if (selectedUser != null)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 98,
                          child: _LiveMatchCard(
                            user: selectedUser,
                            isSelf: myUserId != null && myUserId == selectedUser.userId,
                            matchPercent: _matchPercent(selectedUser, profileProvider),
                            onClose: () => setState(() => _selectedUserId = null),
                            onConnect: () async {
                              final targetUser = selectedUser;
                              if (targetUser == null) return;
                              if (!profileProvider.hasProfile) return;
                              final profile = profileProvider.profile!;
                              final ok = await context.read<ConnectionsProvider>().sendConnectionRequest(
                                    senderId: profile.userId,
                                    senderName: profile.fullName,
                                    senderAge: profile.age,
                                    senderTags: profile.interests,
                                    target: targetUser,
                                  );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok ? 'Connection request sent.' : 'Unable to send request.'),
                                ),
                              );
                              if (ok) {
                                setState(() => _selectedUserId = null);
                                widget.onOpenConnections();
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LiveMatchCard extends StatelessWidget {
  const _LiveMatchCard({
    required this.user,
    required this.isSelf,
    required this.matchPercent,
    required this.onConnect,
    required this.onClose,
  });

  final LiveUserModel user;
  final bool isSelf;
  final int matchPercent;
  final VoidCallback onConnect;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFDBEAFE),
                  child: Text(
                    user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.name}, ${user.age}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user.intent} - ${user.distanceKm.toStringAsFixed(1)} km away',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(tag, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$matchPercent% match',
                    style: const TextStyle(
                      color: Color(0xFF0369A1),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: isSelf ? null : onConnect,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: Text(isSelf ? 'You' : 'Connect'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionsPage extends StatefulWidget {
  const _ConnectionsPage();

  @override
  State<_ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<_ConnectionsPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileProvider, ConnectionsProvider>(
      builder: (context, profileProvider, connectionsProvider, _) {
        if (!profileProvider.hasProfile) {
          return const Center(child: Text('Complete profile first'));
        }

        final profile = profileProvider.profile!;
        connectionsProvider.ensureForUser(
          userId: profile.userId,
          userName: profile.fullName,
        );

        final requests = connectionsProvider.incomingRequests;
        final chats = connectionsProvider.connections;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Connections',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: [
                    ButtonSegment<int>(
                      value: 0,
                      label: Text('Requests (${requests.length})'),
                      icon: const Icon(Icons.inbox_outlined),
                    ),
                    ButtonSegment<int>(
                      value: 1,
                      label: Text('Chats (${chats.length})'),
                      icon: const Icon(Icons.chat_bubble_outline),
                    ),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (set) => setState(() => _tab = set.first),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: _tab == 0
                      ? _RequestsList(requests: requests)
                      : _ChatsList(chats: chats, currentUserId: profile.userId),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RequestsList extends StatelessWidget {
  const _RequestsList({required this.requests});

  final List<ConnectionRequestItem> requests;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ConnectionsProvider>();

    if (requests.isEmpty) {
      return const Center(
        child: Text(
          'No pending requests.',
          style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
        ),
      );
    }

    return ListView.separated(
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final request = requests[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${request.senderName}, ${request.senderAge}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: request.senderTags
                    .map((tag) => Chip(label: Text(tag), visualDensity: VisualDensity.compact))
                    .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => provider.rejectRequest(request),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => provider.acceptRequest(request),
                    child: const Text('Accept'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatsList extends StatelessWidget {
  const _ChatsList({required this.chats, required this.currentUserId});

  final List<ConnectionItem> chats;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    if (chats.isEmpty) {
      return const Center(
        child: Text(
          'No active chats yet.',
          style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
        ),
      );
    }

    return ListView.separated(
      itemCount: chats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final chat = chats[index];
        final partnerName = chat.partnerNameFor(currentUserId);
        return ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(partnerName, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(
            chat.lastMessage.isEmpty ? 'Start chatting' : chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _ConnectionChatScreen(
                  connection: chat,
                  currentUserId: currentUserId,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ConnectionChatScreen extends StatefulWidget {
  const _ConnectionChatScreen({
    required this.connection,
    required this.currentUserId,
  });

  final ConnectionItem connection;
  final String currentUserId;

  @override
  State<_ConnectionChatScreen> createState() => _ConnectionChatScreenState();
}

class _ConnectionChatScreenState extends State<_ConnectionChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partnerName = widget.connection.partnerNameFor(widget.currentUserId);
    final stream = FirebaseFirestore.instance
        .collection('connections')
        .doc(widget.connection.id)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: Text(partnerName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? const [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet.',
                      style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final senderId = (data['senderId'] as String?) ?? '';
                    final text = (data['text'] as String?) ?? '';
                    final mine = senderId == widget.currentUserId;
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: mine ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(color: mine ? Colors.white : const Color(0xFF111827)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      final text = _controller.text.trim();
                      if (text.isEmpty) return;
                      await context.read<ConnectionsProvider>().sendMessage(
                            connectionId: widget.connection.id,
                            senderId: widget.currentUserId,
                            text: text,
                          );
                      if (!mounted) return;
                      _controller.clear();
                    },
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ProfileContentSection { posts, grid }

class _ProfilePage extends StatefulWidget {
  const _ProfilePage();

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  _ProfileContentSection _section = _ProfileContentSection.posts;
  final TextEditingController _profilePostController = TextEditingController();

  @override
  void dispose() {
    _profilePostController.dispose();
    super.dispose();
  }

  Future<void> _submitProfilePost({
    required BuildContext context,
    required String userId,
    required String authorName,
  }) async {
    final content = _profilePostController.text.trim();
    if (content.isEmpty) return;

    await context.read<PostProvider>().addPost(
          userId: userId,
          authorName: authorName,
          content: content,
        );

    if (!mounted) return;
    _profilePostController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProfileProvider, ConnectionsProvider, PostProvider>(
      builder: (context, profileProvider, connectionsProvider, postProvider, _) {
        if (!profileProvider.hasProfile) {
          return const Center(child: Text('Complete profile first'));
        }

        final profile = profileProvider.profile!;
        final myPosts = postProvider.postsByUser(profile.userId);
        connectionsProvider.ensureForUser(
          userId: profile.userId,
          userName: profile.fullName,
        );

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _ProfileAvatar(photoPath: profile.photoPath, name: profile.fullName),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.fullName,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text('${profile.age} - ${profile.city}'),
                            const SizedBox(height: 4),
                            Text(profile.collegeOrProfession),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people_alt_rounded),
                      const SizedBox(width: 10),
                      Text(
                        'Connections: ${connectionsProvider.connectionCount}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.interests.map((interest) => Chip(label: Text(interest))).toList(),
                ),
                const SizedBox(height: 16),
                SegmentedButton<_ProfileContentSection>(
                  segments: const [
                    ButtonSegment<_ProfileContentSection>(
                      value: _ProfileContentSection.posts,
                      icon: Icon(Icons.view_agenda_outlined),
                      label: Text('Posts'),
                    ),
                    ButtonSegment<_ProfileContentSection>(
                      value: _ProfileContentSection.grid,
                      icon: Icon(Icons.grid_view_rounded),
                      label: Text('Grid'),
                    ),
                  ],
                  selected: {_section},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _section = selection.first;
                    });
                  },
                ),
                const SizedBox(height: 14),
                if (_section == _ProfileContentSection.posts)
                  _ProfilePostsSection(
                    posts: myPosts,
                    currentUserId: profile.userId,
                    postController: _profilePostController,
                    onPost: () => _submitProfilePost(
                      context: context,
                      userId: profile.userId,
                      authorName: profile.fullName,
                    ),
                  )
                else
                  _ProfileGridSection(
                    posts: myPosts,
                    currentUserId: profile.userId,
                    postProvider: postProvider,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfilePostsSection extends StatelessWidget {
  const _ProfilePostsSection({
    required this.posts,
    required this.currentUserId,
    required this.postController,
    required this.onPost,
  });

  final List<UserPostModel> posts;
  final String currentUserId;
  final TextEditingController postController;
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    final postWidgets = <Widget>[];
    for (var i = 0; i < posts.length; i++) {
      postWidgets.add(_PostCard(post: posts[i], currentUserId: currentUserId));
      if (i != posts.length - 1) {
        postWidgets.add(const SizedBox(height: 12));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: postController,
                decoration: InputDecoration(
                  hintText: 'Share what\'s on your mind...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                minLines: 1,
                maxLines: 3,
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: onPost,
              child: const Text('Post'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (posts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No posts yet.',
                style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
              ),
            ),
          )
        else
          ...postWidgets,
      ],
    );
  }
}

class _ProfileGridSection extends StatelessWidget {
  const _ProfileGridSection({
    required this.posts,
    required this.currentUserId,
    required this.postProvider,
  });

  final List<UserPostModel> posts;
  final String currentUserId;
  final PostProvider postProvider;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No grid items yet.',
            style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.96,
      ),
      itemBuilder: (context, index) => _ProfileGridTile(
        post: posts[index],
        onDelete: () => postProvider.deletePost(posts[index].id),
      ),
    );
  }
}

class _ProfileGridTile extends StatelessWidget {
  const _ProfileGridTile({
    required this.post,
    required this.onDelete,
  });

  final UserPostModel post;
  final VoidCallback onDelete;

  String _formatPostDateTime(DateTime time) {
    const monthNames = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = time.day.toString().padLeft(2, '0');
    final month = monthNames[time.month - 1];
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$day $month - $hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with author and delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatPostDateTime(post.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Post content
          Expanded(
            child: Text(
              post.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Engagement stats
          Row(
            children: [
              const Icon(Icons.favorite_border, size: 14, color: Color(0xFF6B7280)),
              const SizedBox(width: 3),
              Text(
                '${post.likesCount}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chat_bubble_outline, size: 14, color: Color(0xFF6B7280)),
              const SizedBox(width: 3),
              Text(
                '${post.commentsCount}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photoPath, required this.name});

  final String? photoPath;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (photoPath != null && photoPath!.isNotEmpty) {
      final file = File(photoPath!);
      if (file.existsSync()) {
        return CircleAvatar(radius: 34, backgroundImage: FileImage(file));
      }
    }
    return CircleAvatar(
      radius: 34,
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
