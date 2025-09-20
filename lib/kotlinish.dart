/// Kotlinish - Making Dart smooth as Kotlin
///
/// Kotlin-inspired extensions and utilities for Dart/Flutter development.
///
/// This library provides:
/// - 🎯 **Scope Functions** - `let`, `apply`, `run`, `also`, `use` for fluent code
/// - 📚 **Powerful Collections** - Safe accessors, advanced operators, enhanced operations
/// - ⚡ **Elegant Async** - Kotlin Coroutines-style concurrency for Dart Isolates
/// - 🌊 **Reactive Streams** - Advanced stream operations and reactive extensions
/// - 💾 **Cache Management** - LRU, expiring, and multi-level caching solutions
/// - 🎨 **Flutter Integration** - Widget extensions, state management, and context utilities
library;

export 'src/scope_functions/let.dart';
export 'src/scope_functions/apply.dart';
export 'src/scope_functions/run.dart';
export 'src/scope_functions/also.dart';
export 'src/scope_functions/use.dart';

// Collections
export 'src/collections/safe_accessors.dart';
export 'src/collections/conditional_accessors.dart';
export 'src/collections/grouping_utilities.dart';
export 'src/collections/transformation_pipelines.dart';
export 'src/collections/enhanced_operations.dart';

// Async
export 'src/async/async_core.dart';
export 'src/async/async_builders.dart';
export 'src/async/channels.dart';

// Flutter
export 'src/flutter/widget_extensions.dart';
export 'src/flutter/context_extensions.dart';

// Reactive Programming
export 'src/reactive/reactive_streams.dart';