//
//  CodeRemovalOperation.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 04/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation

class CodeRemovalOperation: Operation {
    let service: CodeRemovalService
    
    init(service: CodeRemovalService) {
        self.service = service
    }
}
