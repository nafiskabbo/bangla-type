//
//  ClusterDeletionTests.swift
//  BanglaType
//

import Testing
@testable import BanglaType

struct ClusterDeletionTests {
    @Test func singleCluster() {
        let text = "ক্ষ্ম"
        let end = text.endIndex
        let range = ClusterDeletionEngine.previousClusterRange(in: text, before: end)
        #expect(range != nil)
        #expect(range?.lowerBound == text.startIndex)
        #expect(range?.upperBound == end)
    }

    @Test func consonantHasanta() {
        let text = "ক্"
        let end = text.endIndex
        let range = ClusterDeletionEngine.previousClusterRange(in: text, before: end)
        #expect(range != nil)
        #expect(range?.lowerBound == text.startIndex)
    }

    @Test func emptyReturnsNil() {
        let range = ClusterDeletionEngine.previousClusterRange(in: "", before: "".startIndex)
        #expect(range == nil)
    }

    @Test func midStringCluster() {
        let text = "কর্ম"
        let idx = text.index(text.startIndex, offsetBy: 2)
        let range = ClusterDeletionEngine.previousClusterRange(in: text, before: idx)
        #expect(range != nil)
        #expect(range?.lowerBound == text.startIndex)
    }

    @Test func singleCharCluster() {
        let text = "আ"
        let range = ClusterDeletionEngine.previousClusterRange(in: text, before: text.endIndex)
        #expect(range != nil)
        #expect(range?.lowerBound == text.startIndex)
        #expect(range?.upperBound == text.endIndex)
    }

    @Test func viramaCluster() {
        let text = "ক্"
        let end = text.endIndex
        let range = ClusterDeletionEngine.previousClusterRange(in: text, before: end)
        #expect(range != nil)
        #expect(range?.lowerBound == text.startIndex)
    }
}
