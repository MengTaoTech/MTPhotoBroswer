//
//  ViewController.swift
//  MTPhotoBroswer
//
//  Created by cycweeds on 02/13/2022.
//  Copyright (c) 2022 cycweeds. All rights reserved.
//

import UIKit
import MTPhotoBroswer

class MTViewController: UIViewController {

    @IBOutlet weak var iconVIew: UIImageView!
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
        asset.image = iconVIew.image
        
        let vc = MTAssetBroswerViewController(url: URL(string: "https://p9-passport.byteacctimg.com/img/user-avatar/03040750b9f8ebe875ca1bc7dcfde68d~300x300.image")!)
        present(vc, animated: true, completion: nil)
        
    }
}

