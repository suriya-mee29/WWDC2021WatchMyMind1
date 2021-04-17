import SwiftUI
import PlaygroundSupport




struct AppView : View {
    
    // MARK: - PROPERTIES
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
                //.clipShape(CustomShape())
                
                ScrollView{
                VStack(alignment: .leading ){
                    Text("auto-activity (\(ac.count))".uppercased())
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
