public struct RelativePointer<Pointee>: RuntimeStruct {
    let thisPtr: UnsafeRawPointer

    public init(_ ptr: UnsafeRawPointer) {
        self.thisPtr = ptr
    }

    public var size: Int { return MemoryLayout<Int32>.size }

    public func get() -> UnsafePointer<Pointee> {
        let offset = thisPtr.load(as: Int32.self)
        let advanced = thisPtr.advanced(by: Int(offset))
        return advanced.assumingMemoryBound(to: Pointee.self)
    }
}
