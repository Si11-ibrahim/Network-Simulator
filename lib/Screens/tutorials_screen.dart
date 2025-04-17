import 'package:flutter/material.dart';
import 'package:network_simulator/Constants/appStyles.dart';
import 'package:network_simulator/Constants/constants.dart';
import 'package:network_simulator/Services/Provider/tutorial_provider.dart';
import 'package:network_simulator/Widgets/app_bar.dart';
import 'package:provider/provider.dart';

class TutorialsScreen extends StatelessWidget {
  const TutorialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size(20, 30),
          child: myAppBar('Network Tutorials', showBackButton: true)),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: bgColor,
              child: TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      'TOPOLOGIES',
                      style: AppStyles.mediumWhiteTextStyle(),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'CONCEPTS',
                      style: AppStyles.mediumWhiteTextStyle(),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'PROTOCOLS',
                      style: AppStyles.mediumWhiteTextStyle(),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _TutorialCategoryView(category: 'topologies'),
                  _TutorialCategoryView(category: 'concepts'),
                  _TutorialCategoryView(category: 'protocols'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialCategoryView extends StatelessWidget {
  final String category;

  const _TutorialCategoryView({required this.category});

  @override
  Widget build(BuildContext context) {
    final tutorialProvider = Provider.of<TutorialProvider>(context);
    final tutorials = tutorialProvider.getTutorialsByCategory(category);

    if (tutorials.isEmpty) {
      return const Center(
        child: Text('No tutorials available in this category.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tutorials.length,
      itemBuilder: (context, index) {
        final tutorial = tutorials[index];
        final isCompleted = tutorialProvider.isTutorialCompleted(tutorial.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: InkWell(
            onTap: () => tutorialProvider.startTutorial(tutorial.id),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        color: bgColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tutorial.name,
                          style: AppStyles.bigBlackTextStyle(isBold: true),
                        ),
                      ),
                      if (isCompleted)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tutorial.description,
                    style: AppStyles.mediumBlackTextStyle(),
                  ),
                  const SizedBox(height: 8),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     MyButtons.smallButton(
                  //       isCompleted ? 'Review' : 'Start',
                  //       () => tutorialProvider.startTutorial(tutorial.id),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'topologies':
        return Icons.device_hub;
      case 'concepts':
        return Icons.lightbulb;
      case 'protocols':
        return Icons.lan;
      default:
        return Icons.school;
    }
  }
}
