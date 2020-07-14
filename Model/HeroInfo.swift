import UIKit
class HeroInfo: NSObject,NSCoding {
    var name : String?
    var count : String?
    var win_rate : String?
    var image : String?
    var name_eng : String?
    init(dict:Dictionary<String,String>) {
        super.init();
        self.name = dict["name"];
        self.count = dict["count"];
        self.win_rate = dict["win_rate"];
        self.image = dict["image"];
        self.name_eng = dict["name_eng"];
    }
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.name_eng = aDecoder.decodeObject(forKey: "name_eng") as! String?;
        self.name = aDecoder.decodeObject(forKey: "name") as! String?;
        self.win_rate = aDecoder.decodeObject(forKey: "win_rate") as! String?;
        self.count = aDecoder.decodeObject(forKey: "count") as! String?;
        self.image = aDecoder.decodeObject(forKey: "image") as! String?;
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name");
        aCoder.encode(count, forKey: "count");
        aCoder.encode(win_rate, forKey: "win_rate");
        aCoder.encode(image, forKey: "image");
        aCoder.encode(name_eng, forKey: "name_eng");
    }
}
