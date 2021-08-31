//
//  Prospect.swift
//  HotProspects
//
//  Created by Andres Marquez on 2021-08-18.
//

import SwiftUI

class Prospect: Identifiable, Codable, Comparable, Equatable {
    
    var id = UUID()
    var name = "Anonymus"
    var emailAddress = ""
    fileprivate(set) var isContacted = false
    
    
    static func < (lhs: Prospect, rhs: Prospect) -> Bool {
            lhs.name < rhs.name
    }
    
    static func == (lhs: Prospect, rhs: Prospect) -> Bool {
        return lhs.name == rhs.name && lhs.emailAddress == rhs.emailAddress
    }
}

class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    static let saveKey = "SavedData"
    
    init() {
        self.people = []
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadData() {
        let filename = getDocumentsDirectory().appendingPathComponent(Self.saveKey)

        do {
            let data = try Data(contentsOf: filename)
            let decoded = try JSONDecoder().decode([Prospect].self, from: data)
            self.people = decoded
        } catch {
            print("Unable to load saved data.")
        }
    }
    
    func saveData() {
        do {
            let filename = getDocumentsDirectory().appendingPathComponent(Self.saveKey)
            let data = try JSONEncoder().encode(self.people)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            print("Data saved")
        } catch {
            print("Unabled to save data")
        }
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        saveData()
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        saveData()
    }
}

class SorterOptions: ObservableObject {
    //False if by name, true if by email
    @Published var selection = false
    
    func update() {
        objectWillChange.send()
    }
}
