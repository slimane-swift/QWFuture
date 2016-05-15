//
//  QWFuture.swift
//  QWFuture
//
//  Created by Yuki Takei on 5/12/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

@_exported import Suv

public final class QWFuture<T> {
    
    private let handler: ((() throws -> T) -> ()) -> ()
    
    private let loop: Loop
    
    private var result: T?
    
    private var error: ErrorProtocol?
    
    private var onSucessHandler: (T) -> () = { _ in }
    
    private var onFailureHandler: (ErrorProtocol) -> () = { _ in }
    
    private var settled = false
    
    public init(loop: Loop = Loop.defaultLoop, handler: ((() throws -> T) -> ()) -> ()){
        self.loop = loop
        self.handler = handler
    }
    
    public func onSuccess(_ handler: (T) -> ()){
        self.onSucessHandler = handler
        attemptToInvoke()
    }
    
    public func onFailure(_ handler: (ErrorProtocol) -> ()){
        self.onFailureHandler = handler
        attemptToInvoke()
    }
    
    private func attemptToInvoke(){
        if settled {
            return
        }
        
        settled = true
        
        let onThread = { [unowned self] in
            self.handler {
                do {
                    self.result = try $0()
                } catch {
                    self.error = error
                }
            }
        }
        
        let onFinish = { [unowned self] in
            if let error = self.error {
                self.onFailureHandler(error)
                return
            }
            self.onSucessHandler(self.result!)
        }
        
        Process.qwork(loop: loop, onThread: onThread, onFinish: onFinish)
    }
}