//
//  ProspectsView.swift
//  MeetMeThere
//
//  Created by Максим Нуждин on 24.01.2022.
//

import CodeScanner
import SwiftUI
import UserNotifications

struct ProspectsView: View {
    
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    enum SortMethods {
        case name, dateAdded
    }
    
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var isShowingConfirmationDialog = false
    let filter: FilterType
    @State private var sortedMethod: SortMethods = .name
    
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProspects.sorted {
                    switch sortedMethod {
                    case .name:
                        return $0.name < $1.name
                    case .dateAdded:
                        // for dates the most recent results are less
                        return $0.dateAdded > $1.dateAdded
                    }
                }) { prospect in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(prospect.name)
                                .font(.headline)
                            if filter == .none {
                                Image(systemName: prospect.isContacted ? "person.crop.circle.badge.checkmark" : "person.crop.circle")
                            }
                        }
                        Text(prospect.email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(prospect.displayedDate)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }.swipeActions {
                        if prospect.isContacted {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark uncontacted", systemImage: "person.crop.circle.badge.xmark")
                            }
                            .tint(.blue)
                        } else {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                            }
                            .tint(.green)
                            
                            Button {
                                addNotification(for: prospect)
                            } label: {
                                Label("remind me", systemImage: "bell")
                            }
                            .tint(.orange)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isShowingConfirmationDialog.toggle()
                    } label: {
                        Text("sort")
                    }.confirmationDialog("123", isPresented: $isShowingConfirmationDialog) {
                        Button("sort by name") { sortedMethod = .name}
                        Button("sort by date added") { sortedMethod = .dateAdded}
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingScanner = true
                    } label: {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                }
            }
            .sheet(isPresented: $isShowingScanner){
                let names = ["Maxim", "Oleg", "Vera", "Andrei", "Anot", "Yan"]
                let lastNames = ["Vainikka", "Belii", "CHernii", "Xahori"]
                let name = names.randomElement()!
                let lastName = lastNames.randomElement()!
                CodeScannerView(codeTypes: [.qr], simulatedData: "\(name) \(lastName)\nvainikkaxd@gmail.com", completion: handleScan)
            }
            
        }
    }
    
    var title: String {
        switch filter {
        case .none:
            return "everyone"
        case .contacted:
            return "contacted ppl"
        case .uncontacted:
            return "uncontacted ppl"
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
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect()
            person.name = details[0]
            person.email = details[1]
            prospects.add(person)
        case .failure(let error):
            print("Scanning failed. \(error.localizedDescription)")
        }
    }
    
    func addNotification(for prospect: Prospect) {
        
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.email
            content.sound = UNNotificationSound.default
            
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
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects())
    }
}
