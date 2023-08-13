//
//  OnboardingView.swift
//  SwiftUIDemo
//
//  Created by vulcanlabs-hai on 08/08/2023.
//

import SwiftUI

struct CustomPickerView: View {
    let itemHeight: CGFloat = 48
    let itemPadding: CGFloat = 8
    @ObservedObject var model = SegmentModel.shared
    
    var texts: [Word] {
        
        model.segments.flatMap({$0})
    }

    var body: some View {
        ZStack{
            VStack(alignment: .center, spacing: 25) {
                HStack{
                    Text("+")
                        .foregroundColor(.yellow)
                        .font(.system(size: 20, weight: .bold))
                    Button("split") {
                        model.splitCurrentSegment(at: model.activePageIndex)
                    }
                    .foregroundColor(.red)
                    
                }
                GeometryReader { geometry in
                    AdaptivePagingScrollView(segments: $model.segments,
                                             itemSpacing: itemPadding, itemHeight: itemHeight)
                }
                Spacer()
                
                Text("PAGE INDEX: \(model.activePageIndex) : \(texts[model.activePageIndex].text)")
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
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        CustomPickerView()
    }
}
