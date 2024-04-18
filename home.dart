import 'package:flutter/material.dart';
import 'package:flutter_pos_app/data/repository.dart';
import 'package:flutter_pos_app/domain/entities/category.dart';
import 'package:flutter_pos_app/domain/entities/item.dart';
import 'package:flutter_pos_app/presentation/widgets/category_list.dart';
import 'package:flutter_pos_app/presentation/widgets/items_grid.dart';
import 'package:flutter_pos_app/presentation/widgets/top_menu.dart';
import 'package:flutter_pos_app/presentation/widgets/totals_section.dart';
import 'package:responsive_builder/responsive_builder.dart';

class HomePage extends StatefulWidget {
  final IDashboardRepository repository;

  const HomePage({Key? key, required this.repository}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Category selectedCategory;
  List<Item> selectedItems = [];

  @override
  void initState() {
    super.initState();
    selectedCategory = Category(name: 'Burger', imagePath: '', isActive: true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        widget.repository.getCategoriesFromLocal(),
        widget.repository.getItems(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Category> categories = snapshot.data![0];
          List<Item> items = snapshot.data![1];
          return _buildBody(categories, items);
        }
      },
    );
  }

  Widget _buildBody(List<Category> categories, List<Item> items) {
    return ResponsiveBuilder(
      builder: (BuildContext context, SizingInformation sizingInformation) {
        return Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 14,
                  child: Column(
                    children: [
                      TopMenu(
                        title: 'Smarter POS',
                        subTitle: DateTime.now().toIso8601String(),
                        action: _search(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: CategoryList(
                          categories: categories,
                          onCategorySelected: onCategorySelected,
                          selectedCategory: selectedCategory,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Selected Category: ${selectedCategory.name}',
                        style: TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: ItemsGrid(
                          items: items
                              .where(
                                  (item) => item.category == selectedCategory.name)
                              .toList(),
                          onItemSelected: onItemSelected,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                if (sizingInformation.isDesktop)
                  Expanded(
                    flex: 5,
                    child: TotalsSection(selectedItems: selectedItems),
                  )
              ],
            ),
            if (sizingInformation.isTablet || sizingInformation.isMobile)
              Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 5),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white24,
                    tooltip: 'Show totals',
                    onPressed: () {
                      showModalBottomSheet<void>(
                        backgroundColor: const Color(0xff1f2029),
                        context: context,
                        builder: (BuildContext context) {
                          return TotalsSection(selectedItems: selectedItems);
                        },
                      );
                    },
                    child: const Icon(
                      Icons.summarize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void onCategorySelected(Category category) {
    setState(() {
      selectedCategory = category;
    });
    print("Category: ${category.name}");
  }

  void onItemSelected(Item item) {
    setState(() {
      selectedItems.add(item);
    });
    print("Selected item details:");
    print("Name: ${item.name}");
    print("Image Path: ${item.imagePath}");
    print("Quantity: ${item.quantity}");
    print("Price: \$${item.prices.first.amount.toStringAsFixed(2)}");
  }

  Widget _search() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xff1f2029),
      ),
      child: Row(
        children: const [
          Icon(
            Icons.search,
            color: Colors.white54,
          ),
          SizedBox(width: 10),
          Text(
            'Search menu here...',
            style: TextStyle(color: Colors.white54, fontSize: 11),
          )
        ],
      ),
    );
  }
}
