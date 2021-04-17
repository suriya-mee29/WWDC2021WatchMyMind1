import SwiftUI
import HealthKit

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
    @ObservedObject var autoActivityStore : AutoActivityStore



    @State private var isPresented = true
    @State private var hasdone : Int = 0


    var healthStore = HealthStore2()
    // MARK: - CONSTRUCTOR
    init(headline: String, isActivity : Bool) {
        self.headLine = headline
        mindfulnessMV = MindfulnessStore(MindfulnessArr: [])
        self.isActivity = isActivity
        autoActivityStore = AutoActivityStore(autoActivityCollection: [])
    }

    // MARK: - FUNCTION
    private func fetchData(){

        var arrMindFul = [MindfulnessModel]()
        healthStore.mindfultime(startDate: Date() , numberOfday: -7) { (samples) in

            for sample in samples {

                guard  let uuid = sample?.uuid else {return}
                guard let time = sample?.endDate.timeIntervalSince(sample!.startDate) else{return}
                guard let date = sample?.startDate else {return}

                let mif  = MindfulnessModel(id: uuid , date: date, time: Int32(time / 60))
                arrMindFul.append( mif )
            }
            mindfulnessMV.setMindfulness(newData: arrMindFul)
        }
        healthStore.calculateMindfulTime(startDate: Date(), numberOfday: -7) { (time) in
            self.hasdone = Int(time / 60)
        }
    }
    private func loadData(){

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
                        Text("You might close this app to get a new snapshot data")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top,45)
                    
                
                    if !isActivity {
                        
                            
                            ForEach(self.mindfulnessMV.mindfulnessArr){ data in
                                BioDataCardIView(title: "breathing", imageIcon:  UIImage(named: "lungs") ?? UIImage(named: "other")! , value: "\(data.time)", date: data.date)
                            }
                            
                            

                    
                    }else{

                                ForEach(self.autoActivityStore.autoActivityCollection){ data in

                                    NavigationLink(
                                        destination: MoreBioDataView(sample: data.workOut, hrv: data.avgHeartRate),
                                        label: {
                                            BioDataCardIView(title: data.workOut.workoutActivityType.name,
                                                             imageIcon: UIImage(named: data.workOut.workoutActivityType.associatedIcon ?? "other")!, value: "\(Int(data.avgHeartRate)) BMP", date:data.workOut.startDate)
                                        })



                                }
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
            fetchData()
            self.autoActivityStore.loadData(startDate: Date(), numberOfObserved: -30)


        })
        .onChange(of: isPresented, perform: { value in
           fetchData()
           self.autoActivityStore.loadData(startDate: Date(), numberOfObserved: -30)
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
public class HealthStore2 {
    var healthStore : HKHealthStore?
    var query : HKStatisticsCollectionQuery?
    var querySampleQuery : HKSampleQuery?
    var queryStaticQuery : HKStatisticsQuery?
    var summaryQuery : HKActivitySummaryQuery?
    var mindfulObserverQuery : HKObserverQuery?
    
  
    
    let mindfulType = HKSampleType.categoryType(forIdentifier: .mindfulSession)!
    let standType = HKQuantityType.quantityType(forIdentifier: .appleStandTime)!
    let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    let sleepType =  HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    let activityType = HKObjectType.activitySummaryType()
    let workoutType = HKSampleType.workoutType()
    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    
    
    public init(){
        // to check data is avaliable or not?
        if HKHealthStore.isHealthDataAvailable(){
            //Create instance of HKHealthStore
            healthStore = HKHealthStore()
            
        }
        
    }
    // MARK: - Authorization
    public func requestAuthorization(compleion: @escaping(Bool)-> Void){
        guard let healthStore = self.healthStore else { return compleion(false)}
        healthStore.requestAuthorization(toShare: [], read: [mindfulType,standType,stepType,sleepType,activityType,workoutType,heartRateType]) { (success, error) in
            compleion(success)
        }
    }
    // MARK: - Heart Rate
    public func getHeartRateBetween2(startDate: Date , endDate : Date , completion: @escaping ([HKSample]?) -> Void){
    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
    let sortDescriptors = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
    
        querySampleQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate , limit: 30, sortDescriptors: [sortDescriptors], resultsHandler: { (query, samples, error) in
            guard let samples = samples else {
                completion([])
                print("Error : \(error?.localizedDescription ?? "error")");
                return }
            
            completion(samples)
        }) // end of quary
        
        
        
        
        if let healthStore = self.healthStore , let querySampleQuery = self.querySampleQuery {
            healthStore.execute(querySampleQuery)
        }// end of ex.
    }
    
   public func getAVGHeartRate(startDate : Date , endDate : Date , completion: @escaping (HKStatistics?) -> Void){
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        self.queryStaticQuery = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage, completionHandler: { (query, statistic, error) in
            
            guard statistic != nil  else {
                return
            }
            completion(statistic)
    
         
        })
        if let healthStore = self.healthStore , let queryStaticQuery = self.queryStaticQuery {
            healthStore.execute(queryStaticQuery)
        }
        
    }
    
   public func getHeartRateBetween(sample : HKSample? , isActivity : Bool , completion: @escaping ([Double]?) -> Void){
        let predicate = HKQuery.predicateForSamples(withStart: sample!.startDate as Date, end: sample!.endDate as Date?, options: [])
    let sortDescriptors = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let heartRateUnit:HKUnit = HKUnit(from: "count/min")
        querySampleQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate , limit: 30, sortDescriptors: [sortDescriptors], resultsHandler: { (query, samples, error) in

            guard let samples = samples else {
              //  compleion([])
                print("Error : \(error?.localizedDescription ?? "error")");
                return }
            
            if isActivity {
                guard let mySample = sample as? HKWorkout else {
                    print("error")
                    return
                }
           
              
                //mySample.
                
                
                for (_, sample) in samples.enumerated() {
                    
                         guard let currData:HKQuantitySample = sample as? HKQuantitySample else { return }
                    
                    
                    
                         print("[\(sample)]")
                         print("Heart Rate: \(currData.quantity.doubleValue(for: heartRateUnit))")
                         print("quantityType: \(currData.quantityType)")
                         print("Start Date: \(currData.startDate)")
                         print("End Date: \(currData.endDate)")
                    print("Metadata: \(String(describing: currData.metadata))")
                         print("UUID: \(currData.uuid)")
                         print("Source: \(currData.sourceRevision)")
                    print("Device: \(String(describing: currData.device))")
                         print("---------------------------------\n")
                
                    
            }
                
                
       
            }
        })
        if let healthStore = self.healthStore , let querySampleQuery = self.querySampleQuery {
            healthStore.execute(querySampleQuery)
        }
        
    }
    
    
    
    // MARK: - Workout
  public  func calculateWorkout2(startDate: Date , numberOfObserved: Int ,completion: @escaping ([HKWorkout]?) -> Void){
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let endDate = Calendar.current.date(byAdding: .day , value: numberOfObserved , to: startDate)
        let predicate = HKQuery.predicateForSamples(withStart: endDate, end: startDate, options: .strictStartDate)

        querySampleQuery = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor ], resultsHandler: { (query, samples, error) in
            
            guard let mySamples = samples as? [HKWorkout] else{
                print("Error: \(String(describing: error?.localizedDescription))")
                completion([])
                return }
            completion(mySamples)
          
        })
        if let healthStore = self.healthStore , let querySampleQuery = self.querySampleQuery {
           healthStore.execute(querySampleQuery)
          }
        
    }
   public func calculateWorkout(completion: @escaping ([HKWorkout]?, Error?) -> Void){
        //1. Get all workouts with the "Other" activity type.
         let workoutPredicate = HKQuery.predicateForWorkouts(with: .other)
         
         //2. Get all workouts that only came from this app.
         let sourcePredicate = HKQuery.predicateForObjects(from: .default())
         
         //3. Combine the predicates into a single predicate.
         let compound = NSCompoundPredicate(andPredicateWithSubpredicates:
           [workoutPredicate, sourcePredicate])
         
         let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        querySampleQuery = HKSampleQuery(sampleType: workoutType, predicate: compound, limit: 0, sortDescriptors: [sortDescriptor], resultsHandler: { (query, samples, error) in
            DispatchQueue.main.async {
                  guard
                    let samples = samples as? [HKWorkout],
                    error == nil
                    else {
                      completion(nil, error)
                      return
                  }
                  
                  completion(samples, nil)
                }
        })
        
      if let healthStore = self.healthStore , let querySampleQuery = self.querySampleQuery {
         healthStore.execute(querySampleQuery)
        }
        
    }
    // MARK: - Calculate Sleeping
    
    public func getDailySleeping(compleion: @escaping([HKSample])-> Void){
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
     
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        querySampleQuery = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 30, sortDescriptors: [sortDescriptor], resultsHandler: { (query, results, error) in
            
            
            if error != nil {
                print(" HealthKit returned error while trying to query today's mindful sessions. The error was: \(String(describing: error?.localizedDescription))")
            }
            
            if let results = results {
            compleion(results)
            } else {
                compleion([])
            }
            
            
            
            
        })
        
        if let healthStore = self.healthStore , let querySampleQuery = self.querySampleQuery {
            
            healthStore.execute(querySampleQuery)
        }
    }
    
    // MARK: - Calculate Moving
  public  func getDailyMoving (completion : @escaping(HKActivitySummary?)->Void){
        let calendar = Calendar.autoupdatingCurrent
        var dateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: Date())
        
        // This line is required to make the whole thing work
          dateComponents.calendar = calendar
        let predicate = HKQuery.predicateForActivitySummary(with: dateComponents)
        summaryQuery = HKActivitySummaryQuery(predicate: predicate) { (query, summaries, error) in
            guard let summaries = summaries else {

                return
            }
            if summaries.count != 0{
            completion(summaries[0])
            }
            // Handle the activity rings data here
            
        }
        
        if let healthStore = self.healthStore , let query = self.summaryQuery {
          
             healthStore.execute(query)
                
           
        }
        
        
    }
    
    // MARK: - Calculate hr. of standing
  public  func calculateStanding(completion : @escaping(HKStatisticsCollection?)->Void){
        let calendar = Calendar.autoupdatingCurrent
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour], from: Date())
        let endDate = Date()
        let startDate = calendar.date(from: dateComponents)!
        var interval = DateComponents()
        interval.hour = 1
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        query = HKStatisticsCollectionQuery(quantityType: self.standType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: startDate, intervalComponents: interval)
        
        query!.initialResultsHandler = { query, statisticsCollection , error in
            completion(statisticsCollection)
        }
        if let healthStore = self.healthStore, let query = self.query {
            healthStore.execute(query)
        }
    }
    
  public  func getDailyStanding(completion: @escaping (TimeInterval) -> Void){
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        querySampleQuery = HKSampleQuery(sampleType: stepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (_, results, error) in
            
            if let results = results {
                var totalTime = TimeInterval()
                for result in results{
                    totalTime += result.endDate.timeIntervalSince(result.startDate)
                }
                completion(totalTime)
            }else{
                completion(0)
                
            }
            
        }
        
        if let healthStore = self.healthStore , let querySampleQuery = self.querySampleQuery {
          
            healthStore.execute(querySampleQuery)
        
        }
        
    }
    
    
    // MARK: - Calculate steps count
   public func calculateSteps(completion : @escaping(HKStatisticsCollection?)->Void){
       
        
        let startDate  = Calendar.current.date(byAdding: .day,value: -7, to: Date())
        let anchorDate = Date.mondayAt12AM2()
        let daily = DateComponents(day:1)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date() , options: .strictStartDate)
        //cumulativeSum  (Watch+Iphone)
        query =  HKStatisticsCollectionQuery(quantityType: self.stepType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: daily)
        
        query!.initialResultsHandler = { query, statisticsCollection , error in
            completion(statisticsCollection)
          
        }
        
        if let healthStore = self.healthStore, let query = self.query {
            healthStore.execute(query)
        }
    }
    
    
    // MARK: - MINDFULNESS V1
    // DailyMindfulnessTime
   public func mindfultime(startDate : Date , numberOfday:Int ,completion: @escaping([HKSample?])-> Void){
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let endDate = Calendar.current.date(byAdding: .day , value: numberOfday, to: startDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: endDate, end: startDate, options: .strictStartDate)

        querySampleQuery = HKSampleQuery(sampleType: mindfulType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (_, results, error) in
           
           if error != nil {
               print(" HealthKit returned error while trying to query today's mindful sessions. The error was: \(String(describing: error?.localizedDescription))")
           }
           
           
           if let results = results {
              
               completion(results)
               
           } else {
               completion([])
           }
       }


   if let healthStore = self.healthStore, let querySampleQuery  = self.querySampleQuery {
   healthStore.execute(querySampleQuery)
       }
        
     
    }
   public func calculateMindfulTime(startDate : Date , numberOfday:Int ,completion: @escaping (TimeInterval) -> Void) {
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let endDate = Calendar.current.date(byAdding: .day , value: numberOfday, to: startDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: endDate, end: startDate, options: .strictStartDate)

                 querySampleQuery = HKSampleQuery(sampleType: mindfulType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (_, results, error) in
                    
                    if error != nil {
                        print(" HealthKit returned error while trying to query today's mindful sessions. The error was: \(String(describing: error?.localizedDescription))")
                    }
                    
                    
                    
                    if let results = results {
                        var totalTime = TimeInterval()
                        for result in results {
                            totalTime += result.endDate.timeIntervalSince(result.startDate)
                        }
                        completion(totalTime)
                    } else {
                        completion(0)
                    }
                }
        
        
            if let healthStore = self.healthStore, let querySampleQuery  = self.querySampleQuery {
            healthStore.execute(querySampleQuery)
                }

            }
    
    // MARK: - MINDFULNESS
  public  func mindfulObserverQueryTriggered() {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let mindfulSampleQuery = HKSampleQuery(
                sampleType: mindfulType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors:  [sortDescriptor],
                resultsHandler: { [weak self] (query, samples, error) in
                    if error != nil {
                    print(" HealthKit returned error while trying to query today's mindful sessions. The error was: \(String(describing: error?.localizedDescription))")
                    }
                    self?.mindfulSampleQueryFinished(samples: samples ?? [])
            })
        if let healthStore = self.healthStore {
            healthStore.execute(mindfulSampleQuery)
        }
    } // END OF MINDFULOBSERVER QUERY TRIGGRED
    
 public   func startObservedMindful(){
        
      mindfulObserverQuery = HKObserverQuery( sampleType: mindfulType , predicate: nil) {
        [weak self] (query, completion, error) in
            self?.mindfulObserverQueryTriggered()
        }
        
        if let healthStore = self.healthStore , let mindfulObserverQuery = self.mindfulObserverQuery {
            healthStore.execute(mindfulObserverQuery)
        }
        
    }// END OF SRATR OBSERVED MINDFULNESS
    
  public  func mindfulSampleQueryFinished(samples: [HKSample]){
        if samples.count > 0 {
        var ttTime = TimeInterval()
        for sample in samples {
            ttTime += sample.endDate.timeIntervalSince(sample.startDate)
        }
            print("(count > 0 )total time --> \(ttTime)")
        }else{
            print("total time --> 0")
        }
       
  }
  public  func testAnchoredQuery(){
    
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        var anchor = HKQueryAnchor.init(fromValue: 0)
        let query = HKAnchoredObjectQuery(type: mindfulType,
                                              predicate: predicate,
                                              anchor: anchor,
            limit: HKObjectQueryNoLimit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
                    guard let samples = samplesOrNil else {
                        fatalError("*** An error occurred during the initial query: \(errorOrNil!.localizedDescription) ***")
                    }
                    anchor = newAnchor!
            self.mindfulSampleQueryFinished(samples: samples)
            print(anchor.description)
            }
        
        query.updateHandler = { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
        
               guard let samples = samplesOrNil else {
                   // Handle the error here.
                   fatalError("*** An error occurred during an update: \(errorOrNil!.localizedDescription) ***")
               }
        
               anchor = newAnchor!
              print("update")
            self.mindfulSampleQueryFinished(samples: samples)
            
            print(anchor.description)
            
        
        
               
        
              
           }
        self.healthStore?.execute(query)
    }
    
    
    } //: End of Class
