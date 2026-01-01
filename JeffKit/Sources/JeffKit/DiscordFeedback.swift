//
//  DiscordFeedback.swift
//  JeffKit
//
//  Created by Jeff Cedilla
//

import SwiftUI

/// Default Discord webhook URL for feedback across all apps
public let defaultDiscordWebhookURL = "https://discord.com/api/webhooks/1447434068319928475/z2XWBclelY-1JNcuTvYraDfZWkjROhZh-Bi1bEIHm_HHJD9chBQm99XlQRpIFJ_J01uE"

// MARK: - Localized Strings
private enum FeedbackStrings {
    static let thankYou = String(localized: "Thank you!", bundle: .module)
    static let feedbackSent = String(localized: "Your feedback has been sent.", bundle: .module)
    static let done = String(localized: "Done", bundle: .module)
    static let sendFeedback = String(localized: "Send Feedback", bundle: .module)
    static let emailOptional = String(localized: "Email (optional)", bundle: .module)
    static let emailPlaceholder = String(localized: "your@email.com", bundle: .module)
    static let emailHint = String(localized: "Include your email if you'd like a response", bundle: .module)
    static let cancel = String(localized: "Cancel", bundle: .module)
    static let send = String(localized: "Send", bundle: .module)
    static let feedback = String(localized: "Feedback", bundle: .module)
}

/// A reusable Discord feedback component that can be used across apps.
/// Provides a popover-based feedback form that sends messages to a Discord webhook.
@available(iOS 16.0, macOS 13.0, *)
public struct DiscordFeedbackView: View {
    @Binding var isPresented: Bool
    let webhookURL: String
    let appName: String

    @State private var feedbackText = ""
    @State private var feedbackEmail = ""
    @State private var isSending = false
    @State private var feedbackSent = false

    public init(isPresented: Binding<Bool>, webhookURL: String = defaultDiscordWebhookURL, appName: String) {
        self._isPresented = isPresented
        self.webhookURL = webhookURL
        self.appName = appName
    }

    public var body: some View {
        VStack(spacing: 12) {
            if feedbackSent {
                successView
            } else {
                feedbackForm
            }
        }
        .padding()
        .frame(width: 320)
    }

    private var successView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text(FeedbackStrings.thankYou)
                .font(.headline)

            Text(FeedbackStrings.feedbackSent)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(FeedbackStrings.done) {
                feedbackSent = false
                isPresented = false
            }
            #if os(macOS)
            .keyboardShortcut(.defaultAction)
            #endif
        }
        .frame(width: 280)
        .padding(.vertical, 20)
    }

    private var feedbackForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(FeedbackStrings.sendFeedback)
                .font(.headline)

            #if os(macOS)
            TextEditor(text: $feedbackText)
                .font(.body)
                .frame(width: 280, height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            #else
            TextEditor(text: $feedbackText)
                .font(.body)
                .frame(height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            #endif

            VStack(alignment: .leading, spacing: 4) {
                Text(FeedbackStrings.emailOptional)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                TextField(FeedbackStrings.emailPlaceholder, text: $feedbackEmail)
                    #if os(iOS)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    #else
                    .textFieldStyle(.roundedBorder)
                    #endif
                Text(FeedbackStrings.emailHint)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            HStack {
                Spacer()
                Button(FeedbackStrings.cancel) {
                    feedbackText = ""
                    feedbackEmail = ""
                    isPresented = false
                }
                #if os(macOS)
                .keyboardShortcut(.cancelAction)
                #endif

                Button {
                    sendFeedback()
                } label: {
                    if isSending {
                        ProgressView()
                            #if os(macOS)
                            .scaleEffect(0.7)
                            #endif
                            .frame(width: 50)
                    } else {
                        Text(FeedbackStrings.send)
                    }
                }
                #if os(macOS)
                .keyboardShortcut(.defaultAction)
                #endif
                .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
            }
        }
    }

    private func sendFeedback() {
        guard let url = URL(string: webhookURL) else { return }

        let message = feedbackText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }

        let email = feedbackEmail.trimmingCharacters(in: .whitespacesAndNewlines)

        isSending = true

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var content = "**[\(appName)] New Feedback:**\n\(message)"
        if !email.isEmpty {
            content += "\n\n**Reply to:** \(email)"
        }

        let payload: [String: Any] = [
            "content": content
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            isSending = false
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isSending = false
                if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 {
                    feedbackText = ""
                    feedbackEmail = ""
                    feedbackSent = true
                }
            }
        }.resume()
    }
}

/// A sheet-based feedback view for use with UIKit presentation or .sheet modifier.
@available(iOS 16.0, macOS 13.0, *)
public struct DiscordFeedbackSheet: View {
    @Environment(\.dismiss) private var dismiss
    let webhookURL: String
    let appName: String

