//
//  ContentView.swift
//  PopOverView
//
//  Created by robevans on 4/22/22.
//

import Popovers
import UIKit
import SwiftUI

struct ContentView: View {

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]


    var body: some View {
        GeometryReader { geo in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0 ..< 35) { item in
                        VStack {
                            SomeView(text: "item: \(item)")
                        }
                    }
                }
            }
        }
    }
}

struct SomeView: View {
    let text: String
    @State var open = false

    var body: some View {
        VStack {
            Text(text)
                .onTapGesture {
                    open = true
                }
                .popover(
                    present: $open,
                    attributes: {
                        $0.sourceFrameInset.top = 35
                        $0.presentation.animation = .spring()
                        $0.position = .absolute(
                            originAnchor: .bottom,
                            popoverAnchor: .topLeft
                        )
                    }
                ) {
                    VStack {
                        Text("Hi, I'm a popover. - \(text)")
                            .padding()
                    }
                    .frame(width: 350, height: 350, alignment:  .center)
                    .background(.white)
                    .cornerRadius(46)
                    .shadow(color: .secondary, radius: 14, x: 2, y: 4)
                }
            .padding()

/*

This is an example of with an arrow, but we need to do some work to determine arrow location with lazygrid

 Templates.Container(
     arrowSide: .bottom(.mostClockwise),
     backgroundColor: .green
 ) {
     Text("This is a pretty standard-looking popover with an arrow.")
         .foregroundColor(.white)
 }
 .frame(maxWidth: 300)

 */

        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
