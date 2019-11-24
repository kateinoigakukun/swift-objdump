
struct Header {
    let title: String
}

struct Row {
    let values: [CustomStringConvertible]
}

class Table {
    let rows: [Row]
    init(rows: [Row]) {
        self.rows = rows
    }

    func render() -> String {

        let widthByColumn = rows.reduce(into: [Int:Int]()) { result, row in
            row.values.enumerated().forEach { index, value in
                if result[index].map({ $0 < value.description.count }) ?? true {
                    result[index] = value.description.count
                }
            }
        }

        let rowsString = rows.map {
            $0.values.enumerated().map { index, value in
                value.description.addingPadding(width: widthByColumn[index]!)
            }
                .joined(separator: "  ")
        }
        return rowsString.joined(separator: "\n")
    }
}

extension String {
    fileprivate func addingPadding(width: Int) -> String {
        return self + repeatElement(" ", count: width-count)
    }

    fileprivate func centeredPadding(width: Int) -> String {
        let paddings = (width-self.count)
        let left = (paddings/2)
        let right = left + paddings % 2
        return String(repeatElement(" ", count: left)) + self + repeatElement(" ", count: right)
    }
}

extension Array where Element == String {
    fileprivate func edged(separator: String) -> String {
        return separator + self.joined(separator: separator) + separator
    }
}

extension Array where Element: Equatable {
    fileprivate func allEqual() -> Bool {
        if let firstElem = first {
            return !dropFirst().contains { $0 != firstElem }
        }
        return true
    }
}
