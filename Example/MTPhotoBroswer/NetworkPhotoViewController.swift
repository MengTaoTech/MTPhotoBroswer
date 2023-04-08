//
//  ViewController.swift
//  MTPhotoBroswer
//
//  Created by cycweeds on 02/13/2022.
//  Copyright (c) 2022 cycweeds. All rights reserved.
//

import UIKit
import MTPhotoBroswer
import Kingfisher

class NetworkPhotoViewController: UIViewController {

    @IBOutlet weak var iconView: UIImageView!
    
    
    
    
    
    //  小图后面拼接&fit=crop&w=987&q=80
    
    
    
    
    var image0 =  "https://dogefs.s3.ladydaily.com/~/source/unsplash/photo-1644782849836-c21b4423c326?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format"
    var image1 =  "https://dogefs.s3.ladydaily.com/~/source/unsplash/photo-1644773741876-e5f43ac020ce?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format"
    var image2 =  "https://dogefs.s3.ladydaily.com/~/source/unsplash/photo-1644704437845-ddd169cebb13?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format"
    
    lazy var imageURLs = [image0, image1, image2]
    
    @IBOutlet weak var supportMutipleSwitch: UISwitch!
    
    @IBOutlet weak var pageStackView: UIStackView!
    
    @IBOutlet weak var pageSelectControl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? ImageCache.default.diskStorage.removeAll()
        ImageCache.default.memoryStorage.removeAll()
        print("页面加载 会清除一下缓存")
        
        iconView.kf.setImage(with: URL(string: imageURLs[0]))
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func iconViewTapped(_ sender: Any) {
        
        
        let vc: MTAssetBroswerViewController
        
        if supportMutipleSwitch.isOn {
            vc = MTAssetBroswerViewController(imageURLs: imageURLs.map { URL(string: $0)!} )
            vc.currentPage = pageSelectControl.selectedSegmentIndex
        } else {
            
        
            vc = MTAssetBroswerViewController(imageURLs: imageURLs.map { return URL(string: $0)! }, index: pageSelectControl.selectedSegmentIndex)
        }
        vc.presentingImageView = iconView
        present(vc, animated: false, completion: nil)
        
    }
    @IBAction func pageSelectControlValueChanged(_ sender: UISwitch) {
        pageStackView.isHidden = !sender.isOn
        
    }
    
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
        iconView.kf.cancelDownloadTask()
        iconView.image = nil
        iconView.kf.setImage(with: URL(string: imageURLs[sender.selectedSegmentIndex] + "&fit=crop&w=987&q=80"))
    }
}

