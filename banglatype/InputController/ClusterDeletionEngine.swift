//
//  ClusterDeletionEngine.swift
//  BanglaType
//
//  Bengali grapheme cluster boundary (UAX #29). Option+Backspace deletes one cluster.
//

import Foundation

struct ClusterDeletionEngine {
    /// Returns the range of the cluster ending immediately before `index` (exclusive).
    static func previousClusterRange(in text: String, before index: String.Index) -> Range<String.Index>? {
        guard index > text.startIndex else { return nil }
        var end = text.unicodeScalars.index(before: index)
        var start = end
        while start != text.unicodeScalars.startIndex {
            let prev = text.unicodeScalars.index(before: start)
            if !isPartOfBengaliCluster(text.unicodeScalars[prev]) {
                break
            }
            start = prev
        }
        return start..<end
    }

    private static func isPartOfBengaliCluster(_ scalar: Unicode.Scalar) -> Bool {
        let v = scalar.value
        if v >= 0x0980 && v <= 0x09FF { return true }
        if v == 0x200C || v == 0x200D { return true }
        if v >= 0x1CD0 && v <= 0x1CFF { return true }
        return false
    }
}
