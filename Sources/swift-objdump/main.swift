import Foundation
import MachOParser

func main(arguments: [String]) {
    let filePath = arguments.first!
    let data = NSData(contentsOfFile: filePath)!
    let object = data.bytes
    let parser = MachOParser(object)
    let visitor = AnalysisVisitor(objectFile: object)
    parser.parse(with: visitor)

    let pairs: [(String, UInt32)] = [
        ("Command Size", visitor.commandSize!),
        ("Relocation Info Size", UInt32(visitor.relocationInfoBySection.reduce(0, {
            $0 + $1.value.reduce(0, { $0 + $1.r_length})
        }))),
        ("Sections Size", UInt32(visitor.sections.reduce(0, { $0 + $1.size }))),
        ("Symbol Table Size", visitor.symbolTableSize!),
    ]

    let others = ("Others", UInt32(data.length) - pairs.lazy.map { $0.1 }.reduce(0, +))


    let total = Row(values: ["Total Size", UInt32(data.length), ""])
    let column = Row(values: ["Name", "Size", "%"])
    let rows = [column] + (pairs + [others]).map {
        Row(values: [$0, $1, "\(round(Double($1) / Double(data.length) * 100 * 10)/10)%"])
    } + [total]

    let table = Table(rows: rows)

    print(table.render())
}

main(arguments: ProcessInfo.processInfo.arguments)
