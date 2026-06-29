// lib/features/_shared/pagination_mixin.dart
import 'package:flutter/material.dart';
import '../../services/api_client.dart'; // ← ApiClient thay cho ApiService

mixin ExpensePaginationMixin<T extends StatefulWidget> on State<T> {
  final ApiClient _api = ApiClient.instance;
  final ScrollController scrollCtrl = ScrollController();

  List<dynamic> items = [];
  bool loading = true;
  bool loadingMore = false;
  bool hasMore = true;
  int currentPage = 1;
  static const int pageSize = 20;

  String get apiEndpoint;
  Map<String, dynamic> extraParams() => {};

  void initPagination() {
    scrollCtrl.addListener(_onScroll);
    loadFirstPage();
  }

  void disposePagination() {
    scrollCtrl.dispose();
  }

  void _onScroll() {
    if (!scrollCtrl.hasClients) return;
    final max = scrollCtrl.position.maxScrollExtent;
    final current = scrollCtrl.position.pixels;
    if (current >= max * 0.8 && !loadingMore && hasMore) loadMore();
  }

  Future<void> loadFirstPage() async {
    setState(() {
      loading = true;
      currentPage = 1;
      hasMore = true;
      items = [];
    });
    try {
      final res = await _api.get(apiEndpoint, params: {
        'PageIndex': 1,
        'PageSize': pageSize,
        ...extraParams(),
      });
      if (!mounted) return;
      final data = res['data'];
      final newItems = data['items'] as List? ?? [];
      final totalCount = data['totalCount'] as int? ?? 0;
      setState(() {
        items = newItems;
        loading = false;
        hasMore = items.length < totalCount;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> loadMore() async {
    if (loadingMore || !hasMore) return;
    setState(() => loadingMore = true);
    try {
      final nextPage = currentPage + 1;
      final res = await _api.get(apiEndpoint, params: {
        'PageIndex': nextPage,
        'PageSize': pageSize,
        ...extraParams(),
      });
      if (!mounted) return;
      final data = res['data'];
      final newItems = data['items'] as List? ?? [];
      final totalCount = data['totalCount'] as int? ?? 0;
      setState(() {
        currentPage = nextPage;
        items.addAll(newItems);
        hasMore = items.length < totalCount;
        loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loadingMore = false);
    }
  }

  Widget buildPaginationFooter(Color color) {
    if (loadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
            child: CircularProgressIndicator(color: color, strokeWidth: 2)),
      );
    }
    if (!hasMore && items.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Đã hiển thị tất cả ${items.length} phiếu',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
