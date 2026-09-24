import 'package:flutter/material.dart';
import '../apptheme.dart';

class MediaLinksDocsScreen extends StatefulWidget {
  final String receiverName;

  const MediaLinksDocsScreen({
    Key? key,
    required this.receiverName,
  }) : super(key: key);

  @override
  State<MediaLinksDocsScreen> createState() => _MediaLinksDocsScreenState();
}

class _MediaLinksDocsScreenState extends State<MediaLinksDocsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textPrimary = isDark ? AppTheme.darkLightText : AppTheme.lightDarkText;
    final textSecondary = isDark ? AppTheme.darkNavInactive : AppTheme.lightNavInactive;
    final primaryColor = isDark ? AppTheme.darkNavActive : AppTheme.lightNavActive;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.receiverName,
          style: TextStyle(
            color: textPrimary,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          indicatorWeight: 3,
          labelColor: primaryColor,
          unselectedLabelColor: textSecondary,
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          dividerColor: isDark
              ? textPrimary.withOpacity(0.06)
              : textSecondary.withOpacity(0.2),
          tabs: const [
            Tab(text: 'Media'),
            Tab(text: 'Docs'),
            Tab(text: 'Links'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMediaTab(isDark, textSecondary, surfaceColor),
          _buildDocsTab(isDark, textPrimary, textSecondary, surfaceColor, primaryColor),
          _buildLinksTab(isDark, textPrimary, textSecondary, surfaceColor, primaryColor),
        ],
      ),
    );
  }

  Widget _buildMediaTab(bool isDark, Color textSecondary, Color surfaceColor) {
    // Dummy media grid
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Container(
          color: surfaceColor.withOpacity(0.5),
          child: Center(
            child: Icon(
              index % 3 == 0 ? Icons.videocam : Icons.image,
              color: textSecondary.withOpacity(0.3),
              size: 32,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocsTab(bool isDark, Color textPrimary, Color textSecondary,
      Color surfaceColor, Color primaryColor) {
    final docs = [
      {'name': 'Project_Proposal.pdf', 'size': '2.4 MB', 'date': 'Today'},
      {'name': 'Meeting_Notes.docx', 'size': '156 KB', 'date': 'Yesterday'},
      {'name': 'Budget_2026.xlsx', 'size': '890 KB', 'date': '2 days ago'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description,
              color: primaryColor,
            ),
          ),
          title: Text(
            doc['name']!,
            style: TextStyle(
              color: textPrimary,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '${doc['size']} · ${doc['date']}',
            style: TextStyle(
              color: textSecondary,
              fontFamily: 'Poppins',
              fontSize: 12,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.more_vert, color: textSecondary),
            onPressed: () {},
          ),
        );
      },
    );
  }

  Widget _buildLinksTab(bool isDark, Color textPrimary, Color textSecondary,
      Color surfaceColor, Color primaryColor) {
    final links = [
      {'url': 'https://flutter.dev', 'title': 'Flutter - Build apps for any screen', 'date': 'Today'},
      {'url': 'https://pub.dev', 'title': 'Dart packages', 'date': 'Yesterday'},
      {'url': 'https://github.com', 'title': 'GitHub - Let\'s build from here', 'date': '3 days ago'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: links.length,
      itemBuilder: (context, index) {
        final link = links[index];
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.link,
              color: primaryColor,
            ),
          ),
          title: Text(
            link['title']!,
            style: TextStyle(
              color: textPrimary,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            link['url']!,
            style: TextStyle(
              color: primaryColor,
              fontFamily: 'Poppins',
              fontSize: 12,
            ),
          ),
          trailing: Text(
            link['date']!,
            style: TextStyle(
              color: textSecondary,
              fontFamily: 'Poppins',
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }
}
