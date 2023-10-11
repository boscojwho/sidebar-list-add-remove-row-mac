//
//  ContentView.swift
//  List
//
//  Created by Bosco Ho on 2023-10-10.
//

import SwiftUI

struct Item: Identifiable, Hashable {
    let id = UUID()
    var name: String { id.uuidString }
}

@MainActor
class Model: ObservableObject
{
    @Published var items: [Item] = .init()
    
    func add() {
        if items.count > 5 {
            print("insert")
            items.insert(.init(), at: 2)
        } else {
            let rng = Int.random(in: 0...1)
            if rng == 1 {
                print("append")
                items.append(.init())
            } else {
                print("prepend")
                items.insert(.init(), at: 0)
            }
        }
    }
}

struct ContentView: View {
    
    @StateObject private var model: Model = .init()
    
    var body: some View {
        NavigationSplitView {
            List {
                Section {
                    if model.items.isEmpty {
                        ProgressView()
                    } else {
                        ForEach(model.items, id: \.self) { item in
                            NavigationLink {
                                Text("Item: \(item.name)")
                                    .id("detail-\(item.name)")
                            } label: {
                                Text("Item: \(item.name)")
                            }
                            .contextMenu {
                                Button {
                                    Task(priority: .userInitiated) {
                                        if let idx = model.items.firstIndex(of: item) {
                                            withAnimation {
                                                model.items.remove(at: idx)
                                            }
                                        }
                                    }
                                } label: {
                                    Text("Remove Item")
                                }
                            }
                        }
                    }
                }
            }
        } detail: {
            Text("Homepage")
        }
        .toolbar {
            Button {
                withAnimation {
                    model.add()
                }
            } label: {
                Text("Add")
            }
        }
    }
}
