# Repository Pattern Implementation

This document describes the repository pattern implementation for the Oscar app, providing clean data access abstraction and improved testability.

## Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   UI Screens    │───▶│   Service Layer  │───▶│   Repository    │
│   (Widgets)     │    │  (Business Logic)│    │  (Data Access)  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
                                                ┌─────────────────┐
                                                │   Data Source   │
                                                │   (ObjectBox)   │
                                                └─────────────────┘
```

## Core Components

### 1. Repository Interface (`lib/repositories/oscar_repository.dart`)
Defines the contract for Oscar data operations:
- `getAllOscars()` - Get all Oscar winners
- `getOscarsByFilm(String filmName)` - Get nominations for a specific film
- `getOscarsByNomineeId(String nomineeId)` - Get all nominations for a nominee
- `searchOscars(String query)` - Search across multiple fields
- `getSpecialAwards()` - Get only special awards
- `getWinners()` - Get only winners
- And more...

### 2. ObjectBox Implementation (`lib/repositories/objectbox_oscar_repository.dart`)
Concrete implementation using ObjectBox database:
- Implements all repository interface methods
- Uses DatabaseService for actual data operations
- Handles data transformation and filtering

### 3. Service Layer (`lib/services/oscar_service.dart`)
High-level business logic operations:
- `getFilmStats(String filmName)` - Returns comprehensive film statistics
- `searchWithFilters(...)` - Advanced search with multiple filters
- `getSummaryStats()` - Overall Oscar statistics
- `getOscarsByDecades()` - Groups Oscars by decade

### 4. Providers (`lib/providers/oscar_repository_providers.dart`)
Riverpod providers for dependency injection:
- `oscarRepositoryProvider` - Main repository instance
- `oscarServiceProvider` - Service layer instance
- `oscarDataRepositoryProvider` - All Oscar data
- `oscarsByFilmRepositoryProvider` - Film-specific data
- And more specialized providers...

## Usage Examples

### Basic Repository Usage
```dart
// In your widget
Consumer(
  builder: (context, ref, _) {
    final oscarsAsync = ref.watch(oscarDataRepositoryProvider);
    return oscarsAsync.when(
      data: (oscars) => ListView.builder(...),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  },
)
```

### Film-Specific Data
```dart
// Get nominations for a specific film
Consumer(
  builder: (context, ref, _) {
    final filmNominations = ref.watch(
      oscarsByFilmRepositoryProvider('The Godfather')
    );
    return filmNominations.when(
      data: (nominations) => FilmNominationsList(nominations),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  },
)
```

### Service Layer Usage
```dart
// Using the service for complex operations
Consumer(
  builder: (context, ref, _) {
    final oscarService = ref.read(oscarServiceProvider);
    return FutureBuilder(
      future: oscarService.getFilmStats('The Godfather'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final stats = snapshot.data!;
          return StatsWidget(
            nominations: stats.totalNominations,
            wins: stats.wins,
            specialAwards: stats.specialAwards,
          );
        }
        return CircularProgressIndicator();
      },
    );
  },
)
```

### Direct Repository Access
```dart
// For imperative operations
class SomeWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final repository = ref.read(oscarRepositoryProvider);
        final specialAwards = await repository.getSpecialAwards();
        // Do something with special awards
      },
      child: Text('Load Special Awards'),
    );
  }
}
```

## Benefits

### 1. Testability
```dart
// Easy to mock for testing
class MockOscarRepository implements OscarRepository {
  @override
  Future<List<OscarWinner>> getAllOscars() async {
    return [
      // Test data
    ];
  }
  // ... implement other methods
}
```

### 2. Flexibility
- Easy to switch from ObjectBox to SQLite or API
- Can add caching layers transparently
- Database migrations become easier

### 3. Performance
- Specific query methods prevent over-fetching
- Repository can implement smart caching
- Batch operations possible

### 4. Maintenance
- Business logic separated from UI
- Single responsibility principle
- Clear dependencies

## Migration Guide

### Step 1: Update Imports
```dart
// Old
import '../providers/oscar_providers.dart';

// New
import '../providers/oscar_repository_providers.dart';
```

### Step 2: Replace Providers
```dart
// Old
final allOscarsAsync = ref.watch(oscarDataProvider);

// New
final allOscarsAsync = ref.watch(oscarDataRepositoryProvider);
```

### Step 3: Use Specific Providers
```dart
// Instead of filtering in UI
final allOscars = ref.watch(oscarDataRepositoryProvider);
final filmOscars = allOscars.when(
  data: (oscars) => oscars.where((o) => o.film == filmName).toList(),
  // ...
);

// Use specific provider
final filmOscars = ref.watch(oscarsByFilmRepositoryProvider(filmName));
```

### Step 4: Leverage Service Layer
For complex business logic, use the service layer instead of doing calculations in widgets.

## Testing

### Repository Testing
```dart
void main() {
  group('OscarRepository', () {
    late OscarRepository repository;
    
    setUp(() {
      // Setup test database or mocks
      repository = ObjectBoxOscarRepository(mockDatabaseService);
    });
    
    test('should return all oscars', () async {
      final oscars = await repository.getAllOscars();
      expect(oscars, isNotEmpty);
    });
    
    test('should filter by film', () async {
      final oscars = await repository.getOscarsByFilm('The Godfather');
      expect(oscars.every((o) => o.film == 'The Godfather'), isTrue);
    });
  });
}
```

### Service Testing
```dart
void main() {
  group('OscarService', () {
    late OscarService service;
    late MockOscarRepository mockRepository;
    
    setUp(() {
      mockRepository = MockOscarRepository();
      service = OscarService(mockRepository);
    });
    
    test('should calculate film stats correctly', () async {
      // Given
      when(mockRepository.getOscarsByFilm('Test Film'))
          .thenAnswer((_) async => testOscars);
      
      // When
      final stats = await service.getFilmStats('Test Film');
      
      // Then
      expect(stats.totalNominations, equals(5));
      expect(stats.wins, equals(2));
    });
  });
}
```

## Best Practices

1. **Use Specific Providers**: Prefer `oscarsByFilmRepositoryProvider` over filtering `oscarDataRepositoryProvider`
2. **Service Layer for Business Logic**: Keep complex calculations in the service layer
3. **Error Handling**: Always handle loading and error states
4. **Caching**: Consider using Riverpod's built-in caching for expensive operations
5. **Testing**: Write tests for repositories and services
6. **Documentation**: Keep this documentation updated as the API evolves

## Future Enhancements

1. **Caching Layer**: Add intelligent caching to the repository
2. **Offline Support**: Handle offline scenarios gracefully
3. **Real-time Updates**: Add stream-based methods for real-time data
4. **Pagination**: Add pagination support for large datasets
5. **Sync**: Add synchronization with external data sources
