import SwiftUI

class GnomeShortcutSettings: ObservableObject {
    @Published var disabledShortcuts: Set<String>

    init() {
        disabledShortcuts = Set(
            UserDefaults.standard.stringArray(forKey: "gnomeDisabledShortcuts") ?? [])
    }

    func isEnabled(_ id: String) -> Bool {
        !disabledShortcuts.contains(id)
    }

    func setEnabled(_ id: String, _ enabled: Bool) {
        if enabled {
            disabledShortcuts.remove(id)
        } else {
            disabledShortcuts.insert(id)
        }
        UserDefaults.standard.set(Array(disabledShortcuts), forKey: "gnomeDisabledShortcuts")
    }

    func binding(for id: String) -> Binding<Bool> {
        Binding(
            get: { [weak self] in self?.isEnabled(id) ?? true },
            set: { [weak self] in self?.setEnabled(id, $0) }
        )
    }
}
