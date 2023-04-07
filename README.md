# **MTPhotoBroswer**

[![CI Status](https://img.shields.io/travis/cycweeds/MTPhotoBroswer.svg?style=flat)](https://travis-ci.org/cycweeds/MTPhotoBroswer)
[![Version](https://img.shields.io/cocoapods/v/MTPhotoBroswer.svg?style=flat)](https://cocoapods.org/pods/MTPhotoBroswer)
[![License](https://img.shields.io/cocoapods/l/MTPhotoBroswer.svg?style=flat)](https://cocoapods.org/pods/MTPhotoBroswer)
[![Platform](https://img.shields.io/cocoapods/p/MTPhotoBroswer.svg?style=flat)](https://cocoapods.org/pods/MTPhotoBroswer)


*MTPhotoBroswer*是一个方便查看完整图片、视频的框架。

## **Use**

``` swift

// 单图
let vc = MTAssetBroswerViewController(image: image)
// let vc = MTAssetBroswerViewController(url: imageurl)

/// 当前点击的视图
vc.presentingImageView = imageView
present(vc, animated: false, completion: nil)


// 多图
let vc = MTAssetBroswerViewController(images: [images])
// let vc = MTAssetBroswerViewController(urls: [imageurls])
// 设置当前查看的位置
vc.currentPage = 2
present(vc, animated: false, completion: nil)


```

## **Effect**



## **Requirements**
iOS 11.0+  
Swift 4.0+


## **Dependency**
SnapKit  
Kingfisher

## **Installation**

MTPhotoBroswer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MTPhotoBroswer'
```

## **Author**

cycweeds, cycweeds@gmail.com

## **License**

MTPhotoBroswer is available under the MIT license. See the LICENSE file for more info.
