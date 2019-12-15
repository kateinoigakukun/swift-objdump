public struct RelativeDirectPointerIntPair<Pointee, IntTy: RawRepresentable>: RuntimeStruct
    where IntTy.RawValue == Int32
{
    let thisPtr: UnsafeRawPointer

    public init(_ ptr: UnsafeRawPointer) {
        self.thisPtr = ptr
    }

    public var size: Int { return MemoryLayout<Int32>.size }

    public func get() -> UnsafePointer<Pointee> {
        let offsetWithInt = thisPtr.load(as: Int32.self)
        let offset = offsetWithInt & ~intMask
        let advanced = thisPtr.advanced(by: Int(offset))
        let ptr = advanced.assumingMemoryBound(to: Pointee.self)
        return ptr
    }

    public func getValue() -> IntTy {
        let offsetWithInt = thisPtr.load(as: Int32.self)
        return IntTy(rawValue: offsetWithInt & intMask)!
    }

    var intMask: Int32 {
        Int32(
            min(
                MemoryLayout<Pointee>.alignment,
                MemoryLayout<Int32>.alignment
            ) - 1
        )
    }
}
