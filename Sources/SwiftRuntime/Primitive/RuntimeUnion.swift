public struct RuntimeUnion<E1: RuntimeStruct, E2: RuntimeStruct>: RuntimeStruct {
    private let ptr: UnsafeRawPointer

    public func project1() -> E1 { E1(ptr) }
    public func project2() -> E2 { E2(ptr) }

    public var size: Int { max(project1().size, project2().size) }
    public init(_ ptr: UnsafeRawPointer) { self.ptr = ptr }
}
