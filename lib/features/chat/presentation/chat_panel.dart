import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_notifier.dart';
import 'widgets/message_bubble.dart';
import 'package:vyjadrenia/utils/app_theme.dart';

class ChatPanel extends StatefulWidget {
  final String screenId;

  const ChatPanel({
    Key? key,
    required this.screenId,
  }) : super(key: key);

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isMaximized = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatNotifier = context.watch<ChatNotifier>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      right: chatNotifier.isPanelOpen ? 0 : (isMobile ? -screenWidth : -800),
      top: 0,
      bottom: 0,
      child: Container(
        width: isMobile ? screenWidth : (_isMaximized ? screenWidth * 0.8 : 400),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkBackground : Colors.white,
          borderRadius: isMobile 
            ? BorderRadius.zero 
            : const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 30,
              offset: const Offset(-5, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(context, chatNotifier),
            
            // Messages List
            Expanded(
              child: chatNotifier.isLoading && chatNotifier.messages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _buildMessageList(chatNotifier),
            ),

            // Error Message
            if (chatNotifier.errorMessage != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.red.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chatNotifier.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Resend last message if possible or just clear error
                        if (chatNotifier.messages.isNotEmpty && chatNotifier.messages.last.role == 'user') {
                          final lastText = chatNotifier.messages.last.content;
                          // Should probably remove the failed message first or handle it in notifier
                          // For now, let's just clear the error to allow the user to try again
                          chatNotifier.clearError(); 
                        } else {
                          chatNotifier.clearError();
                        }
                      },
                      child: const Text('Skúsiť znova', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

            // Input Area
            _buildInput(context, chatNotifier),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChatNotifier chatNotifier) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 12, 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryRed, size: 20),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Asistent',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                Text(
                  'Vždy online • Pripravený pomôcť',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Maximize Button
          IconButton(
            onPressed: () => setState(() => _isMaximized = !_isMaximized),
            icon: Icon(
              _isMaximized ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
              color: Colors.grey,
              size: 20,
            ),
            tooltip: _isMaximized ? 'Zmenšiť' : 'Zväčšiť',
          ),
          // New Chat Button
          IconButton(
            onPressed: () => _confirmNewChat(context, chatNotifier),
            icon: const Icon(Icons.refresh_rounded, color: Colors.grey, size: 20),
            tooltip: 'Nová konverzácia',
          ),
          // Close Button
          IconButton(
            onPressed: () => chatNotifier.closePanel(),
            icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 24),
            tooltip: 'Zatvoriť',
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatNotifier chatNotifier) {
    if (chatNotifier.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'Ako vám môžem pomôcť?',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    _scrollToBottom();
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: chatNotifier.messages.length,
      itemBuilder: (context, index) {
        return MessageBubble(message: chatNotifier.messages[index]);
      },
    );
  }

  Widget _buildInput(BuildContext context, ChatNotifier chatNotifier) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool canSend = !chatNotifier.isLoading && _messageController.text.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                ),
              ),
              child: TextField(
                controller: _messageController,
                enabled: !chatNotifier.isLoading,
                onChanged: (val) => setState(() {}),
                onSubmitted: canSend ? (val) => _handleSend(chatNotifier) : null,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Opýtajte sa čokoľvek...',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: 5,
                minLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedScale(
            scale: canSend ? 1.0 : 0.9,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: BoxDecoration(
                color: canSend ? AppTheme.primaryRed : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: canSend ? () => _handleSend(chatNotifier) : null,
                icon: Icon(
                  Icons.arrow_upward_rounded,
                  color: canSend ? Colors.white : Colors.grey,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend(ChatNotifier chatNotifier) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    _messageController.clear();
    setState(() {});
    
    chatNotifier.sendMessage(text, widget.screenId);
  }

  void _confirmNewChat(BuildContext context, ChatNotifier chatNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nová konverzácia'),
        content: const Text('Naozaj chcete začať novú konverzáciu? História bude vymazaná.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zrušiť'),
          ),
          TextButton(
            onPressed: () {
              chatNotifier.clearSession();
              Navigator.pop(context);
            },
            child: const Text('Áno, začať znova'),
          ),
        ],
      ),
    );
  }
}
