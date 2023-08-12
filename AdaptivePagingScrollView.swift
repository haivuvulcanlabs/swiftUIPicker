//
//  AdaptivePagingScrollView.swift
//  SwiftUIDemo
//
//  Created by vulcanlabs-hai on 08/08/2023.
//

import SwiftUI
import Combine

enum ScrollDirection {
    case leftToRight
    case rightToLeft
}

struct AdaptivePagingScrollView: View {
    private let borderWidth: CGFloat = 4
    private let itemsView: [AnyView]
    private let itemSpacing: CGFloat
    private let itemHeight: CGFloat
    @State var leadingOffset: CGFloat = 0
    @State var traingOffset: CGFloat = 0
    
    private let scrollDampingFactor: CGFloat = 0.2
    
    @Binding var currentPageIndex: Int
    @Binding var segmentIndex: Int
    @State private var hightlightWidth: CGFloat = 100
    @State private var hightlightXOffset: CGFloat = 0
//    @State private var segmentIndex: Int = 0
    @State var highlightIndex: Int = 0
    @State var leftToRight: Bool = true
    
    @Binding var segments: [[String]]
    var texts: [String] {
        return segments.flatMap({$0})
    }
    
    var itemWidths: [CGFloat] {
        return texts.compactMap { s in
            return s.capitalized.textWidth
        }
    }
    
    let detector: CurrentValueSubject<CGFloat, Never>
    let publisher: AnyPublisher<CGFloat, Never>
    @State private var scrolling: Bool = false
    
    @State private var lastValue: CGFloat = 0
    @State var position: CGPoint = .zero
    
    @State var currentWidths: [CGFloat] = []
    
    init<A: View>(segments: Binding<[[String]]>,
                  currentPageIndex: Binding<Int>,
                  activeSegmentIndex: Binding<Int>,
                  currentScrollOffset: Binding<CGFloat>,
                  itemSpacing: CGFloat,
                  itemHeight: CGFloat,
                  @ViewBuilder content: () -> A) {
        
        let views = content()
        self._segments = segments
        self.itemsView = [AnyView(views)]
        self.itemSpacing = itemSpacing
        self.itemHeight = itemHeight
        debugPrint("hai test init")
        
        self._currentPageIndex = currentPageIndex
        self._segmentIndex = activeSegmentIndex

        let detector = CurrentValueSubject<CGFloat, Never>(0)
        self.publisher = detector
            .dropFirst()
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
        self.detector = detector
        

        
    }
    
    func handleScroll(_ offset: CGPoint) {
        if !scrolling {
            scrolling = true
        }
        detector.send(offset.x)
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
                        
                        
                        ForEach(itemsView.indices, id: \.self) { itemIndex in
                            itemsView[itemIndex]
                                .id(itemIndex )
                                .frame(maxWidth: .infinity)
                                
                        }
                        //rightView
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .frame(width: traingOffset, height: itemHeight)
                        
                    }
                    HStack{
                        HightLightRectView(widths: $currentWidths, spacing: itemSpacing)
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
                    self.currentPageIndex = newPageIndex
           
                    withAnimation{
                        scrollView.scrollTo(newPageIndex , anchor: .center)
                        
                    }
               
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.scrolling = false
                    }
                }
                .onChange(of: currentPageIndex ){ newValue in
                    debugPrint("hai test index \(newValue) -> \(hightlightWidth)")
                    let newSegmentIndex = SegmentUtils.getIndex(of: segments, from: newValue)
                    if newSegmentIndex != segmentIndex {
                        segmentIndex = newSegmentIndex
                    }
                    
//                    let offset = countOffset(for: currentPageIndex)
//                    if offset != lastValue {
//                    }
                    withAnimation {
                        scrollView.scrollTo(currentPageIndex, anchor: .center)

                    }
                }
                .onChange(of: segmentIndex ){ newValue in
                        self.updateHighlightBox()
                    
                }
                
            }
        }
        .onAppear {
            debugPrint("hai test appear")
            self.leadingOffset = UIScreen.main.bounds.width / 2 - self.itemWidths[0]/2 - itemSpacing;
            self.traingOffset = UIScreen.main.bounds.width / 2 - (self.itemWidths.last ?? 10)/2 - itemSpacing;

            
            updateHighlightBox()
           
        }
        .background(Color.black.opacity(0.00001))
        
    }
    
    
    private func countOffset(for pageIndex: Int) -> CGFloat {
        guard pageIndex >= 0, pageIndex < itemWidths.count else {
            return leadingOffset
        }
        
        var activePageOffset: CGFloat = 0
        for i in 0 ..< pageIndex {
            activePageOffset += itemWidths[i] + itemSpacing + 0.11
        }
        
        return -activePageOffset
    }
    
    private func countPageIndex(for offset: CGFloat) -> Int {
        
        let itemsAmount = texts.count
        guard itemsAmount > 0 else { return 0 }
        
        let offset = countLogicalOffset(offset)
        
        var activePageOffset: CGFloat = -itemWidths[0]/2 - itemSpacing
        var floatIndex  = 0
        debugPrint("count page index offset \(offset)")
        for i in 0 ..< itemWidths.count {
            activePageOffset += itemWidths[i]
            
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
        return countOffset(for: currentPageIndex)
    }
    
    private func countLogicalOffset(_ trueOffset: CGFloat) -> CGFloat {
        return (trueOffset) * -1.0
    }
    
    func getHighlightWidth(from index: Int, name: String) -> CGFloat {
        var hilightWidth: CGFloat = 0
        guard index >= 0, index < texts.count else {
            return 0
        }
        
        let segmentIndex = SegmentUtils.getIndex(of: segments, from: currentPageIndex)
        let segment = segments[segmentIndex]
        
        //        var width: CGFloat = 0
        for text in segment {
            hilightWidth +=  text.capitalized.widthOfString(usingFont: UIFont.systemFont(ofSize: 12, weight: .regular)) + 20
            
        }
        hilightWidth += itemSpacing * CGFloat(segment.count - 1)
        debugPrint("number of block \(segmentIndex)   -> \(hilightWidth)")
        return hilightWidth
    }
    
    func updateHighlightBox() {
        var leftOffset: CGFloat = 0
        
        var index = 0
        while index < segmentIndex {
            let segment = segments[index]
            for text in segment {
                leftOffset += (text.capitalized.widthOfString(usingFont: .systemFont(ofSize: 12)) + 20) + itemSpacing
            }
            index += 1
        }
        let borderPadding: CGFloat = 3

        hightlightXOffset = leftOffset + leadingOffset + itemSpacing - borderWidth - borderPadding
        
        
        hightlightWidth =  self.getHighlightWidth(from: currentPageIndex , name: "left") + borderWidth*2 + borderPadding * 2
        
        
        let startIndex = SegmentUtils.getStartIndexOfSegment(of: segments, from: segmentIndex)
        let segment = segments[segmentIndex]
        currentWidths = Array(itemWidths[startIndex..<(startIndex + segment.count)])
        
        debugPrint("hai updateHighlightBox  \(startIndex) -> \(segmentIndex) \(segment) ->\(segments.count)")

    }
}

