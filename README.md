# Monami: Your E-commerce Flutter App

Monami is a versatile e-commerce mobile/web application built with Flutter. This project serves as an exploration of essential concepts that every Flutter developer should understand when building large, robust, and scalable flutter applications.

## Key Concepts Explored

- User Authentication: Secure user registration and authentication powered by Firebase Authentication.
- State Management: Efficient state management using Riverpod, ensuring smooth user interactions and data synchronization
- Responsive Design: A responsive UI design that adapts seamlessly to various screen sizes, providing an optimal viewing experience across devices.
- Payment Integration: Seamless integration of Paystack payment gateway for secure and convenient transactions.
- Location Services: Integration of Google Maps API for location-based features such as store locator and order tracking.
- Optimized Performance: Implementation of tree shaking techniques to eliminate unused code and optimize app performance.

## Features

- [x] The Splash Screen
- [x] The Onboarding screens
- [x] Authentication screen
- [x] HomeScreen
- [x] Cart screen
- [x] Favourite screen
- [x] Account screen
- Order Screen
- Payment screen
- Track your order

### Application structure

After successful build, your application structure should look like this:

```
.
├── android                         - It contains files required to run the application on an Android platform.
├── assets                          - It contains all images and fonts of your application.
├── ios                             - It contains files required to run the application on an iOS platform.
├── lib                             - Most important folder in the application, used to write most of the Dart code..
    ├── main.dart                   - Starting point of the application
    ├── core
    │   ├── app_export.dart         - It contains commonly used file imports
    │   ├── constants               - It contains static constant class file
    │   └── utils                   - It contains common files and utilities of the application
    ├── presentation                - It contains widgets of the screens
    ├── routes                      - It contains all the routes of the application
    └── theme                       - It contains app theme and decoration classes
    └── widgets                     - It contains all custom widget classes
```

### How to format your code?

- if your code is not formatted then run following command in your terminal to format code
  ```
  dart format .
  ```

### How you can improve code readability?

Resolve the errors and warnings that are shown in the application.

### Libraries and tools used

- Riverpod - State management
  https://riverpod.dev/docs/getting_started
- cached_network_image - For storing internet image into cache
  https://pub.dev/packages/cached_network_image
