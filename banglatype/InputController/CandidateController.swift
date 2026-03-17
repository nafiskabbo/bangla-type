//
//  CandidateController.swift
//  BanglaType
//
//  Wraps IMKCandidates for suggestion list; lazy creation, horizontal/vertical.
//

import AppKit
import InputMethodKit

final class CandidateController {
    private var candidates: IMKCandidates?
    private let orientation: NSUserInterfaceLayoutOrientation

    var isVisible: Bool { candidates?.isVisible() ?? false }

    init(orientation: NSUserInterfaceLayoutOrientation = .horizontal) {
        self.orientation = orientation
    }

    private func ensureCandidates() -> IMKCandidates {
        if let c = candidates { return c }
        let c = IMKCandidates(server: server, panelType: kIMKSingleColumnScrollingCandidatePanel)
        c?.setSelectionKeys([1, 2, 3, 4, 5].map { NSNumber(value: $0) })
        candidates = c
        return c!
    }

    func show(suggestions: [String], at location: NSPoint) {
        let panel = ensureCandidates()
        panel.setCandidateData(suggestions as [Any])
        panel.setPanelType(kIMKSingleColumnScrollingCandidatePanel)
        panel.show(kIMKLocateCandidatesAboveHint)
    }

    func hide() {
        candidates?.hide()
    }

    func candidateSelected(at index: Int, from suggestions: [String]) -> String? {
        guard index >= 0, index < suggestions.count else { return nil }
        return suggestions[index]
    }
}
