import RxSwift
import SwiftyJSON
import UIKit

//MARK: - 정리
//우리는 비동기로 생성되는 데이터를 취급하기 위해 컴플리션으로 전달했었는데, return 값으로 전달해주고 싶어서 RxSwift 를 쓴다.
//1. RxSwift 비동기적으로 생기는 결과를 컴플리션으로 전달하는게 아니라 return 값으로 전달하기 위한 유틸리티다.
//2. Observable로 오는 데이터를 받아서 return 하는 방법 or 비동기로 생기는 데이터를 Observable 로 감싸서 return 하는 방법이 있다.
//2-1. Observable 의 생명주기는 create() -> subscribe(on: ) -> onNext() or onCompleted() or onError() -> disposed()
//2-2. 여기서 onCompleted() 혹은 onError() 가 오게 되면 클로저가 종료되고 재사용이 불가능해진다.
//3. .debug()    .subscribe 전의 데이터가 전달되는 동안 전달되는 데이터를 다 찍어낼 수 있다.
//4. .observe(on: MainScheduler.instance) 메인쓰레드로 변경되는데, subscribe 라던지 아래에 오는 코드(다운스트림) 모두 메인쓰레드에서 실행된다.
//5. onError or onCompleted() 를 하게 되면 클로저가 해제되면서 메모리가 해제되는데, 아래의 코드 경우 onNext() 처리를 해주고 disposeBag 을 해주어야 메모리가 해제된다.

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
    
    var disposBag = DisposeBag()
    
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
    //1. create 로 만들고
    //2. subscribe 로 받아서
    //3. onNext
    //------끝----- 이 난다는게 재사용이 불가능하다.
    //4. onCompleted / onError
    //5. Disposed
    
    func downloadJson(_ url:String) -> Observable<String> {        //Observable 형태로 반환하면 나중에 생기는 데이터를 반환
//        return Observable.just("HelloWorld")            //아래의 3줄을 생략할 수 있다.     just 는 하나만 보낼 수 있는데,
//        return Observable.just(["Hello", "World"])   //이와 같이 배열로 하게 되면 둘다 보낼 수 있다.
//        return Observable.from(["Hello","World"])    //이와 같이 배열로 보내게 되면 Optional[Hello], 따로따로 출력된다.
        return Observable.create() { emitter in
//            emitter.onNext("Hello World")
//            emitter.onCompleted()
//            return Disposables.create()
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
        setVisibleWithAnimation(activityIndicator, true)
        
        //2. Observable 로 오는 데이터로 받아서 처리하는 방법
        //아래와 같이 표현할 수 있지만, 너무 귀찮다. 그래서 여러가지 sugar API 를 제공한다. 그걸 오퍼레이터라고 부른다.
//        _ = downloadJson(MEMBER_LIST_URL)
//            .debug()        //.subscribe 전의 데이터가 전달되는 동안 전달되는 데이터를 다 찍어낼 수 있다.
//            .subscribe { event in       //subscribe 가 나중에 오면 호출한다.      [weak self]
//                switch event {
//                case let .next(json) :      //데이터가 전달될 때 next로 받는다.
//                    DispatchQueue.main.async {
//                        self.editView.text = json
//                        self.setVisibleWithAnimation(self.activityIndicator, false)
//                    }
//                case .completed:        //데이터가 완전히 전달되었을 때
//                    break
//                case .error(_):     //.completed or .error 가 왔을 때 클로저는 종료가 되기 때문에, 참조가 생기지 않는다. 그래서 [weak self] 를 사용할 필요 없이 1번 방법에 한줄만 f.onCompleted 를 호출하게 되면 참조가 사라진다.
//                    break
//                    //completed 와 error 를 받고싶지 않으면
//                }
//            }
        let jsonObservable = downloadJson(MEMBER_LIST_URL)
        let helloObservable = Observable.just("Hello World")
        
        Observable.zip(jsonObservable, helloObservable) { $1 + "'\n'" + $0 }
            .observe(on: MainScheduler.instance)        //super: operator       다운스트림의 쓰레드를 변경
        //MainScheduler.instane 를 선언후에 subscribe 를 하면 모든 동작이 DispatchQueue.main.async 에서 실행된다.
            .subscribe(onNext: { json in                //업스트림의 쓰레드를 변경 시작쓰레드의 영향을 준다.
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
            })
        //disposable.dispose()        //버린다라는 뜻인데, 작업한 것을 끝나지 않았어도 dispose() 를 실행하면 동작을 취소할 수 있다.
//        _ = downloadJson(MEMBER_LIST_URL)
//            .subscribe(onNext: { print($0) }, onCompleted: { print($0) })     //completed 와 error 를 받고싶지 않으면 이렇게도 할 수 있다.
            .disposed(by: disposBag)
    }
}
