//
//  XnifferColors.swift
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

public struct XnifferColors {

    static let red = UIColor(red: 254 / 255, green: 40 / 255, blue: 81 / 255, alpha: 1)
    static let green = UIColor(red: 68 / 255, green: 219 / 255, blue: 94 / 255, alpha: 1)
    static let yellow = UIColor(red: 255 / 255, green: 205 / 255, blue: 0 / 255, alpha: 1)

    static func color(for latency: Double?) -> UIColor {
        guard let latency = latency else { return .white }
        if latency < 250 {
            return XnifferColors.green
        } else if latency >= 250 && latency < 1000 {
            return XnifferColors.yellow
        } else {
            return XnifferColors.red
        }
    }

}
