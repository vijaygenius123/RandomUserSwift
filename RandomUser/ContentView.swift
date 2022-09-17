//
//  ContentView.swift
//  RandomUser
//
//  Created by Vijayaraghavan Sundararaman on 17/09/2022.
//

import SwiftUI


struct Name: Codable {
    let title: String
    let first: String
    let last: String
}

struct Picture: Codable {
    let thumbnail: String
    let medium: String
    let large: String
}
struct Login: Codable {
    let uuid: String
    let username: String
}
struct User: Codable {
    let gender: String
    let name: Name
    let login: Login
    let picture: Picture
}

struct Info: Codable {
    let seed: String
    let results: Int
    let page: Int
}

struct Response: Codable {
    let results: [User]
    let info: Info
}


struct URLImage: View {
    let urlString: String
    @State var data: Data?
    
    var body: some View {
        if let data = data, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode:.fill)
                .frame(width: 130, height: 70)
        } else {
            Image(systemName: "video")
                .resizable()
                .aspectRatio(contentMode:.fill)
                .frame(width: 130, height: 70)
                .background(Color.gray)
                .onAppear{
                    fetchData()
                }
        }
    }
    
    private func fetchData(){
        guard let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) {
                data, _, _ in
            self.data = data
        }
        task.resume()
    }
   
}

class ViewModel: ObservableObject {
    @Published var response: Response = Response(results: [], info: Info(seed: "", results: 0, page: 0))
    func fetch(){
        guard let url = URL(string: "https://randomuser.me/api?results=10") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let users = try JSONDecoder().decode(Response.self, from: data)
                print(users)
                DispatchQueue.main.async {
                    self?.response = users
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    var body: some View {
        NavigationView{
            List {
                ForEach(viewModel.response.results, id: \.login.uuid){ user in
                    HStack {
                        URLImage(urlString: user.picture.medium, data: nil)
                        Text(user.name.first)
                    }
                    .padding(30)
                }
            }
        }.navigationTitle("Random People")
            .onAppear{
                viewModel.fetch()
                
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
