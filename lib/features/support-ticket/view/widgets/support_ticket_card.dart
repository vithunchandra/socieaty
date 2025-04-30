import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/support-ticket/enum/support_ticket_status_enum.dart';
import 'package:socieaty/features/support-ticket/model/support_ticket.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';

class SupportTicketCard extends ConsumerWidget {
  final SupportTicket ticket;
  final VoidCallback? onTap;

  const SupportTicketCard({
    super.key,
    required this.ticket,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    final currentUser = ref.watch(authLocalRepositoryProvider).getUserData();
    final isCurrentUserTicket = currentUser?.id == ticket.user.id;

    return Card(
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      ticket.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(ticket.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ticket.description,
                style: TextStyle(
                  color: AppPallete.neutralColor.shade600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (!isCurrentUserTicket)
                        ProfilePictureWidget(
                          user: ticket.user,
                          radius: 14,
                        ),
                      if (!isCurrentUserTicket) const SizedBox(width: 8),
                      if (!isCurrentUserTicket)
                        Text(
                          ticket.user.name,
                          style: TextStyle(
                            color: AppPallete.neutralColor.shade700,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    '${dateFormat.format(ticket.createdAt)} pada ${timeFormat.format(ticket.createdAt)}',
                    style: TextStyle(
                      color: AppPallete.neutralColor.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(SupportTicketStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case SupportTicketStatus.open:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = 'Terbuka';
      case SupportTicketStatus.closed:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        label = 'Ditutup';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
