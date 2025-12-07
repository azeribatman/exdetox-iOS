//
//  SSEClient+Event.swift
//  
//
//  Created by Aykhan Safarli on 22.03.25.
//

import Foundation

extension SSEClient {
    struct Event {
        let name: String
        let value: String
        
        static func parse(_ dataArray: [String]) -> [Event] {
            var events = [Event]()
            
            var index = 0
            
            while index < dataArray.count {
                let data = dataArray[index]
                
                guard data.contains("event: ") else { 
                    index += 1
                    continue 
                }
                
                let nameString = data
                    .replacingOccurrences(of: "event: ", with: "")
                let name = nameString
                
                // Check if next line exists and contains data
                guard index + 1 < dataArray.count else {
                    print("⚠️ Event parsing: No data line found for event '\(name)'")
                    index += 1
                    continue
                }
                
                let nextLine = dataArray[index + 1]
                guard nextLine.contains("data: ") else {
                    print("⚠️ Event parsing: Next line doesn't contain 'data: ' - '\(nextLine)'")
                    index += 1
                    continue
                }
                
                let value = nextLine.replacingOccurrences(of: "data: ", with: "")
                
                let event = Event(name: name, value: value)
                events.append(event)
                
                print("✅ Parsed event: name='\(name)', value='\(value)'")
                
                index += 2
            }
            
            return events
        }
    }
}
