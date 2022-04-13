//
//  ViewController.swift
//  MTPhotoBroswer
//
//  Created by cycweeds on 02/13/2022.
//  Copyright (c) 2022 cycweeds. All rights reserved.
//

import UIKit
import MTPhotoBroswer

class LocalPhotoViewController: UIViewController {

    @IBOutlet weak var iconView: UIImageView! {
        didSet {
            iconView.layer.cornerRadius = 20
            
        }
    }
    
    // 图有点大
    let image0 = UIImage(named: "cassidy-dickens-l10QZgQFmGE-unsplash")!
    let image1 = UIImage(named: "hailey-wagner-V5-jwSkzzcw-unsplash")!
    let image2 = UIImage(named: "cassidy-dickens-PDXjyaVFmHs-unsplash")!
    
    lazy var images = [image0, image1, image2]
    
    @IBOutlet weak var supportMutipleSwitch: UISwitch!
    
    @IBOutlet weak var pageStackView: UIStackView!
    
    @IBOutlet weak var contentModeLabel: UILabel!
    @IBOutlet weak var pageSelectControl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func iconViewTapped(_ sender: Any) {
        
        var asset = MTBrowseAsset()
        asset.image = iconView.image
        
        let vc: MTAssetBroswerViewController
        
        if supportMutipleSwitch.isOn {
            vc = MTAssetBroswerViewController(images: images)
            vc.currentPage = pageSelectControl.selectedSegmentIndex
        } else {
            vc = MTAssetBroswerViewController(image: iconView.image!)
        }
        vc.presentingImageView = iconView
        
       
        
        present(vc, animated: false, completion: nil)
        
    }
    @IBAction func pageSelectControlValueChanged(_ sender: UISwitch) {
        pageStackView.isHidden = !sender.isOn
        
    }
    
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
            iconView.image = images[sender.selectedSegmentIndex]
    }
    @IBAction func contentModeChange(_ sender: Any) {
        let alertVC = UIAlertController(title: "选择 Content Mode", message: nil, preferredStyle: .actionSheet)
        

// UIView.contentMode
        alertVC.addAction(UIAlertAction(title: "scaleToFill", style: .default, handler: { _ in
            self.iconView.contentMode = .scaleToFill
            self.iconView.sizeToFit()
            self.contentModeLabel.text = "scaleToFill"
        }))
        alertVC.addAction(UIAlertAction(title: "scaleAspectFit", style: .default, handler: { _ in
            self.iconView.contentMode = .scaleAspectFit
            self.iconView.sizeToFit()
            self.contentModeLabel.text = "scaleAspectFit"
        }))
        alertVC.addAction(UIAlertAction(title: "scaleAspectFill", style: .default, handler: { _ in
            self.iconView.contentMode = .scaleAspectFill
            self.iconView.sizeToFit()
            self.contentModeLabel.text = "scaleAspectFill"
        }))
        alertVC.addAction(UIAlertAction(title: "redraw", style: .default, handler: { _ in
            // 这个样式好像并不会改变UIImageView的样式  
            self.iconView.contentMode = .redraw
            self.iconView.sizeToFit()
            self.contentModeLabel.text = "redraw"
        }))
        alertVC.addAction(UIAlertAction(title: "center", style: .default, handler: { _ in
            self.iconView.contentMode = .center
            self.iconView.sizeToFit()
            self.contentModeLabel.text = "center"
        }))
        alertVC.addAction(UIAlertAction(title: "top", style: .default, handler: { _ in
            self.iconView.contentMode = .top
            self.iconView.sizeToFit()
            self.contentModeLabel.text = "top"
        }))
        alertVC.addAction(UIAlertAction(title: "bottom", style: .default, handler: { _ in
            self.iconView.contentMode = .bottom
            self.iconView.sizeToFit()
            self.contentModeLabel.text = "bottom"
        }))
        alertVC.addAction(UIAlertAction(title: "left", style: .default, handler: { _ in
            self.iconView.contentMode = .left
            self.iconView.sizeToFit()
            self.contentModeLabel.text = "left"
        }))
        alertVC.addAction(UIAlertAction(title: "right", style: .default, handler: { _ in
            self.iconView.contentMode = .right
            self.iconView.sizeToFit()
            self.contentModeLabel.text = "right"
        }))
        alertVC.addAction(UIAlertAction(title: "topLeft", style: .default, handler: { _ in
            self.iconView.contentMode = .topLeft
            self.iconView.sizeToFit()
            self.contentModeLabel.text = "topLeft"
        }))
        alertVC.addAction(UIAlertAction(title: "topRight", style: .default, handler: { _ in
            self.iconView.contentMode = .topRight
            self.iconView.sizeToFit()
            self.contentModeLabel.text = "topRight"
        }))
        alertVC.addAction(UIAlertAction(title: "bottomLeft", style: .default, handler: { _ in
            self.iconView.contentMode = .bottomLeft
            self.iconView.sizeToFit()
            self.contentModeLabel.text = "bottomLeft"
        }))
        alertVC.addAction(UIAlertAction(title: "bottomRight", style: .default, handler: { _ in
            self.iconView.contentMode = .bottomRight
            self.iconView.sizeToFit()
            self.contentModeLabel.text = "bottomRight"
        }))
        
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}

