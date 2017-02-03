//
//  URLProtocol.swift
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

final class XnifferURLProtocol: URLProtocol, URLSessionTaskDelegate, URLSessionDataDelegate {

    private var internalSession: URLSession?
    private var internalTask: URLSessionDataTask?
    private var internalResponse: HTTPURLResponse?
    private lazy var internalResponseData = NSMutableData()

    private var requestIdentifier: Int {
        return internalTask?.originalRequest?.hashValue ?? 0
    }

    private func interceptRequest(request: URLRequest) {
        let startStamp = DispatchTime.now()
        let requestWrapper = RequestWrapper(id: requestIdentifier, timestamp: startStamp, request: request)
        Xniffer.shared.enqueue(request: requestWrapper)
    }

    private func interceptResponse(response: HTTPURLResponse, data: NSData?, session: URLSession) {
        let endStamp = DispatchTime.now()
        let responseWrapper = ResponseWrapper(id: requestIdentifier, timestamp: endStamp, response: response, session: session)
        Xniffer.shared.calculateLatency(for: responseWrapper)
    }

    private func interceptError(error: Error, response: HTTPURLResponse?, data: NSData?, session: URLSession) {
        let endStamp = DispatchTime.now()
        let errorWrapper = ErrorWrapper(id: requestIdentifier, timestamp: endStamp, session: session, response: response, error: error)
        Xniffer.shared.calculateLatency(for: errorWrapper)
    }

    // MARK: URLProtocol

    internal override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
        internalSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        internalTask = internalSession?.dataTask(with: request)
    }

    internal override static func canInit(with request: URLRequest) -> Bool {
        guard
            let url = request.url,
            let scheme = url.scheme
        else { return  false }
        return ["http", "https"].contains(scheme)
    }

    internal override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    internal override func startLoading() {
        interceptRequest(request: request)
        internalTask?.resume()
    }

    internal override func stopLoading() {
        Xniffer.shared.cancelRequest(with: requestIdentifier)
        internalSession?.invalidateAndCancel()
    }

    // MARK: URLSessionTaskDelegate

    internal func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            interceptError(error: error, response: internalResponse, data: internalResponseData, session: session)
            client?.urlProtocol(self, didFailWithError: error)
        } else if let response = internalResponse {
            interceptResponse(response: response, data: internalResponseData, session: session)
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    // MARK: URLSessionDataDelegate

    internal func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        internalResponse = response as? HTTPURLResponse
        completionHandler(.allow)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
    }

    internal func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        internalResponseData.append(data)
        client?.urlProtocol(self, didLoad: data)
    }

}
