import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProductsScreen extends StatefulWidget {
  final void Function(int) onCartCountChange;
  const ProductsScreen({super.key, required this.onCartCountChange});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _books = [];
  List<dynamic> _magazines = [];
  List<dynamic> _audioBooks = [];
  bool _loading = true;
  bool get _isAdmin => ApiService.instance.isAdmin;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.instance.getBooks(),
        ApiService.instance.getMagazines(),
        ApiService.instance.getAudioBooks(),
      ]);
      setState(() {
        _books = results[0];
        _magazines = results[1];
        _audioBooks = results[2];
      });
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  // ── Add to Cart ────────────────────────────────────────────────────────────

  Future<void> _addToCart(int productId) async {
    try {
      final cart = await ApiService.instance.addToCart(productId);
      widget.onCartCountChange((cart['products'] as List).length);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to cart!'), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── Delete helpers ─────────────────────────────────────────────────────────

  Future<bool> _confirmDelete(String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete'),
            content: Text('Delete "$name"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
    );
  }

  // ── Book actions ───────────────────────────────────────────────────────────

  Future<void> _deleteBook(dynamic b) async {
    if (!await _confirmDelete(b['title'])) return;
    try {
      await ApiService.instance.deleteBook(b['id']);
      setState(() => _books.removeWhere((x) => x['id'] == b['id']));
    } catch (e) { _showError(e); }
  }

  Future<void> _showBookForm({dynamic book}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _BookFormDialog(book: book),
    );
    if (result == null) return;
    try {
      if (book == null) {
        await ApiService.instance.addBook(result);
      } else {
        await ApiService.instance.updateBook(book['id'], result);
      }
      await _loadAll();
    } catch (e) { _showError(e); }
  }

  // ── Magazine actions ───────────────────────────────────────────────────────

  Future<void> _deleteMagazine(dynamic m) async {
    if (!await _confirmDelete(m['title'])) return;
    try {
      await ApiService.instance.deleteMagazine(m['id']);
      setState(() => _magazines.removeWhere((x) => x['id'] == m['id']));
    } catch (e) { _showError(e); }
  }

  Future<void> _showMagazineForm({dynamic magazine}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _MagazineFormDialog(magazine: magazine),
    );
    if (result == null) return;
    try {
      if (magazine == null) {
        await ApiService.instance.addMagazine(result);
      } else {
        await ApiService.instance.updateMagazine(magazine['id'], result);
      }
      await _loadAll();
    } catch (e) { _showError(e); }
  }

  // ── AudioBook actions ──────────────────────────────────────────────────────

  Future<void> _deleteAudioBook(dynamic a) async {
    if (!await _confirmDelete(a['title'])) return;
    try {
      await ApiService.instance.deleteAudioBook(a['id']);
      setState(() => _audioBooks.removeWhere((x) => x['id'] == a['id']));
    } catch (e) { _showError(e); }
  }

  Future<void> _showAudioBookForm({dynamic audioBook}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _AudioBookFormDialog(audioBook: audioBook),
    );
    if (result == null) return;
    try {
      if (audioBook == null) {
        await ApiService.instance.addAudioBook(result);
      } else {
        await ApiService.instance.updateAudioBook(audioBook['id'], result);
      }
      await _loadAll();
    } catch (e) { _showError(e); }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.book), text: 'Books'),
            Tab(icon: Icon(Icons.newspaper), text: 'Magazines'),
            Tab(icon: Icon(Icons.headphones), text: 'Audio'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTab(_books, _buildBookCard,
                  onAdd: _isAdmin ? () => _showBookForm() : null),
              _buildTab(_magazines, _buildMagazineCard,
                  onAdd: _isAdmin ? () => _showMagazineForm() : null),
              _buildTab(_audioBooks, _buildAudioBookCard,
                  onAdd: _isAdmin ? () => _showAudioBookForm() : null),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(List<dynamic> items, Widget Function(dynamic) cardBuilder, {VoidCallback? onAdd}) {
    return Stack(
      children: [
        items.isEmpty
            ? const Center(child: Text('Nothing here yet.'))
            : RefreshIndicator(
                onRefresh: _loadAll,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                  itemCount: items.length,
                  itemBuilder: (_, i) => cardBuilder(items[i]),
                ),
              ),
        if (onAdd != null)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: onAdd,
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }

  Widget _buildBookCard(dynamic b) {
    final soldOut = (b['copies'] ?? 1) == 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.book, color: Colors.indigo),
        title: Text(b['title'] ?? ''),
        subtitle: Text(
          _isAdmin
              ? '${b['author'] ?? ''}  •  \$${(b['price'] as num).toStringAsFixed(2)}  •  Copies: ${b['copies'] ?? '?'}'
              : '${b['author'] ?? ''}  •  \$${(b['price'] as num).toStringAsFixed(2)}',
        ),
        trailing: _isAdmin
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showBookForm(book: b)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteBook(b)),
              ])
            : soldOut
                ? const Text('SOLD OUT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                : IconButton(icon: const Icon(Icons.add_shopping_cart, color: Colors.green), onPressed: () => _addToCart(b['id'])),
      ),
    );
  }

  Widget _buildMagazineCard(dynamic m) {
    final soldOut = (m['copies'] ?? 1) == 0;
    final issue = (m['currentIssue'] as String?)?.substring(0, 10) ?? '';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.newspaper, color: Colors.teal),
        title: Text(m['title'] ?? ''),
        subtitle: Text(
          _isAdmin
              ? 'Issue: $issue  •  \$${(m['price'] as num).toStringAsFixed(2)}  •  Copies: ${m['copies'] ?? '?'}'
              : 'Issue: $issue  •  \$${(m['price'] as num).toStringAsFixed(2)}',
        ),
        trailing: _isAdmin
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showMagazineForm(magazine: m)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteMagazine(m)),
              ])
            : soldOut
                ? const Text('SOLD OUT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                : IconButton(icon: const Icon(Icons.add_shopping_cart, color: Colors.green), onPressed: () => _addToCart(m['id'])),
      ),
    );
  }

  Widget _buildAudioBookCard(dynamic a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.headphones, color: Colors.deepPurple),
        title: Text(a['title'] ?? ''),
        subtitle: Text('${a['author'] ?? ''}  •  Narrator: ${a['narrator'] ?? ''}  •  \$${(a['price'] as num).toStringAsFixed(2)}'),
        trailing: _isAdmin
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showAudioBookForm(audioBook: a)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteAudioBook(a)),
              ])
            : IconButton(icon: const Icon(Icons.add_shopping_cart, color: Colors.green), onPressed: () => _addToCart(a['id'])),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// ── Book Form Dialog ───────────────────────────────────────────────────────────

