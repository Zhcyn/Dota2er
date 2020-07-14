import UIKit
import MBProgressHUD
typealias callbackClosure = (_ heroData:HeroInfo)->Void
class HeroTableViewController: UITableViewController,UISearchBarDelegate{
    var allHeroInfoArray : [HeroInfo]?
    var myClosure : callbackClosure?
    var unlockDelegate : UnlockNextViewProtocol?
    var viewTag : Int = 0;
    var searchBar : UISearchBar?
    var searchResultArray : [HeroInfo]?
    var htmlStr : String = ""
    var covHtmlStr : NSString = ""
    var htmlCombStr : String = ""
    var covHtmlCombStr : NSString = ""
    var hud:MBProgressHUD?
    override func viewWillAppear(_ animated: Bool) {
    }
    func unlockHeroView(currentState: Int, unlockState: Int) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultArray = allHeroInfoArray;
        self.title = "英雄天梯平均胜率 ⬇︎";
        searchBar = UISearchBar.init();
        searchBar?.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48);
        searchBar?.delegate = self;
        self.tableView.register(UINib.init(nibName: "HeroInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "reuse");
        self.tableView.keyboardDismissMode = .onDrag;
        hud = MBProgressHUD.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        hud?.label.text = "正在缓存英雄数据..."
        hud?.mode = MBProgressHUDMode.indeterminate;
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(hud!)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var resultArray : [HeroInfo]? = [HeroInfo]();
        let predicate = NSPredicate.init(format: "SELF CONTAINS[cd] %@", searchText);
        for item in allHeroInfoArray! {
            let result = predicate.evaluate(with: item.name);
            if result {
                resultArray?.append(item);
            }
        }
        self.searchResultArray = resultArray;
        self.tableView.reloadData();
        if searchText == "" {
            self.searchResultArray = allHeroInfoArray;
            self.tableView.reloadData();
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar?.resignFirstResponder();
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (searchResultArray?.count)!;
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48));
        titleView.addSubview(self.searchBar!);
        return titleView;
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 48;
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> HeroInfoTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuse");
        let heroInfo = searchResultArray?[indexPath.row];
        let newCell = cell as! HeroInfoTableViewCell;
        newCell.heroInfo = heroInfo;
        if indexPath.row % 2 == 0 {
            newCell.contentView.backgroundColor = UIColor.darkText
        } else {
            newCell.contentView.backgroundColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0);
        }
        return newCell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.hud?.show(animated: true)
        let heroInfo = searchResultArray?[indexPath.row];
        if myClosure != nil {
            myClosure!(heroInfo!);
        }
        DispatchQueue.global().async {
            self.saveHeroData(heroEngName: (heroInfo?.name_eng!)!, heroName: (heroInfo?.name!)!);
            DispatchQueue.main.async {
                self.unlockDelegate?.unlockNextHeroView(tag: self.viewTag, info: heroInfo!);
                self.hud?.hide(animated: true)
                _ = self.navigationController?.popViewController(animated: true);
            }
        }
    }
}
protocol UnlockNextViewProtocol {
    func unlockNextHeroView(tag:Int,info: HeroInfo);
}
