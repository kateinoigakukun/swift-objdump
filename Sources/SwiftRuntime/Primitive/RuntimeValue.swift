public struct RuntimeValue<E>: RuntimeStruct {
    public var size: Int {
        print("Size of \(E.self) is \(MemoryLayout<E>.size)")
        return MemoryLayout<E>.size
    }
    private let ptr: UnsafeRawPointer

    public func get() -> E { ptr.load(as: E.self) }
    public init(_ ptr: UnsafeRawPointer) { self.ptr = ptr }
}
