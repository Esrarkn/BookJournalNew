import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:flutter/material.dart';

class CategorySelector extends StatefulWidget {
  final List<String> existingCategories;
  final ValueChanged<String> onCategorySelected;

   CategorySelector({Key? key, required this.existingCategories, required this.onCategorySelected,}) : super(key: key);

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
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
    widget.onCategorySelected(value!); // Seçilen kategoriyi yukarı bildir
  }
},
        ),
        const SizedBox(height: 16),
        if (isAddingNewCategory) ...[
          TextFormField(
            controller: newCategoryController,
            decoration: InputDecoration(
              labelText: 'Yeni Kategori',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
onPressed: () {
  if (newCategoryController.text.trim().isNotEmpty) {
    setState(() {
      selectedCategory = newCategoryController.text.trim();
      isAddingNewCategory = false;
      widget.existingCategories.add(selectedCategory!);
      widget.onCategorySelected(selectedCategory!); // Yeni kategori bildir
      newCategoryController.clear();
    });
  }
},
            child: Text('Kaydet'),
          ),
        ],
        const SizedBox(height: 5),
        if (selectedCategory != null)
          Text('Seçilen Kategori: $selectedCategory'),
      ],
    );
  }
}
