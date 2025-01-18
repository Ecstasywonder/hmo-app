import 'package:flutter/material.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isConnecting = true;
  bool _isTyping = false;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _connectToSupport();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _connectToSupport() async {
    // TODO: Implement real chat connection
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isConnecting = false;
        _messages = [
          {
            'id': '1',
            'text': 'Hello! How can I help you today?',
            'isUser': false,
            'timestamp': DateTime.now().subtract(const Duration(minutes: 1)),
          },
        ];
      });
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().toString(),
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _messageController.clear();
    });

    // Simulate agent typing
    setState(() => _isTyping = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            'id': DateTime.now().toString(),
            'text': 'Thank you for your message. An agent will respond shortly.',
            'isUser': false,
            'timestamp': DateTime.now(),
          });
        });
      }
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Live Support'),
            Text(
              _isConnecting ? 'Connecting...' : 'Connected',
              style: TextStyle(
                fontSize: 12,
                color: _isConnecting ? Colors.grey[300] : Colors.green[100],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildChatOptions(),
              );
            },
          ),
        ],
      ),
      body: _isConnecting
          ? const LoadingWidget(message: 'Connecting to support...')
          : Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.chat_bubble_outline,
                          title: 'No Messages',
                          message: 'Start the conversation by sending a message.',
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isUser = message['isUser'] as bool;
                            return _buildMessage(message, isUser);
                          },
                        ),
                ),
                if (_isTyping)
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: LoadingWidget(size: 8),
                              ),
                              Text('Agent is typing...'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildMessageInput(),
              ],
            ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 20,
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? const Radius.circular(0) : null,
                  bottomLeft: !isUser ? const Radius.circular(0) : null,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'],
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message['timestamp']),
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              // TODO: Implement file attachment
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildChatOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email Transcript'),
            onTap: () {
              // TODO: Implement email transcript
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.rate_review_outlined),
            title: const Text('Rate Conversation'),
            onTap: () {
              // TODO: Implement conversation rating
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_outlined),
            title: const Text('Report Issue'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/support/ticket',
                arguments: {
                  'type': 'Chat Issue',
                  'subject': 'Chat Support Issue Report',
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('End Chat'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
} 