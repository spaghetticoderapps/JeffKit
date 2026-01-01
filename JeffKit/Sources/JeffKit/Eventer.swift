//
//  File.swift
//  JeffKit
//
//  Created by Jeff Cedilla on 12/2/24.
//

import Foundation
import SwiftUI
import Mixpanel

public class Eventer {
    @MainActor public static let shared = Eventer()
    
    public func initializeMixpanel(token: String) {
        #if os(iOS)
        Mixpanel.initialize(token: token, trackAutomaticEvents: false)
        #else
        Mixpanel.initialize(token: token)
        #endif
    }
    
    public init() {
//        Mixpanel.initialize(token: "7d097a3bf16c3ad5adb5519da5287c69", trackAutomaticEvents: false)
        // Enable if you want to key off unique IDs
        //        Mixpanel.mainInstance().identify(distinctId: "USER_ID")
    }
    
    public func tap(_ buttonName: String, screenName: String = "", properties: Properties? = nil) {
        var eventProperties: Properties = [
            "button_name": buttonName,
            "screen_name": screenName
        ]
        
        // Append additional properties if provided
        if let additionalProperties = properties {
            for (key, value) in additionalProperties {
                eventProperties[key] = value
            }
        }
        
        Mixpanel.mainInstance().track(event: "Button Tapped", properties: eventProperties)
    }
    
    public func trackScreenView(screenName: String) {
        Mixpanel.mainInstance().track(event: "Screen Viewed", properties: ["screen_name": screenName])
    }
    
    public func track(_ eventName: String, properties: Properties? = nil) {
        Mixpanel.mainInstance().track(event: eventName, properties: properties)
    }
}

public protocol EventTracking {
    var scrnName: String { get }
}



public extension EventTracking {
    var scrnName: String {
        String(describing: type(of: self))
//            .replacingOccurrences(of: "View", with: " Screen")
//            .components(separatedBy: .uppercaseLetters)
//            .joined(separator: " ")
//            .trimmingCharacters(in: .whitespaces)
    }
    
    @MainActor func trackScreenView() {
        Eventer.shared.trackScreenView(screenName: scrnName)
    }
}

public extension View {
    public func eventTracking<T: EventTracking>(for tracking: T) -> some View {
        self.onAppear {
            tracking.trackScreenView()
        }
    }
}

struct EventerButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            Eventer.shared.tap(title)
            action()
        }) {
            Text(title)
        }
    }
}

// Usage example
//struct ContentView: View, EventTracking {
//    var screenName: String { "Main Screen" }
//    
//    var body: some View {
//        VStack {
//            Text("Welcome to the app!")
//            EventerButton(title: "Tap me") {
//                print("Button tapped")
//            }
//        }
//        .eventTracking(for: self)
//    }
//}

//struct DetailView: View, EventTracking {
//    var screenName: String { "Detail Screen" }
//    
//    var body: some View {
//        Text("This is the detail view")
//            .eventTracking(for: self)
//    }
//}
