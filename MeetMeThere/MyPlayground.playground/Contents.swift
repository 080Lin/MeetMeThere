import SwiftUI
import Foundation

//var greeting = "Hello, playground"
//
//func multiply<T: Numeric>(_ number: T) -> Double {
//    let res = number * number
//    return Double(res)
//}
//
//
//let int = 2
//let double = 2.5
//let float = Float(2.3)
//
//print(multiply(int))
//print(multiply(double))
//
//print(multiply(float))
let num = 12_345.67

let formatter = NumberFormatter()
formatter.numberStyle = .spellOut

formatter.locale = Locale(identifier: "ru_RU")
print(formatter.string(from: num as NSNumber) ?? "")
