# LRUCache

A lightweight Swift library that provides an **LRU (Least Recently Used) cache** with a **Dictionary-like** interface and **Sequence** conformance. This means you can store key-value pairs, read/update them using a convenient subscript, and iterate over them in LRU order—all while respecting Swift’s value semantics (via Copy-on-Write).

## Features

- **LRU Policy**: Automatically evicts the least recently used element whenever the cache exceeds its specified capacity.
- **Dictionary-Like Access**: Supports subscript for getting and setting values, as well as methods like `updateValue(_:forKey:)` and `removeValue(forKey:)`.
- **Sequence Conformance**: Provides a `makeIterator()` that traverses elements from the most recently used (head) to the least recently used (tail).
- **Value Semantics (Copy-on-Write)**: The `LRUCache` is declared as a `struct`, but internally manages its data through a reference type. This allows you to copy and pass it around without accidentally sharing mutable state, unless explicitly intended.

## Installation

### Swift Package Manager

1. In your `Package.swift`, add the package dependency:

   ```swift
   // swift-tools-version:5.5

   import PackageDescription

   let package = Package(
       name: "MyProject",
       dependencies: [
           .package(url: "https://github.com/YourGitHubAccount/LRUCache.git", from: "1.0.0")
       ],
       targets: [
           .target(
               name: "MyProject",
               dependencies: ["LRUCache"]
           )
       ]
   )
   ```

2. In your source code, import `LRUCache`:
   ```swift
   import LRUCache
   ```

3. Run `swift build` to fetch, compile, and link the dependency.

## Usage

```swift
import LRUCache

// 1) Create an LRUCache with a specified capacity
var cache = LRUCache<String, Int>(capacity: 2)

// 2) Store key-value pairs using subscript
cache["apple"] = 10
cache["banana"] = 20

// 3) Access a key’s value
//    Reading a value automatically updates its "recently used" status
if let appleValue = cache["apple"] {
    print("apple => \(appleValue)")
    // Now "apple" is considered the most recently used item
}

// 4) Insert a new item beyond capacity
cache["cherry"] = 30
// Since capacity is 2, the least recently used item is removed ("banana" in this case)

// 5) Iterate over the cache
//    Iteration goes from the most recently used (head) to the least recently used (tail)
for (key, value) in cache {
    print("\(key) => \(value)")
}

// 6) Explicitly remove a value
let removedValue = cache.removeValue(forKey: "apple") 
// removedValue is 10, cache now only has "cherry"
```

### Important Notes

- **LRU Updates on Read**  
  Accessing an element via subscript (`cache[key]`) moves that element to the front of the LRU list, marking it as the “most recently used.” This is critical for usage patterns where read-access also needs to maintain LRU ordering.
  
- **Copy-on-Write**  
  `LRUCache` uses CoW semantics. Modifying a copy of a cache will trigger a deep copy of the underlying storage only if there are additional references to that storage.

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request. When making changes, please ensure:

- Code style follows Swift conventions.
- New features are tested thoroughly.
- Any documentation or README updates are included as needed.

## License

`LRUCache` is released under the MIT License. See [LICENSE](LICENSE) for more details.