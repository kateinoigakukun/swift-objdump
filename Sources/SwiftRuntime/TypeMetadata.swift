public typealias TypeMetadataHeader = RuntimeValue<UnsafeRawPointer> // VWT
public typealias Metadata = RuntimePair<
    TypeMetadataHeader,
    RuntimeValue<UInt> // Kind
>

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
