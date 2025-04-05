//
//  SwiftUIModalView.swift
//  SampleModal
//
//  Created by Takuya Endo on 2025/04/05.
//

import SwiftUI

struct SwiftUIModalView: View {
    @State private var isSheetPresented = false
    @State private var isFullScreenPresented = false
    @State private var detentsSelection = SheetDetentSelection.medium
    
    enum SheetDetentSelection {
        case medium
        case large
        case custom
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Title
                Text("SwiftUIのモーダル")
                    .font(.largeTitle)
                    .padding(.top)
                
                // Sheet (Present as Card)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Sheet (カード状のモーダル)")
                        .font(.headline)
                    
                    Text("iOS 13から導入された基本的なモーダル表示方法。\n.sheet修飾子を使用して表示します。")
                        .font(.body)
                    
                    Picker("サイズ選択", selection: $detentsSelection) {
                        Text("Medium").tag(SheetDetentSelection.medium)
                        Text("Large").tag(SheetDetentSelection.large)
                        Text("カスタム").tag(SheetDetentSelection.custom)
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical)
                    
                    Button(action: {
                        isSheetPresented = true
                    }) {
                        Text("Sheetモーダルを表示")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Full Screen Cover
                VStack(alignment: .leading, spacing: 10) {
                    Text("FullScreenCover (全画面モーダル)")
                        .font(.headline)
                    
                    Text("iOS 14から導入された全画面モーダル。\n.fullScreenCover修飾子を使用して表示します。")
                        .font(.body)
                    
                    Button(action: {
                        isFullScreenPresented = true
                    }) {
                        Text("全画面モーダルを表示")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("SwiftUIモーダル")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isSheetPresented) {
            ModalContentView(title: "Sheetモーダル", color: .blue, isPresented: $isSheetPresented)
                .presentationDetents(getDetentSet())
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $isFullScreenPresented) {
            ModalContentView(title: "FullScreenCoverモーダル", color: .green, isPresented: $isFullScreenPresented)
        }
    }
    
    private func getDetentSet() -> Set<PresentationDetent> {
        switch detentsSelection {
        case .medium:
            return [.medium]
        case .large:
            return [.large]
        case .custom:
            return [.height(200), .medium, .large]
        }
    }
}

struct ModalContentView: View {
    let title: String
    let color: Color
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Spacer()
            
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 70))
                .foregroundColor(color)
            
            Text("これはSwiftUIモーダルの内容です")
                .font(.title2)
            
            Text("実装が簡単で使いやすい点が特徴です")
                .font(.body)
                .foregroundColor(.gray)
            
            Spacer()
            
            Button(action: {
                isPresented = false
            }) {
                Text("閉じる")
                    .frame(width: 200)
                    .padding()
                    .background(color)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom, 30)
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        SwiftUIModalView()
    }
} 