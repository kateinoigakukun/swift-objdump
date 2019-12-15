public protocol RuntimeStruct {
    var size: Int { get }
    init(_: UnsafeRawPointer)
}
