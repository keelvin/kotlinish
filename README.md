# 🚀 Kotlinish

**Making Dart smooth as Kotlin**

Kotlin-inspired extensions and utilities for Dart/Flutter - bringing the elegance and power of Kotlin to your Flutter development experience.

[![Pub Version](https://img.shields.io/pub/v/kotlinish.svg)](https://pub.dev/packages/kotlinish)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter Package](https://img.shields.io/badge/Flutter-Package-blue.svg)](https://flutter.dev)

## ✨ Features

- 🎯 **Scope Functions** - `let`, `apply`, `run`, `also`, `use` for fluent code
- 📚 **Enhanced Collections** - Safe accessors, advanced operators, statistical functions
- ⚡ **Elegant Async** - Kotlin Coroutines-style concurrency for Dart Isolates
- 🌊 **Reactive Streams** - Advanced stream operations and reactive extensions
- 💾 **Smart Caching** - LRU, expiring, multi-level, and reactive caching solutions
- 🎨 **Flutter Integration** - Widget extensions, state management, and context utilities
- 🔧 **Performance Tools** - Memoization, data loaders, and cache management

## 🚀 Quick Start

Add to your `pubspec.yaml`:

```yaml
dependencies:
  kotlinish: ^0.5.0
```

Import and start using:

```dart
import 'package:kotlinish/kotlinish.dart';

// Scope functions for cleaner code
final result = "Hello World"
    .let((it) => it.toUpperCase())
    .also((it) => print('Result: $it'));

// Safe collection operations
final numbers = [1, 2, 3, 4, 5];
final firstEven = numbers.firstWhere((n) => n.isEven).let((it) => it * 2);
final safeAccess = numbers.getOrNull(10) ?? 0; // null-safe access

// Enhanced async with isolates
final heavyResult = await launch(() => heavyComputation());
final parallelResults = await concurrent([
  () => fetchData1(),
  () => fetchData2(),
  () => fetchData3(),
], limit: 3);

// Reactive state management
final counter = StateFlow(0);
counter.update((current) => current + 1);

// Smart caching
final cache = LruCache<String, User>(100);
final userLoader = DataLoader<String, User>((id) => fetchUser(id));
```

## 📋 Comprehensive API Reference

### 🎯 Scope Functions

Transform your code with Kotlin-style scope functions:

```dart
// let - transform and return result
final length = userName?.let((it) => it.length) ?? 0;

// apply - configure object and return it
final list = <String>[]
  .apply((it) {
    it.add('item1');
    it.add('item2');
  });

// run - execute block and return result
final isValid = user.run((self) => 
  self.name.isNotEmpty && self.age > 0);

// also - perform side effects and return original
final user = createUser()
  .also((it) => logger.info('Created user: ${it.name}'))
  .also((it) => analytics.track('user_created'));

// use - operate on object without extending it
final result = use(stringBuffer, (it) {
  it.write('Hello');
  it.write(' World');
  return it.toString();
});
```

### 📚 Enhanced Collections

#### Safe Accessors
```dart
final numbers = [1, 2, 3];
final first = numbers.firstOrNull; // 1
final last = numbers.lastOrNull;   // 3
final single = [42].singleOrNull;  // 42

final empty = <int>[];
final safeFirst = empty.firstOrNull; // null
```

#### Advanced Operations
```dart
// Get elements by index safely
final element = list.getOrNull(10) ?? defaultValue;
final elementOrElse = list.getOrElse(10, () => computeDefault());

// Slice collections
final letters = ['a', 'b', 'c', 'd', 'e'];
final selected = letters.slice([0, 2, 4]); // ['a', 'c', 'e']

// Sliding windows
final numbers = [1, 2, 3, 4, 5];
final windows = numbers.windowed(3); // [[1,2,3], [2,3,4], [3,4,5]]

// Zip with next element
final pairs = numbers.zipWithNext(); // [(1,2), (2,3), (3,4), (4,5)]
final sums = numbers.zipWithNextTransform((a, b) => a + b); // [3, 5, 7, 9]

// Advanced grouping
final users = [User('John', 25), User('Jane', 30), User('Bob', 25)];
final byAge = users.groupBy((user) => user.age);
// Result: {25: [John, Bob], 30: [Jane]}

final ageToNames = users.groupByTransform(
  (user) => user.age,
  (user) => user.name,
);
// Result: {25: ['John', 'Bob'], 30: ['Jane']}

// Split at condition
final numbers = [1, 2, 0, 3, 4, 0, 5];
final parts = numbers.splitWhere((n) => n == 0);
// Result: [[1, 2], [3, 4], [5]]

// Random operations
final randomElement = list.random();
final shuffled = list.shuffled();
```

#### Statistical Operations
```dart
final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

// Basic statistics
final sum = numbers.sum();           // 55
final average = numbers.average();   // 5.5
final median = numbers.median();     // 5.5
final mode = [1,2,2,3].mode();      // 2

// Advanced statistics
final stdDev = numbers.standardDeviation(); // ~2.87
final range = numbers.range();              // 9 (10 - 1)
final min = numbers.minOrNull();            // 1
final max = numbers.maxOrNull();            // 10
```

#### Conditional Access
```dart
// Take if condition is met
final positiveNumber = number.takeIf((it) => it > 0);
final validEmail = email.takeIf((it) => it.contains('@'));

// Take unless condition is met
final nonEmptyString = text.takeUnless((it) => it.isEmpty);

// Collection conditional operations
final nonEmptyList = list.takeIfNotEmpty();
final pair = list.takeIfSize(2);
final allValid = items.takeIfAll((item) => item.isValid);
final hasError = responses.takeIfAny((r) => r.hasError);
```

### ⚡ Async & Concurrency

#### Isolate-based Concurrency
```dart
// Launch single task in isolate
final result = await launch(() => heavyComputation());

// Launch with name for debugging
final result = await launch(() => processData(), name: 'data-processor');

// Launch multiple tasks
final results = await launchAll([
  () => fetchUserData(),
  () => fetchSettings(),
  () => fetchNotifications(),
]);

// Controlled concurrency
final results = await concurrent([
  () => processFile1(),
  () => processFile2(),
  () => processFile3(),
], limit: 2); // Max 2 concurrent

// Race for fastest result
final fastest = await race([
  () => fetchFromPrimaryServer(),
  () => fetchFromBackupServer(),
  () => fetchFromCache(),
]);
```

#### Advanced Async Utilities
```dart
// Retry with exponential backoff
final result = await retry(
  () => unreliableNetworkCall(),
  maxRetries: 3,
  backoff: Duration(seconds: 1),
);

// Timeout operations
final result = await withTimeout(
  () => longRunningTask(),
  timeout: Duration(seconds: 10),
);

// Delay execution
await delay(Duration(seconds: 2));

// Execute in sequence
final results = await sequence([
  () => step1(),
  () => step2(),
  () => step3(),
]);
```

#### Channels for Communication
```dart
// Create channel for isolate communication
final (sender, receiver) = await Channel.isolate<String>();

// Send and receive
await sender.send('Hello from isolate!');
final message = await receiver.receive();

// Buffered channels
final channel = Channel<int>.buffered(capacity: 10);
channel.trySend(42); // Non-blocking send

// Channel utilities
final merged = ChannelUtils.merge([channel1, channel2, channel3]);
final pipeline = ChannelUtils.pipeline(source, (value) => value.toString());
```

### 🌊 Reactive Streams

```dart
// Debounce user input
final searchStream = textController.stream
  .debounce(Duration(milliseconds: 300))
  .distinctUntilChanged()
  .mapNotNull((query) => query.isNotEmpty ? query : null);

// Throttle rapid events
final throttledClicks = buttonClicks
  .throttle(Duration(seconds: 1));

// Combine latest values
final userStream = Stream.fromIterable(['John', 'Jane']);
final ageStream = Stream.fromIterable([25, 30]);
final combined = userStream.combineLatest(ageStream);
// Emits: (John, 25), (John, 30), (Jane, 30)

// Transform and filter
final numbers = Stream.fromIterable(['1', 'abc', '2', '3']);
final validNumbers = numbers
  .mapNotNull((s) => int.tryParse(s))
  .filterKt((n) => n > 1);

// Side effects
final logged = stream
  .doOnEach((value) => print('Value: $value'))
  .doOnError((error) => log.error('Error: $error'))
  .doOnComplete(() => print('Stream completed'));

// Start and end with values
final withPrefix = stream.startWith([0, 1]);
final withSuffix = stream.endWith([99, 100]);

// Merge streams
final merged = stream1.mergeWith(stream2);

// Collect results
final list = await stream.collectList();
final set = await stream.collectSet();
```

#### Stream Utilities
```dart
// Create streams
final timer = ReactiveStreams.interval(Duration(seconds: 1));
final delayed = ReactiveStreams.timer('Hello', Duration(seconds: 2));
final merged = ReactiveStreams.merge([stream1, stream2, stream3]);

// Error handling
final errorStream = ReactiveStreams.error(Exception('Oops!'));
final neverStream = ReactiveStreams.never<String>();
```

### 💾 Cache Management

#### LRU Cache
```dart
final cache = LruCache<String, User>(maxSize: 100);

cache.put('user1', user);
final cachedUser = cache.get('user1');
final removed = cache.remove('user1');
cache.clear();

print('Cache size: ${cache.size}');
print('Contains key: ${cache.containsKey('user1')}');
```

#### Expiring Cache
```dart
final cache = ExpiringCache<String, String>(Duration(minutes: 5));

cache.put('key', 'value');
// After 5 minutes, the value will expire
final value = cache.get('key'); // Returns null if expired

cache.cleanup(); // Manually remove expired entries
```

#### Data Loader
```dart
final userLoader = DataLoader<String, User>(
  (id) => fetchUserFromApi(id),
  expiry: Duration(minutes: 5),
);

// Load single user (cached automatically)
final user = await userLoader.load('user123');

// Load multiple users in parallel
final users = await userLoader.loadMany(['user1', 'user2', 'user3']);

// Prime cache with known data
userLoader.prime('user456', existingUser);

// Evict from cache
userLoader.evict('user123');
```

#### Function Memoization
```dart
// Expensive function
int fibonacci(int n) => n <= 1 ? n : fibonacci(n-1) + fibonacci(n-2);

// Memoize it
final memoizedFib = fibonacci.memoized();

// First call computes and caches
final result1 = memoizedFib(40); // Takes time

// Second call returns cached result
final result2 = memoizedFib(40); // Instant!

// Custom cache for memoization
final customMemoized = fibonacci.memoized(
  cache: ExpiringCache(Duration(minutes: 10))
);
```

#### Multi-Level Cache
```dart
final l1 = LruCache<String, User>(50);      // Small, fast cache
final l2 = LruCache<String, User>(500);     // Larger cache
final l3 = ExpiringCache<String, User>(Duration(hours: 1)); // Persistent

final multiLevel = MultiLevelCache([l1, l2, l3]);

// Get promotes values to higher levels
final user = multiLevel.get('user123');
```

#### Reactive Cache
```dart
final cache = ReactiveCache(LruCache<String, String>(100));

// Listen to cache events
cache.events.listen((event) {
  switch (event.type) {
    case CacheEventType.hit:
      print('Cache hit: ${event.key}');
    case CacheEventType.miss:
      print('Cache miss: ${event.key}');
    case CacheEventType.put:
      print('Cache put: ${event.key} = ${event.value}');
    case CacheEventType.evicted:
      print('Cache evicted: ${event.key}');
  }
});

cache.put('key', 'value');
cache.get('key'); // Triggers hit event
```

### 🎨 Flutter Integration

#### Widget Extensions
```dart
// Padding and margins
Text('Hello').padding(16.0);
Text('Hello').paddingSymmetric(horizontal: 20.0, vertical: 10.0);
Text('Hello').margin(8.0);

// Layout
Text('Centered').center();
Text('Expanded').expanded(flex: 2);
Text('Flexible').flexible();

// Styling
Text('Styled').container(
  color: Colors.blue,
  width: 200,
  height: 100,
);
Text('Rounded').rounded(radius: 12.0, color: Colors.green);
Text('Transparent').opacity(0.5);

// Interactions
Text('Clickable').onTap(() => print('Tapped!'));
Text('Long Press').onLongPress(() => print('Long pressed!'));

// Visibility
Text('Hidden').invisible();
Text('Conditional').visible(showText);

// Transformations
Text('Scaled').scale(1.5);
Text('Rotated').rotate(0.1);

// Hero animations
Image.network(url).hero('image-hero');

// Card wrapper
Text('In Card').card(elevation: 4.0);
```

#### List Extensions
```dart
// Create layouts from widget lists
final widgets = [
  Text('Item 1'),
  Text('Item 2'),
  Text('Item 3'),
];

// Column, Row, Wrap, Stack
widgets.column(crossAxisAlignment: CrossAxisAlignment.start);
widgets.row(mainAxisAlignment: MainAxisAlignment.spaceBetween);
widgets.wrap(spacing: 8.0);
widgets.stack();

// Add separators
widgets.separated(Divider());
widgets.spaced(16.0); // Adds SizedBox with height/width 16
```

#### Context Extensions
```dart
// Theme access
final primaryColor = context.colorScheme.primary;
final headlineStyle = context.textTheme.headlineMedium;
final isDark = context.isDarkMode;

// Screen info
final screenWidth = context.screenWidth;
final screenHeight = context.screenHeight;
final isTablet = context.isTablet;
final isKeyboardVisible = context.isKeyboardVisible;

// Navigation
await context.push(DetailPage());
context.pushReplacement(HomePage());
context.pushAndClearStack(LoginPage());
context.pop('result');

// Snackbars
context.showSnackBar('Operation completed!');
context.showErrorSnackBar('Something went wrong!');
context.showSuccessSnackBar('Success!');

// Dialogs
final confirmed = await context.showConfirmationDialog(
  'Delete Item',
  'Are you sure you want to delete this item?',
);

// Bottom sheets
final result = await context.showBottomSheet(MyBottomSheet());

// Keyboard management
context.hideKeyboard();

// Focus management
context.requestFocus(myFocusNode);
```

### 🔄 State Management

#### StateFlow
```dart
// Create reactive state
final counter = StateFlow(0);

// Listen to changes
counter.stream.listen((value) => print('Counter: $value'));

// Update state
counter.value = 5;
counter.update((current) => current + 1);

// Use in widgets
StateFlowBuilder<int>(
  stateFlow: counter,
  builder: (context, value) => Text('Count: $value'),
)
```

#### Store Pattern (Redux-like)
```dart
// Define actions
class IncrementAction extends Action {}
class DecrementAction extends Action {}

// Define state
class CounterState extends State {
  final int count;
  CounterState(this.count);
}

// Define reducer
CounterState counterReducer(CounterState state, Action action) {
  return switch (action) {
    IncrementAction() => CounterState(state.count + 1),
    DecrementAction() => CounterState(state.count - 1),
    _ => state,
  };
}

// Create store
final store = Store(CounterState(0), counterReducer);

// Provide to widget tree
StoreProvider<CounterState>(
  store: store,
  child: MyApp(),
)

// Use in widgets
StoreBuilder<CounterState>(
  builder: (context, state) => Text('Count: ${state.count}'),
)

// Dispatch actions
final store = StoreProvider.of<CounterState>(context);
store.dispatch(IncrementAction());
```

#### Form State Management
```dart
FormStateProvider(
  builder: (context, manager) {
    return Column(
      children: [
        TextFormField(
          onChanged: (value) => manager.setValue('name', value),
          decoration: InputDecoration(
            errorText: manager.errors['name'],
          ),
        ),
        TextFormField(
          onChanged: (value) => manager.setValue('email', value),
          decoration: InputDecoration(
            errorText: manager.errors['email'],
          ),
        ),
        StateFlowBuilder<bool>(
          stateFlow: manager.isValid,
          builder: (context, isValid) => ElevatedButton(
            onPressed: isValid ? () => submitForm() : null,
            child: Text('Submit'),
          ),
        ),
      ],
    );
  },
)
```

#### Computed State
```dart
final firstName = StateFlow('John');
final lastName = StateFlow('Doe');

// Automatically recomputes when dependencies change
final fullName = ComputedState(
  () => '${firstName.value} ${lastName.value}',
  [firstName, lastName],
);

ComputedStateBuilder<String>(
  compute: () => '${firstName.value} ${lastName.value}',
  dependencies: [firstName, lastName],
  builder: (context, fullName) => Text('Full name: $fullName'),
)
```

## 🎯 Examples

### Real-world Data Processing Pipeline

```dart
class UserService {
  final _userCache = LruCache<String, User>(100);
  final _userLoader = DataLoader<String, User>((id) => _fetchUser(id));

  Future<List<User>> getActiveAdultUsers() async {
    final userIds = await _getAllUserIds();
    
    return userIds
        .chunked(10) // Process in batches of 10
        .map((batch) async => await _userLoader.loadMany(batch))
        .let((futures) => Future.wait(futures))
        .then((batches) => batches.expand((batch) => batch))
        .then((users) => users
            .filter((user) => user.isActive)
            .filter((user) => user.age >= 18)
            .sortedWith((user) => user.name)
        );
  }

  Future<UserStats> calculateUserStats(List<User> users) async {
    return launch(() {
      final ages = users.map((u) => u.age).toList();
      
      return UserStats(
        totalUsers: users.length,
        averageAge: ages.average() ?? 0,
        medianAge: ages.median() ?? 0,
        ageRange: ages.range() ?? 0,
        departmentDistribution: users.groupBy((u) => u.department),
      );
    });
  }
}
```

### Reactive Search with Debouncing

```dart
class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _results = StateFlow<List<SearchResult>>([]);
  final _isLoading = StateFlow(false);
  late final StreamSubscription _searchSubscription;

  @override
  void initState() {
    super.initState();
    
    _searchSubscription = _searchController.stream
        .debounce(Duration(milliseconds: 300))
        .distinctUntilChanged()
        .mapNotNull((query) => query.isNotEmpty ? query : null)
        .doOnEach((_) => _isLoading.value = true)
        .flatMapStream((query) => _performSearch(query))
        .doOnEach((results) {
          _results.value = results;
          _isLoading.value = false;
        })
        .listen(null);
  }

  Stream<List<SearchResult>> _performSearch(String query) {
    return Stream.fromFuture(
      launch(() => SearchAPI.search(query))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(hintText: 'Search...'),
        ).padding(16.0),
        
        StateFlowBuilder<bool>(
          stateFlow: _isLoading,
          builder: (context, isLoading) => isLoading
              ? CircularProgressIndicator().center()
              : SizedBox.shrink(),
        ),
        
        StateFlowBuilder<List<SearchResult>>(
          stateFlow: _results,
          builder: (context, results) => ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) => SearchResultTile(results[index]),
          ).expanded(),
        ),
      ].column(),
    );
  }

  @override
  void dispose() {
    _searchSubscription.cancel();
    _results.dispose();
    _isLoading.dispose();
    super.dispose();
  }
}
```

## 🧪 Testing

Kotlinish includes comprehensive tests for all features:

```bash
# Run all tests
flutter test

# Run specific test suites
flutter test test/scope_functions/
flutter test test/collections/
flutter test test/async/
flutter test test/reactive/
flutter test test/performance/
flutter test test/flutter/
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Follow our [commit conventions](.github/COMMIT_CONVENTION.md)
4. Add tests for your changes
5. Ensure all tests pass (`flutter test`)
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [Kotlin](https://kotlinlang.org/) and its excellent standard library
- Built with ❤️ for the Flutter community
- Special thanks to all contributors and users who help make Kotlinish better

## 🔗 Links

- [Documentation](https://github.com/keelvin/kotlinish#readme)
- [Pub.dev Package](https://pub.dev/packages/kotlinish)
- [Issue Tracker](https://github.com/keelvin/kotlinish/issues)
- [Contributing Guide](CONTRIBUTING.md)

---

*Making Dart development as smooth and enjoyable as Kotlin! 🚀*