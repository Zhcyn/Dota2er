import Foundation
extension UIViewController {
    func saveHeroData(heroEngName:String,heroName:String) -> Void {
        let documentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        let pathStr = (documentPath as NSString).appendingPathComponent("\(heroName)");
        let isFileExist = FileManager.default.fileExists(atPath: pathStr)
        if !isFileExist {
            let urlAntiStr = "http://www.dotamax.com/hero/detail/match_up_anti/\(heroEngName)/?ladder=y";
            let urlAnti = NSURL.init(string: urlAntiStr);
            var htmlStr = ""
            var covHtmlStr : NSString = ""
            do {
                htmlStr = try String.init(contentsOf: urlAnti! as URL)
                covHtmlStr = NSString.init(string: htmlStr);
            } catch {
            }
            let antiArray = getAntiOtherHeroInfo(htmlStr:htmlStr, nsHtmlStr: covHtmlStr);
            let urlCombStr = "http://www.dotamax.com/hero/detail/match_up_comb/\(heroEngName)/?ladder=y";
            let urlComb = NSURL.init(string: urlCombStr);
            var htmlCombStr = ""
            var covHtmlCombStr : NSString = ""
            do {
                htmlCombStr = try String.init(contentsOf: urlComb! as URL)
                covHtmlCombStr = NSString.init(string: htmlCombStr);
            } catch {
            }
            let combArray = getCombOtherHeroInfo(htmlStr:htmlCombStr, nsHtmlStr: covHtmlCombStr);
            let heroModel : HeroModel = HeroModel();
            heroModel.name = heroName;
            heroModel.name_eng = heroEngName;
            heroModel.antiArray = antiArray;
            heroModel.combArray = combArray;
            _ = NSKeyedArchiver.archiveRootObject(heroModel, toFile: pathStr);
        }
    }
    func getAntiOtherHeroInfo(htmlStr:String,nsHtmlStr:NSString) -> [AntiHeroInfo]{
        let patternStr = "<tr><td>[\\s\\S]+?</td></tr>";
        var array = [AntiHeroInfo]();
        do {
            let regular = try NSRegularExpression(pattern: patternStr, options: .caseInsensitive);
            let checkresultSet = regular.matches(in: htmlStr, options: .reportCompletion, range: NSMakeRange(0,nsHtmlStr.length));
            for item in checkresultSet {
                let myloc = item.range.location;
                let mylen = item.range.length;
                let result = nsHtmlStr.substring(with: NSRange.init(location: myloc, length: mylen));
                var dict = self.getAntiOherHeroInfoDetail(result: result);
                getAntiOtherHeroImage(&dict,result: result);
                let antiHeroInfo = AntiHeroInfo.init(dict: dict);
                array.append(antiHeroInfo);
            }
            let sortArray = array.sorted(by: { (s1, s2) -> Bool in
                let val1 : Double = (s1.win_rate! as NSString).doubleValue
                let val2 : Double = (s2.win_rate! as NSString).doubleValue
                if val1 > val2 {
                    return false;
                } else {
                    return true;
                }
            });
            array = sortArray;
        } catch {
        }
        return array;
    }
    func getCombOtherHeroInfo(htmlStr:String,nsHtmlStr:NSString) -> [CombHeroInfo]{
        let patternStr = "<tr><td>[\\s\\S]+?</td></tr>";
        var array = [CombHeroInfo]();
        do {
            let regular = try NSRegularExpression(pattern: patternStr, options: .caseInsensitive);
            let checkresultSet = regular.matches(in: htmlStr, options: .reportCompletion, range: NSMakeRange(0,nsHtmlStr.length));
            for item in checkresultSet {
                let myloc = item.range.location;
                let mylen = item.range.length;
                let result = nsHtmlStr.substring(with: NSRange.init(location: myloc, length: mylen));
                var dict = self.getCombOherHeroInfoDetail(result: result);
                getCombOtherHeroImage(&dict,result: result);
                let combHeroInfo = CombHeroInfo.init(dict: dict);
                array.append(combHeroInfo);
            }
            array = self.rateSort(array: array) as! [CombHeroInfo];
        } catch {
        }
        return array;
    }
    func getAntiOherHeroInfoDetail(result:String) -> Dictionary<String,String>{
        let patternStr2 = ">([^<|\\s]+).<";
        var dict :[String:String] = ["name":"","anti_rate":"","win_rate":"","count":"","image":"","anti_eng_name":""];
        var newArray = [String]();
        do {
            let nsHtmlStr2 = NSString.init(string: result);
            let regular2 = try NSRegularExpression(pattern: patternStr2, options: .caseInsensitive);
            let checkresultSet2 = regular2.matches(in: result, options: .reportCompletion, range: NSMakeRange(0, nsHtmlStr2.length));
            for item2 in checkresultSet2 {
                let myloc2 = item2.range.location;
                let mylen2 = item2.range.length;
                let result2 = nsHtmlStr2.substring(with: NSRange.init(location: myloc2, length: mylen2));
                let nsresult2 = NSString.init(string: result2);
                let result3 = nsresult2.substring(with: NSRange.init(location: 1, length: nsresult2.length - 2));
                newArray.append(result3);
            }
            if (newArray.count == 3) {
                dict["name"] = "陈";
                dict["anti_rate"] = newArray[0];
                dict["win_rate"] = newArray[1];
                dict["count"] = newArray[2];
            } else {
                dict["name"] = newArray[0];
                dict["anti_rate"] = newArray[1];
                dict["win_rate"] = newArray[2];
                dict["count"] = newArray[3];
            }
        } catch  {
        }
        return dict;
    }
    func getAntiOtherHeroImage(_ dict: inout Dictionary<String,String>,result : String) {
        let patternStr = "src=\"[\\s\\S]+?>";
        do {
            let nsHtmlStr2 = NSString.init(string: result);
            let regular2 = try NSRegularExpression(pattern: patternStr, options: .caseInsensitive);
            let checkresultSet2 = regular2.matches(in: result, options: .reportCompletion, range: NSMakeRange(0, nsHtmlStr2.length));
            for item2 in checkresultSet2 {
                let myloc2 = item2.range.location;
                let mylen2 = item2.range.length;
                let result2 = nsHtmlStr2.substring(with: NSRange.init(location: myloc2, length: mylen2));
                let nsresult2 = NSString.init(string: result2);
                let result3 = nsresult2.substring(with: NSRange.init(location: 5, length: nsresult2.length - 7));
                let result4 = nsresult2.substring(with: NSRange.init(location: 51, length: nsresult2.length - 65));
                dict["image"] = result3;
                dict["anti_eng_name"] = result4;
            }
        } catch {
        }
    }
    func getCombOherHeroInfoDetail(result:String) -> Dictionary<String,String>{
        let patternStr2 = ">([^<|\\s]+).<";
        var dict :[String:String] = ["name":"","comb_rate":"","win_rate":"","count":"","image":"","comb_eng_name":""];
        var newArray = [String]();
        do {
            let nsHtmlStr2 = NSString.init(string: result);
            let regular2 = try NSRegularExpression(pattern: patternStr2, options: .caseInsensitive);
            let checkresultSet2 = regular2.matches(in: result, options: .reportCompletion, range: NSMakeRange(0, nsHtmlStr2.length));
            for item2 in checkresultSet2 {
                let myloc2 = item2.range.location;
                let mylen2 = item2.range.length;
                let result2 = nsHtmlStr2.substring(with: NSRange.init(location: myloc2, length: mylen2));
                let nsresult2 = NSString.init(string: result2);
                let result3 = nsresult2.substring(with: NSRange.init(location: 1, length: nsresult2.length - 2));
                newArray.append(result3);
            }
            if (newArray.count == 3) {
                dict["name"] = "陈";
                dict["comb_rate"] = newArray[0];
                dict["win_rate"] = newArray[1];
                dict["count"] = newArray[2];
            } else {
                dict["name"] = newArray[0];
                dict["comb_rate"] = newArray[1];
                dict["win_rate"] = newArray[2];
                dict["count"] = newArray[3];
            }
        } catch  {
        }
        return dict;
    }
    func getCombOtherHeroImage(_ dict: inout Dictionary<String,String>,result : String) {
        let patternStr = "src=\"[\\s\\S]+?>";
        do {
            let nsHtmlStr2 = NSString.init(string: result);
            let regular2 = try NSRegularExpression(pattern: patternStr, options: .caseInsensitive);
            let checkresultSet2 = regular2.matches(in: result, options: .reportCompletion, range: NSMakeRange(0, nsHtmlStr2.length));
            for item2 in checkresultSet2 {
                let myloc2 = item2.range.location;
                let mylen2 = item2.range.length;
                let result2 = nsHtmlStr2.substring(with: NSRange.init(location: myloc2, length: mylen2));
                let nsresult2 = NSString.init(string: result2);
                let result3 = nsresult2.substring(with: NSRange.init(location: 5, length: nsresult2.length - 7));
                let result4 = nsresult2.substring(with: NSRange.init(location: 51, length: nsresult2.length - 65));
                dict["image"] = result3;
                dict["comb_eng_name"] = result4;
            }
        } catch {
        }
    }
    func rateSort(array: [HeroInfo]) -> [HeroInfo] {
        let sortArray = array.sorted(by: { (s1, s2) -> Bool in
            let val1 : Double = (s1.win_rate! as NSString).doubleValue
            let val2 : Double = (s2.win_rate! as NSString).doubleValue
            if val1 > val2 {
                return true;
            } else {
                return false;
            }
        });
        return sortArray;
    }
}
