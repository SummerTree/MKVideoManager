//
//  MKVideoCoverViewController.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/14.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class MKVideoCoverViewController: UIViewController {
    
    var collectionView: UICollectionView?
    var selectedView: UIView?
    
    var leftOpacityImageView: UIImageView?
    
    var rightOpacityImageView: UIImageView?
    
    var selectedImageView: UIImageView?
    
    var coverArray: NSMutableArray?
    
    var selectedCoverIndex: Int = 0
    var backgroundImageView: UIImageView?
    var asset: AVURLAsset?
    var time:CMTime?
    var seconds: Float?
    var generator: AVAssetImageGenerator?
    var slider: MKVideoCoverSlider?
    var tapGes: UITapGestureRecognizer?
    
    var player: AVPlayer?
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        self.setSubViews()
        self.setCoverData()
    }
    
    func setSubViews() {
        
        backgroundImageView = UIImageView.init(image: nil)
        backgroundImageView?.backgroundColor = UIColor.purple
        backgroundImageView?.contentMode = UIViewContentMode.scaleAspectFill
        self.view.addSubview(backgroundImageView!)
        backgroundImageView?.snp.makeConstraints({ (make) in
            make.top.left.right.bottom.equalToSuperview()
        })
        self.initPlayerView()
        self.setCollectionView()
        self.setSelectImageView()
//        self.addSlider()
        
    }
    func initPlayerView() {
        let opts: [String: Any] = [AVURLAssetPreferPreciseDurationAndTimingKey: NSNumber.init(booleanLiteral: false)]
        let videoPath = Bundle.main.path(forResource: "220", ofType: "mp4")
        let videoUrl = URL(fileURLWithPath: videoPath!)
        asset = AVURLAsset.init(url: videoUrl, options: opts)
        time = asset!.duration
        seconds = Float(time!.value) / Float(time!.timescale)
        generator = AVAssetImageGenerator(asset: asset!)
        generator!.appliesPreferredTrackTransform = true
        generator!.requestedTimeToleranceAfter = kCMTimeZero
        generator!.requestedTimeToleranceBefore = kCMTimeZero
        let playerItem = AVPlayerItem.init(asset: self.asset!)
        self.player = AVPlayer.init(playerItem: playerItem)
        let playerLayer = AVPlayerLayer.init(player: self.player)
        playerLayer.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        
        self.backgroundImageView?.layer.addSublayer(playerLayer)
        self.player?.pause()
    }
    
    func setCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize.init(width: (UIScreen.main.bounds.width - 17 - 18 - 16) / 9, height: 64)
        flowLayout.headerReferenceSize = CGSize(width: 0, height: 80)
        flowLayout.footerReferenceSize = CGSize(width: 0, height: 80)
        collectionView = UICollectionView(frame: CGRect.init(x: 0, y: 88, width: UIScreen.main.bounds.width, height: 80), collectionViewLayout: flowLayout)
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "coverCell")
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.allowsMultipleSelection = false
        collectionView?.layer.cornerRadius = 5
        collectionView?.backgroundColor = UIColor.init(red: 7/255, green: 0, blue: 44/255, alpha: 1)
        self.view.addSubview(collectionView!)
        collectionView?.snp.makeConstraints({ (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(17)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(80)
        })
    }
    
    func setSelectImageView() {
        selectedView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width - 17 - 18, height: 80))
//        selectedView.backgroundColor = UIColor.blue
        collectionView?.addSubview(selectedView!)
        
        selectedView!.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize.init(width: UIScreen.main.bounds.width - 17 - 18 - 16, height: 64))
        }
        
        leftOpacityImageView = UIImageView.init(image: UIImage.getImageWithColor(UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.25)))
        selectedView!.addSubview(leftOpacityImageView!)
        
        rightOpacityImageView = UIImageView.init(image: UIImage.getImageWithColor(UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.25)))
        selectedView!.addSubview(rightOpacityImageView!)
        
        selectedImageView = UIImageView.init(image: UIImage.getImageWithColor(UIColor.clear))
        selectedImageView?.layer.borderColor = UIColor.red.cgColor
        selectedImageView?.layer.borderWidth = 2
        selectedImageView?.isUserInteractionEnabled = true
        self.addPanGestureToView(selectedImageView!)
        selectedView!.addSubview(selectedImageView!)
        
        leftOpacityImageView?.snp.makeConstraints({ (make) in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(selectedImageView!.snp.leading)
        })
        rightOpacityImageView?.snp.makeConstraints({ (make) in
            make.trailing.top.bottom.equalToSuperview()
            make.leading.equalTo(selectedImageView!.snp.trailing)
        })
        
        selectedImageView?.snp.makeConstraints({ (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo((UIScreen.main.bounds.width - 17 - 18 - 16) / 9)
        })
    }
    
    func setCoverData() {
        coverArray = NSMutableArray.init(capacity: 9)
        for i in 0..<9{
            
            let frameImg: UIImage = self.getImageWithTime(Float(i) / 8.0)
            coverArray?.add(frameImg)
        }
        collectionView?.reloadData()
    }
    
    
}

