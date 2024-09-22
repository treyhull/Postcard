//
//  PostcardThumbnailView.swift
//  Postcard
//
//  Created by Anna Hull on 8/2/24.
//

import SwiftUI

struct PostcardThumbnailView: View {
    let postcard: Postcard
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: postcard.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 120, height: 180)
            .cornerRadius(10)
            
            Text(postcard.location)
                .font(.caption)
                .lineLimit(1)
        }
    }
}
