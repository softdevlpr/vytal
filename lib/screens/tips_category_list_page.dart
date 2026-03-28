class TipsCategoryListPage extends StatelessWidget {
  final List categories;

  const TipsCategoryListPage({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F011E),
      appBar: AppBar(
        title: const Text("Recommended Tips"),
        backgroundColor: const Color(0xFF0F011E),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          final String categoryName = category["category"] ?? "Unknown";
          final List tips = category["tips"] ?? [];

          return Card(
            color: const Color(0xFF1E1E2C),
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(
                categoryName,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "${tips.length} tips",
                style: const TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryTipsPage(
                      category: categoryName,
                      tips: tips,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
