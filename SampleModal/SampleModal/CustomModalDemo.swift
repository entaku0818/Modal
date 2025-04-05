//
//  CustomModalDemo.swift
//  SampleModal
//
//  Created by Takuya Endo on 2025/04/05.
//

import SwiftUI
import UIKit

struct CustomModalDemo: View {
    @State private var isModalPresented = false
    @State private var animationType: AnimationType = .fade
    @State private var customizeOptions = CustomizeOptions()
    
    enum AnimationType: String, CaseIterable, Identifiable {
        case fade = "フェード"
        case slideUp = "スライドアップ"
        case slideDown = "スライドダウン"
        case scale = "スケール"
        case bounce = "バウンス"
        
        var id: AnimationType { self }
    }
    
    struct CustomizeOptions {
        var cornerRadius: Double = 20
        var backgroundOpacity: Double = 0.7
        var closeOnTapOutside: Bool = true
        var modalWidth: Double = 0.9 // 画面幅に対する比率
        var modalHeight: Double = 0.6 // 画面高さに対する比率
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Title
                Text("完全自作モーダル")
                    .font(.largeTitle)
                    .padding(.top)
                
                // Explanation
                Text("addSubviewを使用して完全にカスタマイズされたモーダル表示です。UIViewをSwiftUI内に統合しています。")
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                // Animation Type Selection
                VStack(alignment: .leading) {
                    Text("アニメーションタイプ")
                        .font(.headline)
                    
                    Picker("アニメーション", selection: $animationType) {
                        ForEach(AnimationType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Customization Options
                VStack(alignment: .leading, spacing: 15) {
                    Text("カスタマイズオプション")
                        .font(.headline)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("角丸の半径: \(Int(customizeOptions.cornerRadius))")
                            Spacer()
                            Text("\(Int(customizeOptions.cornerRadius))")
                                .frame(width: 40)
                        }
                        Slider(value: $customizeOptions.cornerRadius, in: 0...50)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("背景の不透明度: \(customizeOptions.backgroundOpacity, specifier: "%.2f")")
                            Spacer()
                            Text("\(customizeOptions.backgroundOpacity, specifier: "%.2f")")
                                .frame(width: 40)
                        }
                        Slider(value: $customizeOptions.backgroundOpacity, in: 0...1)
                    }
                    
                    Toggle("背景タップで閉じる", isOn: $customizeOptions.closeOnTapOutside)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("モーダル幅（画面比）: \(customizeOptions.modalWidth, specifier: "%.2f")")
                            Spacer()
                            Text("\(customizeOptions.modalWidth, specifier: "%.2f")")
                                .frame(width: 40)
                        }
                        Slider(value: $customizeOptions.modalWidth, in: 0.5...1)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("モーダル高さ（画面比）: \(customizeOptions.modalHeight, specifier: "%.2f")")
                            Spacer()
                            Text("\(customizeOptions.modalHeight, specifier: "%.2f")")
                                .frame(width: 40)
                        }
                        Slider(value: $customizeOptions.modalHeight, in: 0.3...0.9)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Show Modal Button
                Button(action: {
                    isModalPresented = true
                }) {
                    Text("カスタムモーダルを表示")
                        .frame(width: 250)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("カスタムモーダル")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            CustomModalContainer(
                isPresented: $isModalPresented,
                animationType: animationType,
                options: customizeOptions
            )
        )
    }
}

// SwiftUIとUIKitを連携させるViewRepresentable
struct CustomModalContainer: UIViewRepresentable {
    @Binding var isPresented: Bool
    var animationType: CustomModalDemo.AnimationType
    var options: CustomModalDemo.CustomizeOptions
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // すでに保存されているカスタムモーダルがあれば取得
        let container = uiView.subviews.first(where: { $0 is CustomModalContainerView }) as? CustomModalContainerView
        
