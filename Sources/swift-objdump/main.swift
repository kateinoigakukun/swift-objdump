import Foundation
import MachOParser

func main(arguments: [String]) {
    let filePath = arguments[1]
    let data = NSData(contentsOfFile: filePath)!
    let object = data.bytes
    let parser = MachOParser(object)
    let visitor = AnalysisVisitor(objectFile: object)
    parser.parse(with: visitor)

    let pairs: [(String, UInt64)] = [
        ("Command Size", visitor.commandSize!),
        ("Relocation Info Size", UInt64(visitor.relocationInfoBySection.reduce(0, {
            $0 + $1.value.reduce(0, { $0 + $1.r_length})
        }))),
        ("Symbol Table Size", visitor.symbolTableSize!),
        ("Sections Size", UInt64(visitor.sections.reduce(0, { $0 + $1.size }))),
    ]

    let eachSections: [(String, UInt64)] = visitor.sections.map {
        return ("  " + String(fixedLengthString: $0.sectname, length: 16), UInt64($0.size))
    }

    let others = ("Others", UInt64(data.length) - pairs.map { $0.1 }.reduce(0, +))

    let total = Row(values: ["Total Size", UInt64(data.length), ""])
    let column = Row(values: ["Name", "Size", "%"])
    let rows = [column] + (pairs + eachSections + [others]).map {
        Row(values: [$0, $1, "\(round(Double($1) / Double(data.length) * 100 * 10)/10)%"])
    } + [total]

    let table = Table(rows: rows)

    print(table.render())
}

main(arguments: ProcessInfo.processInfo.arguments)
