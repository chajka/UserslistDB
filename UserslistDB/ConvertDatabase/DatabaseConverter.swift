//
//  DatabaseConverter.swift
//  UserslistDB
//
//  Created by Чайка on 2018/07/10.
//  Copyright © 2018 Чайка. All rights reserved.
//

import Cocoa

private enum ElementName: String {
	case user = "user"
	case handle = "handle"
	case note = "note"

	static func ~= (lhs: ElementName, rhs: String) -> Bool {
		return lhs.rawValue == rhs ? true : false
	}// end func ~=
}// end enum ElementName

private enum Attribute {
	enum user {
		enum name: String {
			case identifier = "id"
			case kind = "type"
			case comment = "comment"
			case speech = "speech"

			static func ~= (lhs: name, rhs: String) -> Bool {
				return lhs.rawValue == rhs ? true : false
			}// end func ~=
		}// end enum name
		enum value: String {
			case id = "id"
			case anonymous = "184"
			case anon = "anon"
			case sign = "sign"
			case yes = "yes"
			case no = "no"

			static func == (lhs: value, rhs: String) -> Bool {
				return lhs.rawValue == rhs
			}// end func ==
		}// end enum value
	}// end enum user
	enum handle {
		enum name: String {
			case owner = "personality"
			case lock = "lock"
			case known = "known"
			case color = "color"

			static func ~= (lhs: name, rhs: String) -> Bool {
				return lhs.rawValue == rhs ? true : false
			}// end func ~=
		}// end enum name
		enum value: String {
			case yes = "yes"
		}// end enum value
	}// end enum handle
}// end enum Attribute

extension Attribute.user.name: StringEnum { }
extension Attribute.user.value: StringEnum { }
extension Attribute.handle.name: StringEnum { }
extension Attribute.handle.value: StringEnum { }

public class DatabaseConverter: NSObject , XMLParserDelegate {
	private var owners: NSMutableDictionary = NSMutableDictionary()
	private var users: Dictionary<String, Bool> = Dictionary()
	private let date: String
	private let databaseJSONFilePath: String
	private var serializedData: Data!

	private var currentUserIdentifier: String = String()
	private var currentOwnerIdentifier: String = String()
	private var user: NSMutableDictionary = NSMutableDictionary()
	private var currentUsers: Array<NSMutableDictionary> = Array()
	private var anonymous: Bool = true
	private var stringBuffer: String = String()

	private let parser:XMLParser

	public init (databasePath: String, databaseFile :String = "userslist") throws {
		let databaseFullpath: String = databasePath.prefix(1) == "~" ? (databasePath as NSString).expandingTildeInPath : databasePath
		let databaseXMLFilePath :String = databaseFullpath + "/" + databaseFile + ".xml"
		databaseJSONFilePath = databaseFullpath + "/" + databaseFile + ".json"
		let data: NSData = try NSData(contentsOfFile: databaseXMLFilePath)
		parser = XMLParser(data: data as Data)
		let dateFormatter: DateFormatter = DateFormatter()
		dateFormatter.dateStyle = DateFormatter.Style.short
		dateFormatter.timeStyle = DateFormatter.Style.short
		date = dateFormatter.string(from: Date())
	}// end init

	public func parse() -> Bool {
		parser.delegate = self
		let succcess: Bool = parser.parse()
		do {
			var jsonObj: Dictionary<String, Any> = Dictionary()
			jsonObj[JSONKey.toplevel.owners] = owners
			jsonObj[JSONKey.toplevel.users] = users
			serializedData = try JSONSerialization.data(withJSONObject: jsonObj, options: JSONSerialization.WritingOptions.prettyPrinted)
			print(String(data: serializedData, encoding: .utf8)!)
		} catch {
			print("JSON serialization error")
		}
		return succcess
	}// end func parse

	public func writeJson() -> Bool {
		do {
			try (serializedData as NSData).write(toFile: databaseJSONFilePath, options: NSData.WritingOptions.atomicWrite)
			return true
		} catch {
			return false
		}// end try write to file
	}// end func writeJson

	public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		stringBuffer = String()

		switch elementName {
		case .user:
			guard let userID: String = attributeDict[Attribute.user.name.identifier], let anon = attributeDict[Attribute.user.name.kind] else { return }
			currentUserIdentifier = userID
			anonymous = Attribute.user.value.anonymous == anon ? true : false
			if (!anonymous) {
				users[currentUserIdentifier] = false
				user = NSMutableDictionary()
					// get or create owner
				let owner: NSMutableDictionary = owners[currentUserIdentifier] as? NSMutableDictionary ?? NSMutableDictionary()
				let listeners: NSMutableDictionary = NSMutableDictionary()
				if let comment: String = attributeDict[Attribute.user.name.comment]  {
					let anonComment:Bool = Attribute.user.value.sign == comment
					if !anonComment { owner[JSONKey.owner.anonymous] = true }
				}// end if comment mode to this owner
				if let speech: String = attributeDict[Attribute.user.name.speech] {
					let speechAtThisOwner: Bool = Attribute.user.value.yes == speech
					if speechAtThisOwner { owner[JSONKey.owner.speech] = true }
				}// end if enable speech to this owner
				if listeners.allKeys.count > 0 { owner[JSONKey.owner.listeners] = listeners }
				if owner.allKeys.count > 0 { owners[currentUserIdentifier] = owner }
			}// end if not anonymous
		case .handle:
			guard let currentOwner = attributeDict[Attribute.handle.name.owner] else { return }
			if anonymous { return }
			currentOwnerIdentifier = currentOwner
			let ownerForCurrentUser: NSMutableDictionary = owners[currentOwnerIdentifier] as? NSMutableDictionary ?? NSMutableDictionary()
			let userForCurrentOwner: NSMutableDictionary = NSMutableDictionary(dictionary: user)
			for attribute: String in attributeDict.keys {
				switch attribute {
				case .lock:
					if attributeDict[Attribute.handle.name.lock] == "yes" { userForCurrentOwner[JSONKey.user.lock] = "yes" }
				case .known:
					if attributeDict[Attribute.handle.name.known] == "yes" {userForCurrentOwner[JSONKey.user.friendship] = "yes" }
				case .color:
					if let color = attributeDict[Attribute.handle.name.color] { userForCurrentOwner[JSONKey.user.color] = color }
				default:
					break
				}// end switch case by attribute dictionary key
			}// end foreach attribute dictionary contents
			if ownerForCurrentUser[JSONKey.owner.listeners] == nil { ownerForCurrentUser[JSONKey.owner.listeners] = NSMutableDictionary() }
			if let listeners = ownerForCurrentUser[JSONKey.owner.listeners] as? NSMutableDictionary {
				listeners[currentUserIdentifier] = userForCurrentOwner
			}// end optional binding
			currentUsers.append(userForCurrentOwner)
		default:
			break
		}// end switch case by user element or handle element
	}// end func parser didStartElement

	public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if anonymous { return }
		switch elementName {
		case .user:
			currentUserIdentifier = String()
			currentOwnerIdentifier = String()
			user = NSMutableDictionary()
			currentUsers = Array()
			anonymous = true
			stringBuffer = String()
		case .handle:
			let handle: String = String(stringBuffer)
			for entry: NSMutableDictionary in currentUsers {
				entry[JSONKey.user.handle] = handle
				entry[JSONKey.user.met] = date
			}
		default:
			break
		}// end swith case by element name
	}// end func parser didEndElement

	public func parser(_ parser: XMLParser, foundCharacters string: String) {
		stringBuffer += string
	}// end func parser foundCharacters
}// end class
