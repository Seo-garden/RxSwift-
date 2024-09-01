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
    let id: UUID
    let name: String
    let price: Int
    let count: Int

}

extension Menu {
    static func menuItemToMenu(menuItem: MenuItem) -> Menu {
        return Menu(id: UUID(), name: menuItem.name, price: menuItem.price, count: 0)
    }
}
