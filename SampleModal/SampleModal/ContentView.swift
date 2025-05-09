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
                
                NavigationLink(destination: YouTubeStyleModalView()) {
                    ModalOptionRow(title: "YouTubeスタイルのモーダル", 
                                  description: "小さく最小化できる動画アプリ風のモーダル",
                                  icon: "play.rectangle.fill")
                }
                
                NavigationLink(destination: YouTubeCommentModalView()) {
                    ModalOptionRow(title: "YouTubeコメントモーダル", 
                                  description: "背景のコンテンツと相互作用できるボトムシート",
                                  icon: "text.bubble")
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
