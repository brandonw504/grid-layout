//
//  ContentView.swift
//  grid-layout-test
//
//  Created by Brandon Wong on 7/14/23.
//

import SwiftUI

struct Item: Identifiable {
    var id = UUID()
    let width: Double
    let height: Double
}

struct ContentView: View {
    @State private var items: [Item] = []

    var body: some View {
        VStack {
            BentoBox {
                ForEach(items) { item in
                    RoundedRectangle(cornerRadius: 10.0).frame(width: item.width, height: item.height)
                }
            }
            .animation(.default)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("Large Modules")
                Spacer()
                Button(action: {
                    items.append(Item(width: 170.0, height: 50.0))
                }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.bordered)
                Button(action: {
                    if let i = items.firstIndex(where: { $0.width == 170.0 }) {
                        items.remove(at: i)
                    }
                }) {
                    Image(systemName: "minus")
                }
                .buttonStyle(.bordered)
            }
            HStack(spacing: 8) {
                Text("Medium Modules")
                Spacer()
                Button(action: {
                    items.append(Item(width: 110.0, height: 50.0))
                }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.bordered)
                Button(action: {
                    if let i = items.firstIndex(where: { $0.width == 110.0 }) {
                        items.remove(at: i)
                    }
                }) {
                    Image(systemName: "minus")
                }
                .buttonStyle(.bordered)
            }
            HStack(spacing: 8) {
                Text("Small Modules")
                Spacer()
                Button(action: {
                    items.append(Item(width: 50.0, height: 50.0))
                }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.bordered)
                Button(action: {
                    if let i = items.firstIndex(where: { $0.width == 50.0 }) {
                        items.remove(at: i)
                    }
                }) {
                    Image(systemName: "minus")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}

struct BentoBox: Layout {
    let smallModuleWidth: Double = 50.0 // 1x1 module
    let mediumModuleWidth: Double = 110.0 // 2x1 module
    let largeModuleWidth: Double = 170.0 // 3x1 module
    let totalWidth: Double = 350.0 // total width of six 1x1 modules with spacing between
    let moduleHeight: Double = 50.0
    let spacing: Double = 10.0

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // Calculate how many effective 1x1 modules we have (2x1s count as two, 3x1s count as three)
        var total: Int = 0
        for subview in subviews {
            total += Int(subview.dimensions(in: proposal).width / smallModuleWidth)
        }

        let heightUnits: Int = Int(ceil(Double(total) / 6.0)) - 1
        let height: Double = Double(heightUnits) * (smallModuleWidth + spacing) + smallModuleWidth

        return CGSize(width: totalWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = totalWidth + bounds.minX
        let smallModules = subviews.filter { $0.dimensions(in: proposal).width == smallModuleWidth }
        let mediumModules = subviews.filter { $0.dimensions(in: proposal).width == mediumModuleWidth }
        let largeModules = subviews.filter { $0.dimensions(in: proposal).width == largeModuleWidth }

        var x = bounds.minX
        var y = bounds.minY

        // Place all 3x1 modules first
        for module in largeModules {
            module.place(at: CGPoint(x: x, y: y),
                         anchor: .topLeading,
                         proposal: ProposedViewSize(width: largeModuleWidth, height: moduleHeight))
            x += largeModuleWidth + spacing
            if x >= maxWidth {
                y += moduleHeight + spacing
                x = bounds.minX
            }
        }
        
        var smallIter: Int = 0
        var mediumIter: Int = 0

        // Place a 2x1 if the remaining space will fit it, otherwise place a 1x1
        while mediumIter < mediumModules.count || smallIter < smallModules.count {
            if x + mediumModuleWidth <= maxWidth && mediumIter < mediumModules.count {
                mediumModules[mediumIter].place(at: CGPoint(x: x, y: y),
                                                anchor: .topLeading,
                                                proposal: ProposedViewSize(width: mediumModuleWidth, height: moduleHeight))
                x += mediumModuleWidth + spacing
                mediumIter += 1
            } else if x < maxWidth && smallIter < smallModules.count {
                smallModules[smallIter].place(at: CGPoint(x: x, y: y),
                                              anchor: .topLeading,
                                              proposal: ProposedViewSize(width: smallModuleWidth, height: moduleHeight))
                x += smallModuleWidth + spacing
                smallIter += 1
            } else {
                y += moduleHeight + spacing
                x = bounds.minX
            }
        }
    }
}

#Preview {
    ContentView()
}
