import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/clothing_item.dart';

class ClothingCard extends StatefulWidget {
  final ClothingItem item;
  final VoidCallback? onTap;
  final bool isFavorite;
  final Function(bool)? onFavoriteChanged;

  const ClothingCard({
    super.key,
    required this.item,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteChanged,
  });

  @override
  State<ClothingCard> createState() => _ClothingCardState();
}

class _ClothingCardState extends State<ClothingCard> with SingleTickerProviderStateMixin {
  late AnimationController _favoriteController;
  late Animation<double> _scaleAnimation;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _favoriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _favoriteController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    super.dispose();
  }

  void _handleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    _favoriteController.forward(from: 0.0);
    widget.onFavoriteChanged?.call(_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Image area
            AspectRatio(
              aspectRatio: 0.8,
              child: Hero(
                tag: 'clothing_image_${widget.item.id}',
                child: _buildImage(),
              ),
            ),
            
            // Bottom info bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.item.name.isNotEmpty ? widget.item.name : '时尚单品',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.item.category,
                        style: const TextStyle(color: Colors.white, fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Favorite button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _handleFavorite,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                      size: 18,
                      color: _isFavorite ? Colors.pink : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),

            // Tap listener
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: widget.onTap),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final path = widget.item.imagePath;
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[100],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else {
      final file = File(path);
      return Image.file(
        file,
        fit: BoxFit.cover,
        // 使用 frameBuilder 显示加载占位图
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: frame == null 
              ? Container(
                  color: Colors.grey[100],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : child,
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
        ),
      );
    }
  }
}
