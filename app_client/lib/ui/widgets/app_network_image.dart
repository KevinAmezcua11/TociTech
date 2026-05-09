import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final Widget loading;
  final Widget error;
  final Duration timeout;

  const AppNetworkImage({
    super.key,
    required this.url,
    required this.loading,
    required this.error,
    this.fit = BoxFit.cover,
    this.timeout = const Duration(seconds: 12),
  });

  @override
  State<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends State<AppNetworkImage> {
  Timer? _timer;
  bool _timedOut = false;

  bool get _isValid {
    if (widget.url.isEmpty) return false;
    final uri = Uri.tryParse(widget.url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  void initState() {
    super.initState();
    if (_isValid) {
      _timer = Timer(widget.timeout, () {
        if (mounted) setState(() => _timedOut = true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onSuccess() => _timer?.cancel();
  void _onError()   => _timer?.cancel();

  @override
  Widget build(BuildContext context) {
    if (!_isValid || _timedOut) return widget.error;

    return CachedNetworkImage(
      imageUrl: widget.url,
      fit: widget.fit,
      placeholder:    (_, __) => widget.loading,
      imageBuilder:   (_, provider) {
        _onSuccess();
        return Image(image: provider, fit: widget.fit);
      },
      errorWidget:    (_, __, ___) {
        _onError();
        return widget.error;
      },
    );
  }
}
