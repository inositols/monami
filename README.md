# Monami

Monami is an e-commerce mobile built with flutter. The app was used to explore not all but yet the neccessary concepts a flutter dev were meant to undertand in builidng a large, robust and scalable mobile apps.

## Concepts

- Firebase Authentication
- State Management Options(Riverpod)
- DRY principle
- Tree shaking
- Payment Gateway Integration(Paystack)
- Google Map Integration
- Rewriting Good Documentaion for your project

## Features

- [x] The Splash Screen
- [x] The Onboarding screens
- [x] Authentication screen
- [x] HomeScreen
- Cart screen
- Favourite screen
- Account screen
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
