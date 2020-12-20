//
//  Future.swift
//  Microfutures
//
//  Created by Fernando on 27/1/17.
//  Copyright © 2017 Fernando. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case failure(Error)
}

protocol FutureType {
    associatedtype FutureValueType
    func subscribe(onNext: @escaping (Self.FutureValueType) -> Void, onError: @escaping (Error) -> Void)
    func map<U>(_ f: @escaping (FutureValueType) throws -> U) -> Future<U>
    func flatMap<U>(_ f: @escaping (FutureValueType) -> Future<U>) -> Future<U>
}

public struct Future<T>: FutureType {
    public typealias ResultType = Result<T>
    
    private let operation: ( @escaping (ResultType) -> ()) -> ()
    
    public init(result: ResultType) {
        self.init(operation: { completion in
            completion(result)
        })
    }
    
    public init(value: T) {
        self.init(result: .success(value))
    }
    
    public init(error: Error) {
        self.init(result: .failure(error))
    }
    
    public init(operation: @escaping ( @escaping (ResultType) -> ()) -> ()) {
        self.operation = operation
    }
    
    fileprivate func then(_ completion: @escaping (ResultType) -> ()) {
        self.operation() { result in
            completion(result)
        }
    }
    
    public func subscribe(onNext: @escaping (T) -> Void = { _ in }, onError: @escaping (Error) -> Void = { _ in }) {
        self.then { result in
            switch result {
            case .success(let value): onNext(value)
            case .failure(let error): onError(error)
            }
        }
    }
}

extension Collection where Element: FutureType {
    func subscribe(
        onNext: @escaping (Element.FutureValueType) -> Void = { _ in },
        onError: @escaping (Error) -> Void = { _ in },
        onFinal: @escaping () -> Void = {}
    ) {
        if (self.isEmpty) {
            onFinal()
        } else {
            var counter = self.count
            let queue = DispatchQueue(label: UUID().description)
            let advance = {
                queue.sync {
                    counter = counter - 1
                    if (counter == 0) { onFinal() }
                }
            }
            self.forEach { element in
                element.subscribe(onNext: { next in
                    defer { advance() }
                    onNext(next)
                }, onError: { error in
                    defer { advance() }
                    onError(error)
                })
            }
        }
    }
    
    func flatten() -> Future<[Element.FutureValueType]> {
        return Future { completion in
            if (self.isEmpty) {
                completion(.success([]))
            } else {
                var nextDictionary: Dictionary<UUID, Element.FutureValueType> = [:]
                var errorDictionary: Dictionary<UUID, Error> = [:]
                var counter = self.count
                let queue = DispatchQueue(label: UUID().description)
                let identifiableCollection = self.map { element -> (UUID, Element) in
                    let uuid = UUID()
                    return (uuid, element)
                }
                identifiableCollection.forEach { uuid, element in
                    element.subscribe(onNext: { next in
                        nextDictionary[uuid] = next
                        queue.sync {
                            counter = counter - 1
                            if (counter == 0 && errorDictionary.isEmpty) {
                                completion(.success(identifiableCollection.map { uuid, element in
                                    return nextDictionary[uuid]!
                                }))
                            }
                        }
                    }, onError: { error in
                        if (errorDictionary.isEmpty) {
                            completion(.failure(error))
                        }
                        errorDictionary[uuid] = error
                    })
                }
            }
        }
    }
}

extension Future {
    public func map<U>(_ f: @escaping (T) throws -> U) -> Future<U> {
        return Future<U>(operation: { completion in
            self.then { result in
                switch result {
                    
                case .success(let resultValue):
                    do {
                        let transformedValue = try f(resultValue)
                        completion(Result.success(transformedValue))
                    } catch let error {
                        completion(Result.failure(error))
                    }
                    
                    
                case .failure(let errorBox):
                    completion(Result.failure(errorBox))
                    
                }
            }
        })
    }
    
    public func flatMap<U>(_ f: @escaping (T) -> Future<U>) -> Future<U> {
        return Future<U>(operation: { completion in
            self.then { firstFutureResult in
                switch firstFutureResult {
                case .success(let value): f(value).then(completion)
                case .failure(let error): completion(Result.failure(error))
                }
            }
        })
    }
}
