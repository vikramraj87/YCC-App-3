//
//  CodeRemovalService.swift
//  YCC App 3
//
//  Created by Vikram Raj Gopinathan on 02/12/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation
import Alamofire
import Vision




class CodeRemovalService {
    let url: URL
    
    init(host: String, port: Int) {
        url = URL(string: "http://\(host):\(port)/")!
    }
    
    // Removes detected text observations from
    // Image at imageURL
    // On successful removal, edited image url is passed to completion handler
    // Else nil is passed
    func remove(_ observations: [VNTextObservation],
                fromImageAt imageURL: URL,
                codeRemovalHandler: @escaping (URL?) -> Void) {
        guard let characterBoxesData = observations.encoded.data(using: .utf8) else {
            print("Error encoding character boxes data")
            codeRemovalHandler(nil)
            return
        }
        
        guard let fileName = imageURL.lastPathComponent.data(using: .utf8) else {
            print("Not able to encode original file name of the image")
            codeRemovalHandler(nil)
            return
        }
        
        Alamofire.upload(multipartFormData: { data in
            data.append(imageURL, withName: "image")
            data.append(characterBoxesData, withName: "char_boxes_data")
            data.append(fileName, withName: "original_filename")
        }, to: self.url) { [weak self] encodingResult in
            guard let strongSelf = self else {
                print("Not able to get hold of self")
                codeRemovalHandler(nil)
                return
            }
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    guard let jsonResponse = response.result.value as? [String: Any] else {
                        print("Invalid JSON Response")
                        codeRemovalHandler(nil)
                        return
                    }
                    let fileName = jsonResponse["filename"] as! String
                    let editedURL = strongSelf.urlForEditedImageWithFileName(fileName)
                    codeRemovalHandler(editedURL)
                }
            case .failure(let encodingError):
                print(encodingError)
                codeRemovalHandler(nil)
            }
        }
    }
    
//    func remove(_ observations: [VNTextObservation],
//                from jewelImage: JewelImageProtocol,
//                codeRemovalHandler: @escaping (URL?) -> Void) {
//        guard let characterBoxesData = observations.encoded.data(using: .utf8) else {
//            print("Error encoding character boxes data")
//            return
//        }
//
//        guard let originalFileName = jewelImage.originalURL.lastPathComponent.data(using: .utf8) else {
//            print("Not able to encode original file name")
//            return
//        }
//
//        Alamofire.upload(multipartFormData: { multipartFormData in
//            multipartFormData.append(jewelImage.originalURL, withName: "image")
//            multipartFormData.append(characterBoxesData, withName: "char_boxes_data")
//            multipartFormData.append(originalFileName, withName: "original_filename")
//        }, to: url,
//           encodingCompletion: { [weak self] encodingResult in
//            guard let strongSelf = self else {
//                codeRemovalHandler(nil)
//                return
//            }
//            switch encodingResult {
//            case .success(let upload, _, _):
//                upload.responseJSON { response in
//                    guard let jsonResponse = response.result.value as? [String: Any] else { return }
//                    guard let fileName = jsonResponse["filename"] as? String else { return }
//                    let editedURL = strongSelf.urlForEditedImageWithFileName(fileName)
//                    codeRemovalHandler(editedURL)
//                }
//            case .failure(let encodingError):
//                print(encodingError)
//                codeRemovalHandler(nil)
//            }
//        })
//    }
    
    fileprivate func urlForEditedImageWithFileName(_ fileName: String) -> URL {
        return url.appendingPathComponent("edited")
                  .appendingPathComponent(fileName)
    }
    
}
