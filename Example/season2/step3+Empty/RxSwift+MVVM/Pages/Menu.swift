//
//  Menu.swift
//  RxSwift+MVVM
//
//  Created by 서정원 on 8/25/24.
//  Copyright © 2024 iamchiwon. All rights reserved.
//

import Foundation

//Model: View를 위한 Model -> ViewModel
struct Menu {
    var id: Int
    var name: String
    var price: Int
    var count: Int
}

extension Menu {
    static func fromMenuItems(id: Int, item: MenuItem) -> Menu {
        return Menu(id: 0, name: item.name, price: item.price, count: 0)
    }
    
}
