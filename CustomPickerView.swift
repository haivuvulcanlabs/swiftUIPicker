//
//  OnboardingView.swift
//  SwiftUIDemo
//
//  Created by vulcanlabs-hai on 08/08/2023.
//

import SwiftUI

struct CustomPickerView: View {
    
    @State private var activePageIndex: Int = 0
    @State private var activeSegmentIndex: Int = 0

    @State private var currentScrollOffset: CGFloat = 0
   
    let itemHeight: CGFloat = 48
    let itemPadding: CGFloat = 10
    
    @State var segments: [[String]] = [["However","you","shouldn’t"], ["pass","a","range","that"], ["changes","at", "runtime."], ["If","you","use","a","variable"], ["that","changes"], ["at","runtime","to","define","the ","range"], ["the","list","displays","views","according"], ["to","the","initial","range","and"], ["ignores","any","subsequent"], ["updates","to","the","range."]]
    var texts: [String] {
        
        return ["However", "you", "shouldn’t", "pass", "a", "range", "that", "changes", "at", "runtime.", "If", "you", "use", "a", "variable", "that", "changes", "at", "runtime", "to", "define", "the ", "range", "the", "list", "displays", "views", "according", "to", "the", "initial", "range", "and", "ignores", "any", "subsequent", "updates", "to", "the", "range."]
    }
    
    
    var body: some View {
        ZStack{
            VStack(alignment: .center, spacing: 25) {
                HStack{
                    Text("+")
                        .foregroundColor(.yellow)
                        .font(.system(size: 20, weight: .bold))
                    Button("split") {
                        splitCurrentSegment()
                    }
                    .foregroundColor(.red)
                    
                }
                GeometryReader { geometry in
                    AdaptivePagingScrollView(segments: $segments, currentPageIndex: $activePageIndex, activeSegmentIndex: $activeSegmentIndex, currentScrollOffset: $currentScrollOffset,
                                             itemSpacing: itemPadding, itemHeight: itemHeight) {
                        
                        ForEach(Array(texts.enumerated()), id: \.offset) { index, text in
                            let itemWidth = text.capitalized.textWidth
                            GeometryReader { screen in
                                SimpleTextView(card: text, width: self.texts[index].capitalized.textWidth, itemHeight: itemHeight
                                               , index: index, currentPageIndex: self.$activePageIndex)
                            }
                            .frame(width: CGFloat(itemWidth), height: itemHeight)
                        }
                    }
                }
                
                Spacer()
                
                Text("PAGE INDEX: \(self.activePageIndex) : \(texts[self.activePageIndex])")
                    .foregroundColor(.blue)
                    .font(Font.system(size: 25))
                
                
            }
            
            VStack {
                HStack {
                    Spacer()
                    Rectangle()
                        .fill(.blue)
                        .contentShape(Rectangle())
                        .frame(width: 2, height: 100)
                        .offset(y:30)
                    Spacer()
                }
                Spacer()
            }
        }
    }

    func splitCurrentSegment() {
        let segmentIndex = SegmentUtils.getIndex(of: segments, from: activePageIndex)
        let startIndex = SegmentUtils.getStartIndexOfSegment(of: segments, from: segmentIndex)
        guard startIndex != activePageIndex else { return }
        let segment = segments[segmentIndex]
        let middleIndex = activePageIndex - startIndex
        let firstHaft:[String] = Array(segment[0..<middleIndex])
        let secondHaft:[String] = Array(segment[middleIndex..<segment.count])
        
        segments.remove(at: segmentIndex)
        if !firstHaft.isEmpty {
            segments.insert(firstHaft, at: segmentIndex)
        }
        
        if !secondHaft.isEmpty {
            segments.insert(secondHaft, at: segmentIndex + 1)
        }
        activeSegmentIndex += 1
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        CustomPickerView()
    }
}
