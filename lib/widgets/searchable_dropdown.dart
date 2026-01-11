import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;
  final String? labelText;
  final String? Function(T?)? validator;
  final IconData? icon;
  final String? searchHint;

  const SearchableDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.labelText,
    this.validator,
    this.icon,
    this.searchHint,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<T>(
      isExpanded: true,
      value: widget.value,
      decoration: InputDecoration(
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: const Color(0xFF1E3A8A))
            : null,
        labelText: widget.labelText,
        labelStyle: const TextStyle(
          color: Color(0xFF1E3A8A),
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      dropdownSearchData: DropdownSearchData(
        searchController: _searchController,
        searchInnerWidgetHeight: 50,
        searchInnerWidget: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: widget.searchHint ?? 'Rechercher...',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (val) {
              setState(() {});
            },
          ),
        ),
        searchMatchFn: (DropdownMenuItem<T> item, String? searchValue) {
          final query = (searchValue ?? '').toLowerCase().trim();
          if (query.isEmpty) return true;
          final label =
              (widget.labelBuilder(item.value!)).toLowerCase();
          return label.contains(query);
        },
      ),
      items: widget.items.map((e) {
        return DropdownMenuItem<T>(
          value: e,
          child: Text(
            widget.labelBuilder(e),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1E3A8A),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
      onChanged: widget.onChanged,
      validator: widget.validator,
      onMenuStateChange: (isOpen) {
        if (!isOpen) {
          _searchController.clear();
          setState(() {});
        }
      },
    );
  }
}
