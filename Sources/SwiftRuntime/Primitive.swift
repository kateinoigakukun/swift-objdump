public protocol RuntimeStruct {
    var size: Int { get }
    init(_: UnsafeRawPointer)
}

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

public struct RuntimePair<E1: RuntimeStruct, E2: RuntimeStruct>: RuntimeStruct {
    private let ptr: UnsafeRawPointer

    public func project1() -> E1 { E1(ptr) }
    public func project2() -> E2 { E2(ptr.advanced(by: project1().size)) }

    public var size: Int { project1().size + project2().size }
    public init(_ ptr: UnsafeRawPointer) { self.ptr = ptr }
}

public struct RuntimeUnion<E1: RuntimeStruct, E2: RuntimeStruct>: RuntimeStruct {
    private let ptr: UnsafeRawPointer

    public func project1() -> E1 { E1(ptr) }
    public func project2() -> E2 { E2(ptr) }

    public var size: Int { max(project1().size, project2().size) }
    public init(_ ptr: UnsafeRawPointer) { self.ptr = ptr }
}

public struct RuntimeValue<E>: RuntimeStruct {
    public var size: Int {
        print("Size of \(E.self) is \(MemoryLayout<E>.size)")
        return MemoryLayout<E>.size
    }
    private let ptr: UnsafeRawPointer

    public func get() -> E { ptr.load(as: E.self) }
    public init(_ ptr: UnsafeRawPointer) { self.ptr = ptr }
}


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

public struct Opaque {}
public extension RelativePointer where Pointee == Opaque {
    func bind<T>(to: T.Type) -> RelativePointer<T> {
        RelativePointer<T>(thisPtr)
    }
}

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
