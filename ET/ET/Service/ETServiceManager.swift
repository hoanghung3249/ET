//
//  ETServiceManager.swift
//  ET
//
//  Created by HungNguyen on 11/7/19.
//  Copyright © 2019 HungNguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import Moya_ObjectMapper
import ObjectMapper
import Alamofire

extension ObservableType where E == Response {
    public func filterMMSuccessfulStatus() -> Observable<E> {
        return flatMap { response -> Observable<E> in
            return Observable.just(try response.filterMMSuccessfulStatus())
        }
    }
}

public extension Response {
    func filterMMSuccessfulStatus() throws -> Response {
        guard (200...399).contains(statusCode)/* || statusCode == 404*/ else {
//            let moya = MoyaError.jsonMapping(self)
//            let json = moya.response?.data.toJSON()
//            throw ErrorStatus.wrongFormat(message: json?["message"] as? String ?? "")
            throw MoyaError.statusCode(self)
        }
        return self
    }
}

class DefaultAlamofireManager: Alamofire.SessionManager {
    static let sharedManager: DefaultAlamofireManager = {
        let configuration = URLSessionConfiguration.default
        var timeOut: TimeInterval = 15
        configuration.timeoutIntervalForRequest = timeOut // as seconds, you can set your request timeout
        return DefaultAlamofireManager(configuration: configuration)
    }()
    
    convenience init(requestTimeOut: TimeInterval) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = requestTimeOut
        self.init(configuration: configuration)
    }
}

class ETServiceManager {
    static let shared = ETServiceManager()
    
    private let defaultProvider: MoyaProvider<ETServiceAPI>!
    private let providerPlugins: [PluginType] = [NetworkLoggerPlugin(verbose: true)]
    
    init() {
        defaultProvider = MoyaProvider<ETServiceAPI>(manager: DefaultAlamofireManager.sharedManager, plugins: providerPlugins)
    }
    
    func requestWithMultiPart(_ url: String, _ parameters: [String: Any]? , _ images: [UIImage], _ withNames: [String],_ header:[String:String]) -> Observable<Response> {
        return Observable.create { (observer)  in
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                for i in 0..<images.count{
                    let image = images[i]
                    let withName = withNames[i]
                    let nameFile = UUID().uuidString
                    
                    
                    let imgData = image.jpegData(compressionQuality: 1)
                    let imageSizeMB :Double = Double(imgData!.count) / 1024.0 / 1024.0 //mb
                    
                    print("size of image in B = \(imageSizeMB)")
                    multipartFormData.append(imgData!, withName: withName, fileName: "\(nameFile).jpg", mimeType: "image/jpeg")
                }
                
                // import parameters
                if parameters != nil  {
                    for (key, valueElement) in parameters! {
                        if valueElement is String || valueElement is Int || valueElement is Double {
                            multipartFormData.append("\(valueElement)".data(using: .utf8)!, withName: key)
                        }
                        if let valueElement = valueElement as? [String] {
                            for value in valueElement {
                                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                            }
                        }
                    }
                }
            }, usingThreshold: UInt64.init(), to: url, method: .post, headers: header) { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        switch response.result {
                        case .success(let data):
                            guard let data = data as? [String: Any] else { return }
                            
                            let res = Response(statusCode: response.response?.statusCode ?? 500, data: data.toData() ?? Data())
                            observer.onNext(res)
                            observer.onCompleted()
                            break
                        case .failure(let error):
                            observer.onError(error)
                            break
                        }
                    }
                case .failure(let encodingError):
                    observer.onError(encodingError)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func request<T: BaseMappable>(_ service: ETServiceAPI, mapObject: T.Type) -> Observable<T> {
        return request(serviceAPI: service, requestTimeOut: nil)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .retry(2)
            .mapObject(T.self)
            .observeOn(MainScheduler.instance)
    }
    
    func requestUploadFile<T: BaseMappable>(_ url: String, _ parameters: [String: Any]? , _ images: [UIImage], _ withNames: [String],_ header:[String:String], mapObject: T.Type) -> Observable<T> {
        return requestWithMultiPart(url, parameters, images, withNames,header)
            .filterMMSuccessfulStatus()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .mapObject(T.self)
            .observeOn(MainScheduler.instance)
    }
    
    func request(serviceAPI: ETServiceAPI, requestTimeOut: TimeInterval? = nil) -> Observable<Response> {
        //** Call API request
        return defaultProvider.rx.request(serviceAPI).asObservable()
            .filterMMSuccessfulStatus()
            .flatMapLatest({ (response) -> Observable<Response> in
                return Observable.just(response)
            }).catchError({ (error) -> Observable<Response> in
                return Observable.error(error)
            })
    }
    
}
