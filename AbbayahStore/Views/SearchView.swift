import SwiftUI

// Search is just the unified browse screen with the search bar + chips + sort.
struct SearchView: View {
    var body: some View {
        ProductBrowseView(
            initialCategory: "All",
            initialSearch: "",
            showSearchBar: true,
            showCategoryChips: true
        )
    }
}
