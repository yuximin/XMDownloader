//
//  ViewController.swift
//  XMDownloader
//
//  Created by yuximin on 08/23/2024.
//  Copyright (c) 2024 yuximin. All rights reserved.
//

import UIKit
import XMDownloader

class ViewController: UIViewController {
    
    private let remotePath = "https://github.com/yuximin/StaticResources/raw/master/Test/musics.zip"
    
    private let buttonTitles = ["开始下载", "停止下载"]
    
    private var downloadTask: URLSessionDownloadTask?
    
    private let operationQueue = DispatchQueue(label: "com.queue.test")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let buttonsStackView = UIStackView()
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = 10
        
        for (index, buttonTitle) in buttonTitles.enumerated() {
            let button = UIButton()
            button.tag = index
            button.setTitle(buttonTitle, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
            buttonsStackView.addArrangedSubview(button)
        }
        
        view.addSubview(buttonsStackView)
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func didTapButton(_ sender: UIButton) {
        let index = sender.tag
        switch index {
        case 0:
            self.startDownload()
        case 1:
            self.cancelDownload()
        default:
            break
        }
    }
    
    private func startDownload() {
        XMDownloader.shared.downloadFile(url: self.remotePath) { _, _, _, progress in
            print("whaley log -- download progress: \(progress)")
        } completionHandler: { result in
            switch result {
            case .success(let filePath):
                print("whaley log -- download success:", filePath)
            case .failure(let error):
                print("whaley log -- download failure:", error.localizedDescription)
            }
        }
    }
    
    private func cancelDownload() {
        XMDownloader.shared.cancelDownloadFile(url: self.remotePath)
    }

}

