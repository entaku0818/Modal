//
//  ContentView.swift
//  SampleModal
//
//  Created by 遠藤拓弥 on 2025/04/05.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: SwiftUIModalView()) {
                    ModalOptionRow(title: "SwiftUIのモーダル", 
                                  description: "SwiftUIのsheet、fullScreenCover修飾子を使用",
                                  icon: "square.on.square")
                }
                
                NavigationLink(destination: UIPresentationModalDemo()) {
                    ModalOptionRow(title: "UIPresentationControllerのモーダル", 
                                  description: "UIKitのプレゼンテーションコントローラーを使用",
                                  icon: "rectangle.portrait.on.rectangle.portrait")
                }
                
                NavigationLink(destination: CustomModalDemo()) {
                    ModalOptionRow(title: "完全に自作するモーダル", 
                                  description: "addSubviewでそれっぽく見せる実装",
                                  icon: "rectangle.stack")
                }
            }
            .navigationTitle("モーダルサンプル")
        }
    }
}

struct ModalOptionRow: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView()
}
