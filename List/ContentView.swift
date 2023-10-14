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
    @State private var selectedItem: Int?
    
    var body: some View {
        NavigationSplitView {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    DisclosureGroup(
                        isExpanded: $expanded,
                        content: {
                            VStack(alignment: .leading) {
                                if model.items.isEmpty {
                                    ProgressView()
                                } else {
                                    ForEach(Array(model.items.enumerated()), id: \.element) { index, item in
                                        Group {
                                            NavigationLink {
                                                Text("Item: \(item.name)")
                                                    .id("detail-\(item.name)")
                                            } label: {
                                                HStack {
                                                    Text("Item: \(item.name)")
                                                        .lineLimit(1, reservesSpace: true)
                                                }
                                                .background(
                                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                                        .fill((selectedItem ?? -1) == index ? Color.secondary : Color.clear)
                                                        .padding(.all, -4)
                                                )
                                                .padding(.all, 2)
                                                .border(Color.blue, width: 1)
                                            }
                                            .simultaneousGesture(
                                                TapGesture()
                                                    .onEnded({ _ in
                                                        selectedItem = index
                                                    })
                                            )
                                            .buttonStyle(.plain)
                                            .border(Color.blue, width: 1)
                                            .onTapGesture {
                                                selectedItem = index
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
                                            .animation(.linear(duration: 0.2), value: expanded)
                                        }
                                    }
                                }
                            }
                            .padding(.all, 4)
                            .border(.blue, width: 1)
                        },
                        label: {
                            HStack {
                                Text("Section 1 of All Sections")
                            }
                        }
                    )
                    .disclosureGroupStyle(VStackDisclosureStyle())
                }
                .padding()
            }
            .scrollClipDisabled(true)
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

struct VStackDisclosureStyle: DisclosureGroupStyle {
    
    @State private var isHovering = false
    
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            hStackLayout(configuration: configuration)
            
            if configuration.isExpanded {
                configuration.content
                    .animation(.linear(duration: 0.2), value: configuration.isExpanded)
            }
        }
        .clipped()
    }
    
    private func hStackLayout(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline) {
            configuration.label.foregroundStyle(.tertiary)
            Spacer()
            if isHovering == true {
                Image(systemName: "chevron.down")
                    .foregroundStyle(.tertiary)
                    .transition(.identity)
                    .rotationEffect(.degrees(configuration.isExpanded ? 0 : -90))
                    .animation(.linear(duration: 0.2), value: configuration.isExpanded)
                    .buttonStyle(.plain)
                    .padding(4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            configuration.isExpanded.toggle()
                        }
                    }
//                    .border(.blue, width: 1)
            }
        }
        .background(Rectangle().fill(.clear))
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovering = hovering
        }
    }
    
    private func buttonLayout(configuration: Configuration) -> some View {
        Button {
            withAnimation {
                configuration.isExpanded.toggle()
            }
        } label: {
            HStack(alignment: .firstTextBaseline) {
                configuration.label
                Spacer()
                if isHovering == true {
                    Image(systemName: "chevron.down")
                        .transition(.identity)
                        .rotationEffect(.degrees(configuration.isExpanded ? 0 : -90))
                        .animation(.linear(duration: 0.2), value: configuration.isExpanded)
                }
            }
            .background(Rectangle().fill(.clear))
            .contentShape(Rectangle())
            .onHover { hovering in
                isHovering = hovering
            }
        }
        .buttonStyle(.plain)
    }
}
