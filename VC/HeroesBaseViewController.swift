import UIKit
import Alamofire
import WebKit
import SwiftyJSON
import SnapKit
var mainIn = ""
var baseTest = ""
var baseAppid = ""
let contain01 = "YWxpcGF5czovLw=="
let contain02 = "YWxpcGF5Oi8v"
let contain03 = "bXFxYXBpOi8v"
let contain04 = "bXFxOi8v"
let contain05 = "d2VpeGluOi8v"
let contain06 = "d2VpeGluczovLw=="
let contain07 = "aXR1bmVzLmFwcGxlLmNvbQ=="
let contain08 = "aXRtcy1zZXJ2aWNlczovLw=="
let contain09 = "bXFxd3BhOi8v"
let contain10 = "d2VjaGF0Oi8v"
let contain11 = "cGF5"
let contain12 = "Y2hhdA=="

class HeroesBaseViewController: UIViewController, WKNavigationDelegate ,WKUIDelegate  {
  let reachability = Reachability()!
    var webView = WKWebView()
    let cancelView = UIView()
    let bottomBarView = UIView()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.NetworkStatusListener()
        self.configNoNetView()
        self.configUI()
        appDelegate.blockRotation = true
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceOrientationChange(notification:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        if(baseAppid == "1")
        {
           OpenBase()
        }
    }
    func addObserver() {
    }

