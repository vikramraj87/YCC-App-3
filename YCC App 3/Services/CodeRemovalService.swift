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
    
    func remove(_ observations: [VNTextObservation],
                from jewelImage: JewelImageProtocol,
                codeRemovalHandler: @escaping (URL?) -> Void) {
        guard let characterBoxesData = observations.encoded.data(using: .utf8) else {
            print("Error encoding character boxes data")
            return
        }
        
        guard let originalFileName = jewelImage.originalURL.lastPathComponent.data(using: .utf8) else {
            print("Not able to encode original file name")
            return
        }
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(jewelImage.originalURL, withName: "image")
            multipartFormData.append(characterBoxesData, withName: "char_boxes_data")
            multipartFormData.append(originalFileName, withName: "original_filename")
        }, to: url,
           encodingCompletion: { [weak self] encodingResult in
            guard let strongSelf = self else {
                codeRemovalHandler(nil)
                return
            }
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    guard let jsonResponse = response.result.value as? [String: Any] else { return }
                    guard let fileName = jsonResponse["filename"] as? String else { return }
                    let editedURL = strongSelf.urlForEditedImageWithFileName(fileName)
                    codeRemovalHandler(editedURL)
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    
    fileprivate func urlForEditedImageWithFileName(_ fileName: String) -> URL {
        return url.appendingPathComponent("edited")
                  .appendingPathComponent(fileName)
    }
    
}
