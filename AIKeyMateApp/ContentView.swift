//
//  ContentView.swift
//  AIKeyMateApp
//
//  Created by yihandogs on 2023/4/9.
//

import SwiftUI

struct ContentView: View {
    @State private var text = ""
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            TextField("Enter text", text: $text)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
