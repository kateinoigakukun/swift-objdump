public typealias HeapMetadata = Metadata

public typealias AnyClassMetadata = RuntimeInherit<
    HeapMetadata,
    RuntimePair<
    RuntimePair<
    RuntimePair<
    RuntimeValue<UnsafePointer<Void /* ClassMetadata */>>, // Superclass
    RuntimeValue<UnsafeRawPointer>> /* CacheData[0] */,
    RuntimeValue<UnsafeRawPointer>> /* CacheData[1] */,
    RuntimeValue<Int>> // Data
>
