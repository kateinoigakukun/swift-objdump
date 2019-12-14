protocol RuntimeStruct {
    static var size: Int { get }
    init(_: UnsafeRawPointer)
}

struct RuntimePair<E1: RuntimeStruct, E2: RuntimeStruct>: RuntimeStruct {
    private let ptr: UnsafeRawPointer

    func project1() -> E1 { E1(ptr) }
    func project2() -> E2 { E2(ptr.advanced(by: E1.size)) }

    static var size: Int { E1.size + E2.size }
    init(_ ptr: UnsafeRawPointer) { self.ptr = ptr }
}

struct RuntimeUnion<E1: RuntimeStruct, E2: RuntimeStruct>: RuntimeStruct {
    private let ptr: UnsafeRawPointer

    func project1() -> E1 { E1(ptr) }
    func project2() -> E2 { E2(ptr) }

    static var size: Int { max(E1.size, E2.size) }
    init(_ ptr: UnsafeRawPointer) { self.ptr = ptr }
}

struct RuntimeValue<E>: RuntimeStruct {
    static var size: Int { MemoryLayout<E>.size }
    private let ptr: UnsafeRawPointer

    func dereference() -> E { ptr.load(as: E.self) }
    init(_ ptr: UnsafeRawPointer) { self.ptr = ptr }
}
