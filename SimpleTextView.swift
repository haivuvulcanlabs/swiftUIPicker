//
//  SimpleTextView.swift
//  SwiftUIDemo
//
//  Created by vulcanlabs-hai on 08/08/2023.
//

import SwiftUI
import UIKit

struct SimpleTextView: View {
    
    var word: Word
    var itemHeight: CGFloat
    var index: Int
    let onTapped: TappedAction?

    public typealias TappedAction = (_ index: Int) -> Void
    
    var body: some View {
        VStack {
            Button {
                onTapped?(index)
            } label: {
                Text(word.text.capitalized)
                    .foregroundColor((SegmentModel.shared.activePageIndex) == index ? .black : .white)
                    .font(.system(size: 12, weight: .regular))
                    .frame(width: word.width, height: itemHeight-16)
                    .background {
                        Color.gray
                    }
            }
        }
        .frame( height: itemHeight)
    }
}

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}
