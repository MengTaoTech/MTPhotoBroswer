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

fileprivate var MTAssetBroswerAnimateDuration: TimeInterval = 0.3

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
    
    /// 用户点击的视图
    public var presentingImageView: UIImageView?
    
    private var fakeImageView: UIImageView?
    
    
    public var assets: [MTBrowseAsset] = []
    
    public convenience init(image: UIImage) {
        self.init(images: [image])
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - images: image 数组
    ///   - index: 展示第几个
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
    
    
    /// 当前位置
    public var currentPage: Int = 0
    
    var shadowView: UIView = {
        let shadowView = UIView()
        shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return shadowView
    }()
    
//    let blurEffectView = UIVisualEffectView(frame: .zero)
    
   
    public lazy var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MTAssetBroswerViewController.close)))
        return backgroundView
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        setupUI()
    }
    
    func setupUI() {
        
//        view.addSubview(blurEffectView)
        view.addSubview(backgroundView)

        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
//
//        view.addSubview(shadowView)
//        shadowView.isUserInteractionEnabled = true
//        shadowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MTAssetBroswerViewController.close)))
//        shadowView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
        
//        blurEffectView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
        
       
        
       
        
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
        
        
        if needFakeImageViewAnimateWhenViewDidAppear() {
            if let presentingImageView = presentingImageView, let presentingImage = presentingImageView.image {
                fakeImageView = UIImageView(image: presentingImage)
                fakeImageView?.contentMode = .scaleAspectFit
                fakeImageView?.layer.cornerRadius = presentingImageView.layer.cornerRadius
                view.addSubview(fakeImageView!)
                
               
       
                fakeImageSizeToFit(presentingImageView: presentingImageView)
                
            }
            collectionView.isHidden = true
        }
        
    }
    
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backgroundView.alpha = 0
//        blurEffectView.effect = nil
        
  
        
    }
    
    
    func fakeImageSizeToFit(presentingImageView: UIImageView) {
        guard let presentingImage = presentingImageView.image else {
            return
        }
        // presentingImageView 可能样式不一定是常规格式
        let presentingFrameInWindow = presentingImageView.convert(presentingImageView.bounds, to: nil)
        
        
        let scale = presentingImage.size.width / presentingImage.size.height
        
        switch presentingImageView.contentMode {
            
        //  通过 Example中的 LocalPhotoViewController 去调试查看
        
        // 由于UIImageView 默认是 scaleAspectFit 这个参数
        // 而 redraw 这个参数并不会改变UIImageView的样式的，默认采用 scaleAspectFit这个参数
        //  如果用户按照以下顺序设置contentMode     scaleToFill->redraw  （在设置为redraw 之前设置了另外一个不是scaleAspectFit的） 则会出现bug，场景极其之少
        case .scaleAspectFit, .redraw:
            if scale >= 1 {
                // 宽大于高
                let height = presentingFrameInWindow.size.width / scale
                fakeImageView?.frame = CGRect(x: presentingFrameInWindow.origin.x, y: presentingFrameInWindow.midY - height / 2, width: presentingFrameInWindow.size.width, height: height)
            } else {
                let width = presentingFrameInWindow.size.height * scale
                fakeImageView?.frame = CGRect(x: presentingFrameInWindow.midX - width / 2, y: presentingFrameInWindow.origin.y, width: width, height: presentingFrameInWindow.size.height)
            }
        case .scaleToFill:
            // 和scaleAspectFill的时候 效果会好看一点
            fallthrough
        case .scaleAspectFill:
            let height = presentingFrameInWindow.size.width / scale
            fakeImageView?.frame = CGRect(x: presentingFrameInWindow.origin.x, y: presentingFrameInWindow.midY - height / 2, width: presentingFrameInWindow.size.width, height: height)
        case .center:
            fakeImageView?.frame = CGRect(x: presentingFrameInWindow.midX - presentingImage.size.width / 2, y: presentingFrameInWindow.midY - presentingImage.size.height / 2, width: presentingImage.size.width, height: presentingImage.size.height)
        case .top:
            fakeImageView?.frame = CGRect(x: presentingFrameInWindow.midX - presentingImage.size.width / 2, y: presentingFrameInWindow.origin.y, width: presentingImage.size.width, height: presentingImage.size.height)
        case .bottom:
            fakeImageView?.frame = CGRect(x: presentingFrameInWindow.midX - presentingImage.size.width / 2, y: presentingFrameInWindow.maxY - presentingImage.size.height, width: presentingImage.size.width, height: presentingImage.size.height)
        case .left:
            fakeImageView?.frame = CGRect(x: presentingFrameInWindow.minX, y: presentingFrameInWindow.midY - presentingImage.size.height / 2, width: presentingImage.size.width, height: presentingImage.size.height)
        case .right:
            fakeImageView?.frame = CGRect(x: presentingFrameInWindow.maxX - presentingImage.size.width, y: presentingFrameInWindow.midY - presentingImage.size.height / 2, width: presentingImage.size.width, height: presentingImage.size.height)
        case .topLeft:
            fakeImageView?.frame = CGRect(x: presentingFrameInWindow.origin.x, y: presentingFrameInWindow.origin.y, width: presentingImage.size.width, height: presentingImage.size.height)
        case .topRight:
            fakeImageView?.frame = CGRect(x: presentingFrameInWindow.maxX - presentingImage.size.width, y: presentingFrameInWindow.origin.y, width: presentingImage.size.width, height: presentingImage.size.height)
        case .bottomLeft:
            fakeImageView?.frame = CGRect(x: presentingFrameInWindow.minX, y: presentingFrameInWindow.maxY - presentingImage.size.height, width: presentingImage.size.width, height: presentingImage.size.height)
        case .bottomRight:
            fakeImageView?.frame = CGRect(x: presentingFrameInWindow.maxX - presentingImage.size.width, y: presentingFrameInWindow.maxY - presentingImage.size.height, width: presentingImage.size.width, height: presentingImage.size.height)
        default:
            break
        }
    }
    
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        
        collectionView.scrollToItem(at: IndexPath(item: currentPage, section: 0), at: .centeredHorizontally, animated: false)
        
        if needFakeImageViewAnimateWhenViewDidAppear(), let fakeImageView = fakeImageView, let image = fakeImageView.image {
            
            
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            let photoHeight = screenWidth / image.size.width * image.size.height
            
            var frame: CGRect
            if photoHeight > screenHeight {
                frame = CGRect(x: 0, y: 0, width: screenWidth, height: min(screenWidth, photoHeight))
            } else {
                let minHeight = min(UIScreen.main.bounds.height, photoHeight)
                frame = CGRect(x: 0, y: screenHeight / 2 - minHeight / 2, width: UIScreen.main.bounds.width, height: minHeight)
            }
            
            
            
            UIView.animate(withDuration: MTAssetBroswerAnimateDuration, delay: 0, options: []) {
                fakeImageView.frame = frame
                fakeImageView.layer.cornerRadius = 0
                self.backgroundView.alpha = 1
            } completion: { _ in
                self.fakeImageView?.alpha = 0
                self.collectionView.isHidden = false
            }

        } else {
         
            UIView.animate(withDuration: MTAssetBroswerAnimateDuration) {
    //            self.blurEffectView.effect = UIBlurEffect(style: .light)
                self.view.alpha = 1
            }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    var dismissHandler: (() -> ())?
    
    @objc func close() {
        
        collectionView.isHidden = true
        
        if self.needFakeImageViewAnimateWhenViewWillDisAppear() && self.fakeImageView != nil {
            self.fakeImageView?.alpha = 1
            if let photoImageView = (collectionView.visibleCells.first as? MTAssetBroswerCell)?.photoView {
                
                fakeImageView?.frame = photoImageView.convert(photoImageView.bounds, to: nil)
                
            }
        }
        UIView.animate(withDuration: MTAssetBroswerAnimateDuration, animations: {
//            self.blurEffectView.effect = nil
            self.backgroundView.alpha = 0
            
            if self.needFakeImageViewAnimateWhenViewWillDisAppear() && self.fakeImageView != nil && self.presentingImageView != nil {
//                self.fakeImageView?.frame = self.presentingImageView!.convert(self.presentingImageView!.bounds, to: nil)

                self.fakeImageSizeToFit(presentingImageView: self.presentingImageView!)
                self.fakeImageView?.layer.cornerRadius = self.presentingImageView!.layer.cornerRadius

            }
        }) { (_) in
            self.dismiss(animated: false, completion: self.dismissHandler)
        }
    }
    
    
    func needFakeImageViewAnimateWhenViewDidAppear() -> Bool {
        if presentingImageView == nil && presentingImageView?.image == nil {
            return false
        }
        
        return assets.contains { asset in
            return asset.image != nil
        }
    }
    
    func needFakeImageViewAnimateWhenViewWillDisAppear() -> Bool {
        if presentingImageView != nil && presentingImageView?.image != nil {
            return true
        }
        
        return false
    }
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
            let index = Int(max(scrollView.contentOffset.x / scrollView.frame.width, 0))
            pageControl.currentPage = index
            currentPage = index
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
