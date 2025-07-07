//
//  WeeklyReportDetaillVC.swift
//  WeeklyReportDemo
//
//  Created by zxx on 2025/7/7.
//

import Foundation
import UIKit

class WeeklyReportDetaillVC: UIViewController {
    private var tableView: UITableView!
    private var cellHeights: [IndexPath: CGFloat] = [:]
    private var tableViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupKeyboardObservers()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
        
        // 使用 Masonry 设置约束，保留底部约束以便调整
        tableView.mas_makeConstraints { make in
            make?.top.equalTo()(view)
            make?.left.equalTo()(view)
            make?.right.equalTo()(view)
        }
        
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        tableViewBottomConstraint.isActive = true
        
        tableView.register(QuillEditorCell.self, forCellReuseIdentifier: "QuillEditorCell")
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        tableViewBottomConstraint.constant = -keyboardHeight
        
        // 获取当前活跃的输入视图所在的 cell
        if let activeView = UIResponder.current,
           let cell = activeView.superview?.superview as? QuillEditorCell,
           let indexPath = tableView.indexPath(for: cell) {
            
            // 计算 cell 在 tableView 中的位置
            let cellRect = tableView.rectForRow(at: indexPath)
            let convertedRect = tableView.convert(cellRect, to: view)
            
            // 计算键盘遮挡的区域
            let keyboardY = view.frame.height - keyboardHeight
            
            // 如果 cell 底部被键盘遮挡，计算需要滚动的偏移量
            if convertedRect.maxY > keyboardY {
                let offsetY = convertedRect.maxY - keyboardY + 20 // 额外添加 20 点的间距
                let newOffset = CGPoint(x: 0, y: tableView.contentOffset.y + offsetY)
                
                // 使用动画滚动到新位置
                if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
                    UIView.animate(withDuration: duration) {
                        self.tableView.setContentOffset(newOffset, animated: false)
                        self.view.layoutIfNeeded()
                    }
                }
            } else {
                // 如果没有遮挡，只需要更新布局
                if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
                    UIView.animate(withDuration: duration) {
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        tableViewBottomConstraint.constant = 0
        
        if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension WeeklyReportDetaillVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 // 示例：显示3个编辑器
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuillEditorCell", for: indexPath) as! QuillEditorCell
        
        cell.heightUpdateCallback = { [weak self] height in
            self?.cellHeights[indexPath] = height
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? UITableView.automaticDimension
    }   sdasd dfdsfsda四大是的撒多
}

// 在文件顶部添加这个扩展
extension UIResponder {
    private static weak var _current: UIResponder?
    
    static var current: UIResponder? {
        _current = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _current
    }
    
    @objc private func findFirstResponder(_ sender: Any?) {
        UIResponder._current = self
    }
}
