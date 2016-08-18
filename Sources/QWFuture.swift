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
    
    private var onSucessHandler: (T) -> () = { _ in }
    
    private var onFailureHandler: (Error) -> () = { _ in }
    
    private var settled = false
    
    public init(loop: Loop = Loop.defaultLoop, handler: @escaping ((() throws -> T) -> ()) -> ()){
        self.loop = loop
        self.handler = handler
    }
    
    public func onSuccess(_ handler: @escaping (T) -> ()){
        self.onSucessHandler = handler
        execute()
    }
    
    public func onFailure(_ handler: @escaping (Error) -> ()){
        self.onFailureHandler = handler
        execute()
    }
    
    private func execute(){
        if settled {
            return
        }
        
        settled = true
        
        let onThread: (QueueWorkContext) -> Void = { ctx in
            self.handler {
                do {
                    ctx.storage["result"] = try $0()
                } catch {
                    ctx.storage["error"] = error
                }
            }
        }
        
        let onFinish: (QueueWorkContext) -> Void = { ctx in
            if let error = ctx.storage["error"] as? Error {
                self.onFailureHandler(error)
                return
            }
            self.onSucessHandler(ctx.storage["result"] as! T)
        }
        
        Process.qwork(loop: loop, onThread: onThread, onFinish: onFinish)
    }
}
