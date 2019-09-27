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

    var backButton: UIButton!
    var doneButton: UIButton!

    var coverArray: NSMutableArray?

    var selectedCoverIndex: Int = 0
    var backgroundImageView: UIImageView?
    var asset: AVURLAsset?
    var time: CMTime?
    var seconds: Float?
    var generator: AVAssetImageGenerator?
    var tapGes: UITapGestureRecognizer?

    var player: AVPlayer?
    var currentProgress: Float = 0

    deinit {
        print("deninit")
    }
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        self.setSubViews()
        self.setCoverData()
    }

    func setSubViews() {
        backgroundImageView = UIImageView(image: nil)
        backgroundImageView?.backgroundColor = UIColor.purple
		backgroundImageView?.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.addSubview(backgroundImageView!)
        backgroundImageView?.snp.makeConstraints({ (make) in
            make.top.left.right.bottom.equalToSuperview()
        })
        self.initPlayerView()
        self.setNavigationView()
        self.setCollectionView()
        self.setSelectImageView()
//        self.addSlider()

    }
    func initPlayerView() {
        let opts: [String: Any] = [AVURLAssetPreferPreciseDurationAndTimingKey: NSNumber(booleanLiteral: false)]
        let videoPath = Bundle.main.path(forResource: "220", ofType: "mp4")
        let videoUrl = URL(fileURLWithPath: videoPath!)
        asset = AVURLAsset(url: videoUrl, options: opts)
        time = asset!.duration
        seconds = Float(time!.value) / Float(time!.timescale)
        generator = AVAssetImageGenerator(asset: asset!)
        generator!.appliesPreferredTrackTransform = true
		generator!.requestedTimeToleranceAfter = CMTime.zero
		generator!.requestedTimeToleranceBefore = CMTime.zero
        let playerItem = AVPlayerItem(asset: self.asset!)
        self.player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
		playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect

        self.backgroundImageView?.layer.addSublayer(playerLayer)
        self.player?.pause()
    }

    func setNavigationView() {
        if self.backButton == nil {
            self.backButton = UIButton()
            self.backButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
            self.backButton.setTitle("CANCEL", for: .normal)
            self.backButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
            self.view.addSubview(self.backButton)
            self.backButton.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(14)
                make.top.equalToSuperview().offset(MKDefine.statusBarHeight)
                make.size.equalTo(CGSize(width: 80, height: 44))
            }
        }
        if self.doneButton == nil {
            self.doneButton = UIButton()
            self.doneButton.setTitle("DONE", for: .normal)
            self.doneButton.setTitleColor(UIColor.white, for: .normal)
            self.doneButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
            self.view.addSubview(self.doneButton)
            self.doneButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
            self.doneButton.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(MKDefine.statusBarHeight)
                make.right.equalToSuperview().offset(-14)
                make.size.equalTo(CGSize(width: 60, height: 40))
            }
        }
    }

    func setCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
		flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
		flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize(width: MKVideoCoverViewController.itemWidth, height: MKVideoCoverViewController.itemHeight)
        flowLayout.headerReferenceSize = CGSize(width: 0, height: MKVideoCoverViewController.collectionHeight)
        flowLayout.footerReferenceSize = CGSize(width: 0, height: MKVideoCoverViewController.collectionHeight)
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: MKVideoCoverViewController.collectionWidth, height: MKVideoCoverViewController.collectionHeight), collectionViewLayout: flowLayout)
        collectionView?.register(MKCoverCollectionCell.self, forCellWithReuseIdentifier: "coverCell")
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.allowsMultipleSelection = false
        collectionView?.layer.cornerRadius = 5
        collectionView?.backgroundColor = UIColor(red: 7 / 255, green: 0, blue: 44 / 255, alpha: 1)
        self.view.addSubview(collectionView!)
        collectionView?.snp.makeConstraints({ (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(17)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(MKVideoCoverViewController.collectionHeight)
        })
    }

    func setSelectImageView() {
        selectedView = UIView(frame: CGRect(x: 0, y: 0, width: MKVideoCoverViewController.itemWidth * 9, height: MKVideoCoverViewController.itemHeight))
//        selectedView.backgroundColor = UIColor.blue
        self.addTapGestureToView(selectedView!)
        collectionView?.addSubview(selectedView!)

        selectedView!.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: MKVideoCoverViewController.itemWidth * 9, height: MKVideoCoverViewController.itemHeight))
        }

        leftOpacityImageView = UIImageView(image: UIImage.getImageWithColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)))
        selectedView!.addSubview(leftOpacityImageView!)

        rightOpacityImageView = UIImageView(image: UIImage.getImageWithColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)))
        selectedView!.addSubview(rightOpacityImageView!)

        selectedImageView = UIImageView(image: UIImage.getImageWithColor(UIColor.clear))
        selectedImageView?.layer.borderColor = UIColor(red: 1, green: 252 / 255, blue: 1 / 255, alpha: 1).cgColor
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
        coverArray = NSMutableArray(capacity: 9)
        DispatchQueue.global().async {
            for i in 0..<9 {
                let frameImg: UIImage = self.getImageWithTime(Float(i) / 8.0)
                self.coverArray?.add(frameImg)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        }
    }

    // MARK: Action
	@objc func cancelAction() {
        self.navigationController?.popViewController(animated: true)
    }

	@objc func doneAction() {
        //get cover
//        let image = self.getImageWithTime(self.currentProgress)
        //输出 封面
    }
}

