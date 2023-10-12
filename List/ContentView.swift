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
    @State private var expanded: Bool = true
    
    var body: some View {
        NavigationSplitView {
            ScrollView {
                Form {
                    DisclosureGroup(
                        isExpanded: $expanded,
                        content: {
                            Group {
                                if model.items.isEmpty {
                                    ProgressView()
                                } else {
                                    ForEach(Array(model.items.enumerated()), id: \.element) { index, item in
                                        Group {
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
                                            .transition(
                                                .asymmetric(
                                                    insertion: .offset(y: -44).combined(with: .opacity),
                                                    removal: .offset(y: -44).combined(with: .opacity)
                                                )
                                            )
                                            .animation(.linear(duration: 0.2), value: expanded)
                                        }
                                    }
                                }
                            }
                        },
                        label: {
                            HStack {
                                Text("Section 1 of All Sections")
                            }
                        }
                    )
                    .disclosureGroupStyle(MyDisclosureStyle())
                }
                .padding()
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

struct MyDisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    configuration.label
                    Spacer()
                    Image(systemName: "chevron.down")
                        .transition(.identity)
                        .rotationEffect(.degrees(configuration.isExpanded ? 0 : -90))
                        .animation(.linear(duration: 0.2), value: configuration.isExpanded)
                }
                .background(Rectangle().fill(.clear))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if configuration.isExpanded {
                configuration.content
                    .animation(.linear(duration: 0.2), value: configuration.isExpanded)
            }
        }
        .clipped()
    }
}
