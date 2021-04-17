import SwiftUI



let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 7)
    formatter.dateFormat = "HH:mm"
    return formatter
}()

let taskDateFormat: DateFormatter = {
       let formatter = DateFormatter()
       formatter.dateStyle = .long
       return formatter
   }()

public struct ActivityView: View {
    // MARK: - PROPERTIES
    
    let wmm : Color = Color(red: 117 / 255, green: 31 / 255, blue: 252 / 255)
    let standingColor : Color = Color(red: 253 / 255, green: 113 / 255, blue: 60 / 255)
    @State private var isAnnimatingImage : Bool = false
    
    //let activity : Activity
    let titie : String
    let description : String
    let type : String
    let imageIcon : String
    
    let navigationTag : Int
    let ui : UIImage
    

    @State  var action: Int? = 0
    @State var isDate : Bool = false
    @State var goal : Int = 0
    @State var settingGoal : Bool = false
    
    
    public init(title: String ,description : String , type : String , imageIcon : String , navigationTag : Int , ui : UIImage){
        self.titie = title
        self.description = description
        self.type = type
        self.imageIcon = imageIcon
        
        self.navigationTag = navigationTag
        self.ui = ui
    }
    // MARK: - FUNCTION
    
    
    func loadData(){
        let defaults = UserDefaults.standard
        var value = 0
        if titie == "Mindfulness" {
            if defaults.integer(forKey: "MF")  != nil{
                value = defaults.integer(forKey: "MF")
            }
        } else {
            if defaults.integer(forKey: "EX")  != nil{
                
                value = defaults.integer(forKey: "EX")
            }
        }
        self.goal = value
        
    }
    // MARK: - BODY
   public var body: some View {
            ZStack{
                VStack {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(wmm)
                        .frame(width: 250, height: 250, alignment: .center)
                        .padding(.top , UIScreen.main.bounds.height * 0.05)
                        .scaleEffect(isAnnimatingImage ? 1.0 : 0.6)
                        .padding()
                        .onAppear(){
                            withAnimation(.easeOut(duration: 0.5)){
                                isAnnimatingImage = true
                            }
                        }
                        .onDisappear(perform: {
                            isAnnimatingImage = false
                        })
                    Text(titie.uppercased())
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(wmm)
                    ScrollView(.vertical, showsIndicators: false, content: {
                        Text(description)
                                .font(.body)
                                .padding(.horizontal , UIScreen.main.bounds.width * 0.1)
                                .foregroundColor(.gray)
                                .padding(.top,5)
                        
                        
                    })
                    
                    
                    ZStack {
                        
                        Button(action: {
                            settingGoal.toggle()
                        }, label: {
                            HStack{
                                Text("\(goal) Min/Day")
                                 .font(.system(size: 16))
                                 .fontWeight(.bold)
                                 .foregroundColor(standingColor)
                                
                                
                                Image(systemName: "rosette")
                                    .foregroundColor(standingColor)
                                    
                            }
                            .padding()
                        })
                        .background(RoundedRectangle(cornerRadius: 30).stroke(standingColor,lineWidth: 1))
                       
                    }.onAppear(perform: {
                        self.loadData()
                    })
                    .onChange(of: settingGoal, perform: { value in
                        loadData()
                    })

                    NavigationLink(destination:
                                    BioDataListView(headline: "BREATHING", isActivity: false)
                                   , tag: 1, selection: $action){
                        EmptyView()

                    }
                    NavigationLink(destination:
                                    BioDataListView(headline: "EXERCISE", isActivity: true)
                                   , tag: 2, selection: $action){
                        EmptyView()

                    }
                    //START BTN
                    Button(action: {
                    
                        self.action = navigationTag
                        
                    }, label: {
                        HStack{
                            Text("start".uppercased())
                                .fontWeight(.bold)
                                .padding()
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                    })
                    .background(wmm)
                    .clipShape(Capsule())
                    .padding(.vertical)
                }
               
                
            }//: ZSTACK
            .ignoresSafeArea(.all , edges: .top)
            .sheet(isPresented: $settingGoal, content: {
                goalSettingView(type: titie, show: $settingGoal)
            })
        }
    }
struct goalSettingView : View {
    // MARK: - PROPERTIES
    let type : String
    @State var text = ""
    @Binding var show : Bool
    let standingColor : Color = Color(red: 253 / 255, green: 113 / 255, blue: 60 / 255)
    // MARK: - BODY
    var body: some View{
        VStack{
            Image(systemName: "rosette")
                .resizable()
                .scaledToFit()
                .frame(width: 150 , height: 150 , alignment: .center)
                .foregroundColor(standingColor)
                .padding()
            Text("Setting Your Goal(Min/Day)")
                .font(.title3)
                .foregroundColor(standingColor)
            
            TextField("", text: self.$text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .textContentType(.oneTimeCode)
                .keyboardType(.numberPad)
                .onTapGesture {
                    hideKeyboard()
                }

                
            Button(action: {
                let defaults = UserDefaults.standard
                
                if type == "Mindfulness"{
                    defaults.setValue(Int(self.text), forKey: "MF")
                }else{
                    defaults.setValue(Int(self.text), forKey: "EX")
                }
                show = false
            }, label: {
                ZStack {
                    Text("save".uppercased())
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                }
                .background(standingColor)
                .clipShape(Capsule())
            })
            Spacer()
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct BioDataListView: View {
    // MARK: - PROPERTIES
    let headLine : String
    let isActivity : Bool

    @State var mindfulnessArr = [MindfulnessModel]()
    @ObservedObject var mindfulnessMV : MindfulnessStore



    @State private var isPresented = true
    @State private var hasdone : Int = 0

    // MARK: - CONSTRUCTOR
    init(headline: String, isActivity : Bool) {
        self.headLine = headline
        mindfulnessMV = MindfulnessStore(MindfulnessArr: [])
        self.isActivity = isActivity
     
    }

    // MARK: - FUNCTION
    private func fetchData(){

        var arrMindFul = [MindfulnessModel]()
      
    }
    private func loadData(){
        let userDefults = UserDefaults.standard
        let mfKey = "MFCollection"
        
        do {
            let storedObjItem = userDefults.object(forKey: mfKey )
            let storedItems = try JSONDecoder().decode([MindfulnessModel].self, from: storedObjItem as! Data)
            print("Retrieved items: \(storedItems)")
            self.mindfulnessArr = storedItems
        } catch let err {
            print(err)
        }

    }
    // MARK: - BODY
    var body: some View {
        ZStack {
            VStack {


                ScrollView(.vertical, showsIndicators: true){

                    HStack {
                        Image(systemName: "hourglass.bottomhalf.fill")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text("You might close this app to get a new snapshot data,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top,45)
                    
                
                    if !isActivity {
                        
                            ForEach(self.mindfulnessArr){ data in
                                BioDataCardIView(title: "breathing", imageIcon:  UIImage(named: "lungs") ?? UIImage(named: "other")! , value: "\(data.time)", date: data.date)
                                    .padding(.horizontal)
                            }
                            
                            
                    
                    }else{

                               
                    }

                }//: SCROLL VIEW





                .ignoresSafeArea(.all , edges: .bottom)
                Spacer()
            }//: VSTACK

            .ignoresSafeArea(.all , edges: .bottom)

        }//: ZSTACK
        .ignoresSafeArea(.all , edges : .top)
        .fullScreenCover(isPresented: $isPresented, content: {
            LoadingView(showModal: self.$isPresented, decription: "Please use your Apple Watch to complete an activity ", isActivity: isActivity)
        })
        .onAppear(perform: {
           loadData()
           


        })
        .onChange(of: isPresented, perform: { value in
          loadData()
          
        })
       



    }
}

struct addAutoActivityView : View {
    // MARK: - PROPERTIES
    let wmm : Color = Color(red: 117 / 255, green: 31 / 255, blue: 252 / 255)
    let title : String
    
    @State var textMFT : String = ""
    @State var textBurned : String = ""
    @State var textHRV : String = ""
    @State var textDST : String = ""
    
    //CHECK BOXES
    @State var burnChecked : Bool = false
    @State var heartRateChecked : Bool = false
    @State var distanceChecked : Bool = false
    
    @Binding var present : Bool
    
    // MARK: - function
    func addData (){
        present = false
    }
    
    func addDataMF(mindfulTime : MindfulnessModel){
        let userDefaults = UserDefaults.standard
        let mfKey = "MFCollection"
      
        var mfCollection = [MindfulnessModel]()
        
        do {
            let storedObjItem = userDefaults.object(forKey: mfKey )
            let storedItems = try JSONDecoder().decode([MindfulnessModel].self, from: storedObjItem as! Data)
            print("Retrieved items: \(storedItems)")
            mfCollection = storedItems
        } catch let err {
            print(err)
        }
       
        print("\(mfCollection.count)")
        mfCollection.append(mindfulTime)
        
      
       // userDefaults.set(mfCollection, forKey: mfKey)
        if let mfCollectionEncode = try? JSONEncoder().encode(mfCollection){
            userDefaults.set(mfCollectionEncode, forKey: mfKey)
        }
        
        print("save mf time")
        present = false
    }
    
    // MARK: - BODY
    var body: some View{
        VStack(alignment:.leading){
            HStack{
               Image(systemName: "plus.circle.fill")
                .foregroundColor(wmm)
               Text("Add \(title) data")
            }
            .padding(.vertical)
            
            if title == "Mindfulness"{
                
                //description
                Text("add a mindful time that you have done.")
                    .font(.callout)
                // time
                TextField("mindful time in minutes", text: self.$textMFT)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .textContentType(.oneTimeCode)
                    .keyboardType(.numberPad)
                    .padding(.vertical)
                
                //btn
                if textMFT != "" {
                HStack{
                    Spacer()
                    Button(action: {
                        let newMfTime : MindfulnessModel = MindfulnessModel(id: UUID(), date: Date(), time: Int(textMFT) ?? 0)
                        addDataMF(mindfulTime: newMfTime)
                    }) {
                            Text("add".uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                    }
                    .background(wmm)
                    .clipShape(Capsule())
                    Spacer()
                }
                }
                
                
            }else{
                //description
                Text("add an exercise data that you have done.")
                    .font(.callout)
                // checkbox item
                VStack (alignment:.leading) {
                   
                    //burned calories
                    VStack (alignment : .leading){
                    Button(action: {
                        burnChecked.toggle()
                    }) {
                        HStack{
                            Image(systemName:  burnChecked ? "checkmark.square.fill" : "checkmark.square")
                                .font(.callout)
                                .foregroundColor(
                                    burnChecked ? wmm : Color.secondary)
                            Text("burned calorie")
                                .font(.callout)
                                .fontWeight(.bold)
                                .foregroundColor(
                                    burnChecked ? wmm : Color.secondary)
                            
                        }
                       
                    }
                        
                        if burnChecked {
                    TextField("kcal", text: self.$textBurned)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .textContentType(.oneTimeCode)
                            .keyboardType(.numberPad)
                        }
                        
                    }
                    
                    //heart rate
                    VStack (alignment : .leading){
                    Button(action: {
                        heartRateChecked.toggle()
                    }) {
                        HStack{
                            Image(systemName:  heartRateChecked ? "checkmark.square.fill" : "checkmark.square")
                                .font(.callout)
                                .foregroundColor(
                                    heartRateChecked ? wmm : Color.secondary)
                            Text("average hard rate")
                                .font(.callout)
                                .fontWeight(.bold)
                                .foregroundColor(
                                    heartRateChecked ? wmm : Color.secondary)
                            
                        }
                       
                    }
                        
                        if heartRateChecked {
                    TextField("BMP", text: self.$textHRV)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .textContentType(.oneTimeCode)
                            .keyboardType(.numberPad)
                        }
                        
                    }
                    
                    //distance
                    VStack (alignment : .leading){
                    Button(action: {
                        distanceChecked.toggle()
                    }) {
                        HStack{
                            Image(systemName:  distanceChecked ? "checkmark.square.fill" : "checkmark.square")
                                .font(.callout)
                                .foregroundColor(
                                    distanceChecked ? wmm : Color.secondary)
                            Text("distance")
                                .font(.callout)
                                .fontWeight(.bold)
                                .foregroundColor(
                                    distanceChecked ? wmm : Color.secondary)
                            
                        }
                       
                    }
                        if distanceChecked {
                    TextField("km", text: self.$textDST)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .textContentType(.oneTimeCode)
                            .keyboardType(.numberPad)
                        }
                        
                    }
                    
                }
                .padding(.vertical)
                
                //btn
                if burnChecked || heartRateChecked || distanceChecked {
                HStack{
                    Spacer()
                    Button(action: {
                        addData()
                    }) {
                            Text("add".uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                    }
                    .background(wmm)
                    .clipShape(Capsule())
                    Spacer()
                }
                }
               
                
                
             
            }
           
        }.frame( height: UIScreen.main.bounds.height)
    }
}

public struct MindfulnessModel : Identifiable , Codable{
   public let id : UUID
   public let date : Date
   public var time : Int
}

class MindfulnessStore : ObservableObject {
    
    @Published var mindfulnessArr :[MindfulnessModel] = [MindfulnessModel]()
    
    init(MindfulnessArr : [MindfulnessModel]) {
        self.mindfulnessArr = MindfulnessArr
    }
    var totoTime : Int{
        var toto : Int = 0
        for mf in mindfulnessArr {
            toto += mf.time
        }
        return toto
    }
    func setMindfulness(newData : [MindfulnessModel]){
        mindfulnessArr.removeAll()
        mindfulnessArr = newData
    }
    
  
    
}



struct BioDataCardIView: View {
    // MARK: - PROPERTIES
    let wmm : Color = Color(red: 117 / 255, green: 31 / 255, blue: 252 / 255)
    let title : String
    let imageIcon : UIImage
    var value : String
    var date : Date
    // MARK: - BODY
    var body: some View {
       
        ZStack {
            VStack {
                //Date and Time
                HStack(alignment: .bottom){
                    Spacer()
                    Image(systemName: "calendar.circle.fill")
                        .font(.footnote)
                    .foregroundColor(.gray)
                    Text("\(date , formatter: taskDateFormat)")
                            .font(.footnote)
                        .foregroundColor(.gray)
                    Image(systemName: "clock.fill")
                        .font(.footnote)
                    .foregroundColor(.gray)
                    Text("\(date,formatter: dateFormatter)")
                        .font(.footnote)
                    .foregroundColor(.gray)
                }
              
                
                HStack(alignment:.top){
                    ZStack {
                       Image(uiImage: imageIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .padding()
                            //.foregroundColor(.accentColor)
                    
                           
                    }
                    .background(wmm.opacity(0.5))
                    .clipShape(Circle())
                    
                    VStack (alignment:.leading){
                        Text(title.uppercased())
                            .font(.system(size: 15))
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(wmm)
                        Text("\(value) ")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(wmm)
                        
                    }.padding(.top)
                    Spacer()
                  
                }
                .padding(.top,-8)
            
            }// EO - VSTACK
            .padding()
            .frame(width: UIScreen.main.bounds.width * 0.9)
        
            
         
        }
        .background(Color.gray.opacity(0.2).cornerRadius(25))
    }//View
}

struct HeaderDetailIView: View {
    // MARK: - PROPERTIES
    let date : Date
    let startTime : Date
    let endTime : Date
    // MARK: - BODY
    var body: some View {
        VStack {
            Text(date , formatter: taskDateFormat)
                .font(.title)
            HStack {
                HStack{
               
                    HStack {
                        Image(systemName: "stopwatch.fill")
                            .font(.caption)
                        Text(startTime,formatter: dateFormatter)
                            .font(.caption)
                        Text("-")
                            .font(.caption)
                        Image(systemName: "stopwatch.fill")
                            .font(.caption)
                        Text(endTime,formatter: dateFormatter)
                            .font(.caption)
                    }
                }
                
            }
            
            
        }
    }
}
struct BioDataCardTitleView: View {
    // MARK: - PROPERTIES
    @State private var isAnimated : Bool  = false
    
    let title : String
    let imageIcon : String
    let color : Color
    let value : String
    
    // MARK: - BODY
    var body: some View {
        
        HStack {
            VStack (alignment:.trailing){
                
                    Text(title.uppercased())
                        .foregroundColor(color)
                        .font(.title2)
                        .fontWeight(.medium)
                
                Text(value)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }//: VTACK
            Image(systemName: imageIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 60)
                .padding()
                .foregroundColor(color)
                .scaleEffect(isAnimated ? 1.0 : 0.95 )
        }//: HSTACK
        .onAppear(perform: {
            withAnimation(Animation.easeIn(duration: 0.3).repeatForever(autoreverses: false)){
                isAnimated.toggle()
            }
        })
        
        
    }
}

struct MoreBioDataView: View {
   
    // MARK: - PROPERTIES
    let wmm : Color = Color(red: 117 / 255, green: 31 / 255, blue: 252 / 255)
//    let sample : HKWorkout?
    let hrv : Double
    var value : [Double] = [122.0,122.0,119,119,118,121,124,123,116,115,124,124,126,125,120,121,120,122,120,120,122,122,117,120,120,119,118,120,120,121]
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            VStack {
                
                
                HeaderDetailIView(date: Date(), startTime: Date(), endTime: Date())
                
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack(alignment: .trailing){
                        
                        
//                        if let bruned = sample?.totalEnergyBurned?.doubleValue(for: .kilocalorie()){
//                        let formattedCalories = String(format: "%.2f kcal",bruned)
//                            BioDataCardTitleView(title: "ACTIVE KILOCALORIES", imageIcon: "flame", color: wmm, value: "\(formattedCalories)")
//                                .padding(.top)
//                        }
//
//                        if let distance = sample?.totalDistance?.doubleValue(for: .meter()){
//                            let distanceKm = distance / 1000
//                            let formattedMater = String(format: "%.2f km ",distanceKm)
//                            BioDataCardTitleView(title: "Total distance", imageIcon: "location.north.line", color: wmm, value: "\(formattedMater) ")
//                        }
//
//                        if let floors = sample?.totalFlightsClimbed{
//                            BioDataCardTitleView(title: "Flight Climbed", imageIcon: "arrow.up.right.circle", color: wmm, value: "\(floors) floors")
//                        }
//
//                        if let strokeCount = sample?.totalSwimmingStrokeCount{
//                            BioDataCardTitleView(title: "Stroke Count", imageIcon: "arrow.uturn.left.circle", color: wmm, value: "\(strokeCount)")
//
//                        }
        
                        BioDataCardTitleView(title: "Avg Hart Rate", imageIcon: "heart", color: Color("wmm"), value: "\(Int(hrv)) BPM")
                            .padding(.top)
                       
                       
                    }
                    .padding(.top)
                    .padding(.horizontal)
                })
                
                
                Spacer()
                
            }
        }
        .ignoresSafeArea(.all,edges: .all)
    }
}

struct LoadingView: View {
    // MARK: - PROPERTIES
    
    @State var num : Int = 0
    let wmm : Color = Color(red: 117 / 255, green: 31 / 255, blue: 252 / 255)
    @Binding var showModal: Bool
    
   @State var isAdd = false
    var decription : String
    var isActivity : Bool
    
    // MARK: - FUNCTION
   
    // MARK: - BODY
    var body: some View {
        
        if !isAdd{
        VStack (alignment: .center){
            Spacer()
           WatchView()
            Spacer()
          
                Text(decription)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .padding(.horizontal,30)
                   
            ZStack {
                Button(action: {
                    showModal = false
                }, label: {
                    Text("OK")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                })
                .padding()
            } //ZSTACK OF BTN
            .background(wmm)
            .clipShape(Capsule())
           
            
            ZStack {
                Button(action: {
                    isAdd = true
                }, label: {
                    Text("add new data")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                })
                .padding()
            } //ZSTACK OF BTN
            .background(wmm)
            .clipShape(Capsule())
           

           
            Spacer()
            
            
        }
        .navigationBarBackButtonHidden(true)
        }else{
            VStack (alignment: .center){
                addAutoActivityView(title:  isActivity ? "Exercise" : "Mindfulness" , present: $showModal )
                    .padding(.horizontal)
            }
            .navigationBarBackButtonHidden(true)
            
        }
       
        
    }
}
struct WatchView: View {
    // MARK: - PROPERTIES
    @State private var annimation : Double = 0.0
    let wmm : Color = Color(red: 117 / 255, green: 31 / 255, blue: 252 / 255)
    // MARK: - BODY
    var body: some View {
        ZStack {
            Circle()
                .fill(wmm)
                .frame(width: 120, height: 120, alignment: .center)
            
            Circle()
                .stroke(wmm, lineWidth: 2)
                .frame(width: 120, height: 120, alignment: .center)
                .scaleEffect(1 + CGFloat(annimation))
                .opacity(1 - annimation)
            
            Image(systemName: "applewatch.watchface")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 90, height: 90, alignment: .center)
                
        } //: ZSTACK
        .onAppear(){
            withAnimation(Animation.easeOut(duration: 1).repeatForever(autoreverses: false)){
                annimation = 1
            }
    }
}
}



