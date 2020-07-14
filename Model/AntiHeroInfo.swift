import UIKit
class AntiHeroInfo: HeroInfo {
    var anti_rate : String?
    var anti_eng_name : String?
    override init(dict:Dictionary<String,String>) {
        super.init(dict: dict);
        self.anti_rate = dict["anti_rate"];
        self.anti_eng_name = dict["anti_eng_name"];
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.anti_eng_name = aDecoder.decodeObject(forKey: "anti_eng_name") as! String?
        self.anti_rate = aDecoder.decodeObject(forKey: "anti_rate") as! String?
    }
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(anti_eng_name, forKey: "anti_eng_name");
        aCoder.encode(anti_rate, forKey: "anti_rate");
    }
}
