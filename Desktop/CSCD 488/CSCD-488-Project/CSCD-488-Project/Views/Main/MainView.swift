//
//  MainView.swift
//  CSCD-488-Project
//
//  Created by Jacob Lucas on 2/27/25.
//

import SwiftUI

struct MainView: View {
    @State var index: Int = 0
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch index {
                case 0:
                    PodcastSelectionView()
                case 1:
                    VStack {
                        Spacer()
                        Text("SEARCH")
                        Spacer()
                    }
                case 2:
                    VStack {
                        Spacer()
                        Text("ALERTS")
                        Spacer()
                    }
                case 3:
                    VStack {
                        Spacer()
                        Text("PROFILE")
                        Spacer()
                    }
                default:
                    EmptyView()
                }
            }

            Menu(index: $index)
        }
    }
}

#Preview {
    MainView()
}
