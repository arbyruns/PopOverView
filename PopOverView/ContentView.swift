//
//  ContentView.swift
//  PopOverView
//
//  Created by robevans on 4/22/22.
//

import UIKit
import SwiftUI

struct ContentView: View {
    @State var open = false
    @State var popoverSize = CGSize(width: 300, height: 300)
    @State var positionX: CGFloat = 0
    @State var positionY: CGFloat = 0

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0 ..< 15) { item in
                        VStack {
                            WithPopover(
                                showPopover: $open,
                                popoverSize: popoverSize,
                                arrowDirections: [.up],
                                popoverPosition: CGRect(x: 0, y: 0, width: 0, height: 0),
                                content: {
                                    // The view you want to anchor your popover to.
                                    Button(action: {
                                        self.open.toggle()
                                        positionY = geo.frame(in: .named("OuterV")).midY
                                    }) {
                                        SomeView(positionY: self.positionY)
                                            .coordinateSpace(name: "OuterV")
                                    }
                                    .padding()
                                },
                                popoverContent: {
                                    VStack {
                                        Button(action: { self.popoverSize = CGSize(width: 300, height: 600)}) {
                                            Text("Increase size")
                                        }
                                        Button(action: { self.open = false}) {
                                            Text("Close")
                                        }
                                    }
                                })
                        }
                    }
                }
            }
        }
    }
}

struct SomeView: View {
    let positionY: CGFloat

    var body: some View {
        VStack {
            Text("Tap me - \(positionY)")
        }
    }
}

struct WithPopover<Content: View, PopoverContent: View>: View {

    @Binding var showPopover: Bool
    var popoverSize: CGSize? = nil
    var arrowDirections: UIPopoverArrowDirection = [.down]
    var popoverPosition: CGRect = CGRect()
    let content: () -> Content
    let popoverContent: () -> PopoverContent

    var body: some View {
        content()
            .background(
                Wrapper(showPopover: $showPopover, arrowDirections: arrowDirections, popoverSize: popoverSize, popoverPosition: popoverPosition, popoverContent: popoverContent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
    }

    struct Wrapper<PopoverContent: View> : UIViewControllerRepresentable {

        @Binding var showPopover: Bool
        var arrowDirections: UIPopoverArrowDirection
        let popoverSize: CGSize?
        let popoverPosition: CGRect
        let popoverContent: () -> PopoverContent

        func makeUIViewController(context: UIViewControllerRepresentableContext<Wrapper<PopoverContent>>) -> WrapperViewController<PopoverContent> {
            return WrapperViewController(
                popoverSize: popoverSize,
                popoverPosition: popoverPosition,
                permittedArrowDirections: arrowDirections,
                popoverContent: popoverContent) {
                    self.showPopover = false
                }
        }

        func updateUIViewController(_ uiViewController: WrapperViewController<PopoverContent>,
                                    context: UIViewControllerRepresentableContext<Wrapper<PopoverContent>>) {
            uiViewController.updateSize(popoverSize)

            if showPopover {
                uiViewController.showPopover()
            }
            else {
                uiViewController.hidePopover()
            }
        }
    }

    class WrapperViewController<PopoverContent: View>: UIViewController, UIPopoverPresentationControllerDelegate {

        var popoverSize: CGSize?
        var popoverPosition: CGRect?
        let permittedArrowDirections: UIPopoverArrowDirection
        let popoverContent: () -> PopoverContent
        let onDismiss: () -> Void

        var popoverVC: UIViewController?

        required init?(coder: NSCoder) { fatalError("") }
        init(popoverSize: CGSize?,
             popoverPosition: CGRect,
             permittedArrowDirections: UIPopoverArrowDirection,
             popoverContent: @escaping () -> PopoverContent,
             onDismiss: @escaping() -> Void) {
            self.popoverSize = popoverSize
            self.permittedArrowDirections = permittedArrowDirections
            self.popoverContent = popoverContent
            self.onDismiss = onDismiss
            super.init(nibName: nil, bundle: nil)
        }

        override func viewDidLoad() {
            super.viewDidLoad()
        }

        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            return .none // this is what forces popovers on iPhone
        }

        func showPopover() {
            guard popoverVC == nil else { return }
            let vc = UIHostingController(rootView: popoverContent())
            if let size = popoverSize { vc.preferredContentSize = size }
            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            if let popover = vc.popoverPresentationController {
                popover.sourceView = view
                popover.permittedArrowDirections = self.permittedArrowDirections
                popover.sourceRect = self.popoverPosition ?? CGRect(x: 0, y: 0, width: 0, height: 0)
                popover.sourceView = self.view
                popover.delegate = self
            }
            popoverVC = vc
            self.present(vc, animated: true, completion: nil)
        }

        func hidePopover() {
            guard let vc = popoverVC, !vc.isBeingDismissed else { return }
            vc.dismiss(animated: true, completion: nil)
            popoverVC = nil
        }

        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            popoverVC = nil
            self.onDismiss()
        }

        func updateSize(_ size: CGSize?) {
            self.popoverSize = size
            if let vc = popoverVC, let size = size {
                vc.preferredContentSize = size
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
