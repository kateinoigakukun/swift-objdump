public enum ContextDescriptorKind: UInt8 {
    case Module = 0
    case Extension = 1
    case Anonymous = 2
    case `Protocol` = 3
    case OpaqueType = 4
    case Class = 16
    case Struct = 17
    case Enum = 18
    case Type_Last = 31
};

public struct ContextDescriptorFlags {
    let value: UInt32

    func getKind() -> ContextDescriptorKind {
        ContextDescriptorKind(rawValue: UInt8(value & 0x1F))!
    }

    func isGeneric() -> Bool { (value & 0x80) != 0 }

    func isUnique() -> Bool { (value & 0x40) != 0 }

    func getVersion() -> UInt8 { UInt8(value >> 8) & 0xFF }

    func getKindSpecificFlags() -> UInt16 { UInt16(value >> 16) & 0xFFFF }
}

public enum TypeReferenceKind: ExpressibleByIntegerLiteral {
    case DirectTypeDescriptor, IndirectTypeDescriptor
    case DirectObjCClassName, IndirectObjCClass

    public init(integerLiteral value: Int32) {
        switch (value & 0x1, value & 0x2) {
        case (0, 0):
            self = .DirectTypeDescriptor
        case (0, 1):
            self = .IndirectTypeDescriptor
        case (1, 0):
            self = .DirectObjCClassName
        case (1, 1):
            self = .IndirectObjCClass
        default:
            fatalError()
        }
    }
}

public typealias ContextDescriptor = RuntimePair<
    RuntimeValue<ContextDescriptorFlags>,
    RelativePointer<Opaque>
>

public extension ContextDescriptor {
    func getFlags() -> ContextDescriptorFlags {
        project1().get()
    }
    func getParent() -> ContextDescriptor {
        project2().bind(to: ContextDescriptor.self).get().pointee
    }
}


public typealias TypeMetadataRecord = RuntimeUnion<
    RelativeDirectPointerIntPair<ContextDescriptor, TypeReferenceKind>,
    RelativeDirectPointerIntPair<UnsafePointer<ContextDescriptor>, TypeReferenceKind>
>

public extension TypeMetadataRecord {

    func getTypeKind() -> TypeReferenceKind  {
        return project1().getValue()
    }

    func getContextDescriptor() -> UnsafePointer<ContextDescriptor> {
        switch (getTypeKind()) {
        case .DirectTypeDescriptor:
            return project1().get()
        case .IndirectTypeDescriptor:
            return project2().get().pointee
        case .DirectObjCClassName,
             .IndirectObjCClass:
            fatalError()
        }
    }
}

public struct StoredClassMetadataBounds {}
public struct ExtraClassDescriptorFlags {}

public typealias ResilientSuperclass = RelativePointer<Void>


public typealias ClassDescriptorContent = RuntimePair<
    ContextDescriptor,
    RuntimePair<
    RuntimePair<
    RuntimePair<
    RuntimePair<
    RuntimePair<
    /* SuperclassType */ RelativePointer<CChar>,
    RuntimeUnion<
        /* MetadataNegativeSizeInWords */ RuntimeValue<UInt64>,
        /* ResilientMetadataBounds     */ RelativePointer<StoredClassMetadataBounds>
    >>,
    RuntimeUnion<
        /* MetadataPositiveSizeInWords */ RuntimeValue<UInt32>,
        /* ExtraClassFlags             */ RuntimeValue<ExtraClassDescriptorFlags>
    >>,
    /* NumImmediateMembers */     RuntimeValue<UInt32>>,
    /* NumFields */               RuntimeValue<UInt32>>,
    /* FieldOffsetVectorOffset */ RuntimeValue<UInt32>>
>

extension ClassDescriptorContent {
    var typeContextDescriptorFlags: Bool {
        return true
    }
}

typealias _ClassDescriptor = TrailingObject<
    ClassDescriptorContent,
    ResilientSuperclass, ClassDescriptorResilientSuperclassSizer
>
typealias ClassDescriptor = TrailingObject<
    _ClassDescriptor,
    RuntimeValue<UInt>, ClassDescriptorFoo
>

struct ClassDescriptorResilientSuperclassSizer: TrailingObjectSizer {
    static func numTrailingObjects(this: ClassDescriptorContent) -> Int {
        return this.typeContextDescriptorFlags ? 0 : 1
    }
}

struct ClassDescriptorFoo: TrailingObjectSizer {
    static func numTrailingObjects(this: _ClassDescriptor) -> Int {
        return this.typeContextDescriptorFlags ? 1 : 0
    }
}


extension ClassDescriptor {
    func foo() {
    }
}
