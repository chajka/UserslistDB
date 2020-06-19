//
//  DatabaseConverter.swift
//  UserslistDB
//
//  Created by Чайка on 2018/07/10.
//  Copyright © 2018 Чайка. All rights reserved.
//

import Cocoa
import DeuxCheVaux

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
			static func == (lhs: String, rhs: name) -> Bool {
				return lhs == rhs.rawValue
			}// end func ==
		}// end enum name
		enum value: String {
			case yes = "yes"
			case no = "no"

			static func == (lhs: String, rhs: value) -> Bool {
				return lhs == rhs.rawValue
			}// end func ==
		}// end enum value
	}// end enum handle
}// end enum Attribute

extension Attribute.user.name: StringEnum { }
extension Attribute.user.value: StringEnum { }
extension Attribute.handle.name: StringEnum { }
extension Attribute.handle.value: StringEnum { }

public final class DatabaseConverter: NSObject , XMLParserDelegate {
		// MARK: - Properties
		// MARK: - Member variables
	private let date: String
	private let databaseJSONFileURL: URL
	private let databaseFoldeerURL: URL
	private var serializedData: Data!

	private var currentUserIdentifier: String = String()
	private var currentOwnerIdentifier: String = String()
	private var user: JSONizableUser?
	private var onymous: Bool = true
	private var anonymousComment: Bool = false

	private var lock: Bool?
	private var known: Bool?
	private var color: String?

	private var stringBuffer: String = String()

	private let allUsers: JSONizableAllUsers = JSONizableAllUsers()
	private let parser:XMLParser
	private var data: Data?

		// MARK: - Constructor/Destructor
	public init (databasePath: String, databaseFile :String = "userslist") throws {
		let deuxCheVaux: DeuxCheVaux = DeuxCheVaux.shared
		deuxCheVaux.setFirstLaucn()
		let databaseFullpath: String = databasePath.prefix(1) == "~" ? (NSHomeDirectory() + String(databasePath.suffix(databasePath.count - 1))) : databasePath
		databaseFoldeerURL = URL(fileURLWithPath: databaseFullpath, isDirectory: true)
		let databaseXMLURL: URL = databaseFoldeerURL.appendingPathComponent(databaseFile).appendingPathExtension("xml")
		let data: Data = try Data(contentsOf: databaseXMLURL)
		databaseJSONFileURL = databaseFoldeerURL.appendingPathComponent(databaseFile).appendingPathExtension("json")
		parser = XMLParser(data: data)
		let dateFormatter: DateFormatter = DateFormatter()
		dateFormatter.dateStyle = DateFormatter.Style.short
		dateFormatter.timeStyle = DateFormatter.Style.short
		date = dateFormatter.string(from: Date())
		super.init()
		parser.delegate = self
	}// end init

		// MARK: - Override
		// MARK: - Actions
		// MARK: - Public methods
	public func parse() -> Bool {
		let succcess: Bool = parser.parse()
		do {
			let encoder: JSONEncoder = JSONEncoder()
			encoder.outputFormatting = JSONEncoder.OutputFormatting.prettyPrinted
			data = try encoder.encode(allUsers)
		} catch let error {
			print("JSON serialization error \(error.localizedDescription)")
		}
		return succcess
	}// end func parse

	public func writeJson() -> Bool {
		do {
			if let data: Data = self.data {
				try data.write(to: databaseJSONFileURL)
				return true
			} else {
				return false
			}// end optional binding check for data
		} catch {
			return false
		}// end try write to file
	}// end func writeJson

		// MARK: - Internal methods
		// MARK: - Private methods
		// MARK: - Delegates
			// MARK: XMLParserDelegate
	public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		stringBuffer = String()

		switch elementName {
		case .user:
			guard let userID: String = attributeDict[Attribute.user.name.identifier], let onym = attributeDict[Attribute.user.name.kind] else { return }
			onymous = Attribute.user.value.id == onym ? true : false
			if onymous {
				currentUserIdentifier = userID
				allUsers.addUser(identifier: currentUserIdentifier, onymity: true)
					// get or create owner
				var anonymousComment: Bool = true
				var monitor: Bool = false
				if let comment: String = attributeDict[Attribute.user.name.comment]  {
					if  Attribute.user.value.sign == comment { anonymousComment = false }
				}// end if comment mode to this owner
				if let speech: String = attributeDict[Attribute.user.name.speech] {
					if Attribute.user.value.yes == speech { monitor = true }
				}// end if enable speech to this owner
				if anonymousComment == false || monitor == true {
					let users: JSONizableUsers = allUsers.users(forOwner: currentUserIdentifier)
					users.anonymousComment = anonymousComment
					users.monitor = monitor
				}// end if have attribute omment or speech (update or make owner witth current attribute)
			}// end if not anonymous
		case .handle:
			guard let currentOwnerIdentifier = attributeDict[Attribute.handle.name.owner], onymous else { return }
			self.currentOwnerIdentifier = currentOwnerIdentifier

			lock = nil
			known = nil
			color = nil
			for attribute: String in attributeDict.keys {
				switch attribute {
				case .lock :
					if let lockAttr: String = attributeDict[Attribute.handle.name.lock] {
						if lockAttr == Attribute.handle.value.yes { lock = true }
						if lockAttr == Attribute.handle.value.no { lock = false }
					}// end optional binding check for lock attribute have value
				case .known:
					if let knownAttr: String = attributeDict[Attribute.handle.name.known] {
						known = knownAttr == Attribute.handle.value.yes ? true : false
					}// end optional binding check for lock attribute have value
				case .color:
					if let color = attributeDict[Attribute.handle.name.color] { self.color = color }
				default:
					break
				}// end switch case by attribute dictionary key
			}// end foreach attribute dictionary contents
		default:
			break
		}// end switch case by user element or handle element
	}// end func parser didStartElement

	public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if !onymous { return }
		switch elementName {
		case .user:
			currentUserIdentifier = String()
			onymous = false
			stringBuffer = String()
		case .handle:
			let usersFroCurrentOwner: JSONizableUsers = allUsers.users(forOwner: currentOwnerIdentifier)
			let handle: String = String(stringBuffer)
			let user: JSONizableUser = JSONizableUser(handle)

			if let lock: Bool = self.lock { user.lock = lock }
			if let known: Bool = self.known { user.known = known }
			if let color: String = self.color { user.color = color }
			usersFroCurrentOwner.addUser(identifier: currentUserIdentifier, with: user)
		default:
			break
		}// end swith case by element name
	}// end func parser didEndElement

	public func parser(_ parser: XMLParser, foundCharacters string: String) {
		stringBuffer += string
	}// end func parser foundCharacters
}// end class
