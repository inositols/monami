# Clean Architecture Implementation

This document outlines the clean architecture implementation for the Monami e-commerce Flutter application.

## 🏗️ Architecture Overview

The project follows **Clean Architecture** principles with clear separation of concerns and dependency inversion.

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐  │
│  │     Pages       │  │    Widgets      │  │  Providers   │  │
│  └─────────────────┘  └─────────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                           │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐  │
│  │    Entities     │  │  Repositories   │  │   Use Cases   │  │
│  └─────────────────┘  └─────────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────────┘
                                ▲
                                │
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐  │
│  │   Data Sources  │  │   Repositories  │  │    Models     │  │
│  └─────────────────┘  └─────────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Directory Structure

```
lib/
├── core/                           # Core business logic
│   ├── domain/                     # Domain Layer
│   │   ├── entities/               # Business entities
│   │   │   ├── product.dart
│   │   │   ├── cart_item.dart
│   │   │   ├── order.dart
│   │   │   └── user_profile.dart
│   │   ├── repositories/           # Repository interfaces
│   │   │   ├── product_repository.dart
│   │   │   ├── cart_repository.dart
│   │   │   ├── order_repository.dart
│   │   │   └── user_repository.dart
│   │   └── usecases/               # Business use cases
│   │       ├── get_products.dart
│   │       └── add_to_cart.dart
│   ├── data/                       # Data Layer
│   │   ├── datasources/            # Data sources
│   │   │   ├── product_remote_datasource.dart
│   │   │   └── product_local_datasource.dart
│   │   ├── repositories/           # Repository implementations
│   │   │   └── product_repository_impl.dart
│   │   └── models/                 # Data models
│   │       ├── product_model.dart
│   │       └── cart_item_model.dart
│   ├── presentation/               # Presentation Layer
│   │   ├── pages/                  # UI pages
│   │   ├── widgets/                # Reusable widgets
│   │   └── providers/              # State management
│   └── shared/                     # Shared utilities
│       ├── constants/              # App constants
│       ├── utils/                  # Utility functions
│       └── errors/                 # Error handling
├── features/                       # Feature modules
└── main.dart                       # App entry point
```

## 🔄 Dependency Flow

### Dependency Rule
- **Inner layers** don't know about outer layers
- **Dependencies** point inward only
- **Abstractions** are in inner layers
- **Implementations** are in outer layers

### Layer Dependencies
1. **Presentation** → **Domain** ← **Data**
2. **Shared** utilities can be used by any layer
3. **Domain** layer is completely independent

## 🧩 Layer Responsibilities

### Domain Layer (Core Business Logic)
- **Entities**: Core business objects with no external dependencies
- **Repositories**: Abstract interfaces for data access
- **Use Cases**: Business logic and application rules

### Data Layer (External Concerns)
- **Data Sources**: API calls, local storage, external services
- **Repository Implementations**: Concrete implementations of domain interfaces
- **Models**: Data transfer objects with JSON serialization

### Presentation Layer (UI)
- **Pages**: Screen components and UI logic
- **Widgets**: Reusable UI components
- **Providers**: State management and business logic coordination

### Shared Layer (Common Utilities)
- **Constants**: Application-wide constants
- **Utils**: Helper functions and utilities
- **Errors**: Error handling and failure classes

## 🎯 Benefits

### 1. **Testability**
- Each layer can be tested independently
- Business logic is isolated from external dependencies
- Easy to mock dependencies

### 2. **Maintainability**
- Clear separation of concerns
- Easy to modify without affecting other layers
- Consistent code organization

### 3. **Scalability**
- Easy to add new features
- Modular architecture
- Clear dependency management

### 4. **Flexibility**
- Easy to swap implementations
- Platform-independent business logic
- Technology-agnostic core

## 📝 Implementation Guidelines

### 1. **Entity Design**
```dart
// Domain entities should be pure Dart classes
class Product {
  final String id;
  final String name;
  final double price;
  
  const Product({
    required this.id,
    required this.name,
    required this.price,
  });
}
```

### 2. **Repository Pattern**
```dart
// Abstract repository interface
abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(String id);
}

// Concrete implementation
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  
  // Implementation details...
}
```

### 3. **Use Case Pattern**
```dart
// Business logic encapsulation
class GetProducts {
  final ProductRepository repository;
  
  const GetProducts(this.repository);
  
  Future<List<Product>> call() async {
    return await repository.getProducts();
  }
}
```

### 4. **Error Handling**
```dart
// Consistent error handling
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
```

## 🚀 Usage Examples

### 1. **Using Use Cases in UI**
```dart
class ProductListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getProducts = GetProducts(ref.read(productRepositoryProvider));
    
    return FutureBuilder<List<Product>>(
      future: getProducts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ProductList(products: snapshot.data!);
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
```

### 2. **Dependency Injection**
```dart
// Provider setup
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    remoteDataSource: ref.read(productRemoteDataSourceProvider),
    localDataSource: ref.read(productLocalDataSourceProvider),
  );
});
```

## 🔧 Migration Strategy

### Phase 1: Core Structure
- ✅ Create clean architecture folder structure
- ✅ Move domain entities
- ✅ Create repository interfaces
- ✅ Implement use cases

### Phase 2: Data Layer
- ✅ Create data models
- ✅ Implement data sources
- ✅ Create repository implementations

### Phase 3: Presentation Layer
- 🔄 Move UI components
- 🔄 Update state management
- 🔄 Refactor providers

### Phase 4: Integration
- 🔄 Update imports
- 🔄 Test functionality
- 🔄 Optimize performance

## 📚 Best Practices

1. **Keep entities pure** - No external dependencies
2. **Use abstract classes** for repository interfaces
3. **Implement proper error handling** with Result types
4. **Follow naming conventions** consistently
5. **Write comprehensive tests** for each layer
6. **Use dependency injection** for loose coupling
7. **Document interfaces** clearly
8. **Keep use cases focused** on single responsibilities

## 🧪 Testing Strategy

### Unit Tests
- Test each layer independently
- Mock external dependencies
- Focus on business logic

### Integration Tests
- Test layer interactions
- Verify data flow
- Test error scenarios

### Widget Tests
- Test UI components
- Mock use cases
- Verify user interactions

This clean architecture implementation provides a solid foundation for building maintainable, testable, and scalable Flutter applications.

