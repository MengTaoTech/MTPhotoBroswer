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

/// 动画加载时间
public var MTAssetBroswerAnimateDuration: TimeInterval = 0.25

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

    
    /// 用户点击的视图
    public var presentingImageView: UIImageView?
    
    
    public var assets: [MTBrowseAsset] = []
    
    private var fakeImageView: UIImageView?
    
    private var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        return pageControl
    }()
    
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
        self.init(assets: assets, index: index)
    }
    
    
    public convenience init(imageURL: URL) {
        self.init(imageURLs: [imageURL])
    }
    
    public convenience init(imageURLs: [URL], index: Int = 0) {
        let assets = imageURLs.map { url -> MTBrowseAsset in
            var asset = MTBrowseAsset()
            asset.imageURL = url
            return asset
        }
        self.init(assets: assets, index: index)
    }
    
    public convenience init(asset: MTBrowseAsset) {
        self.init(assets: [asset])
    }
    
    public convenience init(assets: [MTBrowseAsset], index: Int = 0) {
        self.init()
        self.assets = assets
        _initializeCurrentPage = index
        currentPage = index
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
    
    var _initializeCurrentPage = 0
    
    
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
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
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
        
        
        if needFakeImageViewAnimate() {
            if let presentingImageView = presentingImageView, let presentingImage = presentingImageView.image {
                fakeImageView = UIImageView(image: presentingImage)
                fakeImageView?.clipsToBounds = true
                view.addSubview(fakeImageView!)
                assets[currentPage].image = presentingImage
                if presentingImageView.contentMode == .scaleToFill || presentingImageView.contentMode == .scaleAspectFit || presentingImageView.contentMode == .scaleAspectFill {
                    self.fakeImageView?.frame = self.presentingImageView!.convert(self.presentingImageView!.bounds, to: nil)
                    fakeImageView?.contentMode = presentingImageView.contentMode
                } else {
                    fakeImageSizeToFit(presentingImageView: presentingImageView)
                }
            }
            collectionView.isHidden = true
        }
        
    }
    
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backgroundView.alpha = 0
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
                let height = min(presentingFrameInWindow.size.width / scale, presentingFrameInWindow.height)
                
                fakeImageView?.frame = CGRect(x: 0, y: 0, width: height * scale, height: height)
                fakeImageView?.center = CGPoint(x: presentingFrameInWindow.midX, y: presentingFrameInWindow.midY)
            } else {
                let width = min(presentingFrameInWindow.size.height * scale, presentingFrameInWindow.width)
                fakeImageView?.frame = CGRect(x: 0, y: 0, width: width, height: width / scale)
                fakeImageView?.center = CGPoint(x: presentingFrameInWindow.midX, y: presentingFrameInWindow.midY)
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
        
        _initializeCurrentPage = currentPage
        collectionView.scrollToItem(at: IndexPath(item: currentPage, section: 0), at: .centeredHorizontally, animated: false)
        
        if needFakeImageViewAnimate(), let fakeImageView = fakeImageView, let image = fakeImageView.image {
            
            
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
                self.presentingImageView?.alpha = 0
            }
            
        } else {
            
            UIView.animate(withDuration: MTAssetBroswerAnimateDuration) {
                self.backgroundView.alpha = 1
                self.view.alpha = 1
            } completion: { _ in
                self.presentingImageView?.alpha = 0
            }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    var dismissHandler: (() -> ())?
    
    @objc func close(dragCell: MTAssetBroswerCell? = nil) {
        
        
        if _initializeCurrentPage != currentPage {
            
            UIView.animate(withDuration: MTAssetBroswerAnimateDuration, animations: {
                self.view.alpha = 0
                self.presentingImageView?.alpha = 1
            }) { (_) in
                
                self.dismiss(animated: false, completion: self.dismissHandler)
            }
            return
        }
        
        
    
        collectionView.isHidden = true
        
        if self.needFakeImageViewAnimate() && self.fakeImageView != nil {
            if let cell = dragCell ?? (collectionView.visibleCells.first as? MTAssetBroswerCell) {
                let photoImageView = cell.photoView
                    
                    fakeImageView?.frame = photoImageView.convert(photoImageView.bounds, to: nil)
                    fakeImageView?.alpha = 1

            }
           
        }
        
        UIView.animate(withDuration: MTAssetBroswerAnimateDuration, animations: {
            self.backgroundView.alpha = 0
            
            if self.needFakeImageViewAnimate() && self.fakeImageView != nil , let presentingImageView = self.presentingImageView  {
                if presentingImageView.contentMode == .scaleToFill || presentingImageView.contentMode == .scaleAspectFit || presentingImageView.contentMode == .scaleAspectFill {
                    self.fakeImageView?.contentMode = self.presentingImageView!.contentMode
                    
                    self.fakeImageView?.frame = self.presentingImageView!.convert(self.presentingImageView!.bounds, to: nil)
                } else {
                    // 这些的动效会在缩放最后 图片多余部分会直接消失  没有很平滑的动效
                    self.fakeImageSizeToFit(presentingImageView: self.presentingImageView!)
                }
            }
        }) { (_) in
            self.presentingImageView?.alpha = 1

            self.dismiss(animated: false, completion: self.dismissHandler)
        }
    }
    
    func needFakeImageViewAnimate() -> Bool {
        if presentingImageView?.image != nil {
            return true
        }
        
        return false
    }

    
    
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(max((scrollView.contentOffset.x / scrollView.frame.width).rounded(), 0))
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
            fatalError("Don't match any cell")
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
