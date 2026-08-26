import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class MessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['sender_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ChatState {
  final AsyncValue<List<MessageModel>> messages;

  ChatState({required this.messages});

  ChatState copyWith({AsyncValue<List<MessageModel>>? messages}) {
    return ChatState(messages: messages ?? this.messages);
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this.roomId, this.currentUserId)
    : super(ChatState(messages: const AsyncValue.loading())) {
    fetchMessages();
  }

  final String roomId;
  final String currentUserId;
  final SupabaseClient supabase = Supabase.instance.client;

  int get messageCount {
    return state.messages.value?.length ?? 0;
  }

  Future<void> fetchMessages() async {
    try {
      final response = await supabase
          .from('messages')
          .select()
          .eq('room_id', roomId)
          .order('created_at', ascending: true);

      final messages = (response as List)
          .map((e) => MessageModel.fromJson(e))
          .toList();

      state = state.copyWith(messages: AsyncValue.data(messages));
    } catch (e, st) {
      state = state.copyWith(messages: AsyncValue.error(e, st));
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      await supabase.from('messages').insert({
        'room_id': roomId,
        'sender_id': currentUserId,
        'content': content,
      });
      await fetchMessages();
    } catch (e) {
      debugPrint('Send message error: $e');
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    try {
      await supabase
          .from('messages')
          .update({'content': newContent})
          .eq('id', messageId);
      await fetchMessages();
    } catch (e) {
      debugPrint('Edit message error: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await supabase.from('messages').delete().eq('id', messageId);
      await fetchMessages(); // refresh after delete
    } catch (e) {
      debugPrint('Delete message error: $e');
    }
  }
}

final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, String>((
      ref,
      roomId,
    ) {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
      return ChatNotifier(roomId, currentUserId);
    });

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({
    super.key,
    required this.roomId,
    required this.currentUserId,
  });

  final String roomId;
  final String currentUserId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (_) {
      ref.read(chatProvider(widget.roomId).notifier).fetchMessages();
    });
  }

  void _showEditDialog(MessageModel message) {
    final editController = TextEditingController(text: message.content);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.white,
        title: const Text('Edit Message', style: AppFontStyle.title),
        content: TextField(
          controller: editController,
          autofocus: true,
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppFontStyle.caption.copyWith(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                ref
                    .read(chatProvider(widget.roomId).notifier)
                    .editMessage(message.id, editController.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text(
              'Save',
              style: AppFontStyle.caption.copyWith(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(MessageModel message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.white,
        title: const Text('Delete Message?', style: AppFontStyle.title),
        content: const Text('This message will be deleted for everyone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppFontStyle.caption.copyWith(color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(chatProvider(widget.roomId).notifier)
                  .deleteMessage(message.id);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: AppFontStyle.caption.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider(widget.roomId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Chat', style: AppFontStyle.title),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.messages.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet.\nStart the conversation!',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final isMe = message.senderId == widget.currentUserId;

                    return GestureDetector(
                      onLongPress: () {
                        if (isMe) {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            builder: (_) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: const Text(
                                    'Edit',
                                    style: AppFontStyle.caption,
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showEditDialog(message);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  title: Text(
                                    'Delete',
                                    style: AppFontStyle.caption.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showDeleteDialog(message);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.grey[100] : Colors.blue,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                message.content,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('hh:mm a').format(message.createdAt),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
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
          // Input box
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                          hintStyle: AppFontStyle.caption,
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (text) {
                          if (text.trim().isNotEmpty) {
                            ref
                                .read(chatProvider(widget.roomId).notifier)
                                .sendMessage(text.trim());
                            _controller.clear();
                          }
                        },
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.red,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          final text = _controller.text.trim();
                          if (text.isEmpty) return;
                          ref
                              .read(chatProvider(widget.roomId).notifier)
                              .sendMessage(text);
                          _controller.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
