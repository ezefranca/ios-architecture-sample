import Foundation
import RxSwift

protocol RideProgressViewType: class {
    func show(viewModel: RideProgressViewModel)
    func didFinishProgress()
}

class RideProgressPresenter: RideProgressPresenterType {
    
    weak var view: RideProgressViewType?
    
    fileprivate let repository: RideRepositoryType
    fileprivate let disposeBag = DisposeBag()
    fileprivate var viewModel = RideProgressViewModel(progress: 0) {
        didSet(oldValue) {
            if viewModel != oldValue {
                self.view?.show(viewModel: self.viewModel)
            }
        }
    }
    
    init(repository: RideRepositoryType) {
        self.repository = repository
    }
    
    func viewDidLoad() {
        self.listenToRideUpdates()
        self.view?.show(viewModel: RideProgressViewModel(progress:0))
    }
}

extension RideProgressPresenter {
    
    fileprivate func listenToRideUpdates() {
        self.repository.rideObservable
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (progress) in
                    self?.viewModel = RideProgressViewModel(progress: progress)
                },
                onCompleted: { [weak self] in
                    self?.view?.didFinishProgress()
                })
            .addDisposableTo(self.disposeBag)
    }
}
