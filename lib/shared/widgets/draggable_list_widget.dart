/// Draggable list widget for reordering items
/// Supports drag and drop to reorder items with order_index
import 'package:flutter/material.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item, int index);
typedef OnReorder<T> = Future<void> Function(List<T> reorderedItems);

class DraggableListWidget<T> extends StatefulWidget {
  final List<T> items;
  final ItemBuilder<T> itemBuilder;
  final OnReorder<T> onReorder;
  final String? emptyMessage;
  final Widget? emptyWidget;

  const DraggableListWidget({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onReorder,
    this.emptyMessage,
    this.emptyWidget,
  });

  @override
  State<DraggableListWidget<T>> createState() => _DraggableListWidgetState<T>();
}

class _DraggableListWidgetState<T> extends State<DraggableListWidget<T>> {
  late List<T> _items;
  bool _isReordering = false;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  void didUpdateWidget(DraggableListWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _items = List.from(widget.items);
    }
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    setState(() {
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
      _isReordering = true;
    });

    try {
      await widget.onReorder(_items);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _items = List.from(widget.items);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReordering = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return widget.emptyWidget ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.drag_handle, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  widget.emptyMessage ?? 'No items to display',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
    }

    return ReorderableListView(
      onReorder: _handleReorder,
      children: _items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return _ReorderableItemWrapper(
          key: ValueKey('item_${item.hashCode}_$index'),
          index: index,
          isReordering: _isReordering,
          child: widget.itemBuilder(context, item, index),
        );
      }).toList(),
    );
  }
}

class _ReorderableItemWrapper extends StatelessWidget {
  final int index;
  final bool isReordering;
  final Widget child;

  const _ReorderableItemWrapper({
    required super.key,
    required this.index,
    required this.isReordering,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: child,
    );
  }
}

