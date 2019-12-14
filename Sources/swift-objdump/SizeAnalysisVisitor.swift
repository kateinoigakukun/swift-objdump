import MachOParser
import MachO.loader
import Foundation

class SizeAnalyzer {
    func report(object: Data) {
        let result = object.withUnsafeBytes { ptr -> Visitor.Result in
            let parser = MachOParser(ptr.baseAddress!)
            let visitor = Visitor(objectFile: ptr.baseAddress!)
            parser.parse(with: visitor)
            return visitor.finalize()
        }
        let formatter = TableFormatter()
        let table = formatter.format(result, dataLength: object.count)
        print(table.render())
    }

    class Visitor {
        class SegmentContext {
            let segment: segment_command_64
            var sectionCount: UInt32 = 0
            init(_ segment: segment_command_64) { self.segment = segment }
        }

        struct Result {
            var commandSize: UInt64?
            var symbolTableSize: UInt64?
            var sections: [section_64] = []

            var relocationInfoBySection: [String: [relocation_info]] = [:]
            var symbolTable: [String] = []
        }

        private let objectFile: UnsafeRawPointer
        private var segmentContext: SegmentContext?
        private var result: Result

        init(objectFile: UnsafeRawPointer) {
            self.objectFile = objectFile
            self.result = Result()
        }

        func finalize() -> Result { result }
    }

    class TableFormatter {
        func format(_ result: Visitor.Result, dataLength: Int) -> Table {
            let pairs: [(String, UInt64)] = [
                ("Command Size", result.commandSize!),
                ("Relocation Info Size", UInt64(result.relocationInfoBySection.reduce(0, {
                    $0 + $1.value.reduce(0, { $0 + $1.r_length})
                }))),
                ("Symbol Table Size", result.symbolTableSize!),
                ("Sections Size", UInt64(result.sections.reduce(0, { $0 + $1.size }))),
            ]

            let eachSections: [(String, UInt64)] = result.sections.map {
                return ("  " + String(fixedLengthString: $0.sectname, length: 16), UInt64($0.size))
            }

            let others = ("Others", UInt64(dataLength) - pairs.map { $0.1 }.reduce(0, +))

            let total = Row(values: ["Total Size", UInt64(dataLength), ""])
            let column = Row(values: ["Name", "Size", "%"])
            let rows = [column] + (pairs + eachSections + [others]).map {
                Row(values: [$0, $1, "\(round(Double($1) / Double(dataLength) * 100 * 10)/10)%"])
            } + [total]

            return Table(rows: rows)
        }
    }
}

extension SizeAnalyzer.Visitor: MachOVisitor {

    func visit(_ header: UnsafePointer<mach_header>) {
        fatalError("32bit is unsupported")
    }

    func visit(_ header: UnsafePointer<mach_header_64>) {
        result.commandSize = UInt64(header.pointee.sizeofcmds)
    }

    func visit(_ command: UnsafePointer<segment_command_64>) {
        segmentContext = SegmentContext(command.pointee)
    }

    func visit(_ section: UnsafePointer<section_64>) {
        guard let context = segmentContext else { preconditionFailure() }
        context.sectionCount += 1
        if context.sectionCount == context.segment.nsects {
            segmentContext = nil
        }
        result.sections.append(section.pointee)

        var relocPtr = objectFile.advanced(by: Int(section.pointee.reloff))
        var relocInfo: [relocation_info] = []
        for _ in 0..<section.pointee.nreloc {
            let info = relocPtr.load(as: relocation_info.self)
            relocInfo.append(info)
            relocPtr = relocPtr.advanced(by: MemoryLayout<relocation_info>.size)
        }
        result.relocationInfoBySection[String(fixedLengthString: section.pointee.sectname, length: 16)] = relocInfo
    }

    func visit(_ section: UnsafePointer<section>) {}

    func visit(_ command: UnsafePointer<symtab_command>) {
        assert(result.symbolTableSize == nil)
        result.symbolTableSize = UInt64(command.pointee.strsize) + UInt64(MemoryLayout<nlist_64>.size) * UInt64(command.pointee.nsyms)

        let stringsPtr = objectFile.advanced(by: Int(command.pointee.stroff))
        var symPtr = objectFile.advanced(by: Int(command.pointee.symoff))
        for _ in 0..<command.pointee.nsyms {
            let sym = symPtr.load(as: nlist_64.self)
            let name = stringsPtr
                .advanced(by: Int(sym.n_un.n_strx) * MemoryLayout<CChar>.size)
                .assumingMemoryBound(to: CChar.self)
            let str = String(cString: name)
            result.symbolTable.append(str)
            symPtr = symPtr.advanced(by: MemoryLayout<nlist_64>.size)
        }
    }
    func visit(_ command: UnsafePointer<dylib_command>) {
        dump(command.pointee)
    }
    func visit<LC: LoadCommand>(_ command: UnsafePointer<LC>) {}
}
