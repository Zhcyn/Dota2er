import UIKit
import MBProgressHUD
class FirstHeroAntiViewController: UITableViewController,UISearchBarDelegate {
    var antiHeroArray : [AntiHeroInfo]?
    var myClosure : callbackClosure?
    var unlockDelegate : UnlockNextViewProtocol?
    var viewTag : Int = 0;
    var searchBar : UISearchBar?
    var searchResultArray : [AntiHeroInfo]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib.init(nibName: "FirstHeroAntiTableViewCell", bundle: nil), forCellReuseIdentifier: "reuseanti");
        searchResultArray = antiHeroArray;
        searchBar = UISearchBar.init();
        searchBar?.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48);
        searchBar?.delegate = self;
        self.tableView.keyboardDismissMode = .onDrag;
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var resultArray : [AntiHeroInfo]? = [AntiHeroInfo]();
        let predicate = NSPredicate.init(format: "SELF CONTAINS[cd] %@", searchText);
        for item in antiHeroArray! {
            let result = predicate.evaluate(with: item.name);
            if result {
                resultArray?.append(item);
            }
        }
        self.searchResultArray = resultArray;
        self.tableView.reloadData();
        if searchText == "" {
            self.searchResultArray = antiHeroArray;
            self.tableView.reloadData();
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar?.resignFirstResponder();
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (searchResultArray?.count)!;
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> FirstHeroAntiTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseanti");
        let antiHero = searchResultArray?[indexPath.row];
        let newCell = cell as! FirstHeroAntiTableViewCell;
        newCell.antiHeroInfo = antiHero;
        if indexPath.row % 2 == 0 {
            newCell.contentView.backgroundColor = UIColor.darkText
        } else {
            newCell.contentView.backgroundColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0);
        }
        return newCell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
        hud.label.text = "正在缓存英雄数据..."
        hud.mode = MBProgressHUDMode.indeterminate;
        let antiHero = searchResultArray?[indexPath.row];
        if myClosure != nil {
            myClosure!(antiHero! as HeroInfo);
        }
        DispatchQueue.global().async {
            self.saveHeroData(heroEngName: (antiHero?.anti_eng_name)!, heroName: (antiHero?.name)!)
            DispatchQueue.main.async {
                self.unlockDelegate?.unlockNextHeroView(tag: self.viewTag,info: antiHero!);
                hud.hide(animated: true)
                _ = self.navigationController?.popViewController(animated: true);
            }
        }
    }
}
