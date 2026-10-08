import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../models/request_model.dart';

class BloodRequestCard extends StatelessWidget {
  final BloodRequestModel request;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final bool isMyRequest;
  final ValueChanged<String>? onStatusChanged;

  const BloodRequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.margin,
    this.isMyRequest = false,
    this.onStatusChanged,
  });

  Future<void> _callRequester(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color urgencyColor;
    Color urgencyBg;
    if (request.urgency == 'Critical') {
      urgencyColor = AppColors.criticalUrgency;
      urgencyBg = const Color(0xFFFFEBEE);
    } else if (request.urgency == 'Urgent') {
      urgencyColor = AppColors.highUrgency;
      urgencyBg = const Color(0xFFFFF3E0);
    } else {
      urgencyColor = AppColors.standardUrgency;
      urgencyBg = const Color(0xFFE1F5FE);
    }

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: request.isCritical && request.isActive
              ? AppColors.criticalUrgency.withValues(alpha: 0.35)
              : AppColors.cardBorder,
          width: request.isCritical && request.isActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (request.isCritical ? Colors.red : Colors.black).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Blood group, Units, Urgency tag & Status tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              request.bloodGroup,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${request.requiredUnits} Unit(s) Needed',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: urgencyBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            request.urgency.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: urgencyColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (isMyRequest || !request.isActive) ...[
                          const SizedBox(width: 6),
                          _buildStatusBadge(request.status),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Patient: ${request.patientName}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.local_hospital_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${request.hospitalName}, ${request.hospitalAddress}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (request.description != null && request.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    request.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${request.area}, ${request.district}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMyRequest) ...[
                      const SizedBox(width: 8),
                      _buildMyRequestActions(context),
                    ] else if (request.requesterMobile != null && request.requesterMobile!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _callRequester(request.requesterMobile),
                        icon: const Icon(Icons.phone, size: 14, color: AppColors.primary),
                        label: const Text(
                          'Contact Family',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status) {
      case 'Fulfilled':
        bg = const Color(0xFFE0F2F1);
        fg = const Color(0xFF00796B);
        icon = Icons.check_circle_outline;
        break;
      case 'Cancelled':
        bg = const Color(0xFFEEEEEE);
        fg = const Color(0xFF757575);
        icon = Icons.cancel_outlined;
        break;
      case 'Active':
      default:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        icon = Icons.radio_button_checked;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 3),
          Text(
            status.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRequestActions(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Update Request Status',
      onSelected: (val) {
        if (onStatusChanged != null) {
          onStatusChanged!(val);
        }
      },
      itemBuilder: (ctx) => [
        if (request.status != 'Fulfilled')
          const PopupMenuItem(
            value: 'Fulfilled',
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF00796B), size: 18),
                SizedBox(width: 8),
                Text('Mark as Fulfilled', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        if (request.status != 'Cancelled')
          const PopupMenuItem(
            value: 'Cancelled',
            child: Row(
              children: [
                Icon(Icons.cancel, color: Colors.grey, size: 18),
                SizedBox(width: 8),
                Text('Cancel Request', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        if (request.status != 'Active')
          const PopupMenuItem(
            value: 'Active',
            child: Row(
              children: [
                Icon(Icons.refresh, color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Text('Reopen as Active', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_note, size: 16, color: AppColors.primary),
            SizedBox(width: 4),
            Text(
              'Update Status',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
