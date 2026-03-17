//
//  ComposingBuffer.swift
//  BanglaType
//
//  Maintains uncommitted text; fires delegate on every change for setMarkedText.
//

import Foundation

protocol ComposingBufferDelegate: AnyObject {
    func onBufferChanged(text: String)
}

final class ComposingBuffer {
    weak var delegate: ComposingBufferDelegate?
    private var buffer: String = ""

    var text: String { buffer }

    func append(scalar: Unicode.Scalar) {
        buffer.unicodeScalars.append(scalar)
        delegate?.onBufferChanged(text: buffer)
    }

    func append(string: String) {
        buffer.append(string)
        delegate?.onBufferChanged(text: buffer)
    }

    func deleteLastScalar() {
        guard let idx = buffer.unicodeScalars.indices.last else { return }
        buffer.unicodeScalars.remove(at: idx)
        delegate?.onBufferChanged(text: buffer)
    }

    func deleteLastCluster() {
        guard !buffer.isEmpty else { return }
        let idx = buffer.endIndex
        var i = buffer.unicodeScalars.index(before: idx)
        while i != buffer.unicodeScalars.startIndex {
            let prev = buffer.unicodeScalars.index(before: i)
            if !isPartOfBengaliCluster(buffer.unicodeScalars[prev]) {
                break
            }
            i = prev
        }
        buffer.removeSubrange(i..<idx)
        delegate?.onBufferChanged(text: buffer)
    }

    func deleteAll() {
        buffer = ""
        delegate?.onBufferChanged(text: buffer)
    }

    func commit() -> String {
        let result = buffer
        buffer = ""
        delegate?.onBufferChanged(text: buffer)
        return result
    }

    private func isPartOfBengaliCluster(_ scalar: Unicode.Scalar) -> Bool {
        let v = scalar.value
        return (v >= 0x0980 && v <= 0x09FF) ||
            (v == 0x200C || v == 0x200D) ||
            (v >= 0x1CD0 && v <= 0x1CFF)
    }
}
