import SwiftUI
import PlaygroundSupport

import Foundation

//let backgroundColor : Color

public struct FootageView: View {
        // MARK: - PROPERTIES
    public init(){}

        // MARK: - BODY
    public var body: some View {

            VStack {
//                Image(systemName: "display.2")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 128, height: 128)
//                HStack{
                Group {
                    Text(" Copyright © 2021 ")

                   
                    Link(" Icon made by Freepik from www.flaticon.com , ",
        destination: (URL(string: "https://www.freepikcompany.com/") ??
                                URL(string: "https://https://www.flaticon.com/"))!)

                    Link(" Icon made by Becris from www.flaticon.com , ",
            destination: (URL(string: "https://www.freepikcompany.com/") ??
                                    URL(string: "https://https://www.flaticon.com/"))!)
                        
                    Link(" Icon made by smashicons from www.flaticon.com ",
            destination: (URL(string: "https://www.freepikcompany.com/") ??
                                    URL(string: "https://https://www.flaticon.com/"))!)

                }//Group
                 .font(.system(size: 9))
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                
//            }
                
 
//                .font(.footnote)
//                .multilineTextAlignment(.center)
             
            } //: VSTACK
            .padding()
            .opacity(0.4)
            
        }
    }



//PlaygroundPage.current.setLiveView(FootageView())
