//
//  TFYUtils.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/12.
//

import Foundation
import UIKit

public let TFYSwiftWidth = UIScreen.main.bounds.width
public let TFYSwiftHeight = UIScreen.main.bounds.height

// MARK: 读取本地json文件
public func getJSON(name:String) -> NSDictionary{
    let path = Bundle.main.path(forResource: name, ofType: "json")
    let url = URL(fileURLWithPath: path!)
    do {
        let data = try Data(contentsOf: url)
        let jsonData:Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
        return jsonData as! NSDictionary
    } catch _ as Error? {
        print("读取本地数据出现错误!")
        return NSDictionary()
    }
}


