//
//  NicoLiveUser.swift
//  UserslistDB
//
//  Created by Чайка on 2018/07/01.
//  Copyright © 2018 Чайка. All rights reserved.
//

import Cocoa
import DeuxCheVaux

public enum Friendship {
	case new
	case known
	case met
	case metOther
}// end enum Friendship

public class UserName {
	public let identifier: String
	public let nickname: String
	public var handle: String

	init (identifier: String, nickname: String = "", handle: String = "") {
		self.identifier = identifier
		self.nickname = nickname.isEmpty ? String(identifier.prefix(10)) : nickname
		self.handle = handle.isEmpty ? nickname : handle
	}// end init

	init (identifier: String, nickname: String = "") {
		self.identifier = identifier
		if nickname.isEmpty { self.nickname = String(identifier.prefix(10)) }
		else { self.nickname = nickname }
		self.handle = nickname
	}// end init
}// end struct UserName

private let True: String = "yes"

public class NicoLiveUser: NSObject {
	public var name: UserName
	private var handle: String {
		get {
			return name.handle
		}// end get
		set (newHandle) {
			name.handle = newHandle
			entry[JSONKey.user.handle] = newHandle
		}// end set
	}// end property handle
	public let anonymous: Bool
	public let isPremium: Bool
	public let isPrivilege: Bool
	public let isVIP : Bool
	public var isOwner: Bool = false
	public let language: UserLanguage
	public var friendship: Friendship
	@objc public dynamic var thumbnail: NSImage?
	public var lock: Bool = false {
		didSet (newState) {
			entry[JSONKey.user.lock] = newState ? True : nil
		}// end didSet
	}// end property lock
	public let lastMet: Date
	public var color: NSColor?
	public var note: String? {
		didSet (newNote) {
			entry[JSONKey.user.note] = newNote
		}// end didSet
	}// end property note

	private(set) var entry: NSMutableDictionary

	public init (nickname: String, identifier: String, premium: Int, anonymous: Bool, lang: UserLanguage, met: Friendship) {
		entry = NSMutableDictionary()
		name = anonymous ? UserName(identifier: identifier) : UserName(identifier: identifier, nickname: nickname)
		let handle = name.handle
		isPremium = (premium & (0x01 << 0)) != 0x00 ? false : true
		isPrivilege = (premium & (0x01 << 1)) != 0x00 ? false : true
		isVIP = (premium & (0x01 << 2)) != 0x00 ? false : true
		self.anonymous = anonymous
		friendship = met
		lastMet = Date()
		language = lang
			// set entry object
		entry[JSONKey.user.handle] = handle
		let formatter:DateFormatter = DateFormatter()
		formatter.dateStyle = DateFormatter.Style.short
		formatter.timeStyle = DateFormatter.Style.short
		entry[JSONKey.user.met] = formatter.string(from: lastMet)
	}// end init

	public init (user: NSMutableDictionary, nickname: String, identifier: String, premium: Int, anonymous: Bool, lang: UserLanguage) {
		entry = user
		self.anonymous = anonymous
		language = lang
		let handlename: String = entry[JSONKey.user.handle] as? String ?? ""
		name = UserName(identifier: identifier, nickname: nickname, handle: handlename)
		isPremium = (premium & (0x01 << 0)) != 0x00 ? false : true
		isPrivilege = (premium & (0x01 << 1)) != 0x00 ? false : true
		isVIP = (premium & (0x01 << 2)) != 0x00 ? false : true
		friendship = entry[JSONKey.user.friendship] as? String == True ? Friendship.known : Friendship.met
		lock = entry[JSONKey.user.lock] as? String == True ? true : false
			// update time
		let formatter: DateFormatter = DateFormatter()
		formatter.dateStyle = DateFormatter.Style.short
		formatter.timeStyle = DateFormatter.Style.short
		let lastMetString: String = entry[JSONKey.user.met] as? String ?? formatter.string(from: Date())
		lastMet = formatter.date(from: lastMetString)!
		entry[JSONKey.user.met] = formatter.string(from: Date())
		super.init()
			// color
		if let colorString: String = entry[JSONKey.user.color] as? String {
			color = hexcClorToColor(hexColor: colorString)
		}// end if have color
			// note
		if let noteString: String = entry[JSONKey.user.note] as? String { note = noteString }
	}// end init from entry

	public func setColor (hexColor: String) -> Void {
		color = hexcClorToColor(hexColor: hexColor)
		entry.setValue(hexColor, forKey: JSONKey.user.color.rawValue)
	}// end setColor

	public func setColor (rgbColor: NSColor) -> Void {
		color = rgbColor
		entry.setValue(rgbColorToHexColor(rgbColor: rgbColor), forKey: JSONKey.user.color.rawValue)
	}// end setColor
	
	public func addEntryTo (listensers: NSMutableDictionary) {
		let identifier = name.identifier
		listensers.setValue(entry, forKey: identifier)
	}// end func addEntryTo

	private func hexcClorToColor (hexColor: String) -> NSColor {
		guard hexColor.count == 7, hexColor.prefix(1) == "#" else { return NSColor.white }
		let redStr: String = hexColor[hexColor.index(hexColor.startIndex, offsetBy: 1) ... hexColor.index(hexColor.startIndex, offsetBy: 2)].description
		let greenStr: String = hexColor[hexColor.index(hexColor.startIndex, offsetBy: 3) ... hexColor.index(hexColor.startIndex, offsetBy: 4)].description
		let blueStr: String = hexColor[hexColor.index(hexColor.startIndex, offsetBy: 5) ..< hexColor.endIndex].description
		
		let red: CGFloat = CGFloat(Int(redStr)!) / 0xff
		let green: CGFloat = CGFloat(Int(greenStr)!) / 0xff
		let blue: CGFloat = CGFloat(Int(blueStr)!) / 0xff
		
		return NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1.0)
	}// end func hexColorToColor

	private func rgbColorToHexColor (rgbColor: NSColor) -> String {
		var red: CGFloat = 1.0
		var green: CGFloat = 1.0
		var blue: CGFloat = 1.0
		var alpha: CGFloat = 1.0
		rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

		let intRed: Int = Int(red * 0xff)
		let intGreen: Int = Int(green * 0xff)
		let intBlue: Int = Int(blue * 0xff)
		let hexColor: String = String(format: "#%02x%02x%02x", intRed, intGreen, intBlue)

		return hexColor
	}// end func rgbColorToHexColor
}// end class NicoLiveUser
