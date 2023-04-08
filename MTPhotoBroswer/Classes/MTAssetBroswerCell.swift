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
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = true
        scrollView.addGestureRecognizer(tapGesture)
        scrollView.contentInsetAdjustmentBehavior = .never
        
        tapGesture.require(toFail: scrollView.panGestureRecognizer)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(MTAssetBroswerCell.scrowViewDidDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        tapGesture.require(toFail: doubleTap)
        scrollView.addGestureRecognizer(doubleTap)
        return scrollView
    }()
    
    var indicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .white)
    
    var tappedHandle: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(scrollView)
        scrollView.addSubview(photoView)
        contentView.addSubview(indicatorView)
        clipsToBounds = true
        
        
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
                photoView.kf.setImage(with: imageURL) { [weak self] result in
                    self?.photoViewSizeToFit()
                }
            }
        }
    }
    
    var startPoint: CGPoint?
}

extension MTAssetBroswerCell : UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.photoView
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            print("捏合状态是否：")
            print(scrollView.pinchGestureRecognizer?.state == .changed)
            let gesturePoint = scrollView.panGestureRecognizer.location(in: nil)
            let scale = 1 - min(1, abs(gesturePoint.y - startPoint!.y) / 200) / scrollView.zoomScale
            (mt_controller as? MTAssetBroswerViewController)?.backgroundView.alpha = scale
//            self.transform = .init(scaleX: max(0.2, scale), y: max(0.2, scale))
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startPoint = scrollView.panGestureRecognizer.location(in: nil)
        
    }
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let gesturePoint = scrollView.panGestureRecognizer.location(in: nil)
        let scale = 1 - min(1, abs(gesturePoint.y - startPoint!.y) / 200) / scrollView.zoomScale
        let vc = (mt_controller as? MTAssetBroswerViewController)
        if scale <= 0.6  {
            vc?.close(dragCell: self)
        } else {
            UIView.animate(withDuration: 0.25) {
                scrollView.panGestureRecognizer.view?.transform = CGAffineTransform.identity
                vc?.backgroundView.alpha = 1
            }
        }
    }
}
