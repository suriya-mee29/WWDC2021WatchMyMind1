import SwiftUI
import PlaygroundSupport
import HealthKit



struct AppView : View {
    
    // MARK: - PROPERTIES
    var healthStore : HealthStore? = HealthStore()
    @State private var isAnimated : Bool = false
    @State private var moveing : Int = 0
    @State private var aSleep : String = "0"
    @State private var inBad : String = "0"
    @State private var standing : String = "0"
    @State private var steping : Int = 0
    @State private var name : String = ""
    

    //DATA
    let ac : [Activity] = Bundle.main.decode("Data/Activities.json")

    
// MARK: - FUNCTION

    
    
    var body : some View {
        NavigationView{
        
            VStack{
                //Header
                ZStack{
                    VStack{
                        Text("watchmymind".uppercased())
                            .font(.title3)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5 )
                            .padding(.vertical)
                            .onAppear(perform: {
                                withAnimation(Animation.easeIn(duration: 0.5)){
                                    isAnimated = true
                                }
                            })
                        
                        
                    VStack (alignment: .leading ){
                        
                        HStack{
                            Image(systemName: "flame.fill")
                                .font(.title3)
                                .foregroundColor(burningColor)

                            
                            Text("BURNING \(moveing) KCAL".uppercased())
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(burningColor)
                                
                        }
                        .padding(.bottom,1)
                        //in bed
                        HStack{
                            Image(systemName: "bed.double.fill")
                                .font(.title3)
                                .foregroundColor(sleepingColor)
                             
                            Text("INBED \(inBad)  HR".uppercased())
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(sleepingColor)
                              
                        }
                        .padding(.bottom,1)
                        // a sleep
                        HStack{
                            Image(systemName: "powersleep")
                                .font(.title3)
                                .foregroundColor(sleepingColor)
                         
                            Text("ASLEEP \(aSleep) HR".uppercased())
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(sleepingColor)
                               
                        }
                        .padding(.bottom,1)
                        HStack{
                            Image(systemName: "figure.stand")
                                .font(.title3)
                                .foregroundColor(standingColor)
                            
                            Text("STANDING \(standing) HR".uppercased())
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(standingColor)
                               
                        }
                        .padding(.bottom , 1)
                        HStack{
                            Image(systemName: "figure.walk")
                                .font(.title3)
                                .foregroundColor(steppingColor)
                            Text("STEPING \(steping) STEPS".uppercased())
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(steppingColor)
                                
                        }
                        .padding(.bottom,1)
                        
                        
                    }
                    .padding(.bottom,30)
                    .padding(.horizontal)
                    }
                    .padding()
                    .frame(width: UIScreen.main.bounds.width)
                        
                }
                .background(wmm)
                .clipShape(CustomShape())
                .onAppear(perform: {
                    
                    if let healthStore = healthStore {
                        healthStore.requestAuthorization { success in
                            //Activity burned
                            healthStore.getDailyMoving { summary in
                                self.moveing = Int(summary?.activeEnergyBurned.doubleValue(for: HKUnit.kilocalorie()) ?? 0)
                                
                            }
     
                            //Sleeping
                            healthStore.getDailySleeping { samples in
                               // let startDate = Calendar.current.startOfDay(for: Date())
                                var asleep_ :TimeInterval = 0
                                var inbed_ :TimeInterval = 0
                                
                                if samples.count > 0{
                                    for sample in samples {
                                        if let categorySample = sample as? HKCategorySample{
                                            if categorySample.value == HKCategoryValueSleepAnalysis.inBed.rawValue{
                                                //inBed
                                                inbed_ += categorySample.endDate.timeIntervalSince(categorySample.startDate)
                                              
                                            }else{
                                                //asleep
                                                asleep_ += categorySample.endDate.timeIntervalSince(categorySample.startDate)
                                                
                                            }
                                        }else{
                                            asleep_ = 0
                                            inbed_ = 0
                                        }
                                        
                                    }
                                    
                                    //finaly
                                    if asleep_ != 0 {
                                        self.aSleep = "\(asleep_.stringFromTimeInterval())"
                                        
                                        
                                        
                                    }else{
                                        self.aSleep = "No data"
                                    }
                                    if inbed_ != 0 {
                                        self.inBad = "\(inbed_.stringFromTimeInterval())"
                                    }else{
                                        self.inBad = "No data"
                                    }
                                    
                                }else{
                                    self.aSleep = "No data"
                                    self.inBad = "No data"
                                }
                                
                            }
                            
                            
                            //Standing
                            healthStore.getDailyStanding { standTime in
                                self.standing = standTime.stringFromTimeInterval()
                            }
                            //Steping
                            let startDate  = Calendar.current.date(byAdding: .day,value: -1, to: Date())!
                            
                            healthStore.calculateSteps{ statisticsCollection in
                                
                                statisticsCollection?.enumerateStatistics(from: startDate, to: Date(), with: { (statistic, stop) in
                                    let count = statistic.sumQuantity()?.doubleValue(for: .count())
                                    self.steping = Int(count ?? 0)
                                })
                                
                                
                            }
                        }
                    }
                })
                
                ScrollView{
                VStack(alignment: .leading ){
                    Text("auto activity (\(ac.count))".uppercased())
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                ScrollView(.horizontal, showsIndicators: false, content: {
                    
                                    LazyHGrid(rows: [GridItem(.fixed(215))], alignment: .center, spacing: 0, pinnedViews: [], content: {
                                    
                                            //CADR1
                                            NavigationLink(
                                                destination:
                                                    ActivityView(title: ac[0].title, description: ac[0].description, type: ac[0].type, imageIcon: ac[0].imageIcon, navigationTag: 1, ui: UIImage(named: ac[0].imageIcon)!)
                                                ,
                                                label: {
                                                            ActivityCard(title: ac[0].title, description: ac[0].description, type: ac[0].type, imageIcon: ac[0].imageIcon, progressColor: Color.green, progress: ac[0].progrss, backgroundColor: Color.white)
                                                })
                                                .padding(.horizontal,13)
                                        
                                        
                                        //CADR2
                                        NavigationLink(
                                            destination:
                                                ActivityView(title: ac[1].title, description: ac[1].description, type: ac[1].type, imageIcon: ac[1].imageIcon, navigationTag: 2, ui: UIImage(named: ac[1].imageIcon)!)
                                            ,
                                            label: {
                                                        ActivityCard(title: ac[1].title, description: ac[1].description, type: ac[1].type, imageIcon: ac[1].imageIcon, progressColor: Color.green, progress: ac[1].progrss, backgroundColor: Color.white)
                                            })
                                            .padding(.horizontal,13)
                                            
                                            
                                        
                                    })//LAZY H GRID
                                
                    
                            })// scrol
                }//VStack
              
                    FootageView()
            }//ScrollView
        }//VStack
        }//Navigatio
       
    }
}
PlaygroundPage.current.setLiveView(AppView())
