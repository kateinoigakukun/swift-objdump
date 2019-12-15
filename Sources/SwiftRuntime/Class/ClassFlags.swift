public struct ClassFlags {

    let value: UInt32
    enum Flag: UInt32 {
        case IsSwiftPreStableABI = 0x1
        case UsesSwiftRefcounting = 0x2
        case HasCustomObjCName = 0x4
    }
}
