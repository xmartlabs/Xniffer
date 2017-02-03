//
//  ViewController.swift
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
import Xniffer

class ViewController: UIViewController {

    var session: URLSession?
    let xmartlabsGithubBaseUrl = "https://api.github.com/users/xmartlabs"

    override func viewDidLoad() {
        super.viewDidLoad()
        session = AppDelegate.session
    }

    @IBAction func fetchUsers(_ sender: UIButton) {
        let request = URLRequest(url: URL(string: xmartlabsGithubBaseUrl)!)
        session?.dataTask(with: request).resume()
    }


    @IBAction func failingRequest(_ sender: Any) {
        let request = URLRequest(url: URL(string: "\(xmartlabsGithubBaseUrl)/broke")!)
        session?.dataTask(with: request).resume()
    }
    @IBAction func fetchRepos(_ sender: UIButton) {
        let request = URLRequest(url: URL(string: "\(xmartlabsGithubBaseUrl)/repos")!)
        session?.dataTask(with: request).resume()
    }

    @IBAction func fetchFollowers(_ sender: UIButton) {
        let request = URLRequest(url: URL(string: "\(xmartlabsGithubBaseUrl)/followers")!)
        session?.dataTask(with: request).resume()
    }
    
}
