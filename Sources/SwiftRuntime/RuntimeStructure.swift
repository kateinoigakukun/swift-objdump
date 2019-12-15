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

public enum TypeReferenceKind: RawRepresentable {
    case DirectTypeDescriptor, IndirectTypeDescriptor
    case DirectObjCClassName, IndirectObjCClass


    public init?(rawValue: Int32) {
        self.init(rawValue)
    }
    public init?<T: BinaryInteger>(_ rawValue: T) {
        switch (rawValue & 0x1, rawValue & 0x2) {
        case (0, 0):
            self = .DirectTypeDescriptor
        case (0, 1):
            self = .IndirectTypeDescriptor
        case (1, 0):
            self = .DirectObjCClassName
        case (1, 1):
            self = .IndirectObjCClass
        default:
            return nil
        }
    }

    public var rawValue: Int32 { fatalError() }
}

protocol FlagSet {
    associatedtype IntTy: BinaryInteger
    var bits: IntTy { get }
}

extension FlagSet {
    func lowMaskFor(_ bitWidth: UInt) -> IntTy {
        IntTy((1 << bitWidth) - 1)
    }

    func maskFor(_ firstBit: UInt, _ bitWidth: UInt) -> IntTy {
        lowMaskFor(bitWidth) << firstBit
    }

    func getFlag(_ firstBit: UInt) -> Bool {
        return bits & maskFor(firstBit, 1) != 0
    }

    func getField<FieldTy: RawRepresentable>(_ firstBit: UInt, _ bitWidth: UInt) -> FieldTy? where FieldTy.RawValue == IntTy {
        FieldTy(rawValue: (bits >> firstBit) & lowMaskFor(bitWidth))
    }
    func getField(_ firstBit: UInt, _ bitWidth: UInt) -> IntTy {
        (bits >> firstBit) & lowMaskFor(bitWidth)
    }
}

public struct TypeContextDescriptorFlags: FlagSet, RawRepresentable {
    private static let MetadataInitialization: UInt = 0
    private static let MetadataInitialization_width: UInt = 2
    private static let HasImportInfo: UInt = 2
    private static let Class_ResilientSuperclassReferenceKind: UInt = 9
    private static let Class_ResilientSuperclassReferenceKind_width: UInt = 3
    private static let Class_AreImmediateMembersNegative: UInt = 12
    private static let Class_HasResilientSuperclass: UInt = 13
    private static let Class_HasOverrideTable: UInt = 14
    private static let Class_HasVTable: UInt = 15

    enum MetadataInitializationKind: UInt16 {
      case NoMetadataInitialization = 0
      case SingletonMetadataInitialization = 1
      case ForeignMetadataInitialization = 2
    }

    let bits: UInt16
    public var rawValue: UInt16 { bits }

    public init(rawValue: UInt16) {
        self.bits = rawValue
    }

    var metadataInitialization: MetadataInitializationKind {
        getField(Self.MetadataInitialization, Self.MetadataInitialization_width)!
    }
    var hasSingletonMetadataInitialization: Bool {
        metadataInitialization == .SingletonMetadataInitialization
    }
    var hasForeignMetadataInitialization: Bool {
        metadataInitialization == .ForeignMetadataInitialization
    }
    var hasImportInfo: Bool {
        getFlag(Self.HasImportInfo)
    }
    var class_hasVTable: Bool {
        getFlag(Self.Class_HasVTable)
    }
    var class_hasOverrideTable: Bool {
        getFlag(Self.Class_HasOverrideTable)
    }
    var class_hasResilientSuperclass: Bool {
        getFlag(Self.Class_HasResilientSuperclass)
    }
    var class_areImmediateMembersNegative: Bool {
        getFlag(Self.Class_AreImmediateMembersNegative)
    }

    var class_getResilientSuperclassReferenceKind: TypeReferenceKind {
        TypeReferenceKind(getField(
            Self.Class_ResilientSuperclassReferenceKind,
            Self.Class_ResilientSuperclassReferenceKind_width
        ))!
    }
}

public typealias ContextDescriptor = RuntimePair<
    RuntimeValue<ContextDescriptorFlags>,
    RelativePointer<Opaque>
>

public extension ContextDescriptor {
    var flags: ContextDescriptorFlags {
        project1().get()
    }
    var parent: ContextDescriptor {
        project2().bind(to: ContextDescriptor.self).get().pointee
    }

