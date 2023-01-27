//
//  ContentView.swift
//  MapLikeScrollView
//
//  Created by Davit Ghushchyan on 15.01.23.
//

import SwiftUI

struct ContentView: View {
    @State var isViewAppeared = false
    
    var body: some View {
        VStack {
            if isViewAppeared {
                ImageCollectionScrollViewSwiftUIWrapper()
            }
        }
        .padding()
        .onAppear {
            isViewAppeared = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
