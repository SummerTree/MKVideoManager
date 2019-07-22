//
//  MKQuestionStickerView.swift
//  MKVideoManager
//
//  Created by holla on 2019/1/18.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

enum MKQuestionStickerAction {
	case editQuestion
	case editAnswer
	case editUnable
}

class MKQuestionStickerView: UIView {
	var ownerIconImageView: UIImageView!
	var questionTextView: MKPlaceholderTextView!
	var answerContentView: UIView!
	var answerTextView: MKPlaceholderTextView!
	var sendButton: UIButton!
	var editAction: MKQuestionStickerAction = .editUnable {
		didSet {
			switch editAction {
			case .editQuestion:
				self.questionTextView.isEditable = true
				self.questionTextView.isSelectable = true
				self.answerTextView.isEditable = false
				self.answerTextView.isSelectable = false
			case .editAnswer:
				self.questionTextView.isEditable = false
				self.questionTextView.isSelectable = false
				self.answerTextView.isEditable = true
				self.answerTextView.isSelectable = true
			default:
				self.questionTextView.isEditable = false
				self.questionTextView.isSelectable = false
				self.answerTextView.isEditable = false
				self.answerTextView.isSelectable = false
			}
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setSubViews()
		self.setBaseData()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.setSubViews()
		self.setBaseData()
	}

	func setSubViews() {
		let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 94))
		contentView.layer.cornerRadius = 12
		contentView.backgroundColor = UIColor.white
		self.addSubview(contentView)
		sendButton = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 48))
		self.addSubview(sendButton)
		sendButton.backgroundColor = UIColor.orange
		sendButton.alpha = 0
		sendButton.setTitle("Send", for: .normal)
		contentView.snp.makeConstraints { (make) in
			make.top.leading.trailing.equalToSuperview()
			make.bottom.equalTo(sendButton.snp.top)
		}
		sendButton.snp.makeConstraints { (make) in
			make.leading.trailing.bottom.equalToSuperview()
			make.height.equalTo(0)
		}
		ownerIconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 30))
		contentView.addSubview(ownerIconImageView)
		ownerIconImageView.layer.cornerRadius = 16
		ownerIconImageView.snp.makeConstraints { (make) in
			make.top.equalToSuperview().offset(10)
			make.leading.equalToSuperview().offset(10)
			make.size.equalTo(CGSize(width: 32, height: 32))
		}

		questionTextView = MKPlaceholderTextView(frame: CGRect(x: 0, y: 0, width: 200, height: 32))
		contentView.addSubview(questionTextView)

		questionTextView.placeholderFont = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
		questionTextView.placeholderColor = UIColor(white: 0, alpha: 0.5)
		questionTextView.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
		questionTextView.textColor = UIColor(white: 0, alpha: 1)
		questionTextView.snp.makeConstraints { (make) in
			make.leading.equalTo(ownerIconImageView.snp.trailing).offset(10)
			make.top.equalTo(ownerIconImageView)
			make.trailing.equalToSuperview().offset(-10)
			make.height.equalTo(32)
		}

		answerContentView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 32))
		contentView.addSubview(answerContentView)
		answerContentView.layer.cornerRadius = 10
		answerContentView.backgroundColor = UIColor(white: 0, alpha: 0.06)
		answerContentView.snp.makeConstraints { (make) in
			make.leading.equalToSuperview().offset(10)
			make.trailing.equalToSuperview().offset(-10)
			make.top.equalTo(questionTextView.snp.bottom).offset(6)
			make.height.equalTo(32)
			make.bottom.equalToSuperview().offset(-8)
		}

		answerTextView = MKPlaceholderTextView(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
		answerContentView.addSubview(answerTextView)

		answerTextView.placeholderFont = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
		answerTextView.placeholderColor = UIColor(white: 0, alpha: 0.35)
		answerTextView.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
		answerTextView.textColor = UIColor(white: 0, alpha: 0.75)
		answerTextView.snp.makeConstraints { (make) in
			make.leading.equalToSuperview().offset(10)
			make.trailing.equalToSuperview().offset(-10)
			make.top.equalToSuperview()
			make.height.equalTo(32)
			make.bottom.equalToSuperview()
		}
	}

	func setBaseData() {
		self.backgroundColor = UIColor.red
		ownerIconImageView.backgroundColor = UIColor.gray
		answerTextView.backgroundColor = UIColor.clear
		questionTextView.isEditable = false
		questionTextView.isSelectable = false
		answerTextView.isEditable = false
		answerTextView.isSelectable = false
		questionTextView.placeholder = "Ask me a quesstion"
		answerTextView.placeholder = "Viewers respond here"
	}

	func adjustSendButton(show: Bool) {
		let newHeight: CGFloat = show ? 48 : 0
		sendButton.snp.updateConstraints { (make) in
			make.height.equalTo(newHeight)
		}
	}

	func adjustQuestionTextView(_ text: String) {
		questionTextView.snp.updateConstraints { (make) in
			make.height.equalTo(64)
		}
	}

	func adjustAnswerTextView(_ text: String) {
		answerContentView.snp.updateConstraints { (make) in
			make.height.equalTo(64)
		}
	}
}

extension MKQuestionStickerView: MKPlaceholderTextViewDelegate {
	func placeholderTextViewDidChangeText(_ text: String) {
	}

	func placeholderTextViewDidEndEditing(_ text: String) {
	}
}
