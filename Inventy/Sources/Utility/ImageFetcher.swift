import Foundation
import RxSwift
import RxCocoa

protocol ImageFetcher {
    
    func fetch(from path: String) -> Observable<UIImage?>
}

// MARK: -
class DefaultImageFetcher: ImageFetcher {
    
    // The method will not emit errors when an error occurred UIImage will be nil
    func fetch(from path: String) -> Observable<UIImage?> {
        guard let url = URL(string: path) else {
            return Observable.from(optional: nil)
        }
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let cachedImage = cachedImage(for: request) {
            return Observable.from(optional: cachedImage)
        }
        
        let img = BehaviorRelay<UIImage?>(value: nil)
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            guard let imgData = data, error == nil else {
                img.accept(nil)
                return
            }
            
            let image = UIImage(data: imgData)
            img.accept(image)
            if let response = response, image != nil {
                URLCache.shared.storeCachedResponse(CachedURLResponse(response: response, data: imgData), for: request)
            }
        }
        task.resume()
        return img.asObservable()
    }
    
    // MARK: -
    private func cachedImage(for request: URLRequest) -> UIImage? {
        guard let data = URLCache.shared.cachedResponse(for: request)?.data else {
            return nil
        }
        return UIImage(data: data)
    }
}
