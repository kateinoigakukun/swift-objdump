public protocol RuntimeStruct {
    static var size: Int { get }
    init(_: UnsafeRawPointer)
}

public struct RuntimePair<E1: RuntimeStruct, E2: RuntimeStruct>: RuntimeStruct {
    private let ptr: UnsafeRawPointer

    public func project1() -> E1 { E1(ptr) }
    public func project2() -> E2 { E2(ptr.advanced(by: E1.size)) }

    public static var size: Int { E1.size + E2.size }
    public init(_ ptr: UnsafeRawPointer) { self.ptr = ptr }
}

public struct RuntimeUnion<E1: RuntimeStruct, E2: RuntimeStruct>: RuntimeStruct {
    private let ptr: UnsafeRawPointer

    public func project1() -> E1 { E1(ptr) }
    public func project2() -> E2 { E2(ptr) }

    public static var size: Int { max(E1.size, E2.size) }
    public init(_ ptr: UnsafeRawPointer) { self.ptr = ptr }
}

public struct RuntimeValue<E>: RuntimeStruct {
    public static var size: Int { MemoryLayout<E>.size }
    private let ptr: UnsafeRawPointer

    public func dereference() -> E { ptr.load(as: E.self) }
    public init(_ ptr: UnsafeRawPointer) { self.ptr = ptr }
}
