//
//  RemindersView.swift
//  Citadelle
//

import SwiftUI
import UIKit

/// Daily reminders, and how to tie a dua to a moment with Shortcuts.
struct RemindersView: View {
    let library: Library

    @Environment(ReminderSettingsStore.self) private var store
    @Environment(\.openURL) private var openURL
    @State private var permissionDenied = false

    var body: some View {
        Form {
            Section {
                ForEach(ReminderKind.allCases) { kind in
                    reminderRow(kind)
                }
            } header: {
                Text("Rappels quotidiens")
            } footer: {
                Text("La notification montre l'invocation à dire. Touchez-la pour ouvrir la page.")
            }

            if permissionDenied {
                Section {
                    Label("Les notifications sont désactivées pour Citadelle. Activez-les dans Réglages pour recevoir les rappels.",
                          systemImage: "bell.slash")
                        .font(.footnote)
                    Button("Ouvrir les Réglages") {
                        if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                    }
                }
            }

            Section {
                ShortcutGuideRow(
                    icon: "alarm",
                    title: "Quand mon réveil sonne",
                    steps: [
                        "Raccourcis › Automatisation › + › Réveil",
                        "Choisir « Est arrêté », puis « Exécuter immédiatement »",
                        "Optionnel : ajouter « Attendre » (5 ou 10 min)",
                        "Ajouter l'action Citadelle « Rappeler une invocation » › Au réveil",
                    ]
                )
                ShortcutGuideRow(
                    icon: "house",
                    title: "Quand je quitte ou rejoins mon domicile",
                    steps: [
                        "Raccourcis › Automatisation › + › Quitter (ou Arriver)",
                        "Choisir Domicile, puis « Exécuter immédiatement »",
                        "Ajouter « Rappeler une invocation » › En sortant de chez soi (ou En rentrant chez soi)",
                    ]
                )
                ShortcutGuideRow(
                    icon: "car",
                    title: "Quand je monte en voiture",
                    steps: [
                        "Raccourcis › Automatisation › + › CarPlay (ou Bluetooth, avec la voiture)",
                        "Choisir « Se connecte », puis « Exécuter immédiatement »",
                        "Ajouter « Rappeler une invocation » › En montant dans un véhicule",
                    ]
                )
                ShortcutGuideRow(
                    icon: "bed.double",
                    title: "Quand le mode Sommeil s'active",
                    steps: [
                        "Raccourcis › Automatisation › + › Sommeil (ou Concentration › Sommeil)",
                        "Choisir « Le coucher commence », puis « Exécuter immédiatement »",
                        "Ajouter « Rappeler une invocation » › Avant de dormir",
                    ]
                )
                Button {
                    if let url = URL(string: "shortcuts://") { openURL(url) }
                } label: {
                    Label("Ouvrir Raccourcis", systemImage: "arrow.up.forward.app")
                }
            } header: {
                Text("Lier une invocation à un moment")
            } footer: {
                Text("L'app Raccourcis de l'iPhone peut réagir à votre réveil, à vos trajets ou à votre voiture, et vous rappeler l'invocation juste à ce moment-là.")
            }
        }
        .navigationTitle("Rappels")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func reminderRow(_ kind: ReminderKind) -> some View {
        let setting = store.setting(for: kind)
        let title = library.chapter(withID: kind.chapterID)?.title.text(for: AppLanguage.content) ?? ""
        return VStack(alignment: .leading) {
            Toggle(title, isOn: Binding(
                get: { setting.isEnabled },
                set: { isOn in
                    var updated = setting
                    updated.isEnabled = isOn
                    save(kind, updated, askPermission: isOn)
                }
            ))
            .accessibilityIdentifier("reminder-toggle-\(kind.rawValue)")

            if setting.isEnabled {
                DatePicker("Heure", selection: Binding(
                    get: { Calendar.current.date(from: DateComponents(hour: setting.hour, minute: setting.minute)) ?? .now },
                    set: { date in
                        var updated = setting
                        let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
                        updated.hour = parts.hour ?? setting.hour
                        updated.minute = parts.minute ?? setting.minute
                        save(kind, updated, askPermission: false)
                    }
                ), displayedComponents: .hourAndMinute)
            }
        }
    }

    private func save(_ kind: ReminderKind, _ setting: ReminderSetting, askPermission: Bool) {
        store.update(kind, to: setting)
        let plan = ReminderPlanner.plan(settings: store.settings, library: library)
        Task {
            if askPermission {
                permissionDenied = !(await NotificationService.requestPermission())
            }
            await NotificationService.apply(plan)
        }
    }
}

/// One Shortcuts automation, explained in a few steps.
private struct ShortcutGuideRow: View {
    let icon: String
    let title: String
    let steps: [String]

    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    Text("\(index + 1). \(step)")
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, 4)
        } label: {
            Label(title, systemImage: icon)
        }
    }
}
