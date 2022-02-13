//
//  MTAssetBroswerViewModel.swift
//  MT
//
//  Created by cyc on 2019/2/26.
//  Copyright © 2019 MengTao. All rights reserved.
//

import Foundation


public enum MTBrowseAssetMediaType : Int {
    
    case unknown
    
    case image
    
    case video
    
}

// 渠道来源
public struct MTBrowseAsset {
    public var image: UIImage?
    public var imageURL: URL?
    public var videoURL: URL?
    
    
    public init() {
        
    }
    
    public var mediaType: MTBrowseAssetMediaType {
        get {
            if image != nil || imageURL != nil {
                return .image
            }
            
            if videoURL != nil {
                return .video
            }
            
            return .unknown
        }
    }
}