class _BookFormDialog extends StatefulWidget {
  final dynamic book;
  const _BookFormDialog({this.book});

  @override
  State<_BookFormDialog> createState() => _BookFormDialogState();
}

class _BookFormDialogState extends State<_BookFormDialog> {
  late final TextEditingController _title;
  late final TextEditingController _author;
  late final TextEditingController _price;
  late final TextEditingController _copies;

  @override
  void initState() {
    super.initState();
    _title  = TextEditingController(text: widget.book?['title']?.toString() ?? '');
    _author = TextEditingController(text: widget.book?['author']?.toString() ?? '');
    _price  = TextEditingController(text: widget.book?['price']?.toString() ?? '');
    _copies = TextEditingController(text: widget.book?['copies']?.toString() ?? '10');
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.book != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Book' : 'Add Book'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _field(_title, 'Title'),
          _field(_author, 'Author'),
          _field(_price, 'Price', numeric: true),
          _field(_copies, 'Copies', numeric: true),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, {
            'title': _title.text,
            'author': _author.text,
            'price': double.tryParse(_price.text) ?? 0,
            'copies': int.tryParse(_copies.text) ?? 0,
          }),
          child: Text(isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

// ── Magazine Form Dialog ───────────────────────────────────────────────────────

class _MagazineFormDialog extends StatefulWidget {
  final dynamic magazine;
  const _MagazineFormDialog({this.magazine});

  @override
  State<_MagazineFormDialog> createState() => _MagazineFormDialogState();
}

class _MagazineFormDialogState extends State<_MagazineFormDialog> {
  late final TextEditingController _title;
  late final TextEditingController _price;
  late final TextEditingController _copies;
  late final TextEditingController _orderQty;
  late final TextEditingController _issue; // yyyy-MM-ddTHH:mm:ss

  @override
  void initState() {
    super.initState();
    _title    = TextEditingController(text: widget.magazine?['title']?.toString() ?? '');
    _price    = TextEditingController(text: widget.magazine?['price']?.toString() ?? '');
    _copies   = TextEditingController(text: widget.magazine?['copies']?.toString() ?? '10');
    _orderQty = TextEditingController(text: widget.magazine?['orderQty']?.toString() ?? '0');
    final raw = widget.magazine?['currentIssue'] as String?;
    _issue    = TextEditingController(text: raw != null ? raw.substring(0, 10) : '');
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.magazine != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Magazine' : 'Add Magazine'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _field(_title, 'Title'),
          _field(_price, 'Price', numeric: true),
          _field(_copies, 'Copies', numeric: true),
          _field(_orderQty, 'Order Qty', numeric: true),
          _field(_issue, 'Issue Date (yyyy-MM-dd)'),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final issueDate = _issue.text.length == 10 ? '${_issue.text}T00:00:00' : _issue.text;
            Navigator.pop(context, {
              'title': _title.text,
              'price': double.tryParse(_price.text) ?? 0,
              'copies': int.tryParse(_copies.text) ?? 0,
              'orderQty': int.tryParse(_orderQty.text) ?? 0,
              'currentIssue': issueDate,
            });
          },
          child: Text(isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

// ── AudioBook Form Dialog ──────────────────────────────────────────────────────

class _AudioBookFormDialog extends StatefulWidget {
  final dynamic audioBook;
  const _AudioBookFormDialog({this.audioBook});

  @override
  State<_AudioBookFormDialog> createState() => _AudioBookFormDialogState();
}

class _AudioBookFormDialogState extends State<_AudioBookFormDialog> {
  late final TextEditingController _title;
  late final TextEditingController _author;
  late final TextEditingController _price;
  late final TextEditingController _narrator;
  late final TextEditingController _url;

  @override
  void initState() {
    super.initState();
    _title    = TextEditingController(text: widget.audioBook?['title']?.toString() ?? '');
    _author   = TextEditingController(text: widget.audioBook?['author']?.toString() ?? '');
    _price    = TextEditingController(text: widget.audioBook?['price']?.toString() ?? '');
    _narrator = TextEditingController(text: widget.audioBook?['narrator']?.toString() ?? '');
    _url      = TextEditingController(text: widget.audioBook?['downloadUrl']?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.audioBook != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Audio Book' : 'Add Audio Book'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _field(_title, 'Title'),
          _field(_author, 'Author'),
          _field(_price, 'Price', numeric: true),
          _field(_narrator, 'Narrator'),
          _field(_url, 'Download URL'),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, {
            'title': _title.text,
            'author': _author.text,
            'price': double.tryParse(_price.text) ?? 0,
            'narrator': _narrator.text,
            'downloadUrl': _url.text,
          }),
          child: Text(isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

// ── Shared field widget ────────────────────────────────────────────────────────

Widget _field(TextEditingController ctrl, String label, {bool numeric = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
    ),
  );
}
