import Foundation
import SwiftUI
import HealthKit

// MARK: - ext
public extension Date {
    public  func mondayAt12AM() -> Date{
        return Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear,.weekOfYear],from: Date()))!
    }
    
}
public extension TimeInterval{

    public func stringFromTimeInterval() -> String {

            let time = NSInteger(self)

           // let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
            //let seconds = time % 60
            let minutes = (time / 60) % 60
            let hours = (time / 3600)

            return String(format: "%0.2d:%0.2d",hours,minutes)
          //  return String(hours)
        

        }
}





public extension Bundle{
    public func decode < T : Codable> (_ file : String) -> T{
        //create the json file
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("failed to locate \(file) in bundle")
        }
        //create a property for the data
        guard  let data = try? Data(contentsOf: url) else {
            fatalError("failed to load \(file) from bundle")
        }
        //create a decoder
        let decoder = JSONDecoder()
        //create a property for the decoder data
        guard let loaded = try? decoder.decode( T.self , from: data) else {
            fatalError("failed to decode \(file) from bundle")
        }
        //return the ready-to-use data
         return loaded
    }
    public func decodev2 <T : Codable> (_ data : Data) -> T{
        //create a decoder
        let decoder = JSONDecoder()
        //create a property for the decoder data
        guard let loaded = try? decoder.decode( T.self , from: data) else {
            fatalError("failed to decode \(data) from bundle")
        }
        //return the ready-to-use data
         return loaded
    }
}
public extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
     var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    var zeroSeconds: Date? {
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
            return calendar.date(from: dateComponents)
        }
}

