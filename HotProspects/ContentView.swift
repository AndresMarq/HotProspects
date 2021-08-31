//
//  ContentView.swift
//  HotProspects
//
//  Created by Andres Marquez on 2021-08-15.
//

import SwiftUI

struct ContentView: View {
    var prospects = Prospects()
    
    //False sort by name, true by email
    var selectedSorter = SorterOptions()
    
    var body: some View {
        TabView {
            ProspectsView(filter: .none, sorter: (selectedSorter.selection ? .email : .name))
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Everyone")
                }
            
            ProspectsView(filter: .contacted, sorter: (selectedSorter.selection ? .email : .name))
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Contacted")
                }
            
            ProspectsView(filter: .uncontacted, sorter: (selectedSorter.selection ? .email : .name))
                .tabItem {
                    Image(systemName: "questionmark.diamond")
                    Text("Uncontacted")
                }
            
            MeView()
                .tabItem {
                    Image(systemName: "person.crop.square")
                    Text("Me")
                }
        }
        .environmentObject(prospects)
        .environmentObject(selectedSorter)
        .onAppear(perform: prospects.loadData)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
