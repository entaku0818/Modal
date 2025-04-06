import SwiftUI

struct YouTubeCommentModalView: View {
    @State private var isCommentsShown = false
    @State private var commentSheetHeight: CGFloat = 0
    @State private var dragState: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // メインコンテンツ（動画プレーヤーなどのバックグラウンド）
            VStack {
                // ダミービデオプレーヤー
                ZStack {
                    Color.black
                    
                    VStack {
                        Spacer()

                        // 再生/一時停止ボタン - モーダル表示中でも操作可能
                        Button(action: {
                            // 動画の再生・一時停止ロジック
                            print("動画の再生/一時停止ボタンがタップされました")
                        }) {
                            Image(systemName: "play.rectangle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.white)
                                .padding(.vertical, 30)
                        }
                        Spacer()

                    }
                }
                .frame(height: 300)
                
                // ビデオ情報セクション
                VStack(alignment: .leading, spacing: 15) {
                    Text("動画のタイトルがここに表示されます")
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
                    .disabled(isCommentsShown) // アクションボタンはモーダル表示中は無効化
                    
                    Divider()
                    
                    // コメントセクション（タップしてコメントモーダルを表示）
                    Button(action: {
                        withAnimation(.spring()) {
                            isCommentsShown = true
                        }
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("コメント")
                                    .font(.headline)
                                
                                HStack {
                                    Image(systemName: "person.circle")
                                        .foregroundColor(.gray)
                                    
                                    Text("とても良い動画でした！もっと見たいです")
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 10)
                    }
                    .disabled(isCommentsShown) // コメントボタンはモーダル表示中は無効化
                    
                    Spacer()
                }
                .padding(.horizontal)
                


            }
            
            // コメントモーダル（YouTubeスタイルのボトムシート）
            GeometryReader { geometry in
                let videoPlayerHeight: CGFloat = 300
                let modalHeight = geometry.size.height - videoPlayerHeight
                
                VStack(spacing: 0) {
                    // ドラッグハンドル
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 40, height: 5)
                        .cornerRadius(2.5)
                        .padding(.top, 10)
                        .padding(.bottom, 15)
                    
                    // コメントヘッダー
                    HStack {
                        Text("コメント")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                isCommentsShown = false
                                dragState = 0
                            }
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                                .padding(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                    Divider()
                    
                    // コメント入力フィールド
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                        
                        Text("コメントを追加...")
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    // コメントリスト
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            ForEach(1...15, id: \.self) { i in
                                CommentRow(
                                    username: "ユーザー\(i)",
                                    commentText: "これは\(i)番目のコメントです。YouTubeのコメントセクションのようなUIです。",
                                    time: "\(i)時間前",
                                    likes: Int.random(in: 0...1000)
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
                .background(Color.white)
                .cornerRadius(15, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: -2)
                .frame(height: modalHeight)
                .offset(y: isCommentsShown ? dragState + videoPlayerHeight : geometry.size.height)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // 下方向のドラッグのみ処理
                            if value.translation.height > 0 {
                                dragState = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > 100 {
                                // 十分に下にドラッグしたらモーダルを閉じる
                                withAnimation(.spring()) {
                                    isCommentsShown = false
                                    dragState = 0
                                }
                            } else {
                                // 元の位置に戻す
                                withAnimation(.spring()) {
                                    dragState = 0
                                }
                            }
                        }
                )
                .onAppear {
                    commentSheetHeight = modalHeight
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .opacity(isCommentsShown ? 1 : 0)
        }
        .navigationTitle("YouTube風コメントモーダル")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CommentRow: View {
    let username: String
    let commentText: String
    let time: String
    let likes: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading) {
                    Text(username)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Text(commentText)
                .font(.body)
                .padding(.leading, 42)
            
            HStack {
                Spacer()
                    .frame(width: 42)
                
                HStack(spacing: 8) {
                    Button(action: {}) {
                        Image(systemName: "hand.thumbsup")
                    }
                    
                    Text(String(likes))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Button(action: {}) {
                    Image(systemName: "hand.thumbsdown")
                        .padding(.leading, 8)
                }
                
                Button(action: {}) {
                    Text("返信")
                        .font(.caption)
                        .padding(.leading, 16)
                }
            }
            .foregroundColor(.gray)
            .padding(.top, 4)
        }
    }
}


// 角丸の一部だけを適用するための拡張
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    NavigationView {
        YouTubeCommentModalView()
    }
} 
