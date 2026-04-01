import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/adhkar_category.dart';
import '../../bloc/adhkar_reader_cubit.dart';
import 'mobile_adhkar_category_card.dart';

class MobileAdhkarCategoryGrid extends StatelessWidget {
  final List<AdhkarCategory> categories;

  const MobileAdhkarCategoryGrid({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 120),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 170,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return MobileAdhkarCategoryCard(
            category: category,
            onTap: () {
              context.read<AdhkarReaderCubit>().openCategory(category);
            },
          );
        },
      ),
    );
  }
}
