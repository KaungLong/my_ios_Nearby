//
//  PlaceTableViewCell.swift
//  NearBy
//
//  Created by 危末狂龍 on 2023/2/3.
//

import Foundation
import UIKit

class PlaceTableViewCell: UITableViewCell{
    
    let PlaceText:UILabel = {
        let label = UILabel()
        label.text = "_"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    let SecondaryText:UILabel = {
        let label = UILabel()
        label.text = "_"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    
}
