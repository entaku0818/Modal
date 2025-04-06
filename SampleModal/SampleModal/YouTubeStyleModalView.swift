import SwiftUI

struct YouTubeStyleModalView: View {
    @State private var isModalPresented = false
    @State private var modalHeight: CGFloat = .zero
    @State private var dragOffset: CGFloat = .zero
    @State private var currentState: ModalState = .fullScreen
    
    enum ModalState {
        case fullScreen
        case minimized
        case hidden
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    Text("YouTubeスタイルのモーダル")
                        .font(.largeTitle)
                        .padding(.top)
                    
                    // Explanation
                    Text("YouTubeアプリのような、動画を視聴しながら最小化できるモーダルの実装です。下にスワイプすると小さくなり、再度タップすると全画面に戻ります。")
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    // Button to show modal
                    Button(action: {
                        self.isModalPresented = true
                        self.currentState = .fullScreen
                    }) {
                        Text("YouTubeスタイルモーダルを表示")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                    
                    // Features description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("このモーダルの特徴:")
                            .font(.headline)
                        
                        FeatureRow(iconName: "arrow.down", text: "下にスワイプすると小さくなります")
                        FeatureRow(iconName: "arrow.up", text: "小さい状態で上にスワイプすると元に戻ります")
                        FeatureRow(iconName: "hand.tap", text: "小さい状態でタップすると全画面に戻ります")
                        FeatureRow(iconName: "xmark", text: "最小化状態で右にスワイプすると閉じます")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("YouTubeスタイル")
            .navigationBarTitleDisplayMode(.inline)
            
            // YouTubeスタイルモーダル
            if isModalPresented {
                GeometryReader { geometry in
                    YouTubeStyleModal(
                        isPresented: $isModalPresented,
                        currentState: $currentState,
                        dragOffset: $dragOffset,
                        screenSize: geometry.size
                    )
                    .onAppear {
                        modalHeight = geometry.size.height
                    }
                }
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: isModalPresented)
            }
        }
    }
}

struct YouTubeStyleModal: View {
    @Binding var isPresented: Bool
    @Binding var currentState: YouTubeStyleModalView.ModalState
    @Binding var dragOffset: CGFloat
    let screenSize: CGSize
    
    @State private var viewOffset: CGFloat = 0
    
    var body: some View {
        let minHeight: CGFloat = 70
        let fullHeight = screenSize.height
        let miniWidth: CGFloat = screenSize.width / 2.5
        
        let currentHeight: CGFloat = {
            switch currentState {
            case .fullScreen:
                return fullHeight
            case .minimized:
                return minHeight
            case .hidden:
                return 0
            }
        }()
        
        let currentWidth: CGFloat = {
            switch currentState {
            case .fullScreen:
                return screenSize.width
            case .minimized:
                return miniWidth
            case .hidden:
                return 0
            }
        }()
        
        ZStack {
            Color.black
                .opacity(currentState == .fullScreen ? 0.5 : 0)
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut, value: currentState)
                .onTapGesture {
                    if currentState == .fullScreen {
                        // タップでモーダルを閉じるのは全画面時のみ
                        withAnimation {
                            currentState = .minimized
                        }
                    }
                }
            
            VStack(spacing: 0) {
                // ビデオヘッダー（赤い部分）
                ZStack {
                    Color.red
                    
                    if currentState == .fullScreen {
                        // 全画面時のコンテンツ
                        VStack {
                            Text("YouTube風モーダル")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            // ダミービデオプレイヤー
                            Image(systemName: "play.rectangle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                                .padding()
                        }
                    } else {
                        // 最小化時のコンテンツ
                        HStack {
                            Image(systemName: "play.rectangle.fill")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            Text("再生中...")
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    isPresented = false
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .padding(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .frame(height: currentState == .fullScreen ? 250 : minHeight)
                
                // 追加コンテンツ（全画面時のみ表示）
                if currentState == .fullScreen {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("動画タイトルがここに表示されます")
                                .font(.headline)
                                .padding(.top)
                            
                            Text("チャンネル名 • 12万回視聴 • 1日前")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Divider()
                            
                            HStack(spacing: 30) {
                                ActionButton(icon: "hand.thumbsup", text: "1.2万")
                                ActionButton(icon: "hand.thumbsdown", text: "表示しない")
                                ActionButton(icon: "arrowshape.turn.up.right", text: "共有")
                                ActionButton(icon: "square.and.arrow.down", text: "保存")
                            }
                            .padding(.vertical, 8)
                            
                            Divider()
                            
                            ForEach(1...5, id: \.self) { index in
                                HStack(spacing: 15) {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 120, height: 70)
                                    
                                    VStack(alignment: .leading) {
                                        Text("関連動画タイトル \(index)")
                                            .font(.subheadline)
                                        
                                        Text("チャンネル名 • \(index)万回視聴")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .padding()
                    }
                    .background(Color.white)
                }
            }
            .background(Color.white)
            .cornerRadius(currentState == .minimized ? 10 : 0)
            .frame(width: currentWidth, height: currentHeight - viewOffset)
            .position(
                x: currentState == .minimized ? screenSize.width - miniWidth/2 - 20 : screenSize.width/2, 
                y: currentState == .minimized ? screenSize.height - minHeight/2 - 20 : screenSize.height/2
            )
            .shadow(radius: currentState == .minimized ? 5 : 0)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        let yTranslation = gesture.translation.height
                        let xTranslation = gesture.translation.width
                        
                        switch currentState {
                        case .fullScreen:
                            // 下方向のドラッグのみ受け付ける
                            if yTranslation > 0 {
                                viewOffset = yTranslation
                            }
                        case .minimized:
                            // 小さい状態では上または右方向のドラッグを受け付ける
                            if yTranslation < 0 {
                                // 上方向のドラッグ
                                viewOffset = yTranslation
                            } else if xTranslation > 0 {
                                // 右方向のドラッグ
                                dragOffset = xTranslation
                            }
                        case .hidden:
                            break
                        }
                    }
                    .onEnded { gesture in
                        let yTranslation = gesture.translation.height
                        let xTranslation = gesture.translation.width
                        
                        switch currentState {
                        case .fullScreen:
                            if yTranslation > 100 {
                                // 下に十分ドラッグされたら最小化
                                withAnimation {
                                    currentState = .minimized
                                    viewOffset = 0
                                }
                            } else {
                                // ドラッグが不十分なら元の状態に戻す
                                withAnimation {
                                    viewOffset = 0
                                }
                            }
                        case .minimized:
                            if yTranslation < -50 {
                                // 上に十分ドラッグされたら全画面に
                                withAnimation {
                                    currentState = .fullScreen
                                    viewOffset = 0
                                }
                            } else if xTranslation > 100 {
                                // 右に十分ドラッグされたら閉じる
                                withAnimation {
                                    isPresented = false
                                    dragOffset = 0
                                }
                            } else {
                                // ドラッグが不十分なら元の状態に戻す
                                withAnimation {
                                    viewOffset = 0
                                    dragOffset = 0
                                }
                            }
                        case .hidden:
                            break
                        }
                    }
            )
            .onTapGesture {
                if currentState == .minimized {
                    withAnimation {
                        currentState = .fullScreen
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ActionButton: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title3)
            
            Text(text)
                .font(.caption)
        }
    }
}

struct FeatureRow: View {
    let iconName: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.red)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    NavigationView {
        YouTubeStyleModalView()
    }
} 