import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zero_world/state/theme_manager.dart';

/// Simple and easy customization screen
/// Users can customize colors, themes, fonts, and layout in one place
class CustomizationScreen extends StatelessWidget {
  const CustomizationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Your App'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Preview section
          _buildPreviewSection(context),

          const Divider(height: 32),

          // Theme mode section
          _buildThemeModeSection(context),

          const Divider(height: 32),

          // Color scheme section
          _buildColorSection(context),

          const Divider(height: 32),

          // Text size section
          _buildTextSizeSection(context),

          const Divider(height: 32),

          // Layout density section
          _buildLayoutSection(context),

          const SizedBox(height: 32),

          // Reset button
          _buildResetSection(context),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.palette,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Live Preview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'All changes apply instantly',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeSection(BuildContext context) {
    final themeManager = Provider.of<AppThemeManager>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme Mode',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('Auto'),
                icon: Icon(Icons.brightness_auto),
              ),
            ],
            selected: {themeManager.themeMode},
            onSelectionChanged: (Set<ThemeMode> selection) {
              themeManager.setThemeMode(selection.first);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection(BuildContext context) {
    final themeManager = Provider.of<AppThemeManager>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accent Color',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your favorite color',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AppThemeManager.colorSchemes.map((scheme) {
              final isSelected = themeManager.accentColor.value == scheme.color.value;
              return InkWell(
                onTap: () => themeManager.setAccentColor(scheme.color),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: scheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: Colors.white, width: 4) : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: scheme.color.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected) const Icon(Icons.check, color: Colors.white, size: 32),
                      const SizedBox(height: 4),
                      Text(
                        scheme.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSizeSection(BuildContext context) {
    final themeManager = Provider.of<AppThemeManager>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Text Size',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Make text easier to read',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.text_fields, size: 16),
              Expanded(
                child: Slider(
                  value: themeManager.fontSizeScale,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  label: '${(themeManager.fontSizeScale * 100).round()}%',
                  onChanged: (value) {
                    themeManager.setFontSizeScale(value);
                  },
                ),
              ),
              const Icon(Icons.text_fields, size: 32),
            ],
          ),
          Center(
            child: Text(
              'Sample Text',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutSection(BuildContext context) {
    final themeManager = Provider.of<AppThemeManager>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Layout Density',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Control spacing and information density',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          ...LayoutDensity.values.map((density) {
            final isSelected = themeManager.layoutDensity == density;
            return RadioListTile<LayoutDensity>(
              value: density,
              groupValue: themeManager.layoutDensity,
              onChanged: (value) {
                if (value != null) {
                  themeManager.setLayoutDensity(value);
                }
              },
              title: Text(density.displayName),
              subtitle: Text(_getLayoutDescription(density)),
              selected: isSelected,
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getLayoutDescription(LayoutDensity density) {
    switch (density) {
      case LayoutDensity.compact:
        return 'More content, less space';
      case LayoutDensity.comfortable:
        return 'Balanced spacing (recommended)';
      case LayoutDensity.spacious:
        return 'More breathing room';
    }
  }

  Widget _buildResetSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () {
          _showResetDialog(context);
        },
        icon: const Icon(Icons.restore),
        label: const Text('Reset to Defaults'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Customization?'),
        content: const Text(
          'This will reset all customization settings to their default values.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final themeManager = Provider.of<AppThemeManager>(context, listen: false);
              themeManager.setThemeMode(ThemeMode.system);
              themeManager.setAccentColor(Colors.blue);
              themeManager.setFontSizeScale(1.0);
              themeManager.setLayoutDensity(LayoutDensity.comfortable);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset successfully')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
