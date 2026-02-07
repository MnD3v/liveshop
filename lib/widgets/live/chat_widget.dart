import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liveshop/providers/live_event_provider.dart';
import 'package:liveshop/models/chat_message.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liveshop/widgets/app_icons.dart';

class ChatWidget extends StatefulWidget {
  final bool isReadOnly;
  const ChatWidget({Key? key, this.isReadOnly = false}) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<ChatMessage>(
            stream: context.read<LiveEventProvider>().chatStream,
            builder: (context, snapshot) {
              return _ChatList(newMessage: snapshot.data);
            },
          ),
        ),
        if (!widget.isReadOnly) _buildInputArea(context),
      ],
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent, // Laisser le fond apparaître
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _controller,
                style: GoogleFonts.sora(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Dites quelque chose...',
                  hintStyle: GoogleFonts.sora(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  filled: false,
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _ReactionButton(
            icon: AppIcons.icon(AppIcons.heart, color: Colors.white, size: 20),
            onTap: () => _sendMessage('❤️'),
          ),
          const SizedBox(width: 8),
          _ReactionButton(
            icon: AppIcons.icon(AppIcons.flash, color: Colors.white, size: 20),
            onTap: () => _sendMessage('🔥'),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFF2600),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: AppIcons.icon(AppIcons.send, color: Colors.white, size: 20),
              onPressed: () => _sendMessage(_controller.text),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    context.read<LiveEventProvider>().sendMessage(text);
    _controller.clear();
  }
}

class _ReactionButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;

  const _ReactionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: icon,
      ),
    );
  }
}

class _ChatList extends StatefulWidget {
  final ChatMessage? newMessage;
  const _ChatList({Key? key, this.newMessage}) : super(key: key);

  @override
  State<_ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<_ChatList> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(_ChatList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.newMessage != null &&
        widget.newMessage != oldWidget.newMessage) {
      // Éviter les doublons (vérification basique)
      if (_messages.isEmpty || _messages.last.id != widget.newMessage!.id) {
        setState(() {
          _messages.add(widget.newMessage!);
        });
        // Défiler vers le bas
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.white],
          stops: [0.0, 0.15],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final msg = _messages[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg.isVendor)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF2600),
                        shape: BoxShape.circle,
                      ),
                      child: AppIcons.icon(
                        AppIcons.star,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${msg.senderName}: ',
                          style: GoogleFonts.sora(
                            color: msg.isVendor
                                ? const Color(0xFFFF2600)
                                : Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: msg.message,
                          style: GoogleFonts.sora(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
