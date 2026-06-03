import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/notification_utils.dart';
import 'entity_provider.dart';
import 'form_entity_page.dart';
import 'entity_detail_page.dart';

class EntityListPage extends StatefulWidget {
  const EntityListPage({super.key});

  @override
  State<EntityListPage> createState() => _EntityListPageState();
}

class _EntityListPageState extends State<EntityListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<EntityProvider>(context, listen: false).getEntity();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰MoneyApp-xValeGroup'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<EntityProvider>(
        builder: (context, provider, child) {
          // 1. Loading State
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.getEntity(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          // 3. Empty List State (Fixed Here)
          if (provider.entities.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada catatan keuangan',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Klik + untuk membuat baru',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Filter logic for search bar
          final filteredEntities = _searchQuery.isEmpty
              ? provider.entities
              : provider.entities.where((entity) {
                  final query = _searchQuery.toLowerCase();
                  return entity.nama.toLowerCase().contains(query) ||
                      entity.deskripsi.toLowerCase().contains(query);
                }).toList();

          // 4. No Search Results State
          if (filteredEntities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 72, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Tidak ada hasil pencarian',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Text('Reset Pencarian'),
                  ),
                ],
              ),
            );
          }

          // 5. Success Data List State
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari entity...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.getEntity,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredEntities.length,
                    itemBuilder: (context, index) {
                      final entity = filteredEntities[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EntityDetailPage(entity: entity),
                              ),
                            ).then((_) => provider.getEntity());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.folder,
                                    color: Colors.blue,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entity.nama,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (entity.deskripsi.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          entity.deskripsi,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      if (entity.tanggalMulai.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          "${entity.tanggalMulai} - ${entity.tanggalSelesai.isEmpty ? 'sekarang' : entity.tanggalSelesai}",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'hapus',
                                      child: Text('Hapus'),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FormEntityPage(entity: entity),
                                        ),
                                      ).then((_) => provider.getEntity());
                                    } else if (value == 'hapus') {
                                      showDialog(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                          title: const Text('Hapus Entity?'),
                                          content: Text('Yakin hapus "${entity.nama}"?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(dialogContext),
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.pop(dialogContext);
                                                await provider.hapusEntity(entity.id);
                                                if (!context.mounted) return;
                                                if (provider.errorMessage.isNotEmpty) {
                                                  NotificationUtils.showError(
                                                    context,
                                                    'Gagal menghapus entity: ${provider.errorMessage}',
                                                  );
                                                } else {
                                                  NotificationUtils.showSuccess(
                                                    context,
                                                    'Entity "${entity.nama}" berhasil dihapus.',
                                                  );
                                                }
                                              },
                                              child: const Text(
                                                'Hapus',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final entityProvider = Provider.of<EntityProvider>(context, listen: false);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormEntityPage()),
          ).then((_) => entityProvider.getEntity());
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}