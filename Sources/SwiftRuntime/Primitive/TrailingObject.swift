public protocol TrailingObjectSizer {
    associatedtype This
    static func numTrailingObjects(this: This) -> Int
}

@dynamicMemberLookup
public struct TrailingObject<This: RuntimeStruct, Object: RuntimeStruct, Sizer>: RuntimeStruct
    where Sizer: TrailingObjectSizer, Sizer.This == This
{
    private let ptr: UnsafeRawPointer
    public init(_ ptr: UnsafeRawPointer) {
        self.ptr = ptr
    }

    func getThis() -> This {
        return This(ptr)
    }

    func getTrailingObjects() -> UnsafePointer<Object> {
        ptr.advanced(by: getThis().size).bindMemory(
            to: Object.self,
            capacity: Sizer.numTrailingObjects(this: getThis())
        )
    }

    public var size: Int {
        getThis().size + getTrailingObjects().pointee.size * Sizer.numTrailingObjects(this: getThis())
    }

    subscript<U>(dynamicMember keyPath: KeyPath<This, U>) -> U {
        return getThis()[keyPath: keyPath]
    }
}