    public init(webhookURL: String = defaultDiscordWebhookURL, appName: String) {
        self.webhookURL = webhookURL
        self.appName = appName
    }

    public var body: some View {
        NavigationStack {
            DiscordFeedbackViewInternal(
                webhookURL: webhookURL,
                appName: appName,
                onDismiss: { dismiss() }
            )
            .navigationTitle(FeedbackStrings.sendFeedback)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(FeedbackStrings.cancel) { dismiss() }
                }
            }
        }
    }
}

/// Internal feedback view without the isPresented binding for sheet use.
@available(iOS 16.0, macOS 13.0, *)
private struct DiscordFeedbackViewInternal: View {
    let webhookURL: String
    let appName: String
    let onDismiss: () -> Void

    @State private var feedbackText = ""
    @State private var feedbackEmail = ""
    @State private var isSending = false
    @State private var feedbackSent = false

    var body: some View {
        VStack(spacing: 16) {
            if feedbackSent {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)

                    Text(FeedbackStrings.thankYou)
                        .font(.headline)

                    Text(FeedbackStrings.feedbackSent)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button(FeedbackStrings.done) {
                        onDismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.vertical, 40)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    TextEditor(text: $feedbackText)
                        .font(.body)
                        .frame(height: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(FeedbackStrings.emailOptional)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        TextField(FeedbackStrings.emailPlaceholder, text: $feedbackEmail)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                        Text(FeedbackStrings.emailHint)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    Spacer()

                    Button {
                        sendFeedback()
                    } label: {
                        if isSending {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text(FeedbackStrings.sendFeedback)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
                }
            }
        }
        .padding()
    }

    private func sendFeedback() {
        guard let url = URL(string: webhookURL) else { return }

        let message = feedbackText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }

        let email = feedbackEmail.trimmingCharacters(in: .whitespacesAndNewlines)

        isSending = true

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var content = "**[\(appName)] New Feedback:**\n\(message)"
        if !email.isEmpty {
            content += "\n\n**Reply to:** \(email)"
        }

        let payload: [String: Any] = ["content": content]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            isSending = false
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isSending = false
                if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 {
                    feedbackText = ""
                    feedbackEmail = ""
                    feedbackSent = true
                }
            }
        }.resume()
    }
}

/// A toolbar button that shows a feedback sheet when tapped.
@available(iOS 16.0, macOS 13.0, *)
public struct DiscordFeedbackButton: View {
    @State private var showSheet = false
    let webhookURL: String
    let appName: String

    public init(webhookURL: String = defaultDiscordWebhookURL, appName: String) {
        self.webhookURL = webhookURL
        self.appName = appName
    }

    public var body: some View {
        Button {
            showSheet.toggle()
        } label: {
            Label(FeedbackStrings.feedback, systemImage: "bubble.left.fill")
        }
        .help(FeedbackStrings.sendFeedback)
        .sheet(isPresented: $showSheet) {
            DiscordFeedbackSheet(webhookURL: webhookURL, appName: appName)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

/// A service class for sending feedback to Discord programmatically.
public final class DiscordFeedbackService: @unchecked Sendable {
    public static let shared = DiscordFeedbackService()

    private init() {}

    /// Sends feedback to a Discord webhook.
    /// - Parameters:
    ///   - message: The feedback message to send
    ///   - email: Optional email for reply
    ///   - appName: The name of the app sending feedback
    ///   - webhookURL: The Discord webhook URL (uses default if not provided)
    ///   - completion: Called with success/failure result
    public func sendFeedback(
        message: String,
        email: String? = nil,
        appName: String,
        webhookURL: String = defaultDiscordWebhookURL,
        completion: @escaping (Bool) -> Void
    ) {
        guard let url = URL(string: webhookURL) else {
            completion(false)
            return
        }

        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var content = "**[\(appName)] New Feedback:**\n\(trimmedMessage)"
        if let email = email, !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            content += "\n\n**Reply to:** \(email)"
        }

        let payload: [String: Any] = [
            "content": content
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }

    /// Sends a notification to Discord (useful for analytics/tracking).
    /// - Parameters:
    ///   - title: The notification title
    ///   - message: The notification message
    ///   - appName: The name of the app
    ///   - webhookURL: The Discord webhook URL (uses default if not provided)
    ///   - completion: Called with success/failure result
    public func sendNotification(
        title: String,
        message: String,
        appName: String,
        webhookURL: String = defaultDiscordWebhookURL,
        completion: ((Bool) -> Void)? = nil
    ) {
        guard let url = URL(string: webhookURL) else {
            completion?(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let content = "**[\(appName)] \(title)**\n\(message)"

        let payload: [String: Any] = [
            "content": content
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            completion?(false)
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 {
                    completion?(true)
                } else {
                    completion?(false)
                }
            }
        }.resume()
    }
}
