import 'package:flutter/material.dart';

class AppSnackBar {
  AppSnackBar._();

  static const _radius = 14.0;

  static void show(
    BuildContext context, {
    required String message,
    IconData icon = Icons.info_outline,
    Color backgroundColor = const Color(0xFF111827), 
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
      backgroundColor: backgroundColor,
      elevation: 0,
      duration: duration,
      content: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction,
            )
          : null,
    );

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void success(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: const Color(0xFF008A4E), 
    );
  }

  static void error(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.error_outline,
      backgroundColor: const Color(0xFFDC2626),
    );
  }

  static void info(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: const Color(0xFF111827),
    );
  }

  static void cartAdded(BuildContext context) {
    show(
      context,
      message: "Ditambahkan ke keranjang",
      icon: Icons.shopping_bag_outlined,
      backgroundColor: const Color(0xFF111827),
      actionLabel: "OK",
      onAction: () {},
    );
  }

  static void checkout(BuildContext context) {
    show(
      context,
      message: "Checkout diproses…",
      icon: Icons.credit_card,
      backgroundColor: const Color(0xFF111827),
    );
  }

  static void share(BuildContext context) {
    show(
      context,
      message: "Link siap dibagikan",
      icon: Icons.ios_share,
      backgroundColor: const Color(0xFF111827),
    );
  }
}
