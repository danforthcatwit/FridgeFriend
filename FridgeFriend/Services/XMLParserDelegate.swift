//
//  XMLParserDelegate.swift
//  FridgeFriend
//
//  Created by Colin James on 3/29/25.
//

import Foundation

class XMLParserDelegate: NSObject, Foundation.XMLParserDelegate {
    var foodNames: [String] = []
    private var currentElement = ""
    private var currentSuggestion = ""
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        print("Started element: \(elementName)") // Debug log
        currentElement = elementName
        if elementName == "suggestion" {
            currentSuggestion = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "suggestion" {
            currentSuggestion += string
            print("Found characters in suggestion: \(string)") // Debug log
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("Ended element: \(elementName)") // Debug log
        if elementName == "suggestion" && !currentSuggestion.isEmpty {
            print("Adding suggestion: \(currentSuggestion)") // Debug log
            foodNames.append(currentSuggestion.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("XML Parse Error: \(parseError)") // Debug log
    }
}
