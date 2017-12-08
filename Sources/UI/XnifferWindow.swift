//
//  XnifferWindow.swift
//  Xniffer ( https://github.com/xmartlabs/Xniffer)
//
//  Copyright (c) 2017 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit

class XnifferWindow: UIWindow, XnifferControllerDelegate {

    let xnifferController = XnifferViewController()

    static let widgetFrame: CGRect = {
        let viewWidth = 200.0
        let x = Double(UIScreen.main.bounds.width / 2.0) - viewWidth / 2.0
        let frame = CGRect(x: x, y: 0, width: viewWidth, height: 20)
        return frame
    }()

    static let fullScreenFrame = UIScreen.main.bounds

    var queueCount = 0 {
        didSet {
            updateLatencyLabel()
        }
    }

    var latency: Double? {
        didSet {
            updateLatencyLabel()
        }
    }

    let resultButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        button.backgroundColor = .black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitle("No requests yet", for: .normal)
        button.setTitleColor(.green, for: .normal)
        button.addTarget(self, action: #selector(displayResultController), for: .touchUpInside)
        button.layer.cornerRadius = 10
        return button
    }()

    init() {
        super.init(frame: XnifferWindow.widgetFrame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        addSubview(resultButton)
        backgroundColor = .clear
        clipsToBounds = true
        windowLevel = UIWindowLevelStatusBar + 1
        setupRootViewController()
        xnifferController.setupXniffer()
    }

    @objc func displayResultController() {
        let frame = XnifferWindow.fullScreenFrame
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.rootViewController?.view.frame = frame
                self?.rootViewController?.view.alpha = 1
                self?.frame = frame
                self?.makeKeyAndVisible()
            },
            completion: nil
        )
    }

    func hideResultController() {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.frame = XnifferWindow.widgetFrame
                self?.rootViewController?.view.alpha = 0
            },
            completion: nil
        )
    }

    private func setupRootViewController() {
        xnifferController.windowDelegate = self
        rootViewController = xnifferController
        rootViewController?.view.alpha = 0
    }

    func hideController() {
        hideResultController()
    }

    func updateLatencyLabel() {
        let queueString = "\(queueCount) in queue."
        if let latency = latency {
            resultButton.setTitle("\(queueString) Last: \(String(format: "%.2f", latency))ms", for: .normal)
        } else {
            resultButton.setTitle(queueString, for: .normal)
        }
        resultButton.setTitleColor(XnifferColors.color(for: latency), for: .normal)
    }

    // MARK: XnifferControllerDelegate

    func updateLatency(for result: XnifferResult) {
        latency = result.latency
    }

    func updateQueue(with queueCount: Int) {
        self.queueCount = queueCount
    }
    
}
