# QWFuture
A Future in Swift that works with a separate thread


## What is QWFuture?
QWFuture is a class that allows an application to run a task in a separate thread with common future class syntax as you know.
This is using `uv_queue_work` internally.


#### Detail of [libuv work queue](https://nikhilm.github.io/uvbook/threads.html#id1)
A seemingly simple class, what makes `uv_queue_work` tempting is that it allows potentially any third-party libraries to be used with the event-loop paradigm.
When you use event loops, it is imperative to make sure that no function which runs periodically in the loop thread blocks when performing I/O or is a serious CPU hog, because this means that the loop slows down and events are not being handled at full capacity.

However, a lot of existing code out there features blocking functions (for example a routine which performs I/O under the hood) to be used with threads if you want responsiveness (the classic ‘one thread per client’ server model), and getting them to play with an event loop library generally involves rolling your own system of running the task in a separate thread. libuv just provides a convenient abstraction for this.


## Usage

Super simple!

```swift
import Suv
import QWFuture

let future = QWFuture<AnyObject> { (result: (() throws -> AnyObject) -> ()) in
    result {
        let db = DB.connect()
        do {
            try db.begin()

            let result = try db.execute("insert into users (id, name) values (1, 'jack')")

            try db.commit()

            return result
        } catch {
            do {
                try db.rollback()
            } catch {
                throw error  
            }
            throw error
        }
    }
}

future.onSuccess {
    print($0)
}

future.onFailure {
    print($0)
}

Loop.defaultLoop.run()
```


## Package.swift
```swift
import PackageDescription

let package = Package(
	name: "MyApp",
	dependencies: [
      .Package(url: "https://github.com/slimane-swift/QWFuture.git", majorVersion: 0, minor: 1)
  ]
)
```

## Licence

QWFuture is released under the MIT license. See LICENSE for details.
