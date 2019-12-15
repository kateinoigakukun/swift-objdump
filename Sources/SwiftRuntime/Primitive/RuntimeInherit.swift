@dynamicMemberLookup
public struct RuntimeInherit<Parent: RuntimeStruct, This: RuntimeStruct>: RuntimeStruct {
    private let ptr: UnsafeRawPointer

    public func parent() -> Parent { Parent(ptr) }
    public func this() -> This { This(ptr.advanced(by: parent().size)) }

    public var size: Int { parent().size + this().size }
    public init(_ ptr: UnsafeRawPointer) { self.ptr = ptr }

    subscript<U>(dynamicMember keyPath: KeyPath<This, U>) -> U {
        return this()[keyPath: keyPath]
    }
    subscript<U>(dynamicMember keyPath: KeyPath<Parent, U>) -> U {
        return parent()[keyPath: keyPath]
    }
}