extension MKVideoCoverViewController{
    
    func addPanGestureToView(_ view: UIView) {
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGes(_:)))
        view.addGestureRecognizer(pan)
    }
    
    func panGes(_ gesture: UIPanGestureRecognizer) {
//        var originCenterX: CGFloat! = 0.0
        if gesture.state == UIGestureRecognizer.State.began {
            self.selectedView?.layoutIfNeeded()
        }
        
        if gesture.state == UIGestureRecognizer.State.changed {
            let sliderX = gesture.view?.frame.origin.x
            let sliderMaxX = gesture.view?.frame.maxX
            let translation = gesture.translation(in: gesture.view!)
            let newSliderX = sliderX! + translation.x
            let newSliderMaxX = sliderMaxX! + translation.x
//            let newCenter = CGPoint.init(x: gesture.view!.center.x + translation.x, y: gesture.view!.center.y)
            if newSliderX > 0 && newSliderMaxX < self.selectedView!.frame.width{
                self.selectedImageView!.snp.updateConstraints({ (make) in
//                    make.center.equalTo(newCenter)
                    make.leading.equalToSuperview().offset(newSliderX)
                })
                self.selectedView?.layoutIfNeeded()
//                gesture.view?.center = newCenter
                gesture.setTranslation(CGPoint.init(x: 0, y: 0), in: gesture.view)
                let progress: Float = Float(newSliderX / (self.selectedView!.frame.size.width - self.selectedImageView!.frame.size.width))
                self.reloadImageWithTime(progress)
               
            }
            if newSliderX <= 0 && newSliderMaxX >= self.selectedView!.frame.width{
                return
            }
        }
    }
    func addSlider() {
        
        let sliderImage: UIImage = UIImage.init(named: "border")!
        self.slider = MKVideoCoverSlider.init(frame: CGRect.init(x: 8, y: 0, width: UIScreen.main.bounds.width - 17 - 18 - 16, height: 80))
        self.slider!.setThumbImage(sliderImage, for: .normal)
        self.slider!.setMinimumTrackImage(UIImage.getImageWith(UIColor.blue, CGSize.init(width: 1, height: 1)), for: .normal)
        self.slider!.setMaximumTrackImage(UIImage.getImageWith(UIColor.red, CGSize.init(width: 1, height: 1)), for: .normal)
        self.slider!.addTarget(self, action: #selector(sliderValueChange), for: .valueChanged)
        self.tapGes = UITapGestureRecognizer.init(target: self, action: #selector(sliderTapGes(_:)))
        self.slider!.addGestureRecognizer(self.tapGes!)
        self.slider!.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        self.slider!.addTarget(self, action: #selector(sliderTouchUp(_:)), for: .touchUpInside)
        self.collectionView?.addSubview(self.slider!)
    }
    
    @objc func sliderTouchDown(_ slider: UISlider){
        self.tapGes?.isEnabled = false
    }
    @objc func sliderTouchUp(_ slider: UISlider){
        self.tapGes?.isEnabled = true
    }
    
    @objc func sliderTapGes(_ tapGes: UITapGestureRecognizer){
        let point: CGPoint = tapGes.location(in: tapGes.view)
    
        let value: Float = (self.slider!.maximumValue - self.slider!.minimumValue) * Float((point.x / (self.slider?.frame.size.width)!))
        self.slider?.setValue(value, animated: true)
        self.reloadImageWithTime(self.slider!.value)
    }
    
    @objc func sliderValueChange(_ slider: UISlider) {

        let progress: Float = slider.value
        self.reloadImageWithTime(progress)
    }
    
    //video
    func reloadImageWithTime(_ progress:Float) {
        let seekValue = Float((self.time?.value)!) * progress
        let playerTime: CMTime = CMTimeMake(Int64(seekValue), (self.time?.timescale)!)
        self.player?.seek(to: playerTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    func getImageWithTime(_ progress:Float) -> UIImage {
        print("progress: \(progress)")
        let timeSelect: Float = self.seconds! * Float(progress)
        let imgTime: CMTime = CMTimeMakeWithSeconds(Float64(timeSelect), 30);
        
        let img: CGImage = try! self.generator!.copyCGImage(at: imgTime, actualTime: nil)
        let frameImg: UIImage = UIImage(cgImage: img)
        return frameImg
    }
}

extension MKVideoCoverViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.coverArray!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "coverCell", for: indexPath)
        cell.contentView.backgroundColor = UIColor.orange
        let imageView: UIImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: (UIScreen.main.bounds.width - 17 - 18 - 16) / 9, height: 64))
        cell.contentView.addSubview(imageView)
        imageView.layer.cornerRadius = 1
        imageView.image = coverArray?[indexPath.row] as? UIImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.selectedCoverIndex = indexPath.row
//        self.backgroundImageView?.image = (self.coverArray![self.selectedCoverIndex] as! UIImage)
//        self.collectionView?.reloadData()
    }
}
