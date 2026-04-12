import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../Utils/Constant/colors.dart';
import '../../Utils/Formatters/formatter.dart';
import '../../Utils/Services/supabase_service.dart';

class AppAvatar extends StatefulWidget {
  final String name;
  final String? photoUrl;
  final double radius;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 20,
    this.backgroundColor,
  });

  @override
  State<AppAvatar> createState() => _AppAvatarState();
}

class _AppAvatarState extends State<AppAvatar> {
  String? _resolvedUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _handleUrlResolution();
  }

  @override
  void didUpdateWidget(AppAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoUrl != widget.photoUrl) {
      _handleUrlResolution();
    }
  }

  Future<void> _handleUrlResolution() async {
    final url = widget.photoUrl;
    if (url == null || url.isEmpty) {
      if (mounted) setState(() => _resolvedUrl = null);
      return;
    }

    // If it's already a full URL, use it directly
    if (url.startsWith('http')) {
      if (mounted) setState(() => _resolvedUrl = url);
      return;
    }

    // Otherwise, assume it's a Supabase path and resolve it
    if (mounted) setState(() => _isLoading = true);
    try {
      final signedUrl = await SupabaseService.getSignedUrl(url);
      if (mounted) {
        setState(() {
          _resolvedUrl = signedUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('AppAvatar: Failed to resolve Supabase path: $e');
      if (mounted) {
        setState(() {
          _resolvedUrl = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor:
            widget.backgroundColor ?? AppColors.grey.withValues(alpha: 0.2),
        child: SizedBox(
          width: widget.radius * 0.8,
          height: widget.radius * 0.8,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_resolvedUrl != null && _resolvedUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _resolvedUrl!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: widget.radius,
          backgroundImage: imageProvider,
          backgroundColor: AppColors.grey,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: widget.radius,
          backgroundColor: AppColors.grey,
          child: SizedBox(
            width: widget.radius * 0.8,
            height: widget.radius * 0.8,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => _buildInitials(),
      );
    }

    return _buildInitials();
  }

  Widget _buildInitials() {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.backgroundColor ?? AppColors.blue,
      child: Text(
        AppFormatter.initials(widget.name),
        style: TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: widget.radius * 0.7,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
