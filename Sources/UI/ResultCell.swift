//
//  ResultCell.swift
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

import Foundation
import UIKit

class ResultCell: UITableViewCell {

    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var latencyLabel: UILabel!
    @IBOutlet weak var curlLabel: UILabel!

    static let reuseIdentifier = String(describing: ResultCell.self)

    var result: XnifferResult? {
        didSet {
            updateWith(result: result)
        }
    }

    var isShowingCurl: Bool = false {
        didSet {
            toggleCurl()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        urlLabel.textColor = .white
        urlLabel.numberOfLines = 0
        curlLabel.textColor = .white
        curlLabel.numberOfLines = 0
        curlLabel.isHidden = true
        latencyLabel.textColor = .white
        backgroundColor = .clear
        selectionStyle = .none
    }

    private func toggleCurl() {
        curlLabel.isHidden = !isShowingCurl
        setNeedsLayout()
        layoutIfNeeded()
    }

    private func updateWith(result: XnifferResult?) {
        guard let result = result else { return }
        let statusCode = result.response?.statusCode ?? 0
        let status = (statusCode >= 200 && statusCode < 300) ? "SUCCESS" : "ERROR"
        urlLabel.text = "\(status): \(statusCode) - \(result.request.url?.absoluteString ?? "NO_URL")"
        latencyLabel.text = "\(String(format: "%.2f", result.latency))ms"
        latencyLabel.textColor = XnifferColors.color(for: result.latency)
        curlLabel.text = result.cURLRepresentation()
    }
}
