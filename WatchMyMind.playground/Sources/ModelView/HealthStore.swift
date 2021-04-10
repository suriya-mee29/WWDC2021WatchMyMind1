import Foundation
import HealthKit

public class HealthStore {
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
                print("HealthKit returned error while trying to query today's mindful sessions. The error was: \(String(describing: error?.localizedDescription))")
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
        let anchorDate = Date.mondayAt12AM()
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
    static func mondayAt12AM() -> Date{
        return Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear,.weekOfYear],from: Date()))!
    }
    
}
