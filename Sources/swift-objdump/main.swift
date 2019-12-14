import Foundation
import MachOParser

func main(arguments: [String]) {
    let filePath = arguments[1]
    let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
    data.withUnsafeBytes { (ptr) in

    }
}

main(arguments: ProcessInfo.processInfo.arguments)
