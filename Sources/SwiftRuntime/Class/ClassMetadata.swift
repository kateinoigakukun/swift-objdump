public typealias ClassFullMetadata = RuntimeInherit<
    AnyClassMetadata,
    RuntimePair<
    RuntimePair<
    RuntimePair<
    RuntimePair<
    RuntimePair<
    RuntimePair<
    RuntimePair<
    RuntimeValue<ClassFlags>,
    RuntimeValue<UInt32>>, // InstanceAddressPoint
    RuntimeValue<UInt32>>, // InstanceSize
    RuntimeValue<UInt16>>, // InstanceAlignMask
    RuntimeValue<UInt16>>, // Reserved
    RuntimeValue<UInt32>>, // ClassSize
    RuntimeValue<UInt32>>,  // ClassAddressPoint
    RuntimeValue<ClassDescriptor>>
    // TODO
>


extension ClassFullMetadata {
    var descriptor: ClassDescriptor {
        return this().project2().get()
    }
}
