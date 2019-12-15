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

public typealias TypeContextDescriptor = RuntimeInherit<
    ContextDescriptor,
    RuntimePair<
    RuntimePair<
    RelativePointer<CChar>,
    RelativePointer<() -> Void>>,
    RelativePointer<() -> Void>>
>

extension TypeContextDescriptor {
    var name: RelativePointer<CChar> {
        this().project1().project1()
    }
}
