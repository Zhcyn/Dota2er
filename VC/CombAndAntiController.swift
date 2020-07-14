import UIKit
import MBProgressHUD
class CombAndAntiController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    @IBOutlet weak var combTableView: UITableView!
    @IBOutlet weak var antiTableView: UITableView!
    var viewTag : Int = 0;
    @IBOutlet weak var searchView: UIView!
    var myClosure : callbackClosure?
    @IBOutlet weak var searchBar: UISearchBar!
    var unlockDelegate : UnlockNextViewProtocol?
    var combHeroArray : [CombHeroInfo]?
    var antiHeroArray : [AntiHeroInfo]?
    var searchCombArray : [CombHeroInfo]?
    var searchAntiArray : [AntiHeroInfo]?
    var isFirst : Bool = true;
    var combHeroName : String? {
        didSet {
        }
    }
    var antiHeroName : String? {
        didSet {
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCombArray = combHeroArray;
        searchAntiArray = antiHeroArray;
        self.title = "配合我方            针对敌方";
        self.searchView.frame = CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.width, height: 48);
        self.combTableView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
        self.combTableView.register(UINib.init(nibName: "CombAndAntiCell", bundle: nil), forCellReuseIdentifier: "reusecomb");
        self.antiTableView.register(UINib.init(nibName: "CombAndAntiOtherCell", bundle: nil), forCellReuseIdentifier: "reuseanti");
        self.combTableView.keyboardDismissMode = .onDrag;
        self.antiTableView.keyboardDismissMode = .onDrag;
        searchBar.delegate = self;
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if isFirst {
            searchCombArray = combHeroArray;
            searchAntiArray = antiHeroArray;
            isFirst = false;
        }
        var resultArray1 : [CombHeroInfo]? = [CombHeroInfo]();
        let predicate = NSPredicate.init(format: "SELF CONTAINS[cd] %@", searchText);
        for item in searchCombArray! {
            let result = predicate.evaluate(with: item.name);
            if result {
                resultArray1?.append(item);
            }
        }
        if resultArray1?.count != 0 {
            self.combHeroArray = resultArray1;
        } else {
            self.combHeroArray?.removeAll();
        }
        self.combTableView.reloadData();
        var resultArray2 : [AntiHeroInfo]? = [AntiHeroInfo]();
        for item in searchAntiArray! {
            let result = predicate.evaluate(with: item.name);
            if result {
                resultArray2?.append(item);
            }
        }
        if resultArray2?.count != 0 {
            self.antiHeroArray = resultArray2;
        } else {
            self.antiHeroArray?.removeAll();
        }
        self.combTableView.reloadData();
        self.antiTableView.reloadData();
        if searchText == "" {
            self.combHeroArray = searchCombArray;
            self.antiHeroArray = searchAntiArray;
            self.combTableView.reloadData();
            self.antiTableView.reloadData();
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar?.resignFirstResponder();
    }
    func setupCombHeadView(name: String) -> Void {
        let combHeadView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.5, height: 50));
        combHeadView.backgroundColor = UIColor.darkGray;
        let combLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.5, height: 50));
        combLabel.text = "与\(name)组合胜率 ⬇︎";
        combLabel.textAlignment = NSTextAlignment.center;
        combLabel.font = UIFont.boldSystemFont(ofSize: 15.0);
        combLabel.textColor = UIColor.green;
        combHeadView.addSubview(combLabel);
        self.combTableView.tableHeaderView = combHeadView;
    }
    func setupAntiHeadView(name: String) -> Void {
        let antiHeadView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.5, height: 50));
        antiHeadView.backgroundColor = UIColor.darkGray;
        let antiLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.5, height: 50));
        antiLabel.text = "各英雄对\(name)胜率 ⬇︎";
        antiLabel.font = UIFont.boldSystemFont(ofSize: 15.0);
        antiLabel.textAlignment = NSTextAlignment.center;
        antiLabel.textColor = UIColor.red;
        antiHeadView.addSubview(antiLabel);
        self.antiTableView.tableHeaderView = antiHeadView;
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.5, height: 48));
        titleView.backgroundColor = UIColor.darkGray;
        let titleLabel = UILabel.init()
        titleLabel.frame = titleView.bounds
        titleLabel.textAlignment = NSTextAlignment.center;
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15.0);
        titleView.addSubview(titleLabel)
        if tableView.isEqual(self.combTableView) {
            titleLabel.text = "与\(combHeroName!)组合胜率 ⬇︎"
            titleLabel.textColor = UIColor.green;
        } else {
            titleLabel.text = "各英雄对\(antiHeroName!)胜率 ⬇︎"
            titleLabel.textColor = UIColor.red;
        }
        return titleView;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 48;
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.isEqual(self.combTableView) {
            return (combHeroArray?.count)!;
        } else {
            return (antiHeroArray?.count)!;
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.isEqual(self.combTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reusecomb") as! CombAndAntiCell;
            let combHero = combHeroArray?[indexPath.row];
            cell.combHero = combHero;
            if indexPath.row % 2 == 0 {
                cell.contentView.backgroundColor = UIColor.darkText
            } else {
                cell.contentView.backgroundColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0);
            }
            return cell;
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseanti") as! CombAndAntiOtherCell;
            let antiHero = antiHeroArray?[indexPath.row];
            cell.antiHero = antiHero;
            if indexPath.row % 2 == 1 {
                cell.contentView.backgroundColor = UIColor.darkText
            } else {
                cell.contentView.backgroundColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0);
            }
            return cell;
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
        hud.label.text = "正在缓存英雄数据..."
        hud.mode = MBProgressHUDMode.indeterminate;
        if tableView.isEqual(self.combTableView) {
            let combHero = combHeroArray?[indexPath.row];
            if myClosure != nil {
                myClosure!(combHero! as HeroInfo);
            }
            var covAntiHero : AntiHeroInfo?
            for antiHero in antiHeroArray! {
                if combHero?.name == antiHero.name {
                    covAntiHero = antiHero;
                }
            }
            DispatchQueue.global().async {
                self.saveHeroData(heroEngName: (combHero?.comb_eng_name)!, heroName: (combHero?.name)!)
                DispatchQueue.main.async {
                    self.unlockDelegate?.unlockNextHeroView(tag: self.viewTag,info: covAntiHero!);
                    hud.hide(animated: true)
                    _ = self.navigationController?.popViewController(animated: true);
                }
            }
        } else {
            let antiHero = antiHeroArray?[indexPath.row];
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
}
