import 'package:flutter/material.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/categories/components/category_list_tile_widget.dart';
import 'package:stockall/pages/categories/platforms/categories_page_desktop.dart';

class CategoriesPageMobile extends StatefulWidget {
  const CategoriesPageMobile({super.key});

  @override
  State<CategoriesPageMobile> createState() =>
      _CategoriesPageMobileState();
}

class _CategoriesPageMobileState
    extends State<CategoriesPageMobile> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Categories',
        backAction: () {
          Navigator.of(context).pop();
        },
        widget: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: CreateCategoryWidget(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15.0,
          ),
          child: Column(
            children: [
              SizedBox(height: 20),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (returnCategoriesProvider()
                        .categories()
                        .isEmpty) {
                      return Material(
                        color: Colors.transparent,
                        child: EmptyWidgetDisplayOnly(
                          title: 'No Categories Added',
                          subText:
                              'You have not added any Category.',
                          theme: theme,
                          height: 25,
                          altAction: () {
                            returnCategoriesProvider()
                                .getCategories(shopId());
                          },
                          altActionText: 'Refresh',
                          altIcon: Icons.refresh,
                          icon: Icons.clear,
                        ),
                      );
                    } else {
                      return RefreshIndicator(
                        onRefresh: () {
                          return returnCategoriesProvider()
                              .getCategories(shopId());
                        },
                        backgroundColor: Colors.white,
                        color:
                            theme
                                .lightModeColor
                                .secColor200,
                        displacement: 10,
                        strokeWidth: 2,
                        child: ListView(
                          // shrinkWrap: true,
                          children:
                              returnCategoriesProvider(
                                    context: context,
                                  )
                                  .categories()
                                  .map(
                                    (category) =>
                                        CategoryListTileWidget(
                                          categoryUuid:
                                              category.uuid,
                                        ),
                                  )
                                  .toList(),
                        ),
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
