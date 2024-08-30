# 곰튀김 RxSwift

우리는 비동기로 생성되는 데이터를 취급하기 위해 컴플리션으로 전달했었는데, return 값으로 전달해주고 싶어서 RxSwift 를 쓴다.  
1. RxSwift 비동기적으로 생기는 결과를 컴플리션으로 전달하는게 아니라 return 값으로 전달하기 위한 유틸리티다.  
2. Observable로 오는 데이터를 받아서 return 하는 방법 or 비동기로 생기는 데이터를 Observable 로 감싸서 return 하는 방법이 있다.  
2-1. Observable 의 생명주기는 create() -> subscribe(on: ) -> onNext() or onCompleted() or onError() -> disposed()  
2-2. 여기서 onCompleted() 혹은 onError() 가 오게 되면 클로저가 종료되고 재사용이 불가능해진다. 클로저가 종료되므로 자동으로 메모리가 해제된다.  
3. .debug()    .subscribe 전의 데이터가 전달되는 동안 전달되는 데이터를 다 찍어낼 수 있다.  
4. .observe(on: MainScheduler.instance) 메인쓰레드로 변경되는데, subscribe 라던지 아래에 오는 코드(다운스트림) 모두 메인쓰레드에서 실행된다.  
5. onError or onCompleted() 를 하게 되면 클로저가 해제되면서 메모리가 해제되는데, onError(), onCompleted() 를 선언하지 않고 사용하게 될 경우, 메모리가 해제되지 않는데, onNext() 처리를 해주고 disposeBag 을 해주면 메모리가 해제된다.  
