//
//  LayoutManager.swift
//  BanglaType
//
//  Singleton: loads layouts, persists active index, provides activeEngine.
//

import Foundation

struct LayoutDescriptor {
    let id: String
    let nameEn: String
    let nameBn: String
}

final class LayoutManager {
    static let shared = LayoutManager()
    private var layouts: [LayoutDescriptor] = []
    private var engines: [LayoutEngineProtocol] = []
    private var fixedLayouts: [FixedLayout?] = []
    private var activeIndex: Int = 0

    var activeLayoutIndex: Int {
        get { activeIndex }
        set {
            guard newValue >= 0, newValue < engines.count else { return }
            activeIndex = newValue
            UserDefaults.standard.set(activeIndex, forKey: "BanglaTypeActiveLayoutIndex")
            NotificationCenter.default.post(name: .banglaTypeLayoutChanged, object: nil)
        }
    }

    var activeEngine: LayoutEngineProtocol {
        guard activeIndex >= 0, activeIndex < engines.count else { return PassthroughLayoutEngine() }
        return engines[activeIndex]
    }

    var layoutCount: Int { layouts.count }
    func layoutDescriptor(at index: Int) -> LayoutDescriptor? {
        guard index >= 0, index < layouts.count else { return nil }
        return layouts[index]
    }

    func currentKeyboardViewModel() -> KeyboardLayoutViewModel {
        if activeIndex > 0, activeIndex - 1 < fixedLayouts.count, let layout = fixedLayouts[activeIndex - 1] {
            return KeyboardLayoutViewModel.from(layout: layout)
        }
        return KeyboardLayoutViewModel.qwertyPlaceholder
    }

    private static let allLayoutDescriptors: [LayoutDescriptor] = [
        LayoutDescriptor(id: "avro_phonetic", nameEn: "Avro Phonetic", nameBn: "অভ্র ফোনেটিক"),
        LayoutDescriptor(id: "probhat", nameEn: "Probhat", nameBn: "প্রভাত"),
        LayoutDescriptor(id: "munir_optima", nameEn: "Munir Optima", nameBn: "মুনীর অপ্টিমা"),
        LayoutDescriptor(id: "avro_easy", nameEn: "Avro Easy", nameBn: "অভ্র ইজি"),
        LayoutDescriptor(id: "bornona", nameEn: "Bornona", nameBn: "বর্ণনা"),
        LayoutDescriptor(id: "national_jatiya", nameEn: "National (Jatiya)", nameBn: "জাতীয়"),
        LayoutDescriptor(id: "akkhor", nameEn: "Akkhor", nameBn: "অক্ষর"),
    ]

    private init() {
        layouts = Self.allLayoutDescriptors
        let phonetic = PhoneticEngine()
        var eng: [LayoutEngineProtocol] = [phonetic]
        let bundleNames = ["probhat", "munir_optima", "avro_easy", "bornona", "national_jatiya", "akkhor"]
        for name in bundleNames {
            if let url = Bundle.main.url(forResource: name, withExtension: "avrolayout"),
               let data = try? Data(contentsOf: url),
               let fixed = try? AvroLayoutParser.parse(data: data) {
                eng.append(FixedLayoutEngine(layout: fixed))
                fixedLayouts.append(fixed)
            } else {
                eng.append(PassthroughLayoutEngine())
                fixedLayouts.append(nil)
            }
        }
        engines = eng
        activeIndex = UserDefaults.standard.integer(forKey: "BanglaTypeActiveLayoutIndex")
        if activeIndex >= engines.count { activeIndex = 0 }
    }

    func switchToNextLayout() {
        guard !layouts.isEmpty, !engines.isEmpty else { return }
        activeIndex = (activeIndex + 1) % engines.count
        UserDefaults.standard.set(activeIndex, forKey: "BanglaTypeActiveLayoutIndex")
        NotificationCenter.default.post(name: .banglaTypeLayoutChanged, object: nil)
    }

    func switchToLayout(index: Int) {
        guard index >= 0, index < engines.count else { return }
        activeIndex = index
        UserDefaults.standard.set(activeIndex, forKey: "BanglaTypeActiveLayoutIndex")
        NotificationCenter.default.post(name: .banglaTypeLayoutChanged, object: nil)
    }
}

extension Notification.Name {
    static let banglaTypeLayoutChanged = Notification.Name("BanglaTypeLayoutChanged")
}
