//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Andres Marquez on 2021-08-18.
//

import SwiftUI
import CodeScanner
import UserNotifications

struct ProspectsView: View {
    @State private var isShowingScanner = false
    
    @State private var isShowingSortSheet = false
    
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    enum SortType {
        case name, email
    }
    
    @EnvironmentObject var prospects: Prospects
    @EnvironmentObject var selectedSorter: SorterOptions
    
    let filter: FilterType
    let sorter: SortType
    
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted People"
        case .uncontacted:
            return "Uncontacted People"
        }
    }
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
    }
    
    var sortedProspects: [Prospect] {
        switch sorter {
        case .name:
            return filteredProspects.sorted()
        case .email:
            return filteredProspects.sorted { lhs, rhs in
                lhs.emailAddress < rhs.emailAddress
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedProspects) { prospect in
                    HStack {
                        Image(systemName: (prospect.isContacted ? "person.crop.circle.badge.checkmark" : "person.crop.circle.badge.questionmark"))
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                    }
                    .contextMenu {
                        Button(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted" ) {
                            self.prospects.toggle(prospect)
                        }
                        
                        if !prospect.isContacted {
                            Button("Remind Me") {
                                self.addNotification(for: prospect)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(title)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.isShowingScanner = true
                    }) {
                        Image(systemName: "qrcode.viewfinder")
                        Text("Scan")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.isShowingSortSheet = true
                    }, label: {
                        Text("Sort by")
                    })
                }
            })
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Abdul Hudson\nzaul@hackingwithswift.com", completion: self.handleScan)
            }
            .actionSheet(isPresented: $isShowingSortSheet) {
                ActionSheet(title: Text("Sort by"), buttons: [
                    .default(Text("Name")) {
                        self.selectedSorter.selection = false
                        self.selectedSorter.update()
                    },
                    .default(Text("email")) {
                        self.selectedSorter.selection = true
                        self.selectedSorter.update()
                    },
                    .cancel()
                ])
            }
        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
       self.isShowingScanner = false
        switch result {
        case .success(let code):
            let details = code.components(separatedBy: "\n")
            guard details.count == 2 else { return }

            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]

            self.prospects.add(person)
            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
           // To test notifications: let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none, sorter: .name)
    }
}
