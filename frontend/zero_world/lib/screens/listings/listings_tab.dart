import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/listing.dart';
import '../../state/listings_state.dart';
import 'listing_chat_button.dart';

class ListingsTab extends StatefulWidget {
  const ListingsTab({super.key});

  @override
  State<ListingsTab> createState() => _ListingsTabState();
}

class _ListingsTabState extends State<ListingsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ListingsState>().ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListingsState>(
      builder: (context, state, _) {
        if (state.isLoading && !state.hasLoadedOnce) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.errorMessage != null && !state.hasLoadedOnce) {
          return _ListingsError(message: state.errorMessage!);
        }

        if (state.listings.isEmpty) {
          return RefreshIndicator(
            onRefresh: state.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: Center(
                    child: Text(
                      'No listings yet. Pull down to refresh or add the first one!',
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: state.refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.listings.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final listing = state.listings[index];
              return _ListingTile(listing: listing);
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
          ),
        );
      },
    );
  }
}

class _ListingTile extends StatelessWidget {
  const _ListingTile({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat.simpleCurrency();
    final hasImages = listing.imageUrls.isNotEmpty;
    final createdLabel = DateFormat.yMMMd().add_jm().format(listing.createdAt.toLocal());

    return ListTile(
      leading: hasImages
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                listing.imageUrls.first,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _PlaceholderAvatar(),
              ),
            )
          : const _PlaceholderAvatar(),
      title: Text(listing.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(listing.description, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(createdLabel, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      trailing: Text(
        priceFormatter.format(listing.price),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ListingDetailSheet(listing: listing),
        );
      },
    );
  }
}

class _PlaceholderAvatar extends StatelessWidget {
  const _PlaceholderAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.storefront_outlined),
    );
  }
}

class _ListingsError extends StatelessWidget {
  const _ListingsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final listingsState = context.read<ListingsState>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: listingsState.refresh,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
