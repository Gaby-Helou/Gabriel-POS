import 'package:flutter/material.dart';
import 'package:flutter_pos_app/domain/entities/item.dart';
import 'package:flutter_pos_app/data/local_data_source.dart';
import 'package:flutter_pos_app/presentation/widgets/top_menu.dart';

class TotalsSection extends StatefulWidget {
  final List<Item> selectedItems;

  const TotalsSection({Key? key, required this.selectedItems}) : super(key: key);

  @override
  _TotalsSectionState createState() => _TotalsSectionState();


}

class _TotalsSectionState extends State<TotalsSection> {
  final LocalDataSource localDataSource = LocalDataSource();
  late String subTotal;
  late String tax;
  late String total;

  @override
  void initState() {
    super.initState();
    subTotal = '0.00';
    tax = '0.00';
    total = '0.00';
    _updateTotals();
  }

  void _updateTotals() {
    Map<String, int> itemCounts = {};
    widget.selectedItems.forEach((item) {
      itemCounts.update(
        item.imagePath,
            (value) => value + 1,
            ifAbsent: () => 1,);});
    double subTotalValue = 0.0;
    itemCounts.forEach((imagePath, quantity) {
      final selectedItem = widget.selectedItems.firstWhere(
            (item) => item.imagePath == imagePath,
      );
      subTotalValue += selectedItem.prices.first.amount * quantity;
    });
    double taxValue = subTotalValue * 0.12;//12%
    double totalValue = subTotalValue + taxValue;
    setState(() {
      subTotal = subTotalValue.toStringAsFixed(2);
      tax = taxValue.toStringAsFixed(2);
      total = totalValue.toStringAsFixed(2);
      widget.selectedItems.forEach((item) {
        final newQuantity = itemCounts[item.imagePath]!;
        item.quantity = newQuantity;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopMenu(
          title: 'Order',
          subTitle: 'Table 8',
          action: Container(),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: widget.selectedItems.length,
            itemBuilder: (context, index) {
              final item = widget.selectedItems[index];
              return _itemOrder(
                image: item.imagePath,
                title: item.name,
                qty: item.quantity.toString(),
                price: '\$${item.prices.first.amount.toStringAsFixed(2)}',
                onRemove: () {
                  _removeItem(index);
                },
              );
            },
          ),
        ),
        _buildTotalsSection(),
      ],
    );
  }

  Widget _itemOrder({
    required String image,
    required String title,
    required String qty,
    required String price,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xff1f2029),
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
          Text(
            '$qty x',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(
              Icons.remove_circle,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsSection() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xff1f2029),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sub Total',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '\$$subTotal',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tax',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '\$$tax',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              height: 2,
              width: double.infinity,
              color: Colors.white,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '\$$total',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _showBill();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.print, size: 16),
                  SizedBox(width: 6),
                  Text('Show Bill'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      widget.selectedItems.removeAt(index);
      _updateTotals();
    });
  }

  void _showBill() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bill'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sub Total: \$ $subTotal'),
              Text('Tax: \$ $tax'),
              Text('Total: \$ $total'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
