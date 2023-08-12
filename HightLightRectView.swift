//
//  HightLightRectView.swift
//  SwiftUIPicker
//
//  Created by vulcanlabs-hai on 12/08/2023.
//

import SwiftUI

struct HightLightRectView: View {
    @Binding var widths: [CGFloat]
    let spacing: CGFloat
    var body: some View {
        GeometryReader { goe in
            ZStack() {
                VStack(spacing: 0) {
                    topLineView
                    Spacer()
                   topLineView
                }
                .frame(maxWidth: .infinity)
                
                HStack(spacing: 0){
                    verLineView
                    Spacer()
                    verLineView
                }
            }
            .cornerRadius(4)

            
        }
        
    }
    
    var topLineView : some View {
        
        HStack(spacing: 0, content: {
        ForEach(0 ..< widths.count, id:\.self) { i in
            let width = widths[i]

                RoundedRectangle(cornerRadius: 2)
                    .fill(.blue)
                    .frame(width: width + spacing, height: 4)
            }
        })
    }
    
    var verLineView: some View {
        RoundedRectangle(cornerRadius: 1.5)
            .fill(.blue)
            .frame(width: 4)
    }
}


