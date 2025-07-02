import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:flutter/material.dart';

class CategorySelector extends StatefulWidget {
  final List<String> existingCategories;
  final ValueChanged<String> onCategorySelected;

   CategorySelector({Key? key, required this.existingCategories, required this.onCategorySelected, String? selectedCategory,}) : super(key: key);

  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  String? selectedCategory;
  bool isAddingNewCategory = false;
  final TextEditingController newCategoryController = TextEditingController();

  @override
  void dispose() {
    newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    List<String> categories = ['+ Yeni Kategori Ekle', ...widget.existingCategories];

    return  ConstrainedBox(
  constraints: BoxConstraints(
    maxHeight: 300, // İhtiyaca göre ayarlanabilir
  ),
  child: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          isDense: true,
          dropdownColor: AppPallete.backgroundColor,
          value: selectedCategory,
          hint: Text('Kategori Seç'),
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            if (value == '+ Yeni Kategori Ekle') {
              setState(() {
                isAddingNewCategory = true;
                selectedCategory = null;
              });
            } else {
              setState(() {
                selectedCategory = value;
                isAddingNewCategory = false;
              });
              widget.onCategorySelected(value!);
            }
          },
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        if (isAddingNewCategory) ...[
          TextFormField(
            controller: newCategoryController,
            decoration: InputDecoration(
              labelText: 'Yeni Kategori',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (newCategoryController.text.trim().isNotEmpty) {
                setState(() {
                  selectedCategory = newCategoryController.text.trim();
                  isAddingNewCategory = false;
                  widget.existingCategories.add(selectedCategory!);
                  widget.onCategorySelected(selectedCategory!);
                  newCategoryController.clear();
                });
              }
            },
            child: Text('Kaydet'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              textStyle: TextStyle(fontSize: 14),
              backgroundColor: AppPallete.gradient2,
            ),
          ),
        ],
        const SizedBox(height: 5),
        if (selectedCategory != null)
          Text(
            'Seçilen Kategori: $selectedCategory',
            style: TextStyle(fontSize: 13, color: AppPallete.gradient1),
          ),
      ],
    ),
  ),
);

  }
}
