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
