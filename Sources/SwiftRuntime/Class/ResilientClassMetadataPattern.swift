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