extension MKVideoCoverViewController {
    func addPanGestureToView(_ view: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGes(_:)))
        view.addGestureRecognizer(pan)
    }

    func addTapGestureToView(_ view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGes(_:)))
        view.addGestureRecognizer(tap)
    }

	@objc func tapGes(_ gesture: UITapGestureRecognizer) {
//        let sliderX = self.selectedImageView?.frame.origin.x
//        let sliderMaxX = self.selectedImageView?.frame.maxX
        let locationPoint = gesture.location(in: gesture.view)
        var newSliderX = locationPoint.x - MKVideoCoverViewController.itemWidth / 2
        let newSliderMaxX = locationPoint.x + MKVideoCoverViewController.itemWidth / 2
        if newSliderX <= 0 {
            newSliderX = 0
        }
        if newSliderMaxX >= self.selectedView!.frame.width {
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

	@objc func panGes(_ gesture: UIPanGestureRecognizer) {
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
            if newSliderMaxX >= self.selectedView!.frame.width {
                newSliderX = self.selectedView!.frame.size.width - self.selectedImageView!.frame.size.width
            }
            self.selectedImageView!.snp.updateConstraints({ (make) in
                //                    make.center.equalTo(newCenter)
                make.leading.equalToSuperview().offset(newSliderX)
            })
            self.selectedView?.layoutIfNeeded()
            gesture.setTranslation(CGPoint(x: 0, y: 0), in: gesture.view)
            let progress: Float = Float(newSliderX / (self.selectedView!.frame.size.width - self.selectedImageView!.frame.size.width))
            self.reloadImageWithTime(progress)
        }
    }

    //video
    func reloadImageWithTime(_ progress: Float) {
        currentProgress = progress
        let seekValue = Float((self.time?.value)!) * progress
		let playerTime: CMTime = CMTimeMake(value: Int64(seekValue), timescale: (self.time?.timescale)!)
		self.player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }

    func getImageWithTime(_ progress: Float) -> UIImage {
        print("progress: \(progress)")
        let timeSelect: Float = self.seconds! * Float(progress)
		let imgTime: CMTime = CMTimeMakeWithSeconds(Float64(timeSelect), preferredTimescale: (self.time?.timescale)!)
		var img: CGImage?
		do {
			img = try self.generator!.copyCGImage(at: imgTime, actualTime: nil)
		} catch {
			print(error)
		}

		let frameImg: UIImage = UIImage(cgImage: img!)
        return frameImg
    }
}

extension MKVideoCoverViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.coverArray!.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "coverCell", for: indexPath) as! MKCoverCollectionCell
//        cell.contentView.backgroundColor = UIColor.orange

        cell.imageView.image = coverArray?[indexPath.row] as? UIImage
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
