//
//  LRUCache.swift
//  LRUCache
//
//  Created by yuki on 2025/01/30.
//

public struct LRUCache<Key: Hashable, Value>: Sequence {

    public typealias Element = (key: Key, value: Value)

    public struct Iterator: IteratorProtocol {
        @usableFromInline var current: _Storage<Key, Value>._Node?
        
        @usableFromInline init(startNode: _Storage<Key, Value>._Node?) {
            self.current = startNode
        }
        
        @inlinable public mutating func next() -> Element? {
            guard let node = self.current else { return nil }
            self.current = node.next
            return (node.key, node.value)
        }
    }
    
    @inlinable public var capacity: Int {
        @inlinable get {
            self.storage.capacity
        }
        @inlinable set {
            self.ensureUniqueStorage()
            self.storage.capacity = newValue
            self.storage.trimToCapacity()
        }
    }
    
    @inlinable public var count: Int { self.storage.count }
    
    @inlinable public var isEmpty: Bool { self.count == 0 }
    
    @inlinable public init(capacity: Int) {
        self.storage = _Storage<Key, Value>(capacity: capacity)
    }
    
    @inlinable public subscript(key: Key) -> Value? {
        @inlinable get {
            let result = self.storage.getAndPromote(key)
            return result
        }
        @inlinable _modify {
            self.ensureUniqueStorage()
            var value = self.storage.getAndPromote(key)
            yield &value
            if let unwrapped = value {
                self.storage.put(key: key, value: unwrapped)
            } else {
                _ = self.storage.remove(key)
            }
        }
    }
    
    @discardableResult
    @inlinable public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        self.ensureUniqueStorage()
        let oldValue = self.storage.getAndPromote(key)
        self.storage.put(key: key, value: value)
        return oldValue
    }
    
    @discardableResult
    @inlinable public mutating func removeValue(forKey key: Key) -> Value? {
        self.ensureUniqueStorage()
        return self.storage.remove(key)
    }
    
    @inlinable public func makeIterator() -> Iterator {
        return Iterator(startNode: self.storage.head)
    }
    
    @usableFromInline var storage: _Storage<Key, Value>
    
    @inlinable mutating func ensureUniqueStorage() {
        if !isKnownUniquelyReferenced(&self.storage) {
            self.storage = self.storage.copy()
        }
    }
}

@usableFromInline
final class _Storage<Key: Hashable, Value> {
    @usableFromInline
    final class _Node {
        @usableFromInline let key: Key
        @usableFromInline var value: Value
        @usableFromInline var next: _Node?
        @usableFromInline var prev: _Node?
        
        @inlinable init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }
    
    @usableFromInline var capacity: Int
    
    @usableFromInline var count: Int { self.dict.count }
    
    @usableFromInline var dict: [Key: _Node]
    
    @usableFromInline var head: _Node?
    
    @usableFromInline var tail: _Node?
    
    @inlinable init(capacity: Int) {
        self.capacity = max(capacity, 1)
        self.dict = [:]
        self.head = nil
        self.tail = nil
    }
    
    @inlinable init(original: _Storage<Key, Value>) {
        self.capacity = original.capacity
        self.dict = [:]
        
        var srcNode = original.head
        var prevNewNode: _Node? = nil
        
        while let src = srcNode {
            let newNode = _Node(key: src.key, value: src.value)
            self.dict[newNode.key] = newNode
            
            if let p = prevNewNode {
                p.next = newNode
                newNode.prev = p
            } else {
                self.head = newNode
            }
            
            prevNewNode = newNode
            srcNode = src.next
        }
        self.tail = prevNewNode
    }
    
    @inlinable func copy() -> _Storage<Key, Value> {
        return _Storage<Key, Value>(original: self)
    }
    
    @inlinable func getAndPromote(_ key: Key) -> Value? {
        guard let node = self.dict[key] else { return nil }
        self.moveToHead(node)
        return node.value
    }
    
    @inlinable func put(key: Key, value: Value) {
        if let node = self.dict[key] {
            node.value = value
            self.moveToHead(node)
        } else {
            let newNode = _Node(key: key, value: value)
            self.dict[key] = newNode
            self.pushHead(newNode)
            if self.dict.count > self.capacity {
                self.popTail()
            }
        }
    }
    
    @inlinable func remove(_ key: Key) -> Value? {
        guard let node = self.dict[key] else {
            return nil
        }
        self.removeNode(node)
        self.dict.removeValue(forKey: key)
        return node.value
    }
    
    @inlinable func trimToCapacity() {
        while self.dict.count > self.capacity {
            self.popTail()
        }
    }
    
    @inlinable func pushHead(_ node: _Node) {
        node.prev = nil
        node.next = self.head
        
        if let h = self.head {
            h.prev = node
        }
        self.head = node
        
        if self.tail == nil {
            self.tail = node
        }
    }
    
    @inlinable func popTail() {
        guard let oldTail = self.tail else {
            return
        }
        self.removeNode(oldTail)
        self.dict.removeValue(forKey: oldTail.key)
    }
    
    @inlinable func removeNode(_ node: _Node) {
        let prev = node.prev
        let next = node.next
        
        if let p = prev {
            p.next = next
        } else {
            self.head = next
        }
        
        if let n = next {
            n.prev = prev
        } else {
            self.tail = prev
        }
        
        node.prev = nil
        node.next = nil
    }
    
    @inlinable func moveToHead(_ node: _Node) {
        guard node !== self.head else {
            return
        }
        self.removeNode(node)
        self.pushHead(node)
    }
}
