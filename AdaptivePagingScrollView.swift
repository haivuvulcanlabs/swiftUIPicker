//
//  AdaptivePagingScrollView.swift
//  SwiftUIDemo
//
//  Created by vulcanlabs-hai on 08/08/2023.
//

import SwiftUI
import Combine

struct AdaptivePagingScrollView: View {
    private let borderWidth: CGFloat = 4
    private let itemSpacing: CGFloat
    private let itemHeight: CGFloat
    @State var leadingOffset: CGFloat = 0
    @State var traingOffset: CGFloat = 0
        
    @State private var hightlightWidth: CGFloat = 100
    @State private var hightlightXOffset: CGFloat = 0
    
    @Binding var segments: [[Word]]
    @State private var scrolling: Bool = false
    @State private var lastValue: CGFloat = 0
    @State var segmentBoxWidths: [CGFloat] = []
    
    var texts: [Word] {
        return segments.flatMap({$0})
    }
    
    var model = SegmentModel.shared
    let detector: CurrentValueSubject<CGFloat, Never>
    let publisher: AnyPublisher<CGFloat, Never>
    
    
    init(segments: Binding<[[Word]]>,
                  itemSpacing: CGFloat,
                  itemHeight: CGFloat) {
        
        self._segments = segments
        self.itemSpacing = itemSpacing
        self.itemHeight = itemHeight
        debugPrint("hai test init")
        
        let detector = CurrentValueSubject<CGFloat, Never>(0)
        self.publisher = detector
            .dropFirst()
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
        self.detector = detector
    }
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollViewWithOffset(.horizontal, showsIndicators: false, onScroll: handleScroll) {
                ZStack {
                    HStack(alignment: .center, spacing: itemSpacing) {
                        //leftView
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .frame(width: leadingOffset, height: itemHeight)
                            .id(-1)
                        
                        ForEach(Array(texts.enumerated()), id: \.offset) { index, text in
                            let itemWidth = text.width
                            GeometryReader { screen in
                                SimpleTextView(word: self.texts[index], itemHeight: itemHeight, index: index, onTapped: handleTapped)
                                
                            }
                            .frame(width: CGFloat(itemWidth), height: itemHeight)
                        }
                        
                        //rightView
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .frame(width: traingOffset, height: itemHeight)
                        
                    }
                    HStack{
                        HightLightRectView(widths: $segmentBoxWidths, spacing: itemSpacing)
                            .frame(width: hightlightWidth, height: itemHeight)
                            .offset(x: hightlightXOffset, y: 0)
                        Spacer()
                    }
                }
                .onReceive(publisher) {
                    print("Stopped on: \($0)")
                    
                    guard lastValue != $0 else { return }
                    lastValue = $0
                    var newPageIndex = countPageIndex(for: lastValue)
                    newPageIndex = min(newPageIndex, texts.count - 1)
                    
                    debugPrint("Scrollview onEnded ->\(newPageIndex)")
                    model.activePageIndex = newPageIndex
           
                    withAnimation{
                        scrollView.scrollTo(newPageIndex , anchor: .center)
                        
                    }
               
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.scrolling = false
                    }
                }
                .onChange(of: model.activePageIndex ){ newValue in
                    debugPrint("hai test index \(newValue) -> \(hightlightWidth)")
                    let newSegmentIndex = SegmentUtils.getIndex(of: segments, from: newValue)
                    if newSegmentIndex != model.activeSegmentIndex {
                        model.activeSegmentIndex = newSegmentIndex
                    }
                    
                    self.updateHighlightBox()

                    withAnimation {
                        scrollView.scrollTo(model.activePageIndex, anchor: .center)
                    }
                }
                .onChange(of: model.activeSegmentIndex ){ newValue in
                    self.updateHighlightBox()
                }
            }
        }
        .onAppear {
            debugPrint("hai test appear")
            self.leadingOffset = UIScreen.main.bounds.width / 2 - self.texts[0].width/2 - itemSpacing;
            self.traingOffset = UIScreen.main.bounds.width / 2 - (self.texts.last?.width ?? 10)/2 - itemSpacing;

            self.updateHighlightBox()
        }
        .background(Color.black.opacity(0.00001))
    }
    
    
    private func countOffset(for pageIndex: Int) -> CGFloat {
        guard pageIndex >= 0, pageIndex < texts.count else {
            return leadingOffset
        }
        
        var activePageOffset: CGFloat = 0
        for i in 0 ..< pageIndex {
            activePageOffset += texts[i].width + itemSpacing + 0.11
        }
        
        return -activePageOffset
    }
    
    private func countPageIndex(for offset: CGFloat) -> Int {
        
        let itemsAmount = texts.count
        guard itemsAmount > 0 else { return 0 }
        
        let offset = countLogicalOffset(offset)
        
        var activePageOffset: CGFloat = -texts[0].width/2 - itemSpacing
        var floatIndex  = 0
        debugPrint("count page index offset \(offset)")
        for i in 0 ..< texts.count {
            activePageOffset += texts[i].width
            
            if i > 0 {
                activePageOffset += itemSpacing
                
            }
            debugPrint("count page index activePageOffset \(activePageOffset)")
            
            floatIndex = i
            if activePageOffset >= offset{
                break
            }
        }
        
        var index = floatIndex
        
        if max(index, 0) > itemsAmount {
            index = itemsAmount
        }
        
        return min(max(index, 0), itemsAmount - 1)
    }
    
    private func countCurrentScrollOffset() -> CGFloat {
        return countOffset(for: model.activePageIndex)
    }
    
    private func countLogicalOffset(_ trueOffset: CGFloat) -> CGFloat {
        return (trueOffset) * -1.0
    }
    
    func getHighlightWidth(from index: Int, name: String) -> CGFloat {
        var hilightWidth: CGFloat = 0
        guard index >= 0, index < texts.count else {
            return 0
        }
        
        let segmentIndex = SegmentUtils.getIndex(of: segments, from: model.activePageIndex)
        let segment = segments[segmentIndex]
        
        //        var width: CGFloat = 0
        for word in segment {
            hilightWidth +=  word.width
        }
        hilightWidth += itemSpacing * CGFloat(segment.count - 1)
        debugPrint("number of block \(segmentIndex)   -> \(hilightWidth)")
        return hilightWidth
    }
    
    func updateHighlightBox() {
        var leftOffset: CGFloat = 0
        
        var index = 0
        while index < model.activeSegmentIndex {
            let segment = segments[index]
            for word in segment {
                leftOffset += word.width + itemSpacing
            }
            index += 1
        }
        let borderPadding: CGFloat = 3

        hightlightXOffset = leftOffset + leadingOffset + itemSpacing - borderWidth - borderPadding
        
        
        hightlightWidth =  self.getHighlightWidth(from: model.activePageIndex , name: "left") + borderWidth*2 + borderPadding * 2
        
        
        let startIndex = SegmentUtils.getStartIndexOfSegment(of: segments, from: model.activeSegmentIndex)
        let segment = segments[model.activeSegmentIndex]
        segmentBoxWidths = Array(texts[startIndex..<(startIndex + segment.count)]).compactMap({$0.width})
        
        debugPrint("hai updateHighlightBox  \(startIndex) -> \(model.activeSegmentIndex) \(segment.compactMap({$0.text})) ->\(segments.count)")

    }
    
    func handleTapped(_ index: Int) {
        model.updateWord(at: index, with: "new work")
        model.activePageIndex = index
    }
    
    func handleScroll(_ offset: CGPoint) {
        if !scrolling {
            scrolling = true
        }
        detector.send(offset.x)
    }
}

