import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoarding extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final PageController controller;
  final bool showSmoothIndicator;

  const OnBoarding({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.controller,
    this.showSmoothIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        // Responsive Tasarım için Sabit Değerler
        double imageHeight = height * 0.45; // Resim yüksekliği
        double titleFontSize = width * 0.07; // Başlık font boyutu
        double descriptionFontSize = (width * 0.05)
            .clamp(12.0, 20.0)
            .clamp(12.0, 36.0); // Açıklama font boyutu
        double indicatorSize = width * 0.025; // Sayfa göstergesi boyutu

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: height, // Minimum ekran yüksekliğini koru
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(image, height: imageHeight),
                  SizedBox(
                      height: height *
                          0.05), // Resim ve indikatör arasındaki boşluk

                  // Sayfa göstergesi (SmoothPageIndicator)
                  if (showSmoothIndicator)
                    SmoothPageIndicator(
                      controller: controller,
                      count: 4,
                      effect: SlideEffect(
                        dotHeight: indicatorSize,
                        dotWidth: indicatorSize,
                        activeDotColor: const Color(0XFF8142EF),
                        dotColor: Colors.grey.shade300,
                      ),
                    ),
                  SizedBox(height: height * 0.08),
                  // Başlık
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w400,
                      color: const Color(0XFF461D8D),
                    ),
                    softWrap: true,
                  ),
                  SizedBox(
                      height: height *
                          0.02), // Başlık ve açıklama arasındaki boşluk

                  // Açıklama metni
                  SizedBox(
                    width: width * 0.8,
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: descriptionFontSize,
                        fontWeight: FontWeight.w400,
                        color: const Color(0XFF373737),
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}