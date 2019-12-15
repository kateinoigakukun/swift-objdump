public struct Opaque {}
public extension RelativePointer where Pointee == Opaque {
    func bind<T>(to: T.Type) -> RelativePointer<T> {
        RelativePointer<T>(thisPtr)
    }
}
