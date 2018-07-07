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
	let identifier: String
	let nickname: String
	var handle: String
}// end struct UserName

public class NicoLiveUser: NSObject {
	public var name: UserName
	private var handle: String {
		get {
			return name.handle
		}// end get
		set (newHandle) {
			name.handle = newHandle
			entry.setValue(newHandle, forKey: JSONKey.user.handle.rawValue)
		}// end set
	}// end property handle
	public let anonymous: Bool
	public let isPremium: Bool
	public let language: UserLanguage
	public var friendship: Friendship
	public var thumbnail: NSImage!
	public var lock:Bool = false {
		didSet (newState) {
			entry.setValue(newState ? "yes" : nil, forKey: JSONKey.user.lock.rawValue)
		}// end didSet
	}// end property lock
	public let lastMet: Date
	public var color: NSColor?
	public var note: String? {
		didSet (newNote) {
			entry.setValue(newNote, forKey: JSONKey.user.note.rawValue)
		}// end didSet
	}// end property note

	private var entry: NSMutableDictionary

	public init (nickname:String, identifier:String, premium:Bool, anonymous:Bool, lang:UserLanguage, met:Friendship) {
		entry = NSMutableDictionary()
		let handle:String = anonymous ? nickname : String(nickname.prefix(10))
		name = UserName(identifier: identifier, nickname: nickname, handle: handle)
		isPremium = premium
		self.anonymous = anonymous
		friendship = met
		lastMet = Date()
		language = lang
			// set entry object
		entry.setValue(nickname, forKey: JSONKey.user.nickname.rawValue)
		entry.setValue(handle, forKey: JSONKey.user.handle.rawValue)
		if isPremium { entry.setValue("yes", forKey: JSONKey.user.isPremium.rawValue) }
		let formatter:DateFormatter = DateFormatter()
		formatter.dateStyle = DateFormatter.Style.short
		formatter.timeStyle = DateFormatter.Style.short
		entry.setValue(formatter.string(from: lastMet), forKey: JSONKey.user.met.rawValue)
	}// end init

	public init (user: NSMutableDictionary, identifier:String, anonymous:Bool, lang:UserLanguage) {
		entry = user
		self.anonymous = anonymous
		language = lang
		var username:String = entry.value(forKey: JSONKey.user.nickname.rawValue) as! String
		if anonymous { username = String(username.prefix(10)) }
		let handlename:String = entry.value(forKey: JSONKey.user.handle.rawValue) as! String
		name = UserName(identifier: identifier, nickname: username, handle: handlename)
		isPremium = entry.value(forKey: JSONKey.user.isPremium.rawValue) as? String == "yes" ? true : false
		friendship = entry.value(forKey: JSONKey.user.friendship.rawValue) as? String == "yes" ? Friendship.known : Friendship.met
		lock = entry.value(forKey: JSONKey.user.lock.rawValue) as? String == "yes" ? true : false
			// update time
		let formatter: DateFormatter = DateFormatter()
		formatter.dateStyle = DateFormatter.Style.short
		formatter.timeStyle = DateFormatter.Style.short
		let lastMetString:String = entry.value(forKey: JSONKey.user.met.rawValue) as? String ?? formatter.string(from: Date())
		lastMet = formatter.date(from: lastMetString)!
		entry.setValue(formatter.string(from: Date()), forKey: JSONKey.user.met.rawValue)
		super.init()
			// color
		if let colorString:String = entry.value(forKey: JSONKey.user.color.rawValue) as? String {
			color = hexcClorToColor(hexColor: colorString)
		}// end if have color
			// note
		if let noteString:String = entry.value(forKey: JSONKey.user.note.rawValue) as? String { note = noteString }
	}// end init from entry

	public func setColor (hexColor:String) -> Void {
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
