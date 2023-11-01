//
//  BookmarkDataStore.swift
//  OBAKitCore
// 
//  Copyright © 2023 Open Transit Software Foundation.
//  This source code is licensed under the Apache 2.0 license found in the
//  LICENSE file in the root directory of this source tree.
//

public protocol BookmarkDataStore {
    // MARK: - Bookmark Groups
    /// Retrieves a list of `BookmarkGroup` objects.
    var bookmarkGroups: [BookmarkGroup] { get }

    /// Adds the `BookmarkGroup` to the `UserDataStore`, or updates it if it's new.
    /// - Parameter bookmarkGroup: The `BookmarkGroup` to add.
    func upsert(bookmarkGroup: BookmarkGroup)

    /// Removes the specified `BookmarkGroup` from the `UserDataStore`.
    /// - Parameter group: The `BookmarkGroup` to remove.
    ///
    /// - Note: `Bookmark`s should not be deleted when their `BookmarkGroup` is deleted.
    func deleteGroup(_ group: BookmarkGroup)

    /// Removes the `BookmarkGroup` that matches `id` from the `UserDataStore`.
    /// - Parameter id: The `UUID` of the `BookmarkGroup` to remove.
    ///
    /// - Note: `Bookmark`s should not be deleted when their `BookmarkGroup` is deleted.
    func deleteGroup(id: UUID)

    /// Finds the `BookmarkGroup` with a matching `id` if it exists.
    /// - Parameter id: The `UUID` for which to search in existing bookmark groups.
    func findGroup(id: UUID?) -> BookmarkGroup?

    /// Updates, inserts, and deletes existing bookmark groups with the supplied list.
    /// - Parameter newGroups: The new, canonical list of `BookmarkGroup`s.
    func replaceBookmarkGroups(with newGroups: [BookmarkGroup])

    // MARK: - Bookmarks

    /// Retrieves a list of `Bookmark` objects.
    var bookmarks: [Bookmark] { get }

    /// Retrieves `Bookmark`s where `isFavorite == true`.
    var favoritedBookmarks: [Bookmark] { get }

    /// Returns a list of `Bookmark`s in the specified `BookmarkGroup`
    /// - Parameter bookmarkGroup: The `BookmarkGroup` for which `Bookmark`s should be returned.
    func bookmarksInGroup(_ bookmarkGroup: BookmarkGroup?) -> [Bookmark]

    /// Adds the specified `Bookmark` to the `UserDataStore`, optionally adding it to a `BookmarkGroup`.
    /// - Parameters:
    ///   - bookmark: The `Bookmark` to add to the store.
    ///   - group: Optional. The `BookmarkGroup` to which this `Bookmark` will belong.
    func add(_ bookmark: Bookmark, to group: BookmarkGroup?)

    /// Adds the specified `Bookmark` to the `UserDataStore`, optionally adding it to a `BookmarkGroup` at `index`.
    /// - Parameters:
    ///   - bookmark: The `Bookmark` to add to the store.
    ///   - group: Optional. The `BookmarkGroup` to which this `Bookmark` will belong.
    ///   - index: The sort order or index of the bookmark in its group. Pass in `Int.max` to append to the end.
    func add(_ bookmark: Bookmark, to group: BookmarkGroup?, index: Int)

    /// Deletes the specified `Bookmark` from the `UserDataStore`.
    /// - Parameter bookmark: The `Bookmark` to delete.
    func delete(bookmark: Bookmark)

    /// Finds the `Bookmark` with a matching `id` if it exists.
    /// - Parameter id: The `UUID` for which to search in existing bookmarks.
    func findBookmark(id: UUID) -> Bookmark?

    /// Finds the `Bookmark` with a matching `stopID` if it exists.
    /// - Parameter stopID: The Stop ID for which to search in existing bookmarks.
    func findBookmark(stopID: StopID) -> Bookmark?

    /// Finds `Bookmark`s that match the provided search text.
    /// - Parameter searchText: The text to search `Bookmark`s for.
    func findBookmarks(matching searchText: String) -> [Bookmark]

    /// Finds `Bookmark`s in the specified `Region`.
    /// - Parameter region: The region of the `Bookmark`s.
    func findBookmarks(in region: Region?) -> [Bookmark]

    /// Examines the list of bookmarks to see if a `Bookmark` exists whose contents match `bookmark`
    /// by using the method `Bookmark.isEqualish()` to determine if a match exists.
    /// - Parameter bookmark: The bookmark that will compared to the current list of bookmarks.
    func checkForDuplicates(bookmark: Bookmark) -> Bool
}
