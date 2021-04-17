import SwiftUI


public struct ActivityCard : View {
    // MARK: - PROPERTIES
    
    let titie : String
    let description : String
    let type : String
    let imageIcon : String
    
    let progressColor : Color
    let progrss: String
    let backgroundColor : Color
    
    @State var isGoal : Bool = false
    @State var goalValue : Int = 0
    @State var value : Int = 0
    
    
    let standingColor : Color = Color(red: 253 / 255, green: 113 / 255, blue: 60 / 255)
    // MARK: - Initialize
    public init(title: String ,description : String , type : String , imageIcon : String ,
                progressColor : Color ,progress : String , backgroundColor : Color ){
        self.titie = title
        self.description = description
        self.type = type
        self.imageIcon = imageIcon
        
        self.progrss = progress
        self.progressColor = progressColor
        self.backgroundColor = backgroundColor
    }
    // MARK: - FUNCTION
    
    func goalProgress(){
        let userDefaults = UserDefaults.standard
        
        if titie == "Mindfulness" {
            let MFGoal = userDefaults.integer(forKey: "MF")
            if MFGoal != nil {
                let today = Date()
                let mfKey = "MFCollection"
                var mfCol = [MindfulnessModel2]()
                do {
                    let storedObjItem = userDefaults.object(forKey: mfKey)
                    if storedObjItem != nil{
                    let storedItems = try JSONDecoder().decode([MindfulnessModel2].self, from: storedObjItem as! Data)
                        
                        var value : Int = 0
                        for i in 0...(storedItems.count - 1){
                            if Calendar.current.isDateInToday(storedItems[i].date){
                                value += storedItems[i].time
                            }
                        }
                        self.goalValue = MFGoal
                        self.value = value
                        isGoal = true
                    }else{
                        isGoal = false
                    }
                    
                } catch let err {
                    print(err)
                    isGoal = false
                }
                
            }else{
                isGoal = false
            }
            
        }else{
            let EXGoal = userDefaults.integer(forKey: "EX")
            if EXGoal != nil {
                let today = Date()
                let exKey = "EXCollection"
                var exCol = [Exercise2]()
                do {
                    let storedObjItem = userDefaults.object(forKey: exKey)
                    if storedObjItem != nil{
                    let storedItems = try JSONDecoder().decode([Exercise2].self, from: storedObjItem as! Data)
                        
                        var value : Int = 0
                        for i in 0...(storedItems.count - 1){
                            if Calendar.current.isDateInToday(storedItems[i].date){
                                value += Int(storedItems[i].burnded)
                            }
                        }
                        self.goalValue = EXGoal
                        self.value = value
                        isGoal = true
                    }else{
                        isGoal = false
                    }
                    
                } catch let err {
                    print(err)
                    isGoal = false
                }
                
            }else{
                isGoal = false
            }
            
        }
        
    }
    
    // MARK: - BODY
    public var body: some View {
        
        VStack{
            Text(titie.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .lineLimit(2)
                .padding(.horizontal)
                .foregroundColor(Color.black)
                .padding(.bottom)
            
            if titie == "Mindfulness"{
                Image(uiImage: UIImage(named: "mindfulness")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
    
                if isGoal{
                Text("Goals \(self.value)/\(self.goalValue) ")
                      .foregroundColor(standingColor)
                      .font(.footnote)
                      .fontWeight(.bold)
                }
               
                
                
            }else{
                Image(uiImage: UIImage(named: "other")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                if isGoal{
                Text("Goals \(self.value)/\(self.goalValue) ")
                      .foregroundColor(standingColor)
                      .font(.footnote)
                      .fontWeight(.bold)
                }
                
                
            }
            

            
        } // ef-VSTACK
        .frame(width: 155, height: 198, alignment: .center)
        .background(backgroundColor.cornerRadius(30).shadow(color: Color.gray.opacity(0.5), radius: 2, x: 0, y: 5))
       .background(
            RoundedRectangle(cornerRadius: 30).stroke(Color.gray,lineWidth: 0.5)
        )
        .onAppear(perform: {
            self.goalProgress()
          
        })
    }
}

public struct RingGraphView: View {
    // MARK: - PROPERTIES
    
   @State var progess : CGFloat = 0
    
    let value : CGFloat
    let color : Color
    let standingColor : Color = Color(red: 253 / 255, green: 113 / 255, blue: 60 / 255)
    
    public init(value: CGFloat, color: Color) {
        self.value = value
        self.color = color
    }
    // MARK: - BODY
    public  var body: some View {
    
        ZStack {
            Text("\(Int(value))%")
                .foregroundColor(color)
                .fontWeight(.bold)
                .font(.body)
                .onChange(of: value, perform: { value in
                    withAnimation(Animation.easeIn(duration: 0.7)){
                        progess = value
                    }
                })
            Circle()
                .trim(from: 0, to: 1 )
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundColor(Color.gray.opacity(0.09))
                
                //.foregroundColor(color.opacity(0.09))
            
            Circle()
                
                .trim(from: 0, to: progess / 100 )
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundColor(color)
                .onAppear(perform: {
                    withAnimation(Animation.easeIn(duration: 0.7)){
                        progess = value
                    }
                })
                
                
                
        }
        .frame(width: 90, height: 90, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        
    }
}
 struct MindfulnessModel2 : Identifiable , Codable{
   public let id : UUID
   public let date : Date
   public var time : Int
}
public struct Exercise2 : Identifiable , Codable {
    public let id : UUID
    public let date : Date
    public let type : String
    public let burnded : Double
    public let hr : Int
    public let distance : Double
    public let icon : String
}









