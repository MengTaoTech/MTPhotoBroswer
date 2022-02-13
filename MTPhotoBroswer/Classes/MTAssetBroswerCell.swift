//
//  MTAssetBroswerCell.swift
//  MT
//
//  Created by cyc on 2019/1/14.
//  Copyright © 2019 MengTao. All rights reserved.
//

import UIKit
import Kingfisher

public class MTAssetBroswerCell: UICollectionViewCell {
    
    let photoView: UIImageView = {
        let photoView = UIImageView()
        photoView.isUserInteractionEnabled = true
        photoView.contentMode = .scaleAspectFill
        return photoView
    }()
    
    lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(MTAssetBroswerCell.scrowViewDidTapped))
    
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.delegate = self
        scrollView.maximumZoomScale = 3
        scrollView.clipsToBounds = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.addGestureRecognizer(tapGesture)
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        tapGesture.require(toFail: scrollView.panGestureRecognizer)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(MTAssetBroswerCell.scrowViewDidDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        tapGesture.require(toFail: doubleTap)
        scrollView.addGestureRecognizer(doubleTap)
        return scrollView
    }()
    
    var indicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    var tappedHandle: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(scrollView)
        scrollView.addSubview(photoView)
        contentView.addSubview(indicatorView)
        
        indicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func scrowViewDidTapped() {
        tappedHandle?()
    }
    
    @objc private func scrowViewDidDoubleTapped(_ gesture: UITapGestureRecognizer) {
        if photoView.image == nil {
            return
        }
        
        var zoomScale = scrollView.zoomScale
        if zoomScale == 1.0 {
            zoomScale = (zoomScale == 1.0) ? 3.0 : 1.0
            let tapCenter = gesture.location(in: gesture.view)
            
            
            let zoomRect = CGRect(x: tapCenter.x - scrollView.frame.width / zoomScale / 2, y: tapCenter.y - scrollView.frame.height / zoomScale / 2, width: scrollView.frame.width / zoomScale, height: scrollView.frame.height / zoomScale)
            
            scrollView.zoom(to: zoomRect, animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
        
        
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        indicatorView.isHidden = true
        photoView.kf.cancelDownloadTask()
        photoView.image = nil
        photoViewSizeToFit()
    }
    
    func photoViewSizeToFit() {
        guard let image = photoView.image else {
            return
        }
        if self.indicatorView.isAnimating {
            indicatorView.stopAnimating()
        }
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let photoHeight = screenWidth / image.size.width * image.size.height
        scrollView.contentSize = CGSize(width: screenWidth, height: photoHeight)
        
        if photoHeight > screenHeight {
            scrollView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: min(screenWidth, photoHeight))
        } else {
            scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: min(UIScreen.main.bounds.height, photoHeight))
            scrollView.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        }
        
        photoView.frame = CGRect(origin: .zero, size: scrollView.contentSize)
        
        
    }
    
    
    
    var brosweAsset: MTBrowseAsset? {
        didSet {
            guard let brosweAsset = brosweAsset else { return }
            
            if let image = brosweAsset.image {
                self.photoView.image = image
                self.photoViewSizeToFit()
                
                
            } else if let imageURL = brosweAsset.imageURL {
                indicatorView.startAnimating()
                photoView.kf.setImage(with: imageURL, placeholder: nil, options: nil, progressBlock: nil) { [weak self] (image, error, cacheType, url) in
                    self?.photoViewSizeToFit()
                }
                
                
            }
        }
    }
    
    
    
}

extension MTAssetBroswerCell : UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.photoView
    }
    
}
