//
//  SimpleTextView.swift
//  SwiftUIDemo
//
//  Created by vulcanlabs-hai on 08/08/2023.
//

import SwiftUI
import UIKit

struct SimpleTextView: View {
    
    var card: String
    var width: CGFloat
    var itemHeight: CGFloat
    var index: Int
    @Binding var currentPageIndex: Int
    
    var body: some View {
        VStack {
           
            
            Button {
                currentPageIndex = index
            } label: {
                Text(card.capitalized)
                    .foregroundColor((currentPageIndex) == index ? .black : .white)
                    .font(.system(size: 12, weight: .regular))
                    .frame(width: CGFloat(width), height: itemHeight-16)
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
    
    var textWidth: CGFloat {
        return self.widthOfString(usingFont: .systemFont(ofSize: 12)) + 20
    }
}
