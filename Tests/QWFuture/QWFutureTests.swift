//
//  QWFutureTests.swift
//  QWFuture
//
//  Created by Yuki Takei on 5/12/16.
//
//

import XCTest
import Suv
@testable import QWFuture

enum Error: ErrorProtocol {
    case Something
}

class QWFutureTests: XCTestCase {
    static var allTests: [(String, (QWFutureTests) -> () throws -> Void)] {
        return [
             ("testFutureSuccess", testFutureSuccess),
             ("testFutureFailure", testFutureFailure),
        ]
    }
    
    func testFutureSuccess() {
        let future = QWFuture<String> { (done: (() throws -> String) -> ()) in
            done {
                return "foobar"
            }
        }
        
        future.onSuccess {
            XCTAssertEqual("foobar", $0)
        }
        
        future.onFailure { _ in
            XCTFail("Never called")
        }
        
        Loop.defaultLoop.run()
    }


    func testFutureFailure() {
        let future = QWFuture<String> { (done: (() throws -> String) -> ()) in
            done {
                throw Error.Something
            }
        }
        
        future.onSuccess { _ in
            XCTFail("Never called")
        }
        
        future.onFailure { _ in
            XCTAssertTrue(true)
        }
        
        Loop.defaultLoop.run()
    }
}


