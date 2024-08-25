// 2시간 58분부터 ~~
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by 서정원 on 8/25/24.
//  Copyright © 2024 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

class MenuListViewModel {
    
    
    lazy var menuObservable = BehaviorSubject<[Menu]>(value: [])
    
    lazy var itemsCount = menuObservable.map {
        $0.map { $0.count}.reduce(0, +)
    }
    
    lazy var totalPrice = menuObservable.map {
        $0.map { $0.price * $0.count}.reduce(0, +)
    }

    init() {
        var menus: [Menu] = [
            Menu(id: 0, name: "튀김1", price: 100, count: 0),
            Menu(id: 1, name: "튀김2", price: 200, count: 0),
            Menu(id: 2, name: "튀김3", price: 300, count: 0),
            Menu(id: 3, name: "튀김4", price: 400, count: 0)
        ]
        
        menuObservable.onNext(menus)
    }
    
    func onOrder() {
        
    }
    
    func clearAllItemSelections() {
        menuObservable
            .map { menus in
                return menus.map { m in
                    Menu(id: m.id, name: m.name, price: m.price, count: 0)
                    
                }
            }
            .take(1)        //한번만 실행할꺼.
            .subscribe(onNext: {
                self.menuObservable.onNext($0)
            })
    }

    func changeCount(item: Menu, increase: Int) {
        _ =  menuObservable
            .map { menus in
                return menus.map { m in
                    if m.id == item.id {
                        return Menu(id: m.id, name: m.name, price: m.price, count: max(m.count + increase, 0))
                    } else {
                        return Menu(id: m.id, name: m.name, price: m.price, count: m.count)
                    }
                }
            }
            .take(1)        //한번만 실행할꺼.
            .subscribe(onNext: {
                self.menuObservable.onNext($0)
            })
    }
}
