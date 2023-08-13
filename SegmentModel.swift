//
//  SegmentModel.swift
//  SwiftUIPicker
//
//  Created by vulcanlabs-hai on 13/08/2023.
//

import SwiftUI

class SegmentModel: ObservableObject {
    static let shared = SegmentModel()
    
    var texts: [[String]] = [["However","you","shouldn’t"], ["pass","a","range","that"], ["changes","at", "runtime."], ["If","you","use","a","variable"], ["that","changes"], ["at","runtime","to","define","the ","range"], ["the","list","displays","views","according"], ["to","the","initial","range","and"], ["ignores","any","subsequent"], ["updates","to","the","range."]]
    @Published var segments: [[Word]]
    @Published var activePageIndex: Int = 0
    @Published var activeSegmentIndex: Int = 0
    
    @Published var currentScrollOffset: CGFloat = 0
    
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
    
    func splitCurrentSegment(at index: Int){
        let segmentIndex = SegmentUtils.getIndex(of: segments, from: index)
        let startIndex = SegmentUtils.getStartIndexOfSegment(of: segments, from: segmentIndex)
        guard startIndex != index else { return }
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
        
        activeSegmentIndex += 1
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

