//
//  XnifferViewController.swift
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

protocol XnifferControllerDelegate: class {

    func hideController()

    func updateLatency(for result: XnifferResult)

    func updateQueue(with queueCount: Int)

}

class XnifferViewController: UIViewController {

    weak var windowDelegate: XnifferControllerDelegate?
    fileprivate var historic = [XnifferResult]()

    fileprivate let tableView: UITableView = {
        let table = UITableView(frame: UIScreen.main.bounds, style: .grouped)
        table.frame.origin.y = 44
        table.register(UINib(nibName: "ResultCell", bundle: Resources.bundle), forCellReuseIdentifier: ResultCell.reuseIdentifier)
        table.rowHeight = UITableViewAutomaticDimension
        table.estimatedRowHeight = 80
        table.separatorColor = .white
        table.backgroundColor = .black
        table.separatorInset = UIEdgeInsets.zero
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    fileprivate let closeButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 16, y: 0, width: 50, height: 44))
        button.backgroundColor = .clear
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        return button
    }()

    fileprivate let clearButton: UIButton = {
        let x = UIScreen.main.bounds.width - 66
        let button = UIButton(frame: CGRect(x: x, y: 0, width: 50, height: 44))
        button.backgroundColor = .clear
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(clearHistoric), for: .touchUpInside)
        return button
    }()

    fileprivate let queueLabel: UILabel = {
        let labelWidth = 150
        let x = Int(UIScreen.main.bounds.width / 2) - labelWidth / 2
        let label = UILabel(frame: CGRect(x: x, y: 0, width: labelWidth, height: 44))
        label.text = ""
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    fileprivate let toast: UILabel = {
        let labelWidth = Int(UIScreen.main.bounds.width)
        let labelHeight = 50
        let y = Int(UIScreen.main.bounds.height) - labelHeight
        let label = UILabel(frame: CGRect(x: 0, y: y, width: labelWidth, height: labelHeight))
        label.alpha = 0
        label.text = "Curl copied to clipboard."
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .gray
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(closeButton)
        view.addSubview(clearButton)
        view.addSubview(queueLabel)
        setupTable()
        setupXniffer()
        view.addSubview(toast)
    }

    func setupXniffer() {
        Xniffer.shared.delegate = self
    }

    private func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        let constraints = [
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: tableView, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: tableView, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: tableView, attribute: .top, multiplier: 1.0, constant: -44),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: tableView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        ]
        view.addConstraints(constraints)
    }

    func dismissController() {
        windowDelegate?.hideController()
    }

    func clearHistoric() {
        historic = []
        tableView.reloadData()
    }

    func showToast() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut,
            animations: { [weak self] in
                self?.toast.alpha = 1
            },
            completion: { _ in
                UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveEaseInOut,
                    animations: { [weak self] in
                        self?.toast.alpha = 0
                    },
                    completion: nil
                )
            }
        )
    }

}

extension XnifferViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ResultCell.reuseIdentifier, for: indexPath) as? ResultCell else {
            return UITableViewCell()
        }
        cell.result = historic[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historic.count
    }

}

extension XnifferViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ResultCell else { return }
        if !cell.isShowingCurl {
            UIPasteboard.general.string = cell.result?.cURLRepresentation() ?? ""
            showToast()
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.beginUpdates()
        cell.isShowingCurl = !cell.isShowingCurl
        tableView.endUpdates()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

}

extension XnifferViewController: XnifferDelegate {

    func displayResult(for result: XnifferResult) {
        historic.insert(result, at: 0)
        windowDelegate?.updateLatency(for: result)
        if isViewLoaded {
            tableView.reloadData()
        }
    }

    func queueUpdated(queueCount: Int) {
        if isViewLoaded {
            queueLabel.text = "\(queueCount) in queue."
            windowDelegate?.updateQueue(with: queueCount)
        }
    }

}

