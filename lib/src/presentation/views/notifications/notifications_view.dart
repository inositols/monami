import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monami/src/data/remote/notification_service.dart';
import 'package:monami/src/models/notification_model.dart';
import 'package:monami/src/utils/router/locator.dart';
import 'package:monami/src/handlers/handlers.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView>
    with TickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  final _navigationService = locator<NavigationService>();
  final _snackbarHandler = locator<SnackbarHandler>();

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadNotifications();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  Future<void> _loadNotifications() async {
    try {
      print('DEBUG: NotificationsView - Starting to load notifications');
      
      final notifications = await _notificationService.getUserNotifications();
      print('DEBUG: NotificationsView - Retrieved ${notifications.length} notifications');
      
      final unreadCount = await _notificationService.getUnreadCount();
      print('DEBUG: NotificationsView - Unread count: $unreadCount');
      
      setState(() {
        _notifications = notifications;
        _unreadCount = unreadCount;
        _isLoading = false;
      });
      
      print('DEBUG: NotificationsView - State updated with ${_notifications.length} notifications');
    } catch (e) {
      print('DEBUG: NotificationsView - Error loading notifications: $e');
      setState(() {
        _isLoading = false;
      });
      _snackbarHandler.showErrorSnackbar('Error loading notifications');
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isRead) {
      await _notificationService.markAsRead(notification.id);
      await _loadNotifications();
    }
  }

  Future<void> _markAllAsRead() async {
    await _notificationService.markAllAsRead();
    await _loadNotifications();
    _snackbarHandler.showSnackbar('All notifications marked as read');
  }

  Future<void> _clearAllNotifications() async {
    await _notificationService.clearAllNotifications();
    await _loadNotifications();
    _snackbarHandler.showSnackbar('All notifications cleared');
  }

  Future<void> _sendTestNotification() async {
    await _notificationService.sendTestNotification();
    await _loadNotifications();
    _snackbarHandler.showSnackbar('Test notification sent!');
  }

  Future<void> _debugCheckNotifications() async {
    await _notificationService.debugCheckAllNotifications();
    await _loadNotifications();
    _snackbarHandler.showSnackbar('Debug check completed - check console');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A202C),
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF667EEA),
                ),
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'test_notification':
                  _sendTestNotification();
                  break;
                case 'debug_check':
                  _debugCheckNotifications();
                  break;
                case 'clear_all':
                  _clearAllNotifications();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'test_notification',
                child: Text('Send test notification'),
              ),
              const PopupMenuItem(
                value: 'debug_check',
                child: Text('Debug check notifications'),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear all notifications'),
              ),
            ],
            child: const Icon(
              Icons.more_vert,
              color: Color(0xFF4A5568),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : _buildNotificationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 60,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications Yet',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll receive notifications when someone\nlikes, reviews, or purchases your products',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notification = _notifications[index];
              return _buildNotificationItem(notification, index);
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(NotificationModel notification, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delay = index * 0.1;
        final animationValue = Curves.easeOut.transform(
          ((_animationController.value - delay).clamp(0.0, 1.0) / (1.0 - delay))
              .clamp(0.0, 1.0),
        );

        return Transform.translate(
          offset: Offset(0, 30 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: notification.isRead ? Colors.white : const Color(0xFF667EEA).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: notification.isRead 
                    ? Border.all(color: const Color(0xFFE2E8F0))
                    : Border.all(color: const Color(0xFF667EEA).withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _markAsRead(notification),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Notification Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _getNotificationColor(notification.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getNotificationIcon(notification.type),
                            color: _getNotificationColor(notification.type),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Notification Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.title,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: notification.isRead 
                                            ? FontWeight.w600 
                                            : FontWeight.w700,
                                        color: const Color(0xFF1A202C),
                                      ),
                                    ),
                                  ),
                                  if (!notification.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF667EEA),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification.body,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF4A5568),
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: const Color(0xFFA0AEC0),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTime(notification.createdAt),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFFA0AEC0),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _getNotificationTypeLabel(notification.type),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getNotificationColor(notification.type),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Colors.red;
      case NotificationType.review:
        return Colors.orange;
      case NotificationType.purchase:
        return Colors.green;
      case NotificationType.general:
        return const Color(0xFF667EEA);
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.review:
        return Icons.star;
      case NotificationType.purchase:
        return Icons.shopping_cart;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  String _getNotificationTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return 'Like';
      case NotificationType.review:
        return 'Review';
      case NotificationType.purchase:
        return 'Sale';
      case NotificationType.general:
        return 'General';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}