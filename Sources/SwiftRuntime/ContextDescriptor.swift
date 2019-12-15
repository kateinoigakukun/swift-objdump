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


public typealias GenericContextDescriptorHeader = RuntimePair<
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

public typealias TypeGenericContextDescriptorHeader = RuntimePair<
    RuntimePair<
    RelativePointer<Void>,
    RelativePointer<Void>>,
    GenericContextDescriptorHeader
>
