//
//  OperationQueue+serialQueue.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 13/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation

extension OperationQueue {
    static func serialQueue() -> OperationQueue {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }
}

