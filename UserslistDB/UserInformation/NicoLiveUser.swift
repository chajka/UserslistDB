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

public struct UserName {
	let identifier:String
	let nickname:String
	var handle:String
}// end struct UserName

public enum JSONKey {
	enum user:String {
		case nickname = "nickname"
		case handle = "handle"
		case isPremium = "isPremium"
		case language = "Language"
		case friendship = "known"
		case lock = "lock"
		case color = "color"
		case met = "lasstMet"
		case note = "note"
	}// end enum user
}// end enum JSONKey

extension JSONKey.user: StringEnum { }

public class NicoLiveUser: NSObject {
	public var name:UserName
	private var handle:String {
		get {
			return name.handle
		}// end get
		set (newHandle) {
			name.handle = newHandle
			entry[JSONKey.user.handle] = newHandle
		}// end set
	}// end property handle
	public let anonymous:Bool
	public let isPremium:Bool
	public let language:UserLanguage
	public var friendship:Friendship
	public var thumbnail:NSImage!
	public var lock:Bool = false {
		didSet (newState) {
			entry[JSONKey.user.lock] =  newState ? "yes" : nil
		}// end didSet
	}// end property lock
	public let lastMet:Date
	public var color:NSColor?
	public var note:String? {
		didSet (newNote) {
			entry[JSONKey.user.note] = newNote
		}// end didSet
	}// end property note

	private var entry:Dictionary<String, String>

	public init (nickname:String, identifier:String, premium:Bool, anonymous:Bool, lang:UserLanguage, met:Friendship) {
		entry = Dictionary()
		let handle:String = anonymous ? nickname : String(nickname.prefix(10))
		name = UserName(identifier: identifier, nickname: nickname, handle: handle)
		isPremium = premium
		self.anonymous = anonymous
		friendship = met
		lastMet = Date()
		language = lang
			// set entry object
		entry[JSONKey.user.nickname] = nickname
		entry[JSONKey.user.handle] = handle
		if isPremium { entry[JSONKey.user.isPremium] = "yes" }
		let formatter:DateFormatter = DateFormatter()
		formatter.dateStyle = DateFormatter.Style.short
		formatter.timeStyle = DateFormatter.Style.short
		entry[JSONKey.user.met] = formatter.string(from: lastMet)
	}// end init

	public init (user:[String: String], identifier:String, anonymous:Bool, lang:UserLanguage) {
		entry = user
		self.anonymous = anonymous
		language = lang
		var username:String = entry[JSONKey.user.nickname]!
		if anonymous { username = String(username.prefix(10)) }
		let handlename:String = entry[JSONKey.user.handle]!
		name = UserName(identifier: identifier, nickname: username, handle: handlename)
		isPremium = entry[JSONKey.user.isPremium] == "yes" ? true : false
		friendship = entry[JSONKey.user.friendship] == "yes" ? Friendship.known : Friendship.met
		lock = entry[JSONKey.user.lock] == "yes" ? true : false
			// update time
		let formatter:DateFormatter = DateFormatter()
		formatter.dateStyle = DateFormatter.Style.short
		formatter.timeStyle = DateFormatter.Style.short
		let lastMetString:String = entry[JSONKey.user.met] ?? formatter.string(from: Date())
		lastMet = formatter.date(from: lastMetString)!
		entry[JSONKey.user.met] = formatter.string(from: Date())
		super.init()
			// color
		if let colorString:String = entry[JSONKey.user.color] {
			color = hexcClorToColor(hexColor: colorString)
		}// end if have color
			// note
		if let noteString:String = entry[JSONKey.user.note] { note = noteString }
	}// end init from entry

	public func setColor (hexColor:String) -> Void {
		color = hexcClorToColor(hexColor: hexColor)
		entry[JSONKey.user.color] = hexColor
	}// end setColor

	public func setColor (rgbColor: NSColor) -> Void {
		color = rgbColor
		entry[JSONKey.user.color] = rgbColorToHexColor(rgbColor: rgbColor)
	}// end setColor
	
	public func addEntryTo (listensers:inout [String: [String: String]]) {
		let identifier = name.identifier
		listensers[identifier] = entry
	}// end func addEntryTo

	private func hexcClorToColor (hexColor:String) -> NSColor {
		guard hexColor.count == 7, hexColor.prefix(1) == "#" else { return NSColor.white }
		let redStr:String = hexColor[hexColor.index(hexColor.startIndex, offsetBy: 1) ... hexColor.index(hexColor.startIndex, offsetBy: 2)].description
		let greenStr:String = hexColor[hexColor.index(hexColor.startIndex, offsetBy: 3) ... hexColor.index(hexColor.startIndex, offsetBy: 4)].description
		let blueStr:String = hexColor[hexColor.index(hexColor.startIndex, offsetBy: 5) ..< hexColor.endIndex].description
		
		let red:CGFloat = CGFloat(Int(redStr)!) / 0xff
		let green:CGFloat = CGFloat(Int(greenStr)!) / 0xff
		let blue:CGFloat = CGFloat(Int(blueStr)!) / 0xff
		
		return NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1.0)
	}// end func hexColorToColor

	private func rgbColorToHexColor (rgbColor: NSColor) -> String {
		var red: CGFloat = 1.0
		var green: CGFloat = 1.0
		var blue: CGFloat = 1.0
		var alpha: CGFloat = 1.0
		rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

		let intRed = Int(red * 0xff)
		let intGreen = Int(green * 0xff)
		let intBlue = Int(blue * 0xff)
		let hexColor:String = String(format: "#%02x%02x%02x", intRed, intGreen, intBlue)

		return hexColor
	}// end func rgbColorToHexColor
}// end class NicoLiveUser