        if isPresented {
            if container == nil {
                // モーダルを作成して表示
                let newContainer = CustomModalContainerView(
                    frame: uiView.bounds,
                    animationType: animationType,
                    options: options,
                    onDismiss: { isPresented = false }
                )
                
                uiView.addSubview(newContainer)
                
                // 制約を設定
                newContainer.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    newContainer.topAnchor.constraint(equalTo: uiView.topAnchor),
                    newContainer.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
                    newContainer.trailingAnchor.constraint(equalTo: uiView.trailingAnchor),
                    newContainer.bottomAnchor.constraint(equalTo: uiView.bottomAnchor)
                ])
                
                // モーダルを表示
                newContainer.showModal()
            } else {
                // 表示中のモーダルがある場合、設定を更新
                container?.updateOptions(options)
            }
        } else if !isPresented, let container = container {
            // モーダルを閉じる
            container.dismissModal()
        }
    }
}

// UIKitでのカスタムモーダルコンテナビュー
class CustomModalContainerView: UIView {
    private let backgroundView = UIView()
    private let modalView = UIView()
    private let contentView = UIView()
    private var animationType: CustomModalDemo.AnimationType
    private var options: CustomModalDemo.CustomizeOptions
    private let onDismiss: () -> Void
    
    init(frame: CGRect, animationType: CustomModalDemo.AnimationType, options: CustomModalDemo.CustomizeOptions, onDismiss: @escaping () -> Void) {
        self.animationType = animationType
        self.options = options
        self.onDismiss = onDismiss
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // 背景のセットアップ
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0)
        backgroundView.alpha = 0
        addSubview(backgroundView)
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // 背景タップ時のアクション
        if options.closeOnTapOutside {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
            backgroundView.addGestureRecognizer(tapGesture)
        }
        
        // モーダルコンテナのセットアップ
        modalView.backgroundColor = .white
        modalView.layer.cornerRadius = CGFloat(options.cornerRadius)
        modalView.clipsToBounds = true
        backgroundView.addSubview(modalView)
        
        modalView.translatesAutoresizingMaskIntoConstraints = false
        
        // モーダルサイズの設定
        let modalWidth = bounds.width * CGFloat(options.modalWidth)
        let modalHeight = bounds.height * CGFloat(options.modalHeight)
        
