import 'package:flutter/material.dart';
import 'package:network_simulator/Constants/constants.dart';
import 'package:network_simulator/Services/Provider/tutorial_provider.dart';
import 'package:provider/provider.dart';

class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorialProvider>(
      builder: (context, tutorialProvider, child) {
        if (!tutorialProvider.tutorialMode ||
            tutorialProvider.currentStep == null) {
          return const SizedBox.shrink();
        }

        final step = tutorialProvider.currentStep!;
        final totalSteps = tutorialProvider.currentTutorial?.steps.length ?? 0;
        final currentIndex = tutorialProvider.currentStepIndex;

        return Stack(
          children: [
            // Semi-transparent overlay
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  if (step.dismissible) {
                    tutorialProvider.dismissTutorial();
                  }
                },
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),

            // Tutorial content dialog with opaque background
            Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: bgColor, // Use app background color from constants
                margin: const EdgeInsets.all(24),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  constraints: BoxConstraints(
                    maxWidth: 600,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with title
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              step.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: tutorialProvider.dismissTutorial,
                            tooltip: 'Close tutorial',
                          ),
                        ],
                      ),

                      const Divider(height: 24, color: Colors.white30),

                      // Tutorial content
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Description
                              Text(
                                step.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Images if available
                              if (step.imagePaths != null &&
                                  step.imagePaths!.isNotEmpty)
                                ...step.imagePaths!.map((imagePath) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          imagePath,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    )),
                            ],
                          ),
                        ),
                      ),

                      const Divider(height: 24, color: Colors.white30),

                      // Footer with navigation and progress
                      Column(
                        children: [
                          // Progress indicator
                          LinearProgressIndicator(
                            value: (currentIndex + 1) / totalSteps,
                            backgroundColor: Colors.grey[800],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.teal),
                          ),

                          const SizedBox(height: 8),

                          // Progress text
                          Text(
                            'Step ${currentIndex + 1} of $totalSteps',
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          // Navigation buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (currentIndex > 0)
                                TextButton(
                                  onPressed: tutorialProvider.previousStep,
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white70,
                                  ),
                                  child: const Text('Previous'),
                                ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: tutorialProvider.nextStep,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(currentIndex < totalSteps - 1
                                    ? 'Next'
                                    : 'Finish'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
