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

enum JSONKey {
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
	}
}// end enum JSONKey

extension JSONKey.user: StringEnum { }

class NicoLiveUser: NSObject {
	public let name:UserName
	public let anonymous:Bool
	public let isPremium:Bool
	public let language:UserLanguage
	public var friendship:Friendship
	public var thumbnail:NSImage!
	public var lock:Bool = false
	public let lastMet:Date
	public var color:NSColor?
	public var backgroundColor:String? {
		willSet(newColor) {
			guard let hexColor = newColor, hexColor.count == 7, hexColor.prefix(1) == "#" else { return }
			entry[JSONKey.user.color] = hexColor
			let redStr:String = hexColor[hexColor.index(hexColor.startIndex, offsetBy: 1) ... hexColor.index(hexColor.startIndex, offsetBy: 2)].description
			let greenStr:String = hexColor[hexColor.index(hexColor.startIndex, offsetBy: 3) ... hexColor.index(hexColor.startIndex, offsetBy: 4)].description
			let blueStr:String = hexColor[hexColor.index(hexColor.startIndex, offsetBy: 5) ..< hexColor.endIndex].description
			
			let red:CGFloat = CGFloat(Int(redStr)!) / 0xff
			let green:CGFloat = CGFloat(Int(greenStr)!) / 0xff
			let blue:CGFloat = CGFloat(Int(blueStr)!) / 0xff

			color = NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1.0)
		}// end willSet
	}// end computed property backgroundColor
	public var note:String?

	private var entry:Dictionary<String, String>

	init(user:[String: String], identifier:String, anonymous:Bool, lang:UserLanguage) {
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
			// color
		if let colorString:String = entry[JSONKey.user.color] { self.backgroundColor = colorString }
			// note
		if let noteString:String = entry[JSONKey.user.note] { note = noteString }
	}// end init from entry

}// end class NicoLiveUser
