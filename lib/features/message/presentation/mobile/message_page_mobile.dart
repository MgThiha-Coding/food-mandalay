import 'package:flutter/material.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';

class MessagePageMobile extends StatefulWidget {
  const MessagePageMobile({super.key});

  @override
  State<MessagePageMobile> createState() => _MessagePageMobileState();
}

class _MessagePageMobileState extends State<MessagePageMobile> {
  // Dummy chat data
  final List<Map<String, dynamic>> chats = [
    {
      'name': 'Supplier A',
      'lastMessage': 'Your order has been shipped.',
      'time': '10:24 AM',
      'avatarUrl': null,
      'unread': 2,
    },
    {
      'name': 'Supplier B',
      'lastMessage': 'New products are available!',
      'time': 'Yesterday',
      'avatarUrl': null,
      'unread': 0,
    },
    {
      'name': 'Delivery Rider',
      'lastMessage': 'I will deliver your order soon.',
      'time': 'Mon',
      'avatarUrl': null,
      'unread': 1,
    },
    {
      'name': 'Customer Support',
      'lastMessage': 'How can we help you today?',
      'time': 'Sun',
      'avatarUrl': null,
      'unread': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return GestureDetector(
            onTap: () {
          
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.red.shade100,
                    child: chat['avatarUrl'] != null
                        ? ClipOval(
                            child: Image.network(
                              chat['avatarUrl'],
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            chat['name'][0],
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat['name'],
                          style: AppFontStyle.subtitle.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chat['lastMessage'],
                          style: AppFontStyle.body.copyWith(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        chat['time'],
                        style: AppFontStyle.caption.copyWith(
                          color: Colors.black45,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (chat['unread'] > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${chat['unread']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
