//
//  ContentView.swift
//  DropDown
//
//  Created by Seungchul Ha on 2023/01/25.
//

import SwiftUI

struct ContentView: View {
    
	@State private var selection: String = "Easy"
	@Environment(\.colorScheme) var scheme
	
	var body: some View {
		VStack {
//			DropDown(
//				content: ["Easy", "Normal", "Hard", "Expert"],
//				selection: $selection,
//				activeTint: .primary.opacity(0.1),
//				inActiveTint: .white.opacity(0.05),
//				dynamic: true
//			)
//			.frame(width: 130)
			
			DropDown(
				content: ["Easy", "Normal", "Hard", "Expert"],
				selection: $selection,
				activeTint: .primary.opacity(0.1),
				inActiveTint: .white.opacity(0.05),
				dynamic: false
			)
			.frame(width: 130)
		}
//		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
		.environment(\.colorScheme, .dark)
		.background {
			if scheme == .dark {
				Color("BG")
					.ignoresSafeArea()
			}
		}
		.preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: Custom View Builder
struct DropDown: View {
	/// - Drop Down Properties
	var content: [String]
	@Binding var selection: String
	var activeTint: Color
	var inActiveTint: Color
	var dynamic: Bool = true
	/// - View Properties
	@State private var expandView: Bool = false
	var body: some View {
		GeometryReader {
			let size = $0.size
			
			VStack(alignment: .leading, spacing: 0) {
				if !dynamic {
					RowView(selection, size)
				}
				
				ForEach(content.filter {
					dynamic ? true : $0 != selection
				}, id: \.self) { title in
					RowView(title, size)
				}
			}
			.background {
				Rectangle()
					.fill(inActiveTint)
			}
			/// - Moving View Based on the Selection
			.offset(y: dynamic ? (CGFloat(content.firstIndex(of: selection) ?? 0) * -55) : 0)
		}
		.frame(height: 55)
		.overlay(alignment: .trailing) {
			Image(systemName: "chevron.up.chevron.down")
				.padding(.trailing, 10)
		}
		.mask(alignment: .top) {
			
			/// The logic is straightforward: if the dropdown is not tapped, we only display the active state;
			/// otherwise, we display the whole content. Since there is no space between items in our dropdown,
			/// multiplying the total number of items by 55 makes it simple to reach the maximum height.
			///
			/// The default mask alignment is center;
			/// updating it to start from the top
			
			/// Since the view inside is moved based on selection, we need to update the masking too;
			/// otherwise, it always stays at the top and will not show the views that moved to the top.
			Rectangle()
				.frame(height: expandView ? CGFloat(content.count) * 55 : 55)
				/// - Moving the mask based on the selection, so that every content will be visible
				/// - We only need the views to appear when the view is expanded
				/// - Visible Only When Content is Expanded
				.offset(y: dynamic && expandView ? (CGFloat(content.firstIndex(of: selection) ?? 0) * -55) : 0)
		}
		/// Add zIndex(1000) to ensure that it is at the top of all views.
		
		
	}
	
	/// - Row View
	@ViewBuilder
	func RowView(_ title: String, _ size: CGSize) -> some View {
		Text(title)
			.font(.title3)
			.fontWeight(.semibold)
			.padding(.horizontal)
			.frame(width: size.width, height: size.height, alignment: .leading)
			.background {
				if selection == title {
					Rectangle()
						.fill(activeTint)
						.transition(.identity)
				}
			}
			.contentShape(Rectangle())
			.onTapGesture {
				withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
					/// - If Expanded then Make Selection
					if expandView {
						expandView = false
						
						// Disabling Animation for Non-Dynamic Contents
						if dynamic {
							selection = title
						} else {
							
							// You can notice a glint in the animation,
							// that's the reason we introduced the delay
							DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
								selection = title
							}
						}
					} else {
						/// - Disabling Outside Taps
						if selection == title {
							expandView = true
						}
					}
				}
			}
	}
}
