//
//  MoviePoster.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 07/04/22.
//

import SwiftUI

struct MoviePoster: View {
    let path: String
    var body: some View {
//        AsyncImage(
//            url: URL(string: "https://image.tmdb.org/t/p/w500/\(path)"),
//            content: { image in
//                image.resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 120, height: 160)
//                    .cornerRadius(8)
//            },
//            placeholder: {
//                Spacer()
//                
//                ProgressView()
//                    .frame(width: 120, height: 160)
//                
//                Spacer()
//            }
//        )
        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500/\(path)")) { phase in
            if let image = phase.image {
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 160)
                    .cornerRadius(8)
            } else if phase.error != nil {
                Spacer()
                
                Label("Failed to Load", systemImage: "exclamationmark.circle")
                    .labelStyle(.iconOnly)
                    .foregroundColor(.red)
                    .frame(width: 120, height: 160)
                
                Spacer()
            } else {
                Spacer()
                
                ProgressView()
                    .frame(width: 120, height: 160)
                
                Spacer()
            }
        }
    }
}

struct MoviePoster_Previews: PreviewProvider {
    static var previews: some View {
        MoviePoster(path: "")
    }
}