extension Date {
    static func mondayAt12AM2() -> Date{
        return Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear,.weekOfYear],from: Date()))!
    }
    
}
public struct MindfulnessModel : Identifiable {
   public let id : UUID
   public let date : Date
   public var time : Int32
}
public struct AutoActivityModel : Identifiable {
   public  let id : UUID
   public let workOut : HKWorkout
   public  let heartRate : [Double]
   public  let avgHeartRate : Double
    
}
class MindfulnessStore : ObservableObject {
    @Published var mindfulnessArr :[MindfulnessModel] = [MindfulnessModel]()
    
    init(MindfulnessArr : [MindfulnessModel]) {
        self.mindfulnessArr = MindfulnessArr
    }
    var totoTime : Int32{
        var toto : Int32 = 0
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

public class AutoActivityStore : ObservableObject {
   @Published var autoActivityCollection : [AutoActivityModel]
  public  var healthStore = HealthStore2()
  public  let heartRateUnit:HKUnit = HKUnit(from: "count/min")
    
    init(autoActivityCollection: [AutoActivityModel]) {
        self.autoActivityCollection = autoActivityCollection
    }
    
    func setAutoActivityCollection(newAutoActivityCollection: [AutoActivityModel]){
        self.autoActivityCollection = newAutoActivityCollection
    }
    
    func appendNewData(autoActivityModel : AutoActivityModel){
        print("append")
        self.autoActivityCollection.append(autoActivityModel)
    }
    func displayData (){
        print("display")
        print(self.autoActivityCollection.count)
        for at in self.autoActivityCollection {
           // print("\(at.workOut.workoutActivityType.name)")
            print("start: \(at.workOut.startDate) - end: \(at.workOut.endDate)")
            print("avg hr \(at.avgHeartRate)")
            for hr in at.heartRate{
                print("\(hr) BMP")
            }
            print("------------------------------------")
        }
        
    }
    func loadData (startDate : Date , numberOfObserved : Int){
        var heartRateArr : [Double] = []
        var AVGheartRate : Double = -1.0
        self.healthStore.requestAuthorization{ seccess in
            if seccess {
                self.healthStore.calculateWorkout2(startDate: startDate, numberOfObserved: numberOfObserved) { (workout) in
                    if let workout = workout{
                        self.setAutoActivityCollection(newAutoActivityCollection: [])
                        for wk in workout {
                            
                           
                            // guery - (1) Double callection of Heart rate
                            self.healthStore.getHeartRateBetween2(startDate: wk.startDate, endDate: wk.endDate) { (results) in
                                guard let results = results else {
                                    print("error from get Double callection of Heart rate")
                                    return
                                }
                                for (_,result) in results.enumerated(){
                                    guard let currData:HKQuantitySample = result as? HKQuantitySample else {
                                        print("error from converst HKQuantitySample (currData)")
                                        return }
                                    //1.2 append to Double collection
                                    heartRateArr.append(currData.quantity.doubleValue(for: self.heartRateUnit))
                                   
                                    
                                }
                                // query - (2) heart rate statistic sample
                                self.healthStore.getAVGHeartRate(startDate: wk.startDate, endDate: wk.endDate) { (statistic) in
                                    if let quantity = statistic?.averageQuantity(){
                                        
                                        let beats: Double? = quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                                        AVGheartRate = beats ?? -1.0
                                       
                                        
                                        
                                    }
                                   
                                    self.appendNewData(autoActivityModel: AutoActivityModel(id: wk.uuid, workOut: wk, heartRate: heartRateArr, avgHeartRate: AVGheartRate))
                                  //  print(self.autoActivityCollection.count)
                                   // self.displayData()
                                }//EO - getAVGHeartRate
                            } //EO - getHeartRateBetween2
                           
                            
                            
                        }// EO - Loop Workouts
                     
                    }
                
                }// EO - Calculate Workout-V2
                
            }
        }
        
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
                .frame(width: UIScreen.main.bounds.width * 0.25 , height: 60)
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
    let sample : HKWorkout?
    let hrv : Double
    var value : [Double] = [122.0,122.0,119,119,118,121,124,123,116,115,124,124,126,125,120,121,120,122,120,120,122,122,117,120,120,119,118,120,120,121]
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            VStack {
                
                
                HeaderDetailIView(date: sample!.startDate, startTime: sample!.startDate, endTime: sample!.endDate)
                
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack(alignment: .trailing){
                        
                        
                        if let bruned = sample?.totalEnergyBurned?.doubleValue(for: .kilocalorie()){
                        let formattedCalories = String(format: "%.2f kcal",bruned)
                            BioDataCardTitleView(title: "ACTIVE KILOCALORIES", imageIcon: "flame", color: wmm, value: "\(formattedCalories)")
                                .padding(.top)
                        }
                       
                        if let distance = sample?.totalDistance?.doubleValue(for: .meter()){
                            let distanceKm = distance / 1000
                            let formattedMater = String(format: "%.2f km ",distanceKm)
                            BioDataCardTitleView(title: "Total distance", imageIcon: "location.north.line", color: wmm, value: "\(formattedMater) ")
                        }
                       
                        if let floors = sample?.totalFlightsClimbed{
                            BioDataCardTitleView(title: "Flight Climbed", imageIcon: "arrow.up.right.circle", color: wmm, value: "\(floors) floors")
                        }
                        
                        if let strokeCount = sample?.totalSwimmingStrokeCount{
                            BioDataCardTitleView(title: "Stroke Count", imageIcon: "arrow.uturn.left.circle", color: wmm, value: "\(strokeCount)")
        
                        }
        
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
    private func updateUIFromStatistics(_ StatisticsCollection : HKStatisticsCollection){
        
        
    }
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
// MARK: - EXTENDSION
public extension HKWorkoutActivityType {
    
    /*
     Simple mapping of available workout types to a human readable name.
     */
    public  var name: String {
        switch self {
        case .americanFootball:             return "American Football"
        case .archery:                      return "Archery"
        case .australianFootball:           return "Australian Football"
            
        case .badminton:                    return "Badminton"
        case .barre:                        return "Barre"
        case .baseball:                     return "Baseball"
        case .basketball:                   return "Basketball"
        case .bowling:                      return "Bowling"
        case .boxing:                       return "Boxing"
            
        case .climbing:                     return "Climbing"
        case .cooldown:                     return "Cooldown"
        case .coreTraining:                 return "Core Training"
        case .cricket:                      return "Cricket"
        case .crossCountrySkiing:           return "Cross Country Skiing"
        case .crossTraining:                return "Cross Training"
        case .curling:                      return "Curling"
        case .cycling:                      return "Cycling"
        case .cardioDance:                  return "Cardio Dance"
            
     
        case .discSports:                   return "Disc Sports"
        case .downhillSkiing:               return "Downhill Skiing"
            
        case .elliptical:                   return "Elliptical"
        case .equestrianSports:             return "Equestrian Sports"
            
        case .fencing:                      return "Fencing"
        case .fishing:                      return "Fishing"
        case .functionalStrengthTraining:   return "Functional Strength Training"
            

        case .golf:                         return "Golf"
        case .gymnastics:                   return "Gymnastics"
        
        case .handball:                     return "Handball"
        case .hiking:                       return "Hiking"
        case .hockey:                       return "Hockey"
        case .hunting:                      return "Hunting"
        case .handCycling:                  return "Hand Cycling"
        case .highIntensityIntervalTraining:return "Hight Intensity Interval Training"
            
        case .jumpRope:                     return "Jump Rope"
            
        case .kickboxing:                   return "Kickboxing"
        
        case .lacrosse:                     return "Lacrosse"
        
        case .martialArts:                  return "Martial Arts"
        case .mindAndBody:                  return "Mind and Body"
        case .mixedCardio:                  return "mixed Cardio"
        
            
        case .other:                        return "Other"
        
        case .paddleSports:                 return "Paddle Sports"
        case .play:                         return "Play"
        case .preparationAndRecovery:       return "Preparation and Recovery"
        case .pilates:                      return "Pilates"
        case .pickleball:                   return "Pickleball"
    
        case .racquetball:                  return "Racquetball"
        case .rowing:                       return "Rowing"
        case .rugby:                        return "Rugby"
        case .running:                      return "Running"
        
        case .sailing:                      return "Sailing"
        case .skatingSports:                return "Skating Sports"
        case .snowSports:                   return "Snow Sports"
        case .soccer:                       return "Soccer"
        case .softball:                     return "Softball"
        case .squash:                       return "Squash"
        case .stairClimbing:                return "Stair Climbing"
        case .surfingSports:                return "Surfing Sports"
        case .swimming:                     return "Swimming"
        case .stairs:                       return "Stairs"
        case .snowboarding:                 return "Snow Boarding"
        case .stepTraining:                 return "Step Training"
        case .socialDance:                  return "Social Dance"
        
        case .tableTennis:                  return "Table Tennis"
        case .tennis:                       return "Tennis"
        case .trackAndField:                return "Track and Field"
        case .traditionalStrengthTraining:  return "Traditional Strength Training"
        case .taiChi:                       return "Tai Chi"
        
        case .volleyball:                   return "Volleyball"
        
        case .walking:                      return "Walking"
        case .waterFitness:                 return "Water Fitness"
        case .waterPolo:                    return "Water Polo"
        case .waterSports:                  return "Water Sports"
        case .wrestling:                    return "Wrestling"
        case .wheelchairRunPace:            return "Wheelchair Run Pace"
        case .wheelchairWalkPace:           return "Wheelchair Walk Pace"
        
        case .yoga:                         return "Yoga"
        
        // Catch-all
        default:                            return "Other"
        }
    }
    
    /*
     Additional mapping for common name for activity types where appropriate.
     */
    public var commonName: String {
        switch self {
        case .highIntensityIntervalTraining: return "HIIT"
        default: return name
        }
    }
    
    /*
     Mapping of available activity types to emojis, where an appropriate gender-agnostic emoji is available.
     */
    public var associatedEmoji: String? {
        switch self {
        case .americanFootball:             return "🏈"
        case .archery:                      return "🏹"
        case .badminton:                    return "🏸"
        case .baseball:                     return "⚾️"
        case .basketball:                   return "🏀"
        case .bowling:                      return "🎳"
        case .boxing:                       return "🥊"
        case .curling:                      return "🥌"
        case .cycling:                      return "🚲"
        case .equestrianSports:             return "🏇"
        case .fencing:                      return "🤺"
        case .fishing:                      return "🎣"
        case .functionalStrengthTraining:   return "💪"
        case .golf:                         return "⛳️"
        case .hiking:                       return "🥾"
        case .hockey:                       return "🏒"
        case .lacrosse:                     return "🥍"
        case .martialArts:                  return "🥋"
        case .mixedMetabolicCardioTraining: return "❤️"
        case .paddleSports:                 return "🛶"
        case .rowing:                       return "🛶"
        case .rugby:                        return "🏉"
        case .sailing:                      return "⛵️"
        case .skatingSports:                return "⛸"
        case .snowSports:                   return "🛷"
        case .soccer:                       return "⚽️"
        case .softball:                     return "🥎"
        case .tableTennis:                  return "🏓"
        case .tennis:                       return "🎾"
        case .traditionalStrengthTraining:  return "🏋️‍♂️"
        case .volleyball:                   return "🏐"
        case .waterFitness, .waterSports:   return "💧"
        
        // iOS 10
        case .barre:                        return "🥿"
        case .crossCountrySkiing:           return "⛷"
        case .downhillSkiing:               return "⛷"
        case .kickboxing:                   return "🥋"
        case .snowboarding:                 return "🏂"
        
        // iOS 11
        case .mixedCardio:                  return "❤️"
        
        // iOS 13
        case .discSports:                   return "🥏"
        case .fitnessGaming:                return "🎮"
        
        // Catch-all
        default:                            return nil
        }
    }
    
    public var associatedIcon : String? {
        switch self {
        case .americanFootball:             return "americanFootball"
        case .archery:                      return "archery"
        case .australianFootball:           return "australianFootball"
            
        case .badminton:                    return "badminton"
        case .barre:                        return "barre"
        case .baseball:                     return "baseball"
        case .basketball:                   return "basketball"
        case .bowling:                      return "bowling"
        case .boxing:                       return "boxing"
            
        case .climbing:                     return "climbing"
        case .cooldown:                     return "cooldown"
        case .coreTraining:                 return "coreTraining"
        case .cricket:                      return "cricket"
        case .crossCountrySkiing:           return "crossCountrySkiing"
        case .crossTraining:                return "crossTraining"
        case .curling:                      return "curling"
        case .cycling:                      return "cycling"
        case .cardioDance:                  return "cardio Dance"
            
     
        case .discSports:                   return "discSports"
        case .downhillSkiing:               return "downhillSkiing"
            
        case .elliptical:                   return "elliptical"
        case .equestrianSports:             return "equestrianSports"
            
        case .fencing:                      return "fencing"
        case .fishing:                      return "fishing"
        case .functionalStrengthTraining:   return "functionalStrengthTraining"
            

        case .golf:                         return "golf"
        case .gymnastics:                   return "gymnastics"
        
        case .handball:                     return "handball"
        case .hiking:                       return "hiking"
        case .hockey:                       return "hockey"
        case .hunting:                      return "hunting"
        case .handCycling:                  return "handCycling"
        case .highIntensityIntervalTraining:return "hightIntensityIntervalTraining"
            
        case .jumpRope:                     return "jumpRope"
            
        case .kickboxing:                   return "kickboxing"
        
        case .lacrosse:                     return "lacrosse"
        
        case .martialArts:                  return "martialArts"
        case .mindAndBody:                  return "mindandBody"
        case .mixedCardio:                  return "mixedCardio"
        
            
        case .other:                        return "other"
        
        case .paddleSports:                 return "paddleSports"
        case .play:                         return "play"
        case .preparationAndRecovery:       return "preparationAndRecovery"
        case .pilates:                      return "pilates"
        case .pickleball:                   return "pickleball"
    
        case .racquetball:                  return "racquetball"
        case .rowing:                       return "rowing"
        case .rugby:                        return "rugby"
        case .running:                      return "running"
        
        case .sailing:                      return "sailing"
        case .skatingSports:                return "skatingSports"
        case .snowSports:                   return "snowSports"
        case .soccer:                       return "soccer"
        case .softball:                     return "softball"
        case .squash:                       return "squash"
        case .stairClimbing:                return "stairClimbing"
        case .surfingSports:                return "surfingSports"
        case .swimming:                     return "swimming"
        case .stairs:                       return "stairs"
        case .snowboarding:                 return "snowBoarding"
        case .stepTraining:                 return "stepTraining"
        case .socialDance:                  return "socialDance"
        
        case .tableTennis:                  return "tableTennis"
        case .tennis:                       return "tennis"
        case .trackAndField:                return "trackAndField"
        case .traditionalStrengthTraining:  return "traditionalStrengthTraining"
        case .taiChi:                       return "taiChi"
        
        case .volleyball:                   return "volleyball"
        
        case .walking:                      return "walking"
        case .waterFitness:                 return "waterFitness"
        case .waterPolo:                    return "waterPolo"
        case .waterSports:                  return "waterSports"
        case .wrestling:                    return "wrestling"
        case .wheelchairRunPace:            return "wheelchairRunPace"
        case .wheelchairWalkPace:           return "wheelchairWalkPace"
        
        case .yoga:                         return "yoga"

        // Catch-all
        default:                            return "other"
    }
    
    
    enum EmojiGender {
        case male
        case female
    }
    
    /*
     Mapping of available activity types to appropriate gender specific emojies.
     
     If a gender neutral symbol is available this simply returns the value of `associatedEmoji`.
     */
          func associatedEmoji(for gender: EmojiGender) -> String? {
        switch self {
        case .climbing:
            switch gender {
            case .female:                   return "🧗‍♀️"
            case .male:                     return "🧗🏻‍♂️"
            }
        case .dance, .danceInspiredTraining:
            switch gender {
            case .female:                   return "💃"
            case .male:                     return "🕺🏿"
            }
        case .gymnastics:
            switch gender {
            case .female:                   return "🤸‍♀️"
            case .male:                     return "🤸‍♂️"
            }
        case .handball:
            switch gender {
            case .female:                   return "🤾‍♀️"
            case .male:                     return "🤾‍♂️"
            }
        case .mindAndBody, .yoga, .flexibility:
            switch gender {
            case .female:                   return "🧘‍♀️"
            case .male:                     return "🧘‍♂️"
            }
        case .preparationAndRecovery:
            switch gender {
            case .female:                   return "🙆‍♀️"
            case .male:                     return "🙆‍♂️"
            }
        case .running:
            switch gender {
            case .female:                   return "🏃‍♀️"
            case .male:                     return "🏃‍♂️"
            }
        case .surfingSports:
            switch gender {
            case .female:                   return "🏄‍♀️"
            case .male:                     return "🏄‍♂️"
            }
        case .swimming:
            switch gender {
            case .female:                   return "🏊‍♀️"
            case .male:                     return "🏊‍♂️"
            }
        case .walking:
            switch gender {
            case .female:                   return "🚶‍♀️"
            case .male:                     return "🚶‍♂️"
            }
        case .waterPolo:
            switch gender {
            case .female:                   return "🤽‍♀️"
            case .male:                     return "🤽‍♂️"
            }
        case .wrestling:
            switch gender {
            case .female:                   return "🤼‍♀️"
            case .male:                     return "🤼‍♂️"
            }

        // Catch-all
        default:                            return ""
        }
    }
    
}
}