        let centerXConstraint = modalView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor)
        let centerYConstraint = modalView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
        let widthConstraint = modalView.widthAnchor.constraint(equalToConstant: modalWidth)
        let heightConstraint = modalView.heightAnchor.constraint(equalToConstant: modalHeight)
        
        NSLayoutConstraint.activate([
            centerXConstraint, centerYConstraint,
            widthConstraint, heightConstraint
        ])
        
        // モーダルコンテンツの設定
        setupModalContent()
        
        // 初期状態の設定 (アニメーション前の状態)
        setupInitialState()
    }
    
    private func setupModalContent() {
        // SwiftUIのコンテンツビューをUIKit側に統合
        let modalContent = UIHostingController(rootView: CustomModalContent(onDismiss: { [weak self] in
            self?.dismissModal()
        }))
        
        addSubview(modalContent.view)
        modalContent.view.backgroundColor = .clear
        modalContent.view.translatesAutoresizingMaskIntoConstraints = false
        
        modalContent.view.frame = modalView.bounds
        modalView.addSubview(modalContent.view)
        
        modalContent.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            modalContent.view.topAnchor.constraint(equalTo: modalView.topAnchor),
            modalContent.view.leadingAnchor.constraint(equalTo: modalView.leadingAnchor),
            modalContent.view.trailingAnchor.constraint(equalTo: modalView.trailingAnchor),
            modalContent.view.bottomAnchor.constraint(equalTo: modalView.bottomAnchor)
        ])
    }
    
    @objc private func backgroundTapped() {
        dismissModal()
    }
    
    private func setupInitialState() {
        switch animationType {
        case .fade:
            modalView.alpha = 0
        case .slideUp:
            modalView.transform = CGAffineTransform(translationX: 0, y: bounds.height)
        case .slideDown:
            modalView.transform = CGAffineTransform(translationX: 0, y: -bounds.height)
        case .scale:
            modalView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            modalView.alpha = 0
        case .bounce:
            modalView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            modalView.alpha = 0
        }
    }
    
    func updateOptions(_ newOptions: CustomModalDemo.CustomizeOptions) {
        options = newOptions
        
        // UIの更新
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(options.backgroundOpacity))
        modalView.layer.cornerRadius = CGFloat(options.cornerRadius)
        
        // サイズの更新
        for constraint in modalView.constraints {
            if constraint.firstAttribute == .width {
                constraint.constant = bounds.width * CGFloat(options.modalWidth)
            } else if constraint.firstAttribute == .height {
                constraint.constant = bounds.height * CGFloat(options.modalHeight)
            }
        }
        
        // ジェスチャーの更新
        backgroundView.gestureRecognizers?.forEach { backgroundView.removeGestureRecognizer($0) }
        if options.closeOnTapOutside {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
            backgroundView.addGestureRecognizer(tapGesture)
        }
    }
    
    func showModal() {
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(options.backgroundOpacity))
        
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 1
        }
        
        switch animationType {
        case .fade:
            UIView.animate(withDuration: 0.5) {
                self.modalView.alpha = 1
            }
            
        case .slideUp:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                self.modalView.transform = .identity
            }
            
        case .slideDown:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                self.modalView.transform = .identity
            }
            
        case .scale:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                self.modalView.transform = .identity
                self.modalView.alpha = 1
            }
            
        case .bounce:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                self.modalView.transform = .identity
                self.modalView.alpha = 1
            }
        }
    }
    
    func dismissModal() {
        switch animationType {
        case .fade:
            UIView.animate(withDuration: 0.3, animations: {
                self.modalView.alpha = 0
                self.backgroundView.alpha = 0
            }, completion: { _ in
                self.removeFromSuperview()
                self.onDismiss()
            })
            
        case .slideUp:
            UIView.animate(withDuration: 0.3, animations: {
                self.modalView.transform = CGAffineTransform(translationX: 0, y: self.bounds.height)
                self.backgroundView.alpha = 0
            }, completion: { _ in
                self.removeFromSuperview()
                self.onDismiss()
            })
            
        case .slideDown:
            UIView.animate(withDuration: 0.3, animations: {
                self.modalView.transform = CGAffineTransform(translationX: 0, y: -self.bounds.height)
                self.backgroundView.alpha = 0
            }, completion: { _ in
                self.removeFromSuperview()
                self.onDismiss()
            })
            
        case .scale:
            UIView.animate(withDuration: 0.3, animations: {
                self.modalView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.modalView.alpha = 0
                self.backgroundView.alpha = 0
            }, completion: { _ in
                self.removeFromSuperview()
                self.onDismiss()
            })
            
        case .bounce:
            UIView.animate(withDuration: 0.3, animations: {
                self.modalView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.modalView.alpha = 0
                self.backgroundView.alpha = 0
            }, completion: { _ in
                self.removeFromSuperview()
                self.onDismiss()
            })
        }
    }
}

// モーダルの内容を表示するSwiftUIビュー
struct CustomModalContent: View {
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("カスタムモーダル")
                    .font(.headline)
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Spacer()
            
            Image(systemName: "sparkles")
                .font(.system(size: 70))
                .foregroundColor(.purple)
            
            Text("完全カスタマイズモーダル")
                .font(.title)
                .foregroundColor(.black)
            
            Text("addSubviewを使用した\n完全にカスタマイズ可能なモーダル")
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(.gray)
            
            Text("アニメーションや見た目をカスタマイズできます")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 10)
            
            Spacer()
            
            Button(action: onDismiss) {
                Text("閉じる")
                    .frame(width: 200)
                    .padding()
                    .background(Color.purple)
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
        CustomModalDemo()
    }
} 