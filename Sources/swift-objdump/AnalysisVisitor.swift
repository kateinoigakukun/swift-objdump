import MachOParser
import MachO.loader

class AnalysisVisitor: MachOVisitor {
    class SegmentContext {
        let segment: segment_command_64
        var sectionCount: UInt32 = 0
        init(_ segment: segment_command_64) { self.segment = segment }
    }

    let objectFile: UnsafeRawPointer
    var segmentContext: SegmentContext?
    var segments: [segment_command_64] = []
    var sections: [section_64] = []
    var commandSize: UInt32?
    var symbolTableSize: UInt32?
    var dynamicSymbolTableSize: UInt32?

    var relocationInfoBySection: [String: [relocation_info]] = [:]
    var symbolTable: [String] = []
    var sizeByCommandName: [String: UInt32] = [:]

    init(objectFile: UnsafeRawPointer) {
        self.objectFile = objectFile
    }

    func visit(_ header: UnsafePointer<mach_header>) {
        fatalError("32bit is unsupported")
    }

    func visit(_ header: UnsafePointer<mach_header_64>) {
        commandSize = header.pointee.sizeofcmds
    }

    func visit(_ command: UnsafePointer<segment_command_64>) {
        segmentContext = SegmentContext(command.pointee)
        segments.append(command.pointee)
        sizeByCommandName[_typeName(segment_command_64.self), default: 0] += command.pointee.cmdsize
    }

    func visit(_ section: UnsafePointer<section_64>) {
        guard let context = segmentContext else { preconditionFailure() }
        context.sectionCount += 1
        if context.sectionCount == context.segment.nsects {
            segmentContext = nil
        }
        sections.append(section.pointee)

        var relocPtr = objectFile.advanced(by: Int(section.pointee.reloff))
        var relocInfo: [relocation_info] = []
        for _ in 0..<section.pointee.nreloc {
            let info = relocPtr.load(as: relocation_info.self)
            relocInfo.append(info)
            relocPtr = relocPtr.advanced(by: MemoryLayout<relocation_info>.size)
        }
        relocationInfoBySection[String(fixedLengthString: section.pointee.sectname)] = relocInfo
    }

    func visit(_ section: UnsafePointer<section>) {}

    func visit(_ command: UnsafePointer<symtab_command>) {
        assert(symbolTableSize == nil)
        symbolTableSize = command.pointee.strsize + UInt32(MemoryLayout<nlist_64>.size) * command.pointee.nsyms
        sizeByCommandName[_typeName(symtab_command.self), default: 0] += command.pointee.cmdsize

        let stringsPtr = objectFile.advanced(by: Int(command.pointee.stroff))
        var symPtr = objectFile.advanced(by: Int(command.pointee.symoff))
        for _ in 0..<command.pointee.nsyms {
            let sym = symPtr.load(as: nlist_64.self)
            let name = stringsPtr
                .advanced(by: Int(sym.n_un.n_strx) * MemoryLayout<CChar>.size)
                .assumingMemoryBound(to: CChar.self)
            let str = String(cString: name)
            symbolTable.append(str)
            symPtr = symPtr.advanced(by: MemoryLayout<nlist_64>.size)
        }
    }

    func visit<LC: LoadCommand>(_ command: UnsafePointer<LC>) {
        sizeByCommandName[_typeName(LC.self), default: 0] += command.pointee.cmdsize
    }
}


