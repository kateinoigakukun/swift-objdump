public typealias SingletonMetadataInitialization = RuntimePair<
    RelativePointer<SingletonMetadataCache>,
    RuntimeUnion<
        RelativePointer<Metadata>,
        RelativePointer<ResilientClassMetadataPattern>
    >
>

public typealias SingletonMetadataCache = RuntimePair<
    RuntimeValue<UnsafePointer<Metadata>>,
    RuntimeValue<UnsafeRawPointer>
>
