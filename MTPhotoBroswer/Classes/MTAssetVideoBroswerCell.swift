//
//  MTAssetVideoBroswerCell.swift
//  MT
//
//  Created by cyc on 2019/1/25.
//  Copyright © 2019 MengTao. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

public class MTAssetVideoBroswerCell: UICollectionViewCell {
    
    lazy var avplayLayer: AVPlayerLayer = {
        let avplayLayer = AVPlayerLayer(player: nil)
        avplayLayer.backgroundColor = UIColor.clear.cgColor
        avplayLayer.videoGravity = .resizeAspectFill
        return avplayLayer
    }()
    
    lazy var pauseButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.setImage(UIImage(named: "asset_video_pause"), for: UIControl.State.selected)
        button.setImage(nil, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(MTAssetVideoBroswerCell.pause), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    var indicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.addSublayer(avplayLayer)
        
        avplayLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        contentView.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        contentView.addSubview(pauseButton)
        pauseButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(100)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var observer: NSObjectProtocol?
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if newSuperview != nil {
            observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { [weak self] (notification) in
                
                guard let playerItem = notification.object as? AVPlayerItem else {
                    return
                }
                
                guard let strongSelf = self else { return }
                if strongSelf.avplayLayer.player?.currentItem == playerItem {
                    strongSelf.avplayLayer.player?.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
                    strongSelf.avplayLayer.player?.play()
                }
            }
        } else {
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
            
            avplayLayer.player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status))
        }
    }
    
    deinit {
        print("MTAssetVideoBroswerCell deinit")
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let statusRawvalue = change?[.newKey] as? Int else {
            return
        }
        
        guard let status = AVPlayer.Status(rawValue: statusRawvalue) else { return }
        if status == .readyToPlay {
            indicatorView.stopAnimating()
        }
    }
    
    func update(url: URL) {
        
        let player = AVPlayer(url: url)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new], context: nil)
        avplayLayer.player = player
        let urlAsset = AVURLAsset(url: url)
        var size = CGSize(width: contentView.frame.width, height: contentView.frame.width)
        urlAsset.tracks.forEach { (track) in
            if track.mediaType == AVMediaType.video {
                size = track.naturalSize
                print("track naturalSize \(track.naturalSize)")
            }
        }
        let imageScale = size.width / size.height
        self.avplayLayer.frame = CGRect(x: 0, y: UIScreen.main.bounds.height / 2 -  UIScreen.main.bounds.width / imageScale / 2, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / imageScale)
        self.avplayLayer.player?.play()
    }
    
    @objc private func pause() {
        pauseButton.isSelected = !pauseButton.isSelected
        if pauseButton.isSelected {
            self.avplayLayer.player?.pause()
        } else {
            self.avplayLayer.player?.play()
        }
    }
}
