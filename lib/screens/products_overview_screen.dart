import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products_provider.dart';

import '../widgets/products_item.dart';

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _isInit = true;
  var _isLoading = false;
  final controller = TextEditingController();
  String name = "";
  String category = "";
  @override
  void initState() {
    //Provider.of<Products>(context).getProducts();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<Products>(context).getProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Widget filterButtonBuilder(String name, String productCategory) {
    return GestureDetector(
      onTap: () => setState(() {
        category = productCategory;
      }),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: category == productCategory
              ? Theme.of(context).accentColor
              : Colors.white,
          border: category == productCategory
              ? null
              : Border.all(color: Colors.grey, width: 1),
        ),
        margin: EdgeInsets.only(top: 15, bottom: 15, right: 10),
        width: 70,
        height: 40,
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              color: category == productCategory ? Colors.white : Colors.grey,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context, listen: false);
    List<Product> products = name.isEmpty
        ? productsData.items.where((product) {
            final productCategory = product.category.toLowerCase();
            String input = category.toLowerCase();

            return productCategory.contains(input);
          }).toList()
        : productsData.items.where((product) {
            final productTitle = product.name.toLowerCase();
            String input = name.toLowerCase();

            return productTitle.contains(input) ||
                product.category.toLowerCase().contains(input);
          }).toList();
    // void searchList(String query) {
    //   final suggestions = productsData.items.where((product) {
    //     final productTitle = product.name.toLowerCase();
    //     final input = query.toLowerCase();
    //     return productTitle.contains(input);
    //   }).toList();
    //   print(suggestions);
    //   setState(() => products = suggestions);
    // }

    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Container(
                  height: 50,
                  alignment: Alignment.topLeft,
                  child: TextField(
                    controller: controller,
                    onChanged: (value) {
                      setState(() {
                        name = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      hintText: 'Search',
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      filterButtonBuilder('All', ""),
                      filterButtonBuilder('Clothing', "clothing"),
                      filterButtonBuilder('Shoes', "men-shoes"),
                      filterButtonBuilder('Android', "android"),
                      filterButtonBuilder('Watches', "watch"),
                      filterButtonBuilder('Ladies', "women"),
                      filterButtonBuilder('iPhone', "iphone"),
                    ],
                  ),
                ),
                Expanded(
                  child: products.isEmpty
                      ? Center(
                          child: Text("Sorry, No products found"),
                        )
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3 / 5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (context, index) =>
                              ChangeNotifierProvider.value(
                            value: products[index],
                            child: Card(
                              elevation: 3,
                              child: ProductItem(
                                  // products[index].id,
                                  // products[index].title,
                                  // products[index].imageUrl,
                                  ),
                            ),
                          ),
                          itemCount: products.length,
                        ),
                ),
              ],
            ),
          );
  }
}
