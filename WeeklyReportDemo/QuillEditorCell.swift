import UIKit
import WebKit
import Masonry

class QuillEditorCell: UITableViewCell {
    var webView: WKWebView!
    var heightConstraint: NSLayoutConstraint!
    var heightUpdateCallback: ((CGFloat) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupWebView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "heightChanged")
        configuration.userContentController = userContentController
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false  // 禁用滚动
        webView.scrollView.bounces = false         // 禁用弹性效果
        contentView.addSubview(webView)
        
        webView.mas_makeConstraints { make in
            make?.top.equalTo()(contentView)?.offset()(8)
            make?.left.equalTo()(contentView)?.offset()(16)
            make?.right.equalTo()(contentView)?.offset()(-16)
            make?.bottom.equalTo()(contentView)?.offset()(-8)
        }
        
        // 加载 Quill 编辑器
        let htmlString = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                <link href="https://cdn.quilljs.com/1.3.6/quill.snow.css" rel="stylesheet">
                <script src="https://cdn.quilljs.com/1.3.6/quill.js"></script>
                <style>
                    body { margin: 0; padding: 0; }
                    #editor { height: auto; min-height: 100px; }
                    .ql-container { font-size: 16px; }
                </style>
            </head>
            <body>
                <div id="editor"></div>
                <script>
                    var quill = new Quill('#editor', {
                        theme: 'snow',
                        placeholder: '请输入内容...',
                        modules: {
                            toolbar: [
                                ['bold', 'italic', 'underline'],
                                [{ 'list': 'ordered'}, { 'list': 'bullet' }],
                                ['clean']
                            ]
                        }
                    });
                    
                    quill.on('text-change', function() {
                        var height = document.querySelector('.ql-editor').offsetHeight;
                        window.webkit.messageHandlers.heightChanged.postMessage(height);
                    });
                </script>
            </body>
            </html>
        """
        
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}

extension QuillEditorCell: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateHeight()
    }
  
}

extension QuillEditorCell: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "heightChanged", let height = message.body as? CGFloat {
            heightUpdateCallback?(height + 100) // 添加一些额外的高度用于工具栏
        }
    }
    
    private func updateHeight() {
        webView.evaluateJavaScript("document.querySelector('.ql-editor').offsetHeight") { [weak self] (height, error) in
            if let height = height as? CGFloat {
                self?.heightUpdateCallback?(height + 100)  // 100是工具栏的高度
            }
        }
    }
}

