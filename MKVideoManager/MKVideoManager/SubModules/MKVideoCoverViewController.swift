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
    
    static let collectionWidth: CGFloat = UIScreen.main.bounds.width - 17 - 18
    static let itemWidth: CGFloat = (collectionWidth - 8 - 8) / 9
    static let itemHeight: CGFloat = itemWidth * 16 / 9
    static let collectionHeight: CGFloat = itemHeight + 8 + 8
    
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
    
    deinit {
        print("deninit")
    }
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
        flowLayout.itemSize = CGSize.init(width: MKVideoCoverViewController.itemWidth, height: MKVideoCoverViewController.itemHeight)
        flowLayout.headerReferenceSize = CGSize(width: 0, height: MKVideoCoverViewController.collectionHeight)
        flowLayout.footerReferenceSize = CGSize(width: 0, height: MKVideoCoverViewController.collectionHeight)
        collectionView = UICollectionView(frame: CGRect.init(x: 0, y: 0, width: MKVideoCoverViewController.collectionWidth, height: MKVideoCoverViewController.collectionHeight), collectionViewLayout: flowLayout)
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
            make.height.equalTo(MKVideoCoverViewController.collectionHeight)
        })
    }
    
    func setSelectImageView() {
        selectedView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: MKVideoCoverViewController.itemWidth * 9, height: MKVideoCoverViewController.itemHeight))
//        selectedView.backgroundColor = UIColor.blue
        self.addTapGestureToView(selectedView!)
        collectionView?.addSubview(selectedView!)
        
        selectedView!.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize.init(width: MKVideoCoverViewController.itemWidth * 9, height: MKVideoCoverViewController.itemHeight))
        }
        
        leftOpacityImageView = UIImageView.init(image: UIImage.getImageWithColor(UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.25)))
        selectedView!.addSubview(leftOpacityImageView!)
        
        rightOpacityImageView = UIImageView.init(image: UIImage.getImageWithColor(UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.25)))
        selectedView!.addSubview(rightOpacityImageView!)
        
        selectedImageView = UIImageView.init(image: UIImage.getImageWithColor(UIColor.clear))
        selectedImageView?.layer.borderColor = UIColor.init(red: 1, green: 252/255, blue: 1/255, alpha: 1).cgColor
        selectedImageView?.layer.borderWidth = 1
        selectedImageView?.layer.cornerRadius = 1
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
            make.width.equalTo(MKVideoCoverViewController.itemWidth)
        })
    }
    
    func setCoverData() {
        coverArray = NSMutableArray.init(capacity: 9)
        DispatchQueue.global().async {
            for i in 0..<9{
                let frameImg: UIImage = self.getImageWithTime(Float(i) / 8.0)
                self.coverArray?.add(frameImg)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        }
    }
}

extension MKVideoCoverViewController{
    
    func addPanGestureToView(_ view: UIView) {
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGes(_:)))
        view.addGestureRecognizer(pan)
    }
    
    func addTapGestureToView(_ view:UIView) {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGes(_:)))
        view.addGestureRecognizer(tap)
    }
    
    func tapGes(_ gesture: UITapGestureRecognizer) {
//        let sliderX = self.selectedImageView?.frame.origin.x
//        let sliderMaxX = self.selectedImageView?.frame.maxX
        let locationPoint = gesture.location(in: gesture.view)
        var newSliderX = locationPoint.x - MKVideoCoverViewController.itemWidth/2
        let newSliderMaxX = locationPoint.x + MKVideoCoverViewController.itemWidth/2
        if newSliderX <= 0 {
            newSliderX = 0
        }
        if newSliderMaxX >= self.selectedView!.frame.width{
            newSliderX = self.selectedView!.frame.size.width - self.selectedImageView!.frame.size.width
        }
        self.selectedImageView!.snp.updateConstraints({ (make) in
            //                    make.center.equalTo(newCenter)
            make.leading.equalToSuperview().offset(newSliderX)
        })
        self.selectedView?.layoutIfNeeded()
        let progress: Float = Float(newSliderX / (self.selectedView!.frame.size.width - MKVideoCoverViewController.itemWidth))
        self.reloadImageWithTime(progress)
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
            var newSliderX = sliderX! + translation.x
            let newSliderMaxX = sliderMaxX! + translation.x
            if newSliderX <= 0 {
                newSliderX = 0
            }
            if newSliderMaxX >= self.selectedView!.frame.width{
                newSliderX = self.selectedView!.frame.size.width - self.selectedImageView!.frame.size.width
            }
            self.selectedImageView!.snp.updateConstraints({ (make) in
                //                    make.center.equalTo(newCenter)
                make.leading.equalToSuperview().offset(newSliderX)
            })
            self.selectedView?.layoutIfNeeded()
            gesture.setTranslation(CGPoint.init(x: 0, y: 0), in: gesture.view)
            let progress: Float = Float(newSliderX / (self.selectedView!.frame.size.width - self.selectedImageView!.frame.size.width))
            self.reloadImageWithTime(progress)
            
        }
    }
    func addSlider() {
        
//        let sliderImage: UIImage = UIImage.init(named: "border")!
//        self.slider = MKVideoCoverSlider.init(frame: CGRect.init(x: 8, y: 0, width: UIScreen.main.bounds.width - 17 - 18 - 16, height: 80))
//        self.slider!.setThumbImage(sliderImage, for: .normal)
//        self.slider!.setMinimumTrackImage(UIImage.getImageWith(UIColor.blue, CGSize.init(width: 1, height: 1)), for: .normal)
//        self.slider!.setMaximumTrackImage(UIImage.getImageWith(UIColor.red, CGSize.init(width: 1, height: 1)), for: .normal)
//        self.slider!.addTarget(self, action: #selector(sliderValueChange), for: .valueChanged)
//        self.tapGes = UITapGestureRecognizer.init(target: self, action: #selector(sliderTapGes(_:)))
//        self.slider!.addGestureRecognizer(self.tapGes!)
//        self.slider!.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
//        self.slider!.addTarget(self, action: #selector(sliderTouchUp(_:)), for: .touchUpInside)
//        self.collectionView?.addSubview(self.slider!)
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
        let imageView: UIImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: MKVideoCoverViewController.itemWidth, height: MKVideoCoverViewController.itemHeight))
        cell.contentView.addSubview(imageView)
        imageView.layer.cornerRadius = 1
        imageView.layer.masksToBounds = true
        imageView.image = coverArray?[indexPath.row] as? UIImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}
