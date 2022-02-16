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

    @IBOutlet weak var iconView: UIImageView!
    
    // 图有点大
    let image0 = UIImage(named: "cassidy-dickens-l10QZgQFmGE-unsplash")!
    let image1 = UIImage(named: "hailey-wagner-V5-jwSkzzcw-unsplash")!
    let image2 = UIImage(named: "cassidy-dickens-PDXjyaVFmHs-unsplash")!
    
    lazy var images = [image0, image1, image2]
    
    @IBOutlet weak var supportMutipleSwitch: UISwitch!
    
    @IBOutlet weak var pageStackView: UIStackView!
    
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
        
       
        
        present(vc, animated: true, completion: nil)
        
    }
    @IBAction func pageSelectControlValueChanged(_ sender: UISwitch) {
        pageStackView.isHidden = !sender.isOn
        
    }
    
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
            iconView.image = images[sender.selectedSegmentIndex]
    }
}

