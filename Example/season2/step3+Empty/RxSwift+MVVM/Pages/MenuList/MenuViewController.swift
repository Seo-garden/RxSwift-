//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MenuViewController: UIViewController {
    // MARK: - Life Cycle
    
    let cellIdentifier = "MenuItemTableViewCell"
    
    let viewModel: MenuListViewModel = MenuListViewModel()
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        viewModel.menuObservable
        //rxCocoa 의 rx 를 쓰게 되면 Binder
        //.bing 를 쓰게 될 경우 subscribe 를 하지 않아도 된다. 순환참조를 하지 않아서 [weak self] 도 쓰지 않는다.
            .bind(to: tableView.rx.items(cellIdentifier: cellIdentifier, cellType: MenuItemTableViewCell.self)) { index, item, cell in
                cell.title.text = item.name
                cell.price.text = "\(item.price)"
                cell.count.text = "\(item.count)"
                
                cell.onChange = { [weak self] increase in
                    self?.viewModel.changeCount(item: item, increase: increase)
                }
            }.disposed(by: disposeBag)
        
        viewModel.itemsCount
            .map { "\($0)"}
            .asDriver(onErrorJustReturn: "")        //observeOn + bind
            .drive(itemCountLabel.rx.text)          //항상 메인쓰레드에서 동작한다.
            .disposed(by: disposeBag)

        viewModel.totalPrice
//            .scan(0, accumulator: +)        //0부터 시작해서 기존의 값을 더해라
            .map { $0.currencyKR() }
            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: {
//                self.totalPrice.text = $0
//            })
            .bind(to: totalPrice.rx.text)       //위의 주석과 동일한 동작.
            .disposed(by: disposeBag)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let identifier = segue.identifier ?? ""
//        if identifier == "OrderViewController",
//           let orderVC = segue.destination as? OrderViewController {
//            // TODO: pass selected menus
//        }
//    }
    
    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!
    
    @IBAction private func onClear() {
        viewModel.clearAllItemSelections()
    }
    
    @IBAction private func onOrder(_ sender: UIButton) {
        viewModel.onOrder()
    }
}
