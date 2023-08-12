//
//  SegmentUtils.swift
//  SwiftUIPicker
//
//  Created by vulcanlabs-hai on 12/08/2023.
//

import Foundation

class SegmentUtils {
    static func getIndex(of segments: [[Word]], from elementIndex: Int) -> Int {
        var floatIndex: Int = 0
        for i in 0 ..< segments.count {
            let segment = segments[i]
            floatIndex += segment.count
            if floatIndex > elementIndex {
                return i
            }
        }
        
        return 0
    }
    
    static func getStartIndexOfSegment(of segments: [[Word]], from segmentIndex: Int) -> Int {
        var index = 0
        var leftIndex: Int = 0
        while index < segmentIndex {
            let segment = segments[index]
            index += 1
            leftIndex += segment.count
        }
        
        return leftIndex
    }
}
