public struct StoredClassMetadataBounds {}
public struct ExtraClassDescriptorFlags {}

public typealias ResilientSuperclass = RelativePointer<Void>
public typealias ForeignMetadataInitialization = RelativePointer<() -> Void>

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

public typealias __ClassDescriptor = TrailingObject<
    ___ClassDescriptor,
    TypeGenericContextDescriptorHeader,
    ClassDescriptorSizer.TypeGenericContextDescriptorHeader
>
public typealias _ClassDescriptor = TrailingObject<
    __ClassDescriptor,
    ResilientSuperclass,
    ClassDescriptorSizer.ResilientSuperclass
>
public typealias ClassDescriptor = TrailingObject<
    _ClassDescriptor,
    ForeignMetadataInitialization,
    ClassDescriptorSizer.ForeignMetadataInitialization
>

public enum ClassDescriptorSizer {}
public extension ClassDescriptorSizer {
    struct TypeGenericContextDescriptorHeader: TrailingObjectSizer {
        public static func numTrailingObjects(this: ___ClassDescriptor) -> Int {
            this.isGeneric ? 1 : 0
        }
    }
    struct ResilientSuperclass: TrailingObjectSizer {
        public static func numTrailingObjects(this: __ClassDescriptor) -> Int {
            this.hasResilientSuperclass ? 1 : 0
        }
    }
    struct ForeignMetadataInitialization: TrailingObjectSizer {
        public static func numTrailingObjects(this: _ClassDescriptor) -> Int {
            this.typeContextDescriptorFlags.hasForeignMetadataInitialization ? 1 : 0
        }
    }
}
