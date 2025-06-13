import 'package:book_journal/ui/screens/widgets/onBoarding.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/ink-layer.png",
      "title": "Oku",
      "description": "Haklarını öğren, kendini geliştir!"
    },
    {
      "image": "assets/images/ink-layer.png",
      "title": "Keşfet",
      "description": "Yeni bilgilerle dünyanı genişlet!"
    },
    {
      "image": "assets/images/ink-layer.png",
      "title": "Paylaş",
      "description": "Öğrendiklerini arkadaşlarınla paylaş!"
    },
    {
      "image": "assets/images/ink-layer.png",
      "title": "Eğlen",
      "description": "Öğrenirken keyif al, oyunlarla haklarını keşfet!"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;

          return Container(
            decoration: BoxDecoration(
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 50, 10, 20),
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: controller,
                      itemCount: onboardingData.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        return OnBoarding(
                          image: onboardingData[index]["image"]!,
                          title: onboardingData[index]["title"]!,
                          description: onboardingData[index]["description"]!,
                          controller: controller,
                          showSmoothIndicator:
                              index != onboardingData.length - 1,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  _currentPage == onboardingData.length - 1
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ElevatedButton(
                                      onPressed: () {
                                        controller.nextPage(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeIn);
                                      },
                                      child: Text("Örnek Yazı1"),
                                    ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (_currentPage > 0)
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: SizedBox(
                                  width: width * 0.3,
                                  height: height * 0.06,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        controller.nextPage(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeIn);
                                      },
                                      child: Text("Örnek Yazı2"),
                                    ),
                                ),
                              ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: _currentPage == 0
                                  ? FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: SizedBox(
                                        width: width * 0.3,
                                        height: height * 0.06,
                                        child: ElevatedButton(
                                      onPressed: () {
                                        controller.nextPage(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeIn);
                                      },
                                      child: Text("Örnek Yazı3"),
                                    ),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: () {
                                        controller.nextPage(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeIn);
                                      },
                                      child: Text("Örnek Yazı4"),
                                    ),
                            ),
                          ],
                        ),
                  SizedBox(height: height * 0.1),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}