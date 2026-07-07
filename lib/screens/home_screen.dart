// lib/screens/home_screen.dart
//
// Chỉ còn: layout, state quản lý unreadCount + search + nav.
// Logic UI đã tách ra:
//   lib/widgets/app_mini_card.dart        ← AppMiniItem + AppMiniCard
//   lib/widgets/notification_badge.dart   ← NotificationBadge

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../services/notification_service.dart';
import '../widgets/app_mini_card.dart';
import '../widgets/notification_badge.dart';
import '../features/expense/presentation/expense_screen.dart';
import '../features/baocao/bao_cao_screen.dart';
import '../features/_shared/app_mini_base.dart';
import 'notification_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Services ─────────────────────────────────────────────────────────
  final _api = ApiClient.instance;
  final _auth = AuthService.instance;
  final _notifService = NotificationService();

  // ── State ─────────────────────────────────────────────────────────────
  final _searchCtrl = TextEditingController();
  int _navIndex = 0;
  String _search = '';
  int _unreadCount = 0;

  // ── Danh sách AppMini ─────────────────────────────────────────────────
  // AppMiniItem định nghĩa ở lib/widgets/app_mini_card.dart
  final List<AppMiniItem> _apps = const [
    AppMiniItem(
      name: 'Báo cáo',
      icon: Icons.bar_chart_rounded,
      color: Color(0xFF2563EB),
      screen: BaoCaoScreen(),
    ),
    AppMiniItem(
      name: 'Chi phí',
      icon: Icons.attach_money,
      color: Color(0xFF16A34A),
      screen: ExpenseScreen(),
    ),
    AppMiniItem(
      name: 'Ghi chú',
      icon: Icons.sticky_note_2,
      color: Color(0xFFD97706),
      screen: ComingSoonScreen(title: 'Ghi chú', color: Color(0xFFD97706)),
    ),
    AppMiniItem(
      name: 'QR Code',
      icon: Icons.qr_code_2,
      color: Color(0xFFDC2626),
      screen: ComingSoonScreen(title: 'QR Code', color: Color(0xFFDC2626)),
    ),
    AppMiniItem(
      name: 'Thời tiết',
      icon: Icons.cloud_outlined,
      color: Color(0xFF0891B2),
      screen: ComingSoonScreen(title: 'Thời tiết', color: Color(0xFF0891B2)),
    ),
    AppMiniItem(
      name: 'Cài đặt',
      icon: Icons.tune,
      color: Color(0xFF6366F1),
      screen: ComingSoonScreen(title: 'Cài đặt', color: Color(0xFF6366F1)),
    ),
    AppMiniItem(
      name: 'Nhiệm vụ',
      icon: Icons.task_alt,
      color: Color(0xFF059669),
      screen: ComingSoonScreen(title: 'Nhiệm vụ', color: Color(0xFF059669)),
    ),
    AppMiniItem(
      name: 'Phê duyệt',
      icon: Icons.approval_outlined,
      color: Color(0xFFEA580C),
      screen: ComingSoonScreen(title: 'Phê duyệt', color: Color(0xFFEA580C)),
    ),
    AppMiniItem(
      name: 'Tài liệu',
      icon: Icons.folder_open_outlined,
      color: Color(0xFF6366F1),
      screen: ComingSoonScreen(title: 'Tài liệu', color: Color(0xFF6366F1)),
    ),
  ];

  List<AppMiniItem> get _filtered => _search.isEmpty
      ? _apps
      : _apps
          .where((a) => a.name.toLowerCase().contains(_search.toLowerCase()))
          .toList();

  // ── Initials từ fullName ──────────────────────────────────────────────
  String get _initials {
    final name = _auth.fullName.trim();
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    return parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : name[0].toUpperCase();
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    _connectSignalR();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _notifService.disconnect();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────────────────
  Future<void> _loadUnreadCount() async {
    try {
      final res = await _api.get('/api/notification/unread-count');
      if (!mounted) return;
      setState(() => _unreadCount = (res['data'] as int?) ?? 0);
    } catch (_) {}
  }

  Future<void> _connectSignalR() async {
    _notifService.onNotification = (_) {
      if (!mounted) return;
      setState(() => _unreadCount++);
    };
    await _notifService.connect();
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _openNotifications() async {
    // Reset badge trước khi vào màn hình
    setState(() => _unreadCount = 0);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
    // Reload count khi quay lại (có thể user đọc một phần)
    _loadUnreadCount();
  }

  // ── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: IndexedStack(
        index: _navIndex,
        children: [
          SafeArea(
              child: Column(children: [
            _buildHeader(),
            _buildSearch(),
            Expanded(child: _buildGrid()),
          ])),
          SafeArea(
              child: Column(children: [
            _buildSearch(),
            Expanded(child: _buildGrid()),
          ])),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _navIndex,
      onTap: (i) => setState(() => _navIndex = i),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2563EB),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.apps_outlined), label: 'Apps'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Hồ sơ'),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined), label: 'Cài đặt'),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(children: [
        // Avatar initials
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF2563EB),
          child: Text(
            _initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Tên + lời chào
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Xin chào, ${_auth.fullName}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Text(
            'Chào mừng trở lại!',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ]),
        const Spacer(),
        // ── NotificationBadge — widget tách ra ───────────────────────
        NotificationBadge(
          count: _unreadCount,
          onTap: _openNotifications,
        ),
        // Logout
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.red),
          onPressed: _logout,
          tooltip: 'Đăng xuất',
        ),
      ]),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────
  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _search = v),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm ứng dụng...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _search.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _search = '');
                  })
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ── Grid AppMini ──────────────────────────────────────────────────────
  Widget _buildGrid() {
    final apps = _filtered;

    if (apps.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.search_off, size: 52, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'Không tìm thấy ứng dụng',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ]),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Ứng dụng',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: apps.length,
            // ── AppMiniCard — widget tách ra ──────────────────────────
            itemBuilder: (context, i) => AppMiniCard(
              item: apps[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => apps[i].screen),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
