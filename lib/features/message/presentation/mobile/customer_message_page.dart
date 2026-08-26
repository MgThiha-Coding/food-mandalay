/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';

class OrderEventModel {
  final String orderId;
  final String eventMessage;
  final DateTime createdAt;

  OrderEventModel({
    required this.orderId,
    required this.eventMessage,
    required this.createdAt,
  });

  factory OrderEventModel.fromMap(Map<String, dynamic> map) {
    final raw = map['created_at'];
    return OrderEventModel(
      orderId: map['order_id'] ?? '',
      eventMessage: map['event_message'] ?? '',
      createdAt: raw is String ? DateTime.parse(raw) : raw as DateTime,
    );
  }
}

class CustomerMessageState {
  final bool isLoading;
  final String? error;
  final List<OrderEventModel> messages;

  const CustomerMessageState({
    this.isLoading = false,
    this.error,
    this.messages = const [],
  });

  CustomerMessageState copyWith({
    bool? isLoading,
    String? error,
    List<OrderEventModel>? messages,
  }) {
    return CustomerMessageState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      messages: messages ?? this.messages,
    );
  }
}

class CustomerMessageNotifier extends StateNotifier<CustomerMessageState> {
  CustomerMessageNotifier() : super(const CustomerMessageState());

  final _supabase = Supabase.instance.client;

