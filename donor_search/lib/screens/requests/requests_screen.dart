import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../components/blood_request_card.dart';
import '../../models/request_model.dart';
import '../../services/api_service.dart';
import 'create_request_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BloodRequestModel> _allRequests = [];
  List<BloodRequestModel> _myRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final allRes = await ApiService.getRequests(status: 'Active');
    final myRes = await ApiService.getRequests(myRequests: true);

    if (!mounted) return;
    setState(() {
      _allRequests = allRes.data ?? [];
      _myRequests = myRes.data ?? [];
      _isLoading = false;
    });
  }

  Future<void> _handleStatusUpdate(BloodRequestModel req, String newStatus) async {
    final res = await ApiService.updateRequestStatus(
      requestId: req.id,
      status: newStatus,
    );

    if (!mounted) return;

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: AppColors.availableGreen,
        ),
      );
      _loadRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Blood Requests',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Requests',
            onPressed: _loadRequests,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: [
            Tab(text: 'Active Requests (${_allRequests.length})'),
            Tab(text: 'My Requests (${_myRequests.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
          );
          if (created == true) {
            await _loadRequests();
            // Automatically switch to My Requests tab to see the newly posted request
            _tabController.animateTo(1);
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Request',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRequestList(
                  _allRequests,
                  'No active blood requests at this moment.',
                  isMyList: false,
                ),
                _buildRequestList(
                  _myRequests,
                  'You have not posted any blood requests yet.\nTap "+ Create Request" below to post one.',
                  isMyList: true,
                ),
              ],
            ),
    );
  }

  Widget _buildRequestList(List<BloodRequestModel> list, String emptyMsg, {required bool isMyList}) {
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadRequests,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 54, color: Colors.grey.shade400),
                const SizedBox(height: 14),
                Text(
                  emptyMsg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final req = list[index];
          return BloodRequestCard(
            request: req,
            isMyRequest: isMyList,
            onStatusChanged: isMyList
                ? (newStatus) => _handleStatusUpdate(req, newStatus)
                : null,
          );
        },
      ),
    );
  }
}
