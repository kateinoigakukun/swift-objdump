public struct RuntimePair<E1: RuntimeStruct, E2: RuntimeStruct>: RuntimeStruct {
    private let ptr: UnsafeRawPointer

    public func project1() -> E1 { E1(ptr) }
    public func project2() -> E2 { E2(ptr.advanced(by: project1().size)) }

    public var size: Int { project1().size + project2().size }
    public init(_ ptr: UnsafeRawPointer) { self.ptr = ptr }
}
