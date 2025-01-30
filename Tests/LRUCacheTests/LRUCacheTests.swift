import Testing
@testable import LRUCache

@Test func cacheSample() async throws {
    var cache = LRUCache<String, Int>(capacity: 2)
    
    cache["a"] = 1
    
    #expect(cache["a"] == 1)
    
    cache["b"] = 2
    
    #expect(cache["a"] == 1)
    #expect(cache["b"] == 2)
    
    cache["c"] = 3
    
    #expect(cache["a"] == nil)
    #expect(cache["b"] == 2)
    #expect(cache["c"] == 3)
}
