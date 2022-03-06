//
//  PhotoResponse.swift
//  BackgroundApp
//
//  Created by Cheng Peng on 2022-03-06.
//

import Foundation

struct ImageModel: Codable{
    let id: String
    let created_at: String
    let updated_at: String
    let width: Int
    let height: Int
    let color: String
    let description: String?
    let urls: urls
    let links: links
}

struct urls: Codable{
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    let small_s3: String
}

struct links: Codable{
    let `self`: String
    let html: String
    let download: String
    let download_location: String
}
