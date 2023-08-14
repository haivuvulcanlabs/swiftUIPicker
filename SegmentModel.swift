//
//  SegmentModel.swift
//  SwiftUIPicker
//
//  Created by vulcanlabs-hai on 13/08/2023.
//

import SwiftUI

class SegmentModel: ObservableObject {
    static let shared = SegmentModel()
    
    @Published var segments: [[Word]]
    @Published var activePageIndex: Int = 0
    @Published var activeSegmentIndex: Int = 0
    
    @Published var currentScrollOffset: CGFloat = 0
    
    init(texts: [[String]] = []) {
        
        let texts1: [[String]] = [["If","you","use","a","variable"], ["that","changes"], ["at","runtime","to","define","the ","range"]]
        let texts2: [[String]] = [["However","you","shouldn’t"], ["pass","a","range","that"], ["changes","at", "runtime."], ["ignores","any","subsequent"], ["updates","to","the","range."]]
        let texts3: [[String]] = [["changes","at", "runtime."], ["If","you","use","a","variable"], ["that","changes"], ["at","runtime","to","define","the ","range"], ["the","list","displays","views","according"], ["to","the","initial","range","and"], ["ignores","any","subsequent"]]

      segments = []
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.segments = self.initSegments(from: texts1)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.segments = self.initSegments(from: texts2)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            self.segments = self.initSegments(from: texts3)
        }
    }
    
    func initSegments(from newTexts: [[String]]) -> [[Word]]{
        var indexedSegments: [[Word]] = []
        for i in 0 ..< newTexts.count {
            
            let segment = newTexts[i]
            
            var indexedSegment: [Word] = []
            for j in 0 ..< segment.count {
                let text = segment[j]
                let word = Word(text: text)
                indexedSegment.append(word)
            }
            
            indexedSegments.append(indexedSegment)
        }
//        segments = indexedSegments
        
        return indexedSegments
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
    
    func addNewSegment( segment: [Word]) {
        segments.append(segment)
    }
    
    func addNewWord(word: Word) {
        let segment: [Word] = [word]
        segments.append(segment)
    }
    
}

