# 곰튀김님의 RxSwift + MVVM 

우리는 비동기로 생성되는 데이터를 취급하기 위해 컴플리션으로 전달했었는데, return 값으로 전달해주고 싶어서 RxSwift 를 쓴다.  
  
1. RxSwift 비동기적으로 생기는 결과를 컴플리션으로 전달하는게 아니라 return 값으로 전달하기 위한 유틸리티다.  
2. Observable로 오는 데이터를 받아서 return 하는 방법 or 비동기로 생기는 데이터를 Observable 로 감싸서 return 하는 방법이 있다.  
2-1. Observable 의 생명주기는 create() -> subscribe(on: ) -> onNext() or onCompleted() or onError() -> disposed()  
2-2. 여기서 onCompleted() 혹은 onError() 가 오게 되면 클로저가 종료되고 재사용이 불가능해진다. 클로저가 종료되므로 자동으로 메모리가 해제된다.  
3. .debug()    .subscribe 전의 데이터가 전달되는 동안 전달되는 데이터를 다 찍어낼 수 있다.  
4. .observe(on: MainScheduler.instance) 메인쓰레드로 변경되는데, subscribe 라던지 아래에 오는 코드(다운스트림) 모두 메인쓰레드에서 실행된다.  
5. onError or onCompleted() 를 하게 되면 클로저가 해제되면서 메모리가 해제되는데, onError(), onCompleted() 를 선언하지 않고 사용하게 될 경우, 메모리가 해제되지 않는데, onNext() 처리를 해주고 disposeBag 을 해주면 메모리가 해제된다. 단, disposeBag() 타입의 변수를 선언해줘야 한다.  
6. Observable 은 값을 넘겨주는데, 값을 외부에서 받아들일 순 없다. 외부에서 값을 컨트롤 할 수 있는 타입이 Subject 이다.  
6-1. Observable 은 데이터를 이미 정해져 있는 형태의 스트림인데, create 할 때 부터 어떤 데이터를 내보낼 지 정해져 있다. 내부 컨트롤에 의해서 데이터가 동적으로 생성되는 것이 아니다. Observable 밖에서 데이터를 주입시켜주는 스트림이 필요했는데, 데이터를 넣어주고 구독할 수 있는 양방향성을 가진 스트림이 Subject 이다. Observable 처럼 subscribe도 할 수 있다.
7. .bind 를 사용하게 되면, 자동으로 subscribe 를 하게 될 뿐더러, 순환참조를 하지 않아 [weak self] 를 쓰지 않아도 된다.    
8. UI 작업은 항상 UI 쓰레드에서 동작해야 한다. 항상 메인쓰레드에서 동작해야 하기 때문에, .observe(on: MainScheduler.instance) 를 꼭 사용해줘야 한다. UI는 데이터를 처리하다가 도중 에러가 나면 스트림이 끊어지면 안된다. 그래서 .catchErrorJustReturn("")이 있는데, 이거는 에러가 났을 경우 "" 를 바꿔져서 출력하라는 의미다. UI 에 대해서는 이 2줄이 꼭 필요한데, 이 둘을 합친것이 .asDriver(onErrorJustReturn: "").drive() 이다. 여기서 .asDriver() 는 항상 메인쓰레드에서 동작한다.   
9.  Subject 의 경우 UI와 연결되어 있는데, 에러가 나면 스트림이 끊어진다. 그래서 끊어지지 않는 Subject 가 있는데 그게 Relay 다. Subject 와 똑같은데 에러가 나면 스트림이 끊어지지 않는다. completed() onError()가 없기 때문에 항상 허용하는 .accept() 를 사용한다.  
10. Observable 은 UI용으로 Driver, Subject 는 UI용으로 Relay 이다.  
11. 반응형은 비동기 데이터를 컴플리션으로 전달했는데, return 값으로 전달을 할꺼냐. 에 대한 해결책이 Reactive 방식으로 반응형 프로그래밍이다. 리턴값으로 나오긴 했는데, 나중에 쓸 데이터를 리턴값으로 처리하는 방식이다.
