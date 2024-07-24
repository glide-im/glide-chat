part of 'session_page.dart';

class SessionInfo extends StatelessWidget {
  final Session session;

  const SessionInfo({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        SearchBarTheme(
          data: SearchBarThemeData(
              padding: const MaterialStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 12)),
              elevation: const MaterialStatePropertyAll(1),
              textStyle: MaterialStatePropertyAll(
                context.theme.textTheme.bodyMedium,
              ),
              constraints: const BoxConstraints(minHeight: 32)),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SearchBar(
              leading: Icon(Icons.search, size: 18),
              hintText: "Search",
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: 100,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (item, index) {
              return _SessionMember();
            },
          ),
        ),
      ],
    );
  }
}

class _SessionMember extends StatelessWidget {
  bool get isAdmin => false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage("https://picsum.photos/200"),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "User Name",
                  style: context.theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          if (isAdmin) const SizedBox(width: 8),
          if (isAdmin)
            Text(
              "Admin",
              style: context.theme.textTheme.bodySmall?.copyWith(
                color: context.theme.colorScheme.secondary,
              ),
            ),
        ],
      ),
    );
  }
}