  Future<void> fetchMessages({bool refresh = false}) async {
    try {
      if (!refresh) {
        state = state.copyWith(isLoading: true, error: null);
      }

      final userId = _supabase.auth.currentUser!.id;

      final data = await _supabase
          .from('order_events')
          .select()
          .or('created_by.eq.$userId,customer_id.eq.$userId')
          .order('created_at', ascending: false);

      final messages = (data as List)
          .map((e) => OrderEventModel.fromMap(e))
          .toList();

      state = state.copyWith(messages: messages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final customerMessageProvider =
    StateNotifierProvider<CustomerMessageNotifier, CustomerMessageState>(
      (ref) => CustomerMessageNotifier(),
    );

class CustomerMessagePage extends ConsumerStatefulWidget {
  const CustomerMessagePage({super.key});

  @override
  ConsumerState<CustomerMessagePage> createState() =>
      _CustomerMessagePageState();
}

class _CustomerMessagePageState extends ConsumerState<CustomerMessagePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(customerMessageProvider.notifier).fetchMessages();
    });
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy · hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerMessageProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.appBackground,
        appBar: AppBar(
          backgroundColor: AppColors.appBackground,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Messages',
            style: AppFontStyle.title.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[900],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primaryColor.withOpacity(0.12),
                ),
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: AppFontStyle.subtitle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: AppFontStyle.subtitle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.all(3),
                tabs: const [
                  Tab(text: 'Promotions',height: 36,),
                  Tab(text: 'Messages',height: 36,),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            Center(
              child: Text('No Promotions yet', style: AppFontStyle.subtitle),
            ),

            RefreshIndicator(
              backgroundColor: Colors.white,
              color: Colors.red,
              onRefresh: () async {
                await ref
                    .read(customerMessageProvider.notifier)
                    .fetchMessages(refresh: true);
              },
              child: Builder(
                builder: (_) {
                  if (state.isLoading && state.messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.error != null) {
                    return ListView(
                      children: [
                        const SizedBox(height: 180),
                        Center(
                          child: Text(
                            state.error!,
                            style: AppFontStyle.caption.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (state.messages.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 180),
                        Center(
                          child: Text(
                            'No messages yet',
                            style: AppFontStyle.caption,
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundImage: AssetImage(
                                    'assets/images/app_logo.jpg',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Food Mandalay',
                                      style: AppFontStyle.subtitle.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Order update',
                                      style: AppFontStyle.caption.copyWith(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              msg.eventMessage,
                              style: AppFontStyle.body.copyWith(height: 1.45),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatDate(msg.createdAt),
                                  style: AppFontStyle.caption.copyWith(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Update phone',
                                    style: AppFontStyle.caption.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/features/message/presentation/mobile/chat_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';

/// Chat Conversation Model
class ChatConversationModel {
  final String roomId;
  final String merchantId;
  final String merchantName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isUnread;
  final String? orderId;

  ChatConversationModel({
    required this.roomId,
    required this.merchantId,
    required this.merchantName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.isUnread = false,
    this.orderId,
  });
}

/// Customer Chat State
class CustomerChatState {
  final bool isLoading;
  final String? error;
  final List<ChatConversationModel> conversations;

  const CustomerChatState({
    this.isLoading = false,
    this.error,
    this.conversations = const [],
  });

  CustomerChatState copyWith({
    bool? isLoading,
    String? error,
    List<ChatConversationModel>? conversations,
  }) {
    return CustomerChatState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      conversations: conversations ?? this.conversations,
    );
  }
}

/// Customer Chat Notifier
class CustomerChatNotifier extends StateNotifier<CustomerChatState> {
  CustomerChatNotifier() : super(const CustomerChatState());

  final _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;

  /// Fetch all chat conversations for current customer
  Future<void> fetchConversations({bool refresh = false}) async {
    try {
      if (!refresh) {
        state = state.copyWith(isLoading: true, error: null);
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(error: 'User not logged in');
        return;
      }

      // Get all messages where customer is the sender
      final messagesResponse = await _supabase
          .from('messages')
          .select()
          .eq('sender_id', userId)
          .order('created_at', ascending: false);

      final sentMessages = (messagesResponse as List)
          .map((e) => _MessageModel.fromJson(e))
          .toList();

      // Also get messages where room_id contains customer ID (messages sent to them)
      final allMessagesResponse = await _supabase
          .from('messages')
          .select()
          .order('created_at', ascending: false)
          .limit(1000); // Limit to avoid too many results

      final allMessages = (allMessagesResponse as List)
          .map((e) => _MessageModel.fromJson(e))
          .toList();

      // Filter messages where room_id contains customer ID
      final receivedMessages = allMessages
          .where((msg) => msg.roomId.contains(userId) && msg.senderId != userId)
          .toList();

      // Combine and deduplicate
      final allCustomerMessages = <String, _MessageModel>{};
      for (final msg in [...sentMessages, ...receivedMessages]) {
        if (!allCustomerMessages.containsKey(msg.roomId) ||
            msg.createdAt.isAfter(allCustomerMessages[msg.roomId]!.createdAt)) {
          allCustomerMessages[msg.roomId] = msg;
        }
      }

      // Get unique merchant IDs from room_ids
      final List<ChatConversationModel> conversations = [];
      for (final entry in allCustomerMessages.entries) {
        final roomId = entry.key;
        final lastMsg = entry.value;

        // Extract merchant ID from room_id (format: user1_user2)
        final parts = roomId.split('_');
        String merchantId = '';
        if (parts.length == 2) {
          merchantId = parts[0] == userId ? parts[1] : parts[0];
        } else {
          continue; // Skip if room_id format is unexpected
        }

        // Get merchant name from profiles
        String merchantName = 'Merchant';
        try {
          final profileRes = await _supabase
              .from('profiles')
              .select('full_name')
              .eq('auth_id', merchantId)
              .maybeSingle();
          if (profileRes != null && profileRes['full_name'] != null) {
            merchantName = profileRes['full_name'];
          }
        } catch (e) {
          // Use default name if profile not found
        }

        conversations.add(
          ChatConversationModel(
            roomId: roomId,
            merchantId: merchantId,
            merchantName: merchantName,
            lastMessage: lastMsg.content,
            lastMessageTime: lastMsg.createdAt,
            isUnread: lastMsg.senderId != userId,
          ),
        );
      }

      // Sort by last message time (newest first)
      conversations.sort(
        (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime),
      );

      state = state.copyWith(conversations: conversations);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Subscribe to real-time updates
  void subscribeRealtime() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _channel?.unsubscribe();

    // Listen to all message inserts and filter in callback
    _channel = _supabase
        .channel('customer-messages-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            try {
              final roomId = payload.newRecord['room_id'] as String?;
              if (roomId != null && roomId.contains(userId)) {
                fetchConversations(refresh: true);
              }
            } catch (e) {
              fetchConversations(refresh: true);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            try {
              final roomId = payload.newRecord['room_id'] as String?;
              if (roomId != null && roomId.contains(userId)) {
                fetchConversations(refresh: true);
              }
            } catch (e) {
              fetchConversations(refresh: true);
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

final customerChatProvider =
    StateNotifierProvider<CustomerChatNotifier, CustomerChatState>(
      (ref) => CustomerChatNotifier(),
    );

/// Helper model for messages
class _MessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  _MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory _MessageModel.fromJson(Map<String, dynamic> json) {
    return _MessageModel(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['sender_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// Complete Customer Message Page
class CustomerMessagePage extends ConsumerStatefulWidget {
  const CustomerMessagePage({super.key});

  @override
  ConsumerState<CustomerMessagePage> createState() =>
      _CustomerMessagePageState();
}

class _CustomerMessagePageState extends ConsumerState<CustomerMessagePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(customerChatProvider.notifier).fetchConversations();
      ref.read(customerChatProvider.notifier).subscribeRealtime();
    });
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return DateFormat('hh:mm a').format(date);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  Future<void> _openChat({
    required String roomId,
    required String merchantId,
    required String merchantName,
  }) async {
    try {
      final sender = Supabase.instance.client.auth.currentUser;
      if (sender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to chat')),
        );
        return;
      }
      final senderId = sender.id;

      // Navigate to ChatPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(roomId: roomId, currentUserId: senderId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open chat: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerChatProvider);

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Messages',
          style: AppFontStyle.title.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[900],
          ),
        ),
      ),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: Colors.red,
        onRefresh: () async {
          await ref
              .read(customerChatProvider.notifier)
              .fetchConversations(refresh: true);
        },
        child: Builder(
          builder: (_) {
            if (state.isLoading && state.conversations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
    
            if (state.error != null) {
              return ListView(
                children: [
                  const SizedBox(height: 180),
                  Center(
                    child: Text(
                      state.error!,
                      style: AppFontStyle.caption.copyWith(color: Colors.red),
                    ),
                  ),
                ],
              );
            }
    
            if (state.conversations.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 180),
                  Center(
                    child: Text(
                      'No messages yet',
                      style: AppFontStyle.caption,
                    ),
                  ),
                ],
              );
            }
    
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final conversation = state.conversations[index];
    
                return GestureDetector(
                  onTap: () => _openChat(
                    roomId: conversation.roomId,
                    merchantId: conversation.merchantId,
                    merchantName: conversation.merchantName,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundImage: AssetImage(
                                'assets/images/app_logo.jpg',
                              ),
                            ),
                            if (conversation.isUnread)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      conversation.merchantName,
                                      style: AppFontStyle.subtitle.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    formatDate(conversation.lastMessageTime),
                                    style: AppFontStyle.caption.copyWith(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                conversation.lastMessage,
                                style: AppFontStyle.body.copyWith(
                                  height: 1.45,
                                  fontWeight: conversation.isUnread
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: conversation.isUnread
                                      ? Colors.grey[900]
                                      : Colors.grey[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
          },
        ),
      ),
    );
  }
}
