import SwiftUI

public struct AppInfo: Sendable {
    public let id: String
    public let nameKey: String
    public let descriptionKey: String
    public let iconName: String
    public let appStoreId: String
    public let tintColor: Color
    
    public init(id: String, nameKey: String, descriptionKey: String, iconName: String, appStoreId: String, tintColor: Color) {
        self.id = id
        self.nameKey = nameKey
        self.descriptionKey = descriptionKey
        self.iconName = iconName
        self.appStoreId = appStoreId
        self.tintColor = tintColor
    }
    
    public var localizedName: String {
        NSLocalizedString(nameKey, bundle: .module, comment: "")
    }
    
    public var localizedDescription: String {
        NSLocalizedString(descriptionKey, bundle: .module, comment: "")
    }
}

public struct CrossPromotionView: View {
    let app: AppInfo
    @State private var isPressed = false
    
    public init(app: AppInfo) {
        self.app = app
    }
    
    public var body: some View {
        Button(action: {
            if let url = URL(string: "https://apps.apple.com/app/id\(app.appStoreId)") {
                UIApplication.shared.open(url)
                Eventer.shared.tap("Cross Promotion - \(app.localizedName)")
            }
        }) {
            HStack(spacing: 16) {
                Image(app.iconName, bundle: .module)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(app.localizedName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(app.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

public struct CrossPromotionListView: View {
    let apps: [AppInfo]
    let currentAppId: String
    
    public init(apps: [AppInfo], currentAppId: String) {
        self.apps = apps
        self.currentAppId = currentAppId
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(NSLocalizedString("cross_promotion.discover_apps", bundle: .module, comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top)
                
                ForEach(apps.filter { $0.id != currentAppId }, id: \.id) { app in
                    CrossPromotionView(app: app)
                        .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

public struct CrossPromotionNavigationRow: View {
    let apps: [AppInfo]
    let currentAppId: String
    
    public init(apps: [AppInfo], currentAppId: String) {
        self.apps = apps
        self.currentAppId = currentAppId
    }
    
    private var otherAppsCount: Int {
        apps.filter { $0.id != currentAppId }.count
    }
    
    public var body: some View {
        NavigationLink {
            CrossPromotionListView(apps: apps, currentAppId: currentAppId)
                .navigationTitle(NSLocalizedString("cross_promotion.more_apps", bundle: .module, comment: ""))
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.title3)
                    .foregroundColor(Color("CourtGray"))
                    .frame(width: 30)
                
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("cross_promotion.more_apps", bundle: .module, comment: ""))
                        .foregroundColor(.primary)
                    if otherAppsCount > 0 {
                        Text(String(format: NSLocalizedString("cross_promotion.other_apps_count", bundle: .module, comment: "Number of other apps by Jeff"), otherAppsCount))
                            .font(.caption)
                            .foregroundColor(Color("CourtGray"))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color("CourtGray"))
            }
            .padding()
            .background(Color("NetWhite"))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CrossPromotionRow: View {
    let app: AppInfo
    
    var body: some View {
        HStack(spacing: 12) {
            Image(app.iconName, bundle: .module)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .cornerRadius(9)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(app.localizedName)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text(app.localizedDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = URL(string: "https://apps.apple.com/app/id\(app.appStoreId)") {
                UIApplication.shared.open(url)
                Eventer.shared.tap("Cross Promotion Row - \(app.localizedName)")
            }
        }
    }
}

public class JeffApps {
    public static let pickleballHub = AppInfo(
        id: "pickleball-hub",
        nameKey: "app.pickleball.name",
        descriptionKey: "app.pickleball.description",
        iconName: "PickleballHubIcon",
        appStoreId: "6670420347",
        tintColor: Color.green
    )
    
    public static let gratitudeJournal = AppInfo(
        id: "gratitude-journal",
        nameKey: "app.gratitude.name",
        descriptionKey: "app.gratitude.description",
        iconName: "GratitudeJournalIcon",
        appStoreId: "6450279060",
        tintColor: Color.orange
    )
    
    public static let habitTracker = AppInfo(
        id: "habit-tracker",
        nameKey: "app.habittracker.name",
        descriptionKey: "app.habittracker.description",
        iconName: "HabitTrackerIcon",
        appStoreId: "6477730845",
        tintColor: Color.blue
    )
    
    public static let flashcards = AppInfo(
        id: "flashcards",
        nameKey: "app.flashcards.name",
        descriptionKey: "app.flashcards.description",
        iconName: "FlashcardsIcon",
        appStoreId: "6502370881",
        tintColor: Color.purple
    )
    
    public static let promptManager = AppInfo(
        id: "prompt-manager",
        nameKey: "app.promptmanager.name",
        descriptionKey: "app.promptmanager.description",
        iconName: "PromptManagerIcon",
        appStoreId: "6738073662",
        tintColor: Color.indigo
    )
    
    public static let victoryLog = AppInfo(
        id: "victory-log",
        nameKey: "app.victorylog.name",
        descriptionKey: "app.victorylog.description",
        iconName: "VictoryLogIcon",
        appStoreId: "6449656780",
        tintColor: Color.yellow
    )
    
    public static let recipes = AppInfo(
        id: "recipes",
        nameKey: "app.recipes.name",
        descriptionKey: "app.recipes.description",
        iconName: "RecipesIcon",
        appStoreId: "6449123456",
        tintColor: Color.orange
    )
    
    public static let pizza = AppInfo(
        id: "pizza",
        nameKey: "app.pizza.name",
        descriptionKey: "app.pizza.description",
        iconName: "PizzaIcon",
        appStoreId: "6449789012",
        tintColor: Color.red
    )
    
    public static let pomodoroQuest = AppInfo(
        id: "pomodoro-quest",
        nameKey: "app.pomodoroquest.name",
        descriptionKey: "app.pomodoroquest.description",
        iconName: "PomodoroQuestIcon",
        appStoreId: "6449345678",
        tintColor: Color.purple
    )
    
    public static let all: [AppInfo] = [
        pickleballHub,
        gratitudeJournal,
        habitTracker,
        flashcards,
        promptManager,
        victoryLog,
        recipes,
        pizza,
        pomodoroQuest
    ]
}