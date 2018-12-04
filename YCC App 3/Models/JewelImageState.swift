//
//  JewelImageState.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 04/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation

// Possible states of jewel image
// 0. Image not reviewed yet
// 1. Import cancelled
// 2. Code Removal unsuccessful. Original Image only imported
// 3. Code Removal successful. Both images imported

enum JewelImageState {
    case notReviewed
    case importCancelled
    case codeRemovalUnsuccessful
    case codeRemovalSuccessful
}
