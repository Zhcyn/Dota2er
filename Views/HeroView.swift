import UIKit
import SDWebImage.UIImageView_WebCache
import MBProgressHUD
class HeroView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    var delegate : ShowHeroInfoTableProtocol?
    var isLock : Bool?
    var hud : MBProgressHUD?
    var heroInfo : HeroInfo?
    var rateLabel : UILabel?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        view = (Bundle.main.loadNibNamed("HeroView", owner: self, options: nil)?.first as! UIView);
        view.frame = self.bounds;
        self.addSubview(view);
        imageBtn.addTarget(self, action:#selector(HeroView.buttonClick), for: UIControlEvents.touchUpInside);
    }
    func displayHUD() -> Void {
        hud = MBProgressHUD.showAdded(to: (UIApplication.shared.keyWindow?.rootViewController?.view)!, animated: true);
        hud?.mode = MBProgressHUDMode.indeterminate;
        hud?.label.text = "正在解析数据..."
    }
    @objc func buttonClick() {
        delegate?.show(sender: self);
    }
    func heroInfoClosure(heroData:HeroInfo) -> Void {
        self.heroInfo = heroData;
        self.nameLabel.text = heroData.name;
        let imageURL = URL.init(string: heroData.image!);
        self.imageBtn.sd_setImage(with: imageURL, for: .normal)
    }
}
protocol ShowHeroInfoTableProtocol {
    func show(sender:HeroView)
}
