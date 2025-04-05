//
//  UIPresentationModalDemo.swift
//  SampleModal
//
//  Created by Takuya Endo on 2025/04/05.
//

import SwiftUI
import UIKit

struct UIPresentationModalDemo: View {
    @State private var isModalPresented = false
    @State private var presentationStyle: UIModalPresentationStyle = .automatic
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Title
                Text("UIPresentationControllerのモーダル")
                    .font(.largeTitle)
                    .padding(.top)
                
                // Explanation
                Text("UIKitのUIPresentationControllerを使用したモーダル表示です。UIViewControllerRepresentableプロトコルを使用してSwiftUIと連携しています。")
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                // Presentation Style Selection
                VStack(alignment: .leading) {
                    Text("プレゼンテーションスタイル")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    Picker("Presentation Style", selection: $presentationStyle) {
                        Text("Automatic").tag(UIModalPresentationStyle.automatic)
                        Text("PageSheet").tag(UIModalPresentationStyle.pageSheet)
                        Text("FormSheet").tag(UIModalPresentationStyle.formSheet)
                        Text("OverFullScreen").tag(UIModalPresentationStyle.overFullScreen)
                        Text("Custom").tag(UIModalPresentationStyle.custom)
                    }
                    .pickerStyle(.inline)
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Show Modal Button
                Button(action: {
                    isModalPresented = true
                }) {
                    Text("UIKit モーダルを表示")
                        .frame(width: 250)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
                
                // Description of Selected Style
                VStack(alignment: .leading) {
                    Text("選択したスタイルの説明:")
                        .font(.headline)
                    
                    Text(descriptionForStyle(presentationStyle))
                        .padding(.top, 5)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("UIKit プレゼンテーション")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isModalPresented) {
            UIKitModalWrapper(
                isPresented: $isModalPresented,
                presentationStyle: presentationStyle
            )
        }
    }
    
    private func descriptionForStyle(_ style: UIModalPresentationStyle) -> String {
        switch style {
        case .automatic:
            return "自動: システムが最適なスタイルを選択します。iOS 13以降では通常PageSheetになります。"
        case .pageSheet:
            return "PageSheet: 画面の上部からスライドダウンするカード形式のモーダル。下のビューは暗くなります。"
        case .formSheet:
            return "FormSheet: ページシートより小さい、iPadでよく使われるモーダル。中央に表示されます。"
        case .overFullScreen:
            return "OverFullScreen: 下のビューを隠さずに全画面で表示されるモーダル。透過効果などに使用できます。"
        case .custom:
            return "カスタム: UIPresentationControllerのサブクラスを使って、独自のトランジションとサイズを定義できます。"
        default:
            return "説明なし"
        }
    }
}

// UIKitモーダルをSwiftUIで使用するためのラッパー
struct UIKitModalWrapper: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var presentationStyle: UIModalPresentationStyle
    
    func makeUIViewController(context: Context) -> UIViewController {
        let hostingController = UIHostingController(rootView: HostedModalContent(isPresented: $isPresented))
        
        let presentingVC = UIViewController()
        presentingVC.view.backgroundColor = .clear
        
        return presentingVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            let hostingController = UIHostingController(rootView: HostedModalContent(isPresented: $isPresented))
            
            // カスタムスタイルの場合、カスタムプレゼンテーションコントローラーを設定
            if presentationStyle == .custom {
                hostingController.transitioningDelegate = context.coordinator
            }
            
            hostingController.modalPresentationStyle = presentationStyle
            
            // アニメーションの設定
            let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
            
            uiViewController.present(hostingController, animated: true)
        } else if !isPresented && uiViewController.presentedViewController != nil {
            uiViewController.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIViewControllerTransitioningDelegate {
        // カスタムトランジション用のプレゼンテーションコントローラー
        func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
            CustomPresentationController(presentedViewController: presented, presenting: presenting)
        }
    }
}

// カスタムプレゼンテーションコントローラー
class CustomPresentationController: UIPresentationController {
    private let dimView = UIView()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimViewTapped))
        dimView.addGestureRecognizer(tapGesture)
    }
    
    @objc func dimViewTapped() {
        presentedViewController.dismiss(animated: true)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView else { return }
        
        dimView.alpha = 0
        dimView.frame = containerView.bounds
        containerView.addSubview(dimView)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.dimView.alpha = 1
        })
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.dimView.alpha = 0
        }, completion: { [weak self] _ in
            self?.dimView.removeFromSuperview()
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        guard let containerView = self.containerView else { return }
        
        dimView.frame = containerView.bounds
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = self.containerView else { return .zero }
        
        // モーダルのサイズをカスタマイズ
        let width = containerView.bounds.width * 0.8
        let height = containerView.bounds.height * 0.6
        let xOffset = (containerView.bounds.width - width) / 2
        let yOffset = (containerView.bounds.height - height) / 2
        
        return CGRect(x: xOffset, y: yOffset, width: width, height: height)
    }
}

// モーダルの中身
struct HostedModalContent: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("UIKitプレゼンテーションモーダル")
                    .font(.headline)
                    .foregroundColor(.black)
                
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
            
            Image(systemName: "gear")
                .font(.system(size: 70))
                .foregroundColor(.orange)
            
            Text("UIKitモーダルの内容です")
                .font(.title2)
                .foregroundColor(.black)
            
            Text("UIViewControllerRepresentableを\n使用してSwiftUIと連携しています")
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(.gray)
            
            Text("UIModalPresentationStyleを\n様々なスタイルで試すことができます")
                .multilineTextAlignment(.center)
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 10)
            
            Spacer()
            
            Button(action: {
                isPresented = false
            }) {
                Text("閉じる")
                    .frame(width: 200)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom, 30)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}

#Preview {
    NavigationView {
        UIPresentationModalDemo()
    }
} 