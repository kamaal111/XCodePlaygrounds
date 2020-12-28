import Foundation

func showAppIntroduction() {
    print("Introduction")
}

extension UserDefaults {
    public enum Keys {
        static let hasSeenAppIntroduction = "has_seen_app_introduction"
    }

    var hasSeenAppIndruction: Bool {
        set {
            set(newValue, forKey: Keys.hasSeenAppIntroduction)
        }
        get {
            bool(forKey: Keys.hasSeenAppIntroduction)
        }
    }
}

if !UserDefaults.standard.hasSeenAppIndruction {
    showAppIntroduction()
    UserDefaults.standard.hasSeenAppIndruction = true
}

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value

    init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: Value {
        get {
            let valueToReturn = UserDefaults.standard.object(forKey: key) as? Value
            return valueToReturn ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    var projectedValue: Self {
        get {
            return self
        }
    }

    func removeValue() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

struct UserDefaultValues {
    @UserDefault(key: "hasSeenAppIntroduction", defaultValue: false)
    static var hasSeenAppIntroduction: Bool
}

UserDefaultValues.hasSeenAppIntroduction = false
print(UserDefaultValues.hasSeenAppIntroduction)

UserDefaultValues.hasSeenAppIntroduction = true
print(UserDefaultValues.hasSeenAppIntroduction)

UserDefaultValues.$hasSeenAppIntroduction.removeValue()
