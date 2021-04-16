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
            }else{
                Image(uiImage: UIImage(named: "other")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
            }
        } // ef-VSTACK
        .frame(width: 155, height: 198, alignment: .center)
        .background(backgroundColor.cornerRadius(30).shadow(color: Color.gray.opacity(0.5), radius: 2, x: 0, y: 5))
       .background(
            RoundedRectangle(cornerRadius: 30).stroke(Color.gray,lineWidth: 0.5)
        )
    }
}

public struct RingGraphView: View {
    // MARK: - PROPERTIES
    
   @State var progess : CGFloat = 0
    
    let value : CGFloat
    let color : Color
    
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










