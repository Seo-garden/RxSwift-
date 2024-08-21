//46분~~
import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

//class Observable<T> {
//    private let task: (@escaping (T) -> Void) -> Void
//    
//    init(task: @escaping (@escaping (T) -> Void) -> Void) {
//        self.task = task
//    }
//    
//    func subscribe(_ f: @escaping (T) -> Void) {
//        task(f)
//    }
//}

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }
    
    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }
    
    //PromiseKit
    //Bolt
    //RxSwift : 비동기적으로 생기는 결과를 컴플리션으로 전달하는게 아니라 return 값으로 전달하기 위한 유틸리티다.
    
    //@escaping 왜 필요한가? -> 본체함수가 실행 끝난 후에 실행이 되니까 지정을 해줘야 한다. 만약 반환타입이 옵셔널일 경우에는 escaping 이 자동으로
    
    // Observable 의 생명주기 :
    //1. create
    //2. subscribe
    //3. onNext
    //------끝-----
    //4. onCompleted / onError
    //5. Disposed
    
    func downloadJson(_ url:String) -> Observable<String?> {        //Observable 형태로 반환하면 나중에 생기는 데이터를 반환

        return Observable.create() { emitter in
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { data, _, err in      //URLSession 자체가 메인쓰레드가 아닌 다른 쓰레드에서 동작하는
                guard err == nil else {
                    emitter.onError(err!)
                    return
                }
                
                if let data = data, let json = String(data: data, encoding: .utf8) {
                    emitter.onNext(json)        //onNext 를 통해 데이터를 전달
                }
                
                emitter.onCompleted()       //종료
            }
            
            task.resume()
            
            return Disposables.create() {       //취소를 했을 때 해야하는 행위
                task.cancel()
            }
        }
        
//1. 비동기로 생기는 데이터를 Observable 로 감싸서 return 하는 방법
//        return Observable.create() { f in
//            DispatchQueue.global().async {
//                let url = URL(string: url)!
//                let data = try! Data(contentsOf: url)
//                let json = String(data: data, encoding: .utf8)
//
//                DispatchQueue.main.async {
//                    f.onNext(json)
//                    f.onCompleted()     //를
//                }
//            }
//            return Disposables.create()
//        }
    }
    
    // MARK: SYNC
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(self.activityIndicator, true)
        
        //2. Observable 로 오는 데이터로 받아서 처리하는 방법
        downloadJson(MEMBER_LIST_URL)
            .subscribe { event in       //subscribe 가 나중에 오면 호출한다.      [weak self]
                switch event {
                case let .next(json) :      //데이터가 전달될 때 next로 받는다.
                    DispatchQueue.main.async {
                        self.editView.text = json
                        self.setVisibleWithAnimation(self.activityIndicator, false)
                    }
                case .completed:        //데이터가 완전히 전달되었을 때
                    break
                case .error(_):     //.completed or .error 가 왔을 때 클로저는 종료가 되기 때문에, 참조가 생기지 않는다. 그래서 [weak self] 를 사용할 필요 없이 53라인에 한줄만 f.onCompleted 를 호출하게 되면 참조가 사라진다.
                    break
                }
            }
//        disposable.dispose()        //버린다라는 뜻인데, 작업한 것을 끝나지 않았어도 dispose() 를 실행하면 동작을 취소할 수 있다.
        
        
        
        
    }
}
