import Foundation
import MachOParser

func main(arguments: [String]) {
    let filePath = arguments[1]
    let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
    SizeAnalyzer().report(object: data)
}

main(arguments: ProcessInfo.processInfo.arguments)
