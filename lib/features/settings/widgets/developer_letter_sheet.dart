import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

void showDeveloperLetterSheet(BuildContext context, {required bool isDark, required bool isId}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? JagainColors.darkSurface : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return DeveloperLetterContent(
            scrollController: scrollController,
            isDark: isDark,
            isId: isId,
          );
        },
      );
    },
  );
}

class DeveloperLetterContent extends StatefulWidget {
  const DeveloperLetterContent({
    required this.scrollController,
    required this.isDark,
    required this.isId,
    super.key,
  });

  final ScrollController scrollController;
  final bool isDark;
  final bool isId;

  @override
  State<DeveloperLetterContent> createState() => _DeveloperLetterContentState();
}

class _DeveloperLetterContentState extends State<DeveloperLetterContent> {
  bool _isCopied = false;
  static const String _phoneNumber = '+62851 797 65891';
  static const String _phoneToCopy = '+6285179765891';

  void _copyPhoneNumber() {
    Clipboard.setData(const ClipboardData(text: _phoneToCopy));
    HapticFeedback.lightImpact();
    setState(() {
      _isCopied = true;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.isId
                    ? 'Nomor GoPay ($_phoneNumber) berhasil disalin!'
                    : 'GoPay number ($_phoneNumber) copied to clipboard!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textColor = isDark ? JagainColors.darkText : JagainColors.ink;
    final mutedColor = isDark ? JagainColors.darkMuted : JagainColors.muted;
    final cardBg = isDark ? JagainColors.darkBackground : const Color(0xFFF8FAFC);
    final borderColor = isDark ? JagainColors.darkBorder : const Color(0xFFE2E8F0);

    return Column(
      children: [
        // Drag Handle
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            color: isDark ? JagainColors.darkMuted.withValues(alpha: 0.4) : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: JagainColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: JagainColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isId ? 'Surat dari Tim JAGAIN' : 'Letter from JAGAIN Team',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isId ? 'Catat · Ingat · Rawat' : 'Record · Remember · Care',
                      style: TextStyle(
                        fontSize: 12,
                        color: JagainColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                color: mutedColor,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Scrollable Letter Body
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  widget.isId ? 'Halo,\nTerima kasih sudah memilih menggunakan JAGAIN.' : 'Hello,\nThank you for choosing to use JAGAIN.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 14),

                _buildParagraph(
                  widget.isId
                      ? 'JAGAIN lahir dari sebuah hal sederhana: kami ingin membantu membuat keseharian menjadi sedikit lebih mudah — membantu kita mencatat, mengingat, dan merawat apa yang kita miliki dengan lebih baik.'
                      : 'JAGAIN was born from a simple idea: we want to help make everyday life a little easier — helping us record, remember, and care for what we own in a better way.',
                  textColor,
                ),

                _buildParagraph(
                  widget.isId
                      ? 'Kami menyadari bahwa versi yang Anda gunakan saat ini masih jauh dari sempurna. Masih ada banyak hal yang bisa diperbaiki, dikembangkan, dan mungkin juga belum sesuai dengan apa yang Anda butuhkan.'
                      : 'We recognize that the version you are using today is still far from perfect. There is plenty of room for improvement, refinement, and features you may still need.',
                  textColor,
                ),

                _buildParagraph(
                  widget.isId
                      ? 'Dan kami tidak ingin berpura-pura bahwa semuanya sudah selesai.'
                      : 'And we do not want to pretend that everything is finished.',
                  textColor,
                  isBold: true,
                ),

                _buildParagraph(
                  widget.isId
                      ? 'Justru karena itu, kami sangat terbuka terhadap kritik, saran, ide, maupun feedback dari Anda. Setiap masukan membantu kami memahami bagaimana JAGAIN benar-benar digunakan dalam kehidupan sehari-hari.'
                      : 'Because of this, we are genuinely open to your critique, suggestions, ideas, and feedback. Every input helps us understand how JAGAIN is truly used day-to-day.',
                  textColor,
                ),

                _buildParagraph(
                  widget.isId
                      ? 'Jika Anda memiliki kebutuhan khusus dan merasa JAGAIN akan lebih berguna dengan penyesuaian tertentu, kami juga terbuka untuk berkolaborasi dan membuat versi yang lebih sesuai dengan kebutuhan Anda.'
                      : 'If you have specific needs and feel JAGAIN would serve you better with customized workflows, we are eager to collaborate and craft solutions tailored for you.',
                  textColor,
                ),

                _buildParagraph(
                  widget.isId
                      ? 'Karena bagi kami, produk yang baik bukan hanya tentang apa yang kami pikirkan saat membuatnya, tetapi juga tentang bagaimana produk tersebut benar-benar membantu orang yang menggunakannya.'
                      : 'For us, a good product is not just about what we imagine during development, but about how effectively it genuinely serves the people using it.',
                  textColor,
                ),

                _buildParagraph(
                  widget.isId
                      ? 'Dan jika ternyata JAGAIN sudah cukup membantu keseharian Anda, lalu Anda ingin ikut mendukung perjalanan kecil tim kami, Anda dapat memberikan dukungan melalui:'
                      : 'And if JAGAIN has already helped your daily routines and you wish to support our small team’s journey, you can support us via:',
                  textColor,
                ),
                const SizedBox(height: 8),

                // GoPay Support Box (PRD & User Request)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _isCopied ? const Color(0xFF10B981) : borderColor,
                      width: _isCopied ? 1.8 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GoPay Logo & Badge Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/icons/gopay_logo.png',
                            height: 34,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00AED6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'GoPay',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00AED6).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Support GoPay',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF00AED6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Interactive Tap-to-Copy Phone Number Container
                      Material(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: _copyPhoneNumber,
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00AED6).withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.phone_iphone_rounded,
                                    color: Color(0xFF00AED6),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _phoneNumber,
                                        style: TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.4,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'a.n. Smugh',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: mutedColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _isCopied
                                        ? const Color(0xFF10B981)
                                        : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isCopied ? Icons.check_rounded : Icons.copy_rounded,
                                        size: 15,
                                        color: _isCopied
                                            ? Colors.white
                                            : (isDark ? Colors.white70 : const Color(0xFF475569)),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        _isCopied
                                            ? (widget.isId ? 'Tersalin' : 'Copied')
                                            : (widget.isId ? 'Salin' : 'Copy'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: _isCopied
                                              ? Colors.white
                                              : (isDark ? Colors.white70 : const Color(0xFF475569)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.isId
                            ? 'Ketuk nomor di atas untuk langsung menyalin ke aplikasi GoPay/e-wallet Anda.'
                            : 'Tap the number above to copy directly to your GoPay/e-wallet app.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: mutedColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _buildParagraph(
                  widget.isId
                      ? 'Tidak ada kewajiban apa pun. Dukungan Anda, dalam bentuk apa pun — menggunakan JAGAIN, memberikan feedback, membagikannya kepada orang lain, atau bahkan sekadar memberikan semangat — sudah sangat berarti bagi kami.'
                      : 'There is absolutely no obligation. Your support, in any form — using JAGAIN, sharing feedback, telling others about it, or even just sending words of encouragement — means the world to us.',
                  textColor,
                ),

                _buildParagraph(
                  widget.isId
                      ? 'Terima kasih sudah menjadi bagian dari perjalanan JAGAIN.'
                      : 'Thank you for being part of the JAGAIN journey.',
                  textColor,
                ),

                _buildParagraph(
                  widget.isId
                      ? 'Semoga JAGAIN bisa terus tumbuh, menjadi lebih baik, dan pada akhirnya benar-benar menjadi sesuatu yang berguna dalam keseharian Anda.'
                      : 'May JAGAIN continue to grow, improve, and truly become something helpful in your everyday routines.',
                  textColor,
                ),
                const SizedBox(height: 10),

                // Motto & Signoff
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: JagainColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, size: 16, color: JagainColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Catat. Ingat. Rawat.',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  widget.isId ? 'Dengan hangat,' : 'Warm regards,',
                  style: TextStyle(fontSize: 13.5, color: mutedColor),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.isId ? 'Tim JAGAIN' : 'JAGAIN Team',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _copyPhoneNumber,
                    icon: Icon(
                      _isCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
                      size: 18,
                    ),
                    label: Text(
                      widget.isId
                          ? (_isCopied ? 'Nomor GoPay Tersalin!' : 'Salin Nomor GoPay (+62851 797 65891)')
                          : (_isCopied ? 'GoPay Number Copied!' : 'Copy GoPay Number (+62851 797 65891)'),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCopied ? const Color(0xFF10B981) : const Color(0xFF00AED6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      widget.isId ? 'Tutup Surat' : 'Close Letter',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParagraph(String text, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.5,
          height: 1.6,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          color: color,
        ),
      ),
    );
  }
}
