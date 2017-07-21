//
//  GlobalUtil.swift
//  HuiKaoBa
//
//  Created by Tony on 16/11/17.
//  Copyright © 2016年 Tony. All rights reserved.
//

import UIKit

class GlobalUtil: NSObject {
    
    /** 计算文本尺寸 */
    static func textSizeWithString(_ str: String, font: UIFont, maxSize:CGSize) -> CGSize {
        let dict = [NSFontAttributeName: font]
        let size = (str as NSString).boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: dict, context: nil).size
        return size
    }
    
}
