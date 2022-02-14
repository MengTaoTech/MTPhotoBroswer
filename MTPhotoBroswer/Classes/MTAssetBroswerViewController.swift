//
//  MTAssetBrosweViewController.swift
//  MT
//
//  Created by cyc on 2019/1/14.
//  Copyright © 2019 MengTao. All rights reserved.
//

import UIKit
import Photos
import SnapKit



public class MTAssetBroswerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    lazy private var collectionView: UICollectionView = {
        let latout = UICollectionViewFlowLayout()
        latout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: latout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        // register
        collectionView.register(MTAssetBroswerCell.self, forCellWithReuseIdentifier: "MTAssetBroswerCell")
        collectionView.register(MTAssetVideoBroswerCell.self, forCellWithReuseIdentifier: "MTAssetVideoBroswerCell")
        
        return collectionView
    }()
    
    private var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        return pageControl
    }()
    
    public var assets: [MTBrowseAsset] = []
    
    public convenience init(image: UIImage) {
        self.init(images: [image])
    }
    
    public convenience init(images: [UIImage], index: Int = 0) {
        let assets = images.map { image -> MTBrowseAsset in
            var asset = MTBrowseAsset()
            asset.image = image
            return asset
        }
        self.init(assets: assets)
        self.currentPage = index
    }
    
    
    public convenience init(url: URL) {
        self.init(urls: [url])
    }
    
    public convenience init(urls: [URL]) {
        let assets = urls.map { url -> MTBrowseAsset in
            var asset = MTBrowseAsset()
            asset.imageURL = url
            return asset
        }
        self.init(assets: assets)
    }
    
    public convenience init(asset: MTBrowseAsset) {
        self.init(assets: [asset])
    }
    
    public convenience init(assets: [MTBrowseAsset]) {
        self.init()
        self.assets = assets
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    
    public var currentPage: Int = 0
    
//    var originFrame: CGRect?
    
    var shadowView: UIView = {
        let shadowView = UIView()
        shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return shadowView
    }()
    
//    let blurEffectView = UIVisualEffectView(frame: .zero)
    
    let backgroundView = UIView()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        
//        view.addSubview(blurEffectView)
        view.addSubview(backgroundView)
        backgroundView.backgroundColor = .black
        
        view.addSubview(shadowView)
        shadowView.isUserInteractionEnabled = true
        shadowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MTAssetBroswerViewController.close)))
        
        
//        blurEffectView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        shadowView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            } else {
                make.bottom.equalToSuperview().offset(-20)
            }
        }
        
    
        pageControl.numberOfPages = assets.count
        
        pageControl.currentPage = currentPage
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.alpha = 0
//        blurEffectView.effect = nil
        
    }
    
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) {
//            self.blurEffectView.effect = UIBlurEffect(style: .light)
            self.view.alpha = 1
        }
        
        collectionView.scrollToItem(at: IndexPath(item: currentPage, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    var dismissHandler: (() -> ())?
    
    @objc func close() {
        UIView.animate(withDuration: 0.25, animations: {
//            self.blurEffectView.effect = nil
            self.view.alpha = 0
        }) { (_) in
            self.dismiss(animated: false, completion: self.dismissHandler)
        }
    }
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        print(#function)
//        if scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating {
            let index = Int(max(scrollView.contentOffset.x / scrollView.frame.width, 0))
            pageControl.currentPage = index
            currentPage = index
//        }
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = self.assets[indexPath.row]
        switch asset.mediaType {
        case .image:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MTAssetBroswerCell", for: indexPath) as! MTAssetBroswerCell
            cell.brosweAsset = asset
            cell.tappedHandle = { [unowned self] in
                self.close()
            }
            return cell
        case .video:
            let videoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MTAssetVideoBroswerCell", for: indexPath) as! MTAssetVideoBroswerCell
            videoCell.update(url: asset.videoURL!)
            
            return videoCell
        case .unknown:
            fatalError("Don't match any style cell")
        }
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.close()
    }
}
