# Migration Plan: From `src` to Clean Architecture

## 📋 **Current State Analysis**

### **Files to Migrate from `src` folder:**

#### **1. Data Layer Files**
```
src/data/ → core/data/
├── local/ → datasources/
│   ├── local_cache_impl.dart
│   ├── local_cache.dart
│   ├── secure_storage_impl.dart
│   └── secure_storage.dart
├── remote/ → datasources/
│   ├── auth_service_impl.dart
│   └── auth_service.dart
└── state/ → models/
    ├── api_response.dart
    ├── constants/
    ├── post/
    ├── post_settings/
    └── user_info/
```

#### **2. Features (Domain Logic)**
```
src/features/ → core/domain/
├── auth/ → entities/ + usecases/
├── comments/ → entities/ + usecases/
├── image_upload/ → entities/ + usecases/
└── likes/ → entities/ + usecases/
```

#### **3. Presentation Layer**
```
src/presentation/ → core/presentation/
├── views/ → pages/
├── widgets/ → widgets/ (already moved)
└── components/ → widgets/
```

#### **4. Services & Utilities**
```
src/services/ → core/data/datasources/
src/shared/ → core/shared/
src/utils/ → core/shared/
src/handlers/ → core/shared/
```

## 🚀 **Migration Steps**

### **Phase 1: Data Layer Migration**
1. **Move data sources** from `src/data/` to `core/data/datasources/`
2. **Move models** from `src/data/state/` to `core/data/models/`
3. **Update repository implementations** to use new data sources
4. **Test data layer** functionality

### **Phase 2: Domain Layer Enhancement**
1. **Create entities** for auth, comments, image_upload, likes
2. **Create use cases** for each feature
3. **Update repository interfaces** to include new features
4. **Test domain layer** logic

### **Phase 3: Presentation Layer Migration**
1. **Move views** from `src/presentation/views/` to `core/presentation/pages/`
2. **Move components** to `core/presentation/widgets/`
3. **Update providers** to use new architecture
4. **Test UI functionality**

### **Phase 4: Services & Utilities**
1. **Move services** to appropriate data sources
2. **Move utilities** to `core/shared/`
3. **Update imports** throughout the app
4. **Test complete functionality**

### **Phase 5: Cleanup**
1. **Remove `src` folder** once migration is complete
2. **Update all imports** to use new structure
3. **Run comprehensive tests**
4. **Update documentation**

## 📁 **Detailed File Mapping**

### **Data Layer Files**
| Current Location | New Location | Action |
|------------------|--------------|---------|
| `src/data/local/` | `core/data/datasources/` | Move & rename |
| `src/data/remote/` | `core/data/datasources/` | Move & rename |
| `src/data/state/` | `core/data/models/` | Move & refactor |
| `src/services/` | `core/data/datasources/` | Move & integrate |

### **Domain Layer Files**
| Current Location | New Location | Action |
|------------------|--------------|---------|
| `src/features/auth/` | `core/domain/entities/` | Create entities |
| `src/features/comments/` | `core/domain/usecases/` | Create use cases |
| `src/features/image_upload/` | `core/domain/entities/` | Create entities |
| `src/features/likes/` | `core/domain/usecases/` | Create use cases |

### **Presentation Layer Files**
| Current Location | New Location | Action |
|------------------|--------------|---------|
| `src/presentation/views/` | `core/presentation/pages/` | Move & update |
| `src/presentation/widgets/` | `core/presentation/widgets/` | Already moved |
| `src/presentation/components/` | `core/presentation/widgets/` | Move & organize |

### **Shared Files**
| Current Location | New Location | Action |
|------------------|--------------|---------|
| `src/shared/` | `core/shared/` | Move & integrate |
| `src/utils/` | `core/shared/utils/` | Move & organize |
| `src/handlers/` | `core/shared/` | Move & integrate |

## 🔧 **Implementation Strategy**

### **Option A: Gradual Migration (Recommended)**
- Keep both `src` and `core` folders
- Migrate one feature at a time
- Update imports gradually
- Remove `src` when complete

### **Option B: Complete Migration**
- Move all files at once
- Update all imports
- Test everything
- Remove `src` folder

## ⚠️ **Important Considerations**

1. **Import Updates**: All files will need import path updates
2. **Provider Updates**: State management providers need to be updated
3. **Testing**: Each migrated component needs testing
4. **Documentation**: Update all documentation references
5. **Dependencies**: Ensure all dependencies are properly configured

## 🎯 **Success Criteria**

- [ ] All files migrated to clean architecture
- [ ] All imports updated correctly
- [ ] All tests passing
- [ ] App functionality maintained
- [ ] `src` folder removed
- [ ] Documentation updated

## 📝 **Next Steps**

1. **Choose migration strategy** (gradual vs complete)
2. **Start with data layer** migration
3. **Test each phase** before proceeding
4. **Update imports** as you go
5. **Remove `src` folder** when complete

This migration will transform your project into a fully clean architecture implementation while maintaining all existing functionality.

