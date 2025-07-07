//
//  ViewController.swift
//  WeeklyReportDemo
//
//  Created by zxx on 2025/7/7.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建按钮
        let button = UIButton(type: .system)
        button.setTitle("Push VC", for: .normal)
        button.frame = CGRect(x: 100, y: 100, width: 200, height: 50)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc private func buttonTapped() {
        let newVC = WeeklyReportDetaillVC()
        newVC.view.backgroundColor = .white
        self.present(newVC, animated: true)

    }
}

