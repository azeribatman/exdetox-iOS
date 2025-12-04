//
//  MultipartRequest.swift
//  ExDetox
//
//  Created by Aykhan Safarli on 14.04.25.
//

import Foundation

protocol MultipartRequest: Request {
    var fields: [MultipartField] { get }
    var files: [MultipartFile] { get }
    
    func multipartBoundaryData() throws -> (Data, String)
}
