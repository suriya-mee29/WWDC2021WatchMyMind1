import Foundation

// MARK: - MODEl
public struct Activity : Identifiable , Codable{
    public let id : String
    public let title : String
    public let description : String
    public  let type : String
    public let imageIcon : String
    public  var progrss: String
    
    public mutating func setProgress(pro: String){
        self.progrss = pro
    }
    

}
