//
//  Profiler.swift
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

public struct RequestWrapper {
    
    let id: Int
    let timestamp: DispatchTime
    let request: URLRequest

}

public struct ResponseWrapper {

    let id: Int
    let timestamp: DispatchTime
    let response: HTTPURLResponse
    let session: URLSession

}

public struct ErrorWrapper {

    let id: Int
    let timestamp: DispatchTime
    let session: URLSession
    let response: HTTPURLResponse?
    let error: Error

}

public struct XnifferResult {

    let request: URLRequest
    let response: HTTPURLResponse?
    let error: Error?
    let session: URLSession
    let latency: Double

}

public enum XnifferUI {

    case console
    case custom(() -> ())
    case window

}

public protocol XnifferDelegate: class {

    func displayResult(for result: XnifferResult)
    func queueUpdated(queueCount: Int)
    
}

public final class Xniffer {

    weak var delegate: XnifferDelegate?
    private var requests = [RequestWrapper]()
    private static var profilerWindow: XnifferWindow?

    static let shared = Xniffer()

    private init () {}

    public static func setup(with configuration: URLSessionConfiguration, mode: XnifferUI = .window) {
        Xniffer.enableInURLSessionConfiguration(configuration: configuration)
        switch mode {
        case .console:
            Xniffer.shared.delegate = ConsoleXniffer()
        case .window:
            Xniffer.profilerWindow = XnifferWindow()
            Xniffer.profilerWindow?.makeKeyAndVisible()
        case .custom(let callback):
            callback()
        }
    }

    private static func enableInURLSessionConfiguration(configuration: URLSessionConfiguration) {
        configuration.protocolClasses?.insert(XnifferURLProtocol.self, at: 0)
    }

    public func calculateLatency(for response: ResponseWrapper) {
        guard let request = dequeue(with: response.id) else { return }
        let timeInterval = response.timestamp.uptimeNanoseconds - request.timestamp.uptimeNanoseconds
        let latency = Double(timeInterval) / 1_000_000
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.displayResult(for:
                XnifferResult(request: request.request,
                               response: response.response,
                               error: nil,
                               session: response.session,
                               latency: latency
                )
            )
        }
    }

    public func calculateLatency(for error: ErrorWrapper) {
        guard let request = dequeue(with: error.id) else { return }
        let timeInterval = error.timestamp.uptimeNanoseconds - request.timestamp.uptimeNanoseconds
        let latency = Double(timeInterval) / 1_000_000
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.displayResult(for:
                XnifferResult(request: request.request,
                               response: error.response,
                               error: error.error,
                               session: error.session,
                               latency: latency
                )
            )
        }
    }

    public func cancelRequest(with requestId: Int) {
        _ = dequeue(with: requestId)
    }

    func enqueue(request: RequestWrapper) {
        requests.append(request)
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.queueUpdated(queueCount: self?.requests.count ?? 0)
        }
    }

    func dequeue(with requestId: Int) -> RequestWrapper? {
        guard let index = requests.index(where: { $0.id == requestId } ) else { return nil }
        let request = requests[index]
        requests.remove(at: index)
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.queueUpdated(queueCount: self?.requests.count ?? 0)
        }
        return request
    }

}

