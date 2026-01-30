////
////  MessageRoundedCorners.swift
////  MoodCast
////
////  Created by Jacob Lucas on 5/31/25.
////
//
//import SwiftUI
//
//struct MessageRoundedCorners: Shape {
//    var topLeading: CGFloat = 0.0
//    var topTrailing: CGFloat = 0.0
//    var bottomLeading: CGFloat = 0.0
//    var bottomTrailing: CGFloat = 0.0
//    
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        
//        let w = rect.size.width
//        let h = rect.size.height
//        
//        let tr = min(min(self.topTrailing, h/2), w/2)
//        let tl = min(min(self.topLeading, h/2), w/2)
//        let bl = min(min(self.bottomLeading, h/2), w/2)
//        let br = min(min(self.bottomTrailing, h/2), w/2)
//        
//        path.move(to: CGPoint(x: w / 2.0, y: 0))
//        path.addLine(to: CGPoint(x: w - tr, y: 0))
//        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
//                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
//        
//        path.addLine(to: CGPoint(x: w, y: h - br))
//        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
//                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
//        
//        path.addLine(to: CGPoint(x: bl, y: h))
//        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
//                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
//        
//        path.addLine(to: CGPoint(x: 0, y: tl))
//        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
//                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
//        path.closeSubpath()
//        
//        return path
//    }
//}