    var isGeneric: Bool { flags.isGeneric(); }
    var isUnique: Bool { flags.isUnique(); }
    var kind: ContextDescriptorKind { flags.getKind(); }
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

public typealias TypeMetadataHeader = RuntimeValue<UnsafeRawPointer> // VWT
public typealias Metadata = RuntimePair<
    TypeMetadataHeader,
    RuntimeValue<UInt> // Kind
>

public typealias HeapMetadata = Metadata

public typealias AnyClassMetadata = RuntimeInherit<
    HeapMetadata,
    RuntimePair<
    RuntimePair<
    RuntimePair<
    RuntimeValue<UnsafePointer<Void /* ClassMetadata */>>, // Superclass
    RuntimeValue<UnsafeRawPointer>> /* CacheData[0] */,
    RuntimeValue<UnsafeRawPointer>> /* CacheData[1] */,
    RuntimeValue<Int>> // Data
>

public typealias TypeContextDescriptor = RuntimeInherit<
    ContextDescriptor,
    RuntimePair<
    RuntimePair<
    RelativePointer<CChar>,
    RelativePointer<() -> Void>>,
    RelativePointer<() -> Void>>
>

public typealias ForeignMetadataInitialization = RelativePointer<() -> Void>
public typealias SingletonMetadataCache = RuntimePair<
    RuntimeValue<UnsafePointer<Metadata>>,
    RuntimeValue<UnsafeRawPointer>
>

public enum ClassFlags: UInt32 {

  case IsSwiftPreStableABI = 0x1
  case UsesSwiftRefcounting = 0x2
  case HasCustomObjCName = 0x4
}

public typealias MetadataRelocator = () -> Void
public typealias HeapObjectDestroyer = () -> Void
public typealias ClassIVarDestroyer = () -> Void

public typealias ResilientClassMetadataPattern = RuntimePair<
    RuntimePair<
    RuntimePair<
    RuntimePair<
    RuntimePair<
    RelativePointer<MetadataRelocator>,
    RelativePointer<HeapObjectDestroyer>>,
    RelativePointer<ClassIVarDestroyer>>,
    RuntimeValue<ClassFlags>>,
    RelativePointer<Void>>, // Data
    RelativePointer<AnyClassMetadata> // Metaclass
>
public typealias SingletonMetadataInitialization = RuntimePair<
    RelativePointer<SingletonMetadataCache>,
    RuntimeUnion<
        RelativePointer<Metadata>,
        RelativePointer<ResilientClassMetadataPattern>
    >
>

typealias GenericContextDescriptorHeader = RuntimePair<
    RuntimePair<
    RuntimePair<
    RuntimeValue<UInt16>,
    RuntimeValue<UInt16>>,
    RuntimeValue<UInt16>>,
    RuntimeValue<UInt16>
>

extension GenericContextDescriptorHeader {
    var numParams: UInt16         { project2().get() }
    var numRequirements: UInt16   { project1().project2().get() }
    var numKeyArguments: UInt16   { project1().project1().project2().get() }
    var numExtraArguments: UInt16 { project1().project1().project1().get() }

    var numArguments: UInt32 { UInt32(numKeyArguments) + UInt32(numExtraArguments) }
    var hasArguments: Bool { numArguments > 0 }
}

typealias TypeGenericContextDescriptorHeader = RuntimePair<
    RuntimePair<
    RelativePointer<Void>,
    RelativePointer<Void>>,
    GenericContextDescriptorHeader
>

public typealias ___ClassDescriptor = RuntimeInherit<
    TypeContextDescriptor,
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

extension ___ClassDescriptor {
    var typeContextDescriptorFlags: TypeContextDescriptorFlags {
        TypeContextDescriptorFlags(rawValue: self.flags.getKindSpecificFlags())
    }
    var hasResilientSuperclass: Bool {
        typeContextDescriptorFlags.class_hasResilientSuperclass
    }
}

typealias __ClassDescriptor = TrailingObject<
    ___ClassDescriptor,
    TypeGenericContextDescriptorHeader,
    ClassDescriptorSizer.TypeGenericContextDescriptorHeader
>
typealias _ClassDescriptor = TrailingObject<
    __ClassDescriptor,
    ResilientSuperclass,
    ClassDescriptorSizer.ResilientSuperclass
>
typealias ClassDescriptor = TrailingObject<
    _ClassDescriptor,
    ForeignMetadataInitialization,
    ClassDescriptorSizer.ForeignMetadataInitialization
>

enum ClassDescriptorSizer {}
extension ClassDescriptorSizer {
    struct TypeGenericContextDescriptorHeader: TrailingObjectSizer {
        static func numTrailingObjects(this: ___ClassDescriptor) -> Int {
            this.isGeneric ? 1 : 0
        }
    }
    struct ResilientSuperclass: TrailingObjectSizer {
        static func numTrailingObjects(this: __ClassDescriptor) -> Int {
            this.hasResilientSuperclass ? 1 : 0
        }
    }
    struct ForeignMetadataInitialization: TrailingObjectSizer {
        static func numTrailingObjects(this: _ClassDescriptor) -> Int {
            this.typeContextDescriptorFlags.hasForeignMetadataInitialization ? 1 : 0
        }
    }
}
