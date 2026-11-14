import 'package:flutter/material.dart';
import 'erp_destination.dart';

class WorkspaceSearchDialog extends StatefulWidget {
  const WorkspaceSearchDialog({super.key, required this.destinations});
  final List<ErpDestination> destinations;
  @override
  State<WorkspaceSearchDialog> createState() => _WorkspaceSearchDialogState();
}

class _WorkspaceSearchDialogState extends State<WorkspaceSearchDialog> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final items = widget.destinations
        .where(
            (item) => item.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
            width: 560,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * .75),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                          autofocus: true,
                          onChanged: (value) => setState(() => _query = value),
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: arabic
                                  ? 'ابحث في أقسام النظام...'
                                  : 'Search workspace modules...'))),
                  Flexible(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, index) => ListTile(
                              leading: Icon(items[index].icon),
                              title: Text(items[index].title),
                              trailing:
                                  const Icon(Icons.arrow_forward, size: 18),
                              onTap: () =>
                                  Navigator.pop(context, items[index].id)))),
                ]))));
  }
}
