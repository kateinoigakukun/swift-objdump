
public typealias ContextDescriptor = RuntimePair<
    RuntimeValue<ContextDescriptorFlags>,
    RelativePointer<Opaque>
>

public extension ContextDescriptor {
    var flags: ContextDescriptorFlags {
        project1().get()
    }
    var parent: ContextDescriptor {
        project2().bind(to: ContextDescriptor.self).get().pointee
    }

    var isGeneric: Bool { flags.isGeneric(); }
    var isUnique: Bool { flags.isUnique(); }
    var kind: ContextDescriptorKind { flags.getKind(); }
}
