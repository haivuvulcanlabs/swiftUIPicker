//
//  Word.swift
//  SwiftUIPicker
//
//  Created by vulcanlabs-hai on 12/08/2023.
//

import Foundation
import SwiftUI

class Word: NSObject,ObservableObject {
    var text: String
    init(text: String) {
        self.text = text
    }
    
    var width: CGFloat {
        return text.capitalized.widthOfString(usingFont: .systemFont(ofSize: 12)) + 20
    }
}