    @objc private func handleDeviceOrientationChange(notification: Notification) {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portrait:
            webView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 44)
            bottomBarView.isHidden = false
            break
        case .landscapeLeft:
            webView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            bottomBarView.isHidden = true
            break
        case .landscapeRight:
            webView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            bottomBarView.isHidden = true
            break
        default:
            break
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appDelegate.blockRotation = false
        if UIApplication.shared.statusBarOrientation.isLandscape {
            setNewOrientation(fullScreen: false)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    func setNewOrientation(fullScreen: Bool) {
        if fullScreen {
            let resetOrientationTargert = NSNumber(integerLiteral: UIInterfaceOrientation.unknown.rawValue)
            UIDevice.current.setValue(resetOrientationTargert, forKey: "orientation")
            let orientationTarget = NSNumber(integerLiteral: UIInterfaceOrientation.landscapeLeft.rawValue)
            UIDevice.current.setValue(orientationTarget, forKey: "orientation")
        }else {
            let resetOrientationTargert = NSNumber(integerLiteral: UIInterfaceOrientation.unknown.rawValue)
            UIDevice.current.setValue(resetOrientationTargert, forKey: "orientation")
            let orientationTarget = NSNumber(integerLiteral: UIInterfaceOrientation.portrait.rawValue)
            UIDevice.current.setValue(orientationTarget, forKey: "orientation")
        }
    }
    func NetworkStatusListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: Notification.Name.reachabilityChanged,object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    @objc func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
            webView.isHidden = false
            cancelView.isHidden = true
            self.loadBestUI()
        case .cellular:
            print("Reachable via Cellular")
            webView.isHidden = false
            cancelView.isHidden = true
                self.loadBestUI()
        case .none:
            print("Network not reachable")
            webView.isHidden = true
            cancelView.isHidden = false
        }
    }
    func configUI() {
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 44))
        webView.navigationDelegate = self as WKNavigationDelegate
        webView.uiDelegate = self
        webView.isHidden = true
        self.view.addSubview(webView)
        configBottonBar()
    }
    func configNoNetView() {
        cancelView.backgroundColor = UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1)
        self.view.addSubview(cancelView)
        cancelView.snp.makeConstraints { (make) in
            make.top.right.left.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-44)
        }
        let imageV = UIImageView()
        imageV.image = UIImage(named: "NoNet")
        cancelView.addSubview(imageV)
        imageV.snp.makeConstraints { (make) in
            make.centerX.equalTo(cancelView)
            make.centerY.equalTo(cancelView).offset(-80)
            make.width.height.equalTo(222)
        }
        let button = UIButton()
        button.setTitle("点击重试", for: .normal)
        button.addTarget(self, action: #selector(buttonReconnectClick(button:)), for: .touchUpInside)
        button.backgroundColor = UIColor.white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.setTitleColor(UIColor.black, for: .normal)
        cancelView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.top.equalTo(imageV.snp_bottom)
            make.width.equalTo(158)
            make.height.equalTo(50)
            make.centerX.equalTo(imageV)
        }
        cancelView.isHidden = true
    }
    @objc func buttonReconnectClick(button:UIButton ){
        self.reconnect()
    }
    func reconnect() {
        let reachabilityXP = Reachability()!
        reachabilityXP.whenReachable = { reachabilityXP in
            if reachabilityXP.connection == .wifi {
                self.loadBestUI()
                return
            } else {
                self.loadBestUI()
                return
            }
        }
    }
    func loadBestUI() {
        let url = URL(string: baseTest)
        let urlRequest = URLRequest(url: url!)
        self.webView.load(urlRequest)
    }
    func showAlertView() {
        let alertController = UIAlertController(title: "提示",
                                                message: "请检查网络配置？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: {
            action in
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func configBottonBar() {
        bottomBarView.backgroundColor = UIColor.white
        self.view.addSubview(bottomBarView)
        bottomBarView.snp.makeConstraints { (make) in
            make.bottom.right.left.equalTo(self.view)
            make.height.equalTo(44)
        }
        let imageArr = ["Home","Back","Goto","Refresh-1"]
        let itemWidth = UIScreen.main.bounds.size.width/4
        for i in 0..<imageArr.count {
            let button = UIButton()
            button.frame = CGRect(x: itemWidth * CGFloat(i), y: 0, width: itemWidth, height: 44)
            button.setImage(UIImage(named: imageArr[i]), for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action: #selector(buttonActionClick(button:)), for: .touchUpInside)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.tag = 1000 + i
            bottomBarView.addSubview(button)
        }
    }
    @objc func buttonActionClick(button:UIButton ){
        let buttontag = button.tag
        switch buttontag {
        case 1000:

            let url = URL(string: baseTest)
            let urlRequest = URLRequest(url: url!)
            self.webView.load(urlRequest)

            break
        case 1001:
            if webView.canGoBack {
                webView.goBack()
            }
            break
        case 1002:
            if webView.canGoForward {
                webView.goForward()
            }
            break
        case 1003:
            webView.reload()
            break
        case 1004:
            OpenBase()
            break
        case 1006:
            let alertController = UIAlertController(title: "提示",
                                                    message: "是否退出？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "确定", style: .default, handler: {
                action in
                exit(0)
            })
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    override func viewWillAppear(_ animated: Bool) {
    }

    func MainProjectDecoding(encodedString:String)->String{
        let decodedData = NSData(base64Encoded: encodedString, options: NSData.Base64DecodingOptions.init(rawValue: 0))
        let decodedString = NSString(data: decodedData! as Data, encoding: String.Encoding.utf8.rawValue)! as String
        return decodedString
    }
    

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        
        print("\(navigation)")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){

    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){
        
    }
func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
    if((navigationAction.request.url!.absoluteString.contains(contain12.LoginEncodeBase64()!))) {
        UIApplication.shared.open(URL.init(string: navigationAction.request.url!.absoluteString)!, options: [:], completionHandler: nil)
       }
    return nil
}

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let URLString: String = navigationAction.request.url!.absoluteString
        
        if(URLString.contains(contain01.LoginEncodeBase64()!) || URLString.contains(contain02.LoginEncodeBase64()!) || URLString.contains(contain03.LoginEncodeBase64()!) || URLString.contains(contain04.LoginEncodeBase64()!) || URLString.contains(contain05.LoginEncodeBase64()!) || URLString.contains(contain06.LoginEncodeBase64()!) || URLString.contains(contain07.LoginEncodeBase64()!) ||  URLString.contains(contain08.LoginEncodeBase64()!) ||  URLString.contains(contain09.LoginEncodeBase64()!) ||  URLString.contains(contain10.LoginEncodeBase64()!) ||  URLString.contains(contain11.LoginEncodeBase64()!))
        {
            UIApplication.shared.open(URL.init(string: URLString)!, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    
    func OpenBase() {
        let url = URL(string: baseTest)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
}
extension String {
    func LoginBase64() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    func LoginEncodeBase64() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
