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
    /// 图片
    public var image: UIImage?
    /// image 链接 本地/远程
    public var imageURL: URL?
    /// video 链接 本地/远程
    public var videoURL: URL?
    
    
    public init() {
        
    }
    
    /// 资源类型
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
