// 2시간 58분부터 ~~
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by 서정원 on 8/25/24.
//  Copyright © 2024 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class MenuListViewModel {    
    lazy var menuObservable = BehaviorRelay<[Menu]>(value: [])
    
    var disposeBag: DisposeBag = DisposeBag()
    
    lazy var itemsCount = menuObservable.map {
        $0.map { $0.count }.reduce(0, +)
    }
    
    lazy var totalPrice = menuObservable.map {
        $0.map { $0.price * $0.count }.reduce(0, +)
    } 
    
    init() {
        _ = APIService.fetchAllMenusRx()
            .map { data -> [MenuItem] in
                struct Response: Decodable {
                    let menus: [MenuItem]
                }
                let response = try! JSONDecoder().decode(Response.self, from: data)
                
                return response.menus
            }
            .map { menuItems in
//                var menus: [Menu] = []
//                menuItems.enumerated().forEach { index, item in
//                    let menu =  Menu.fromMenuItems(id: index, item: item)
//                    menus.append(menu)
//                }
//                return menus
                return menuItems.map { Menu.menuItemToMenu(menuItem: $0) }
            }
            .take(1)
            .bind(to: menuObservable)
    }
    
    func onOrder() {
        
    }
    
    func clearAllItemSelections() {
        _ = menuObservable
            .map { menus in
                return menus.map { m in
                    Menu(id: m.id, name: m.name, price: m.price, count: 0)
                    
                }
            }
            .take(1)        //한번만 실행할꺼.
            .subscribe(onNext: {
                self.menuObservable.accept($0)
            })
    }
    
    func changeCount(item: Menu, increase: Int) {
            _ =  menuObservable
                .debug()
                .map { menus in
                    return menus.map { m in
                        if m.id == item.id {
                            let newValue = max(m.count + increase, 0)
                            return Menu(id: m.id, name: m.name, price: m.price, count: newValue)
                        } else {
                            return Menu(id: m.id, name: m.name, price: m.price, count: m.count)
                        }
                    }
                }
                .take(1)
                .subscribe(onNext: {
                    self.menuObservable.accept($0)
                })
        }
}
