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
                    .padding(.horizontal,-8)
                    
                    
                    ZStack {
                        
                        Button(action: {
                           
                            settingGoal.toggle()
                        }, label: {
                            HStack{
                                Text("\(goal) Mins/Day")
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
    let msg_EX : String = "Setting Your Burning Goal(kcal/Day)"
    let msg_MF : String = "Setting Your Time Goal(Mins/Day)"
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
            Text( type == "Mindfulness" ? msg_MF : msg_EX )
                .font(.title3)
                .foregroundColor(standingColor)
            
            TextField("", text: self.$text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .textContentType(.oneTimeCode)
                .keyboardType(.numberPad)


                
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



struct BioDataListView: View {
    // MARK: - PROPERTIES
    let headLine : String
    let isActivity : Bool

    @State var mindfulnessArr = [MindfulnessModel]()
    @State var exerciseArr = [Exercise]()
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
        if !isActivity{
        let userDefults = UserDefaults.standard
        let mfKey = "MFCollection"
        
        do {
            let storedObjItem = userDefults.object(forKey: mfKey)
            if storedObjItem != nil{
            let storedItems = try JSONDecoder().decode([MindfulnessModel].self, from: storedObjItem as! Data)
            print("Retrieved items: \(storedItems)")
            self.mindfulnessArr = storedItems
            }
            
        } catch let err {
            print(err)
        }
        }else{
            let userDefults = UserDefaults.standard
            let exKey = "EXCollection"
            
            do {
                let storedObjItem = userDefults.object(forKey: exKey)
                if storedObjItem != nil{
                let storedItems = try JSONDecoder().decode([Exercise].self, from: storedObjItem as! Data)
                print("Retrieved items: \(storedItems)")
                self.exerciseArr = storedItems
                }
                
            } catch let err {
                print(err)
            }
            
        }
    }
    // MARK: - BODY
    var body: some View {
        ZStack {
            VStack {


                ScrollView(.vertical, showsIndicators: true){
                
                    if !isActivity {
                        
                            ForEach(self.mindfulnessArr){ data in
                                BioDataCardIView(title: "breathing", imageIcon:  UIImage(named: "lungs") ?? UIImage(named: "other")! , value: "\(data.time) mins", date: data.date)
                                    .padding(.horizontal)
                            }
                            
                            
                    
                    }else{
                        
                        ForEach(self.exerciseArr.reversed()){ data in
                            
                            
                            NavigationLink(
                                destination: MoreBioDataView(execriseInfo: data),
                                label: {
                                    BioDataCardIView(title: data.type , imageIcon:  UIImage(named:data.icon) ?? UIImage(named: "other")! , value: "\(data.burnded) kcal", date: data.date)
                                        .padding(.horizontal)
                                })
                            
                           
                            
                            
                        }

                               
                    }

                }//: SCROLL VIEW
                //.ignoresSafeArea(.all , edges: .bottom)
                .padding(.top,50)
                
                
                Spacer()
            }//: VSTACK

            .ignoresSafeArea(.all , edges: .bottom)

        }//: ZSTACK
        .ignoresSafeArea(.all , edges : .top)
        .fullScreenCover(isPresented: $isPresented, content: {
            LoadingView(showModal: self.$isPresented, decription: "Please insert an activity", isActivity: isActivity)
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
    @State var selection: ExecriseType = .americanFootball
    @State var selectionClick : Bool = false
    
    //CHECK BOXES
    @State var burnChecked : Bool = false
    @State var heartRateChecked : Bool = false
    @State var distanceChecked : Bool = false
    
    @Binding var present : Bool
    
    var animation: Animation {
        Animation.easeOut
    }
    // MARK: - function
    func addData (){
        present = false
    }
    
    func addDataEx(ex: Exercise){
        let userDefaults = UserDefaults.standard
        let exKey = "EXCollection"
        var exCollection = [Exercise]()
        
        do {
            let storedExercise = userDefaults.object(forKey: exKey)
            if storedExercise != nil {
                let exerciseItems = try JSONDecoder().decode([Exercise].self, from: storedExercise as! Data)
                print("Retrieved items: \(exerciseItems)")
                exCollection = exerciseItems
            }
        } catch let err{
            print(err)
        }
        
        print("\(exCollection.count)")
        exCollection.append(ex)
        
        if let exCollectionEncode = try? JSONEncoder().encode(exCollection){
            userDefaults.set(exCollectionEncode, forKey: exKey)
        }
        
        present = false
        
    }
    func addDataMF(mindfulTime : MindfulnessModel){
        let userDefaults = UserDefaults.standard
        let mfKey = "MFCollection"
      
        var mfCollection = [MindfulnessModel]()
        
        do {
            let storedObjItem = userDefaults.object(forKey: mfKey)
            if storedObjItem != nil{
            let storedItems = try JSONDecoder().decode([MindfulnessModel].self, from: storedObjItem as! Data)
            print("Retrieved items: \(storedItems)")
            mfCollection = storedItems
            }
            
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
                Text("add a mindfultimes that you have done")
                    .font(.callout)
                // time
                TextField("mindfultimes in minutes", text: self.$textMFT)
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
                Text("add exercise's data that you have done")
                    .font(.callout)
                // checkbox item
                VStack (alignment:.leading) {
                    
                  
                    Button(action: {
                        
                        selectionClick.toggle()
                        
                    }, label: {
                        HStack {
                            Text("Activity type : \(selection.rawValue)")
                                .foregroundColor(wmm)
                            Image(systemName: "greaterthan.square.fill")
                                .foregroundColor(wmm)
                                .rotationEffect(Angle.degrees( selectionClick ? 90 : 0))
                                
                        }
                    })
                    if selectionClick{
                               Picker("This Title Is Localized", selection: $selection) {
                                ForEach(ExecriseType.allCases, id: \.self) { value in
                                       Text(value.localizedName)
                                           .tag(value)
                                   }
                               }
                    }
                    
                           
                    
                    
                   
                    
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
                            Text("Burned calories")
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
                            Text("Average Heart Rate")
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
                            Text("Distance")
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
                       let newEx = Exercise(id: UUID(), date: Date(),
                                            type: selection.rawValue , burnded: Double(textBurned) ?? 0 ,
                                            hr: Int(textHRV) ?? 0, distance: Double(textDST) ?? 0, icon: selection.rawValue )
                        
                        self.addDataEx(ex: newEx)
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

public struct Exercise : Identifiable , Codable {
    public let id : UUID
    public let date : Date
    public let type : String
    public let burnded : Double
    public let hr : Int
    public let distance : Double
    public let icon : String
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
           // .frame(width: UIScreen.main.bounds.width * 0.8 )
        
            
         
        }
        .background(Color.gray.opacity(0.2).cornerRadius(25))
    }//View
}

struct HeaderDetailIView: View {
    // MARK: - PROPERTIES
    let date : Date
    let startTime : Date
    // MARK: - BODY
    var body: some View {
        VStack {
            Text(date , formatter: taskDateFormat)
                .font(.title)
          
                    HStack {
                        Image(systemName: "stopwatch.fill")
                            .font(.caption)
                        Text(startTime,formatter: dateFormatter)
                            .font(.caption)
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
                        .font(.title3)
                        .fontWeight(.medium)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }//: VTACK
            Image(systemName: imageIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
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

    let execriseInfo : Exercise
    // MARK: - BODY
    var body: some View {
        ZStack {
            VStack {
                
                HeaderDetailIView(date: execriseInfo.date, startTime: execriseInfo.date)
                    .padding(.top,50)
                
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack(alignment: .trailing){
                        
                       let bruned = execriseInfo.burnded
                        if bruned != 0 {
                         
                            BioDataCardTitleView(title: "ACTIVE KILOCALORIES", imageIcon: "flame", color: wmm, value: "\(bruned) kcal")
                                .padding(.top)
                        }
                        let hrv = execriseInfo.hr
                        if hrv != 0 {
                            BioDataCardTitleView(title: "Avg. Hart Rate", imageIcon: "heart", color: wmm , value: "\(hrv) BPM")
                                .padding(.top)
                        }
                        let distance =  execriseInfo.distance
                        if distance != 0 {
                            BioDataCardTitleView(title: "Total distance", imageIcon: "location.north.line", color: wmm, value:                              "\(distance) km")
                        }
                        
                                
                       
                    }
                    .padding(.top)
                    .padding(.horizontal)
                })
                
                
                Spacer()
                
            }
            .ignoresSafeArea(.all,edges: .top)
        }
       
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
                    isAdd = true
                }, label: {
                    Text("Add New Activity")
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
             showModal = false
         }, label: {
             Text("Cancle")
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
            
            Image(systemName: "plus")
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

enum ExecriseType : String , Equatable, CaseIterable{
     
        var id : String { UUID().uuidString }
        var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
    
        case americanFootball = "americanFootball"
        case archery = "archery"
        case australianFootball = "australianFootball"
            
        case badminton = "badminton"
        case barre = "barre"
        case baseball = "baseball"
        case basketball = "basketball"
        case bowling = "bowling"
        case boxing = "boxing"
            
        case climbing = "climbing"
        case cooldown = "cooldown"
        case coreTraining  = "coreTraining"
        case cricket = "cricket"
        case crossCountrySkiing = "crossCountrySkiing"
        case crossTraining = "crossTraining"
        case curling = "curling"
        case cycling = "cycling"
        case cardioDance = "cardio Dance"
            
     
        case discSports = "discSports"
        case downhillSkiing = "downhillSkiing"
            
        case elliptical = "elliptical"
        case equestrianSports = "equestrianSports"
            
        case fencing = "fencing"
        case fishing = "fishing"
        case functionalStrengthTraining = "functionalStrengthTraining"
            

        case golf = "golf"
        case gymnastics                    = "gymnastics"
        
        case handball                      = "handball"
        case hiking                        = "hiking"
        case hockey                        = "hockey"
        case hunting                       = "hunting"
        case handCycling                   = "handCycling"
        case highIntensityIntervalTraining = "hightIntensityIntervalTraining"
            
        case jumpRope                     = "jumpRope"
            
        case kickboxing                   = "kickboxing"
        
        case lacrosse                     = "lacrosse"
        
        case martialArts                  = "martialArts"
        case mindAndBody                  = "mindandBody"
        case mixedCardio                  = "mixedCardio"
        
            
        case other                        = "other"
        
        case paddleSports                 = "paddleSports"
        case play                         = "play"
        case preparationAndRecovery       = "preparationAndRecovery"
        case pilates                      = "pilates"
        case pickleball                   = "pickleball"
    
        case racquetball                  = "racquetball"
        case rowing                       = "rowing"
        case rugby                        = "rugby"
        case running                      = "running"
        
        case sailing                      = "sailing"
        case skatingSports                = "skatingSports"
        case snowSports                   = "snowSports"
        case soccer                       = "soccer"
        case softball                     = "softball"
        case squash                       = "squash"
        case stairClimbing                = "stairClimbing"
        case surfingSports                = "surfingSports"
        case swimming                     = "swimming"
        case stairs                       = "stairs"
        case snowboarding  = "snowBoarding"
        case stepTraining      = "stepTraining"
        case socialDance      = "socialDance"
        
        case tableTennis = "tableTennis"
        case tennis                    = "tennis"
        case trackAndField               = "trackAndField"
        case traditionalStrengthTraining  = "traditionalStrengthTraining"
        case taiChi                       = "taiChi"
        
        case volleyball                   = "volleyball"

        case walking                    = "walking"
        case waterFitness               = "waterFitness"
        case waterPolo                    = "waterPolo"
        case waterSports                 =  "waterSports"
        case wrestling                    = "wrestling"
        case wheelchairRunPace          = "wheelchairRunPace"
        case wheelchairWalkPace  = "wheelchairWalkPace"
        case yoga  = "yoga"
    
    
}



