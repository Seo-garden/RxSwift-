//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class MenuViewController: UIViewController {
    // MARK: - Life Cycle
    
    let cellId = "MenuItemTableViewCell"
    
    let viewModel: MenuListViewModel = MenuListViewModel()
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        viewModel.menuObservable
            .bind(to: tableView.rx.items(cellIdentifier: cellId, cellType: MenuItemTableViewCell.self)) { index, item, cell in
                cell.title.text = item.name
                cell.price.text = "\(item.price)"
                cell.count.text = "\(item.count)"
                
                cell.onChange = { [weak self] increase in
                    self?.viewModel.changeCount(item: item, increase: increase)
                }
            }.disposed(by: disposeBag)
        
        
        viewModel.itemsCount
            .map { "\($0)"}
            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: {
//                self.itemCountLabel.text = $0
//            })
            .bind(to: itemCountLabel.rx.text)   //rx는 바인딩을 해줄 수 있는데 주석의 부분과 역할이 동일하고, 바인드를 쓸 경우 순환참조없이 사용가능
            .disposed(by: disposeBag)

        viewModel.totalPrice
        
//            .scan(0, accumulator: +)        //0부터 시작해서 기존의 값을 더해라
            .map { $0.currencyKR() }
            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: {
//                self.totalPrice.text = $0
//            })
            .bind(to: totalPrice.rx.text)
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
    
    @IBAction func onClear() {
        viewModel.clearAllItemSelections()
    }
    
    @IBAction func onOrder(_ sender: UIButton) {
        viewModel.onOrder()
    }
}
