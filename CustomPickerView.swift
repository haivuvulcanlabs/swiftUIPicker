//
//  OnboardingView.swift
//  SwiftUIDemo
//
//  Created by vulcanlabs-hai on 08/08/2023.
//

import SwiftUI

class SegmentModel: ObservableObject {
    var texts: [[String]] = [["However","you","shouldn’t"], ["pass","a","range","that"], ["changes","at", "runtime."], ["If","you","use","a","variable"], ["that","changes"], ["at","runtime","to","define","the ","range"], ["the","list","displays","views","according"], ["to","the","initial","range","and"], ["ignores","any","subsequent"], ["updates","to","the","range."]]
    @Published var segments: [[Word]]
    
    init() {
        var indexedSegments: [[Word]] = []
        for i in 0 ..< texts.count {
            
            let segment = texts[i]
            
            var indexedSegment: [Word] = []
            for j in 0 ..< segment.count {
                let text = segment[j]
                let word = Word(text: text)
                indexedSegment.append(word)
            }
            
            indexedSegments.append(indexedSegment)
        }
        segments = indexedSegments
    }
    
    func splitCurrentSegment(at index: Int) -> Bool{
        let segmentIndex = SegmentUtils.getIndex(of: segments, from: index)
        let startIndex = SegmentUtils.getStartIndexOfSegment(of: segments, from: segmentIndex)
        guard startIndex != index else { return false }
        let segment = segments[segmentIndex]
        let middleIndex = index - startIndex
        let firstHaft:[Word] = Array(segment[0..<middleIndex])
        let secondHaft:[Word] = Array(segment[middleIndex..<segment.count])
        
        segments.remove(at: segmentIndex)
        if !firstHaft.isEmpty {
            segments.insert(firstHaft, at: segmentIndex)
        }
        
        if !secondHaft.isEmpty {
            segments.insert(secondHaft, at: segmentIndex + 1)
        }
        
        return true
    }
    
    func updateWord(at index: Int, with newWord: String) {
        
        var floatIndex: Int = 0
       var shouldBreak = false
        for i in 0 ..< segments.count {
            
            let segment = segments[i]
            
            for j in 0 ..< segment.count {
                if floatIndex == index {
                    segments[i][j].text = newWord
                    shouldBreak = true
                    break
                }
                floatIndex += 1
            }
            if shouldBreak {
                break
            }
        }
    }
    
    func removeWord(at index: Int) {
        
        var floatIndex: Int = 0
        var shouldBreak = false
        for i in 0 ..< segments.count {
            
            let segment = segments[i]
            
            for j in 0 ..< segment.count {
                if floatIndex == index {
                    let removedWord = segments[i].remove(at: j)
                    if segments[i].isEmpty {
                        segments.remove(at: i)
                    }
                    debugPrint("remove \(removedWord.text) \(segments[i].compactMap({$0.text}))")
                    shouldBreak = true
                    break
                }
                floatIndex += 1
            }
            if shouldBreak {
                break
            }
        }
    }
    
    func updateSegment(at index: Int, with segment: [Word]) {
        guard index >= 0, index < segment.count else {
            return
        }
        
        segments[index] = segment
    }
    
}

struct CustomPickerView: View {
    
    @State private var activePageIndex: Int = 0
    @State private var activeSegmentIndex: Int = 0
    
    @State private var currentScrollOffset: CGFloat = 0
    
    let itemHeight: CGFloat = 48
    let itemPadding: CGFloat = 8
    @ObservedObject var model = SegmentModel()
    
    var texts: [Word] {
        
        model.segments.flatMap({$0})
    }
    
    init() {
        self.activePageIndex = 0
        self.activeSegmentIndex = 0
        self.currentScrollOffset = 0
        
        
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
                    AdaptivePagingScrollView(segments: $model.segments, currentPageIndex: $activePageIndex, activeSegmentIndex: $activeSegmentIndex, currentScrollOffset: $currentScrollOffset,
                                             itemSpacing: itemPadding, itemHeight: itemHeight) {
                        
                        
                        
                        
                        ForEach(Array(texts.enumerated()), id: \.offset) { index, text in
                            let itemWidth = text.width
                            GeometryReader { screen in
                                SimpleTextView(word: self.texts[index], itemHeight: itemHeight, index: index
                                               , currentPageIndex: self.$activePageIndex, onTapped: handleTapped)
                                
                            }
                            .frame(width: CGFloat(itemWidth), height: itemHeight)
                        }
                    }
                }
                
                Spacer()
                
                Text("PAGE INDEX: \(self.activePageIndex) : \(texts[self.activePageIndex].text)")
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
        let isSplited = model.splitCurrentSegment(at: activePageIndex)
        guard isSplited else { return }
        activeSegmentIndex += 1
    }
    
    
    func handleTapped(_ index: Int) {
        model.updateWord(at: index, with: "new work")
        activePageIndex = index
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        CustomPickerView()
    }
}
