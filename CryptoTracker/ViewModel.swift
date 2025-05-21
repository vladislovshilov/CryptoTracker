//
//  ViewModel.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import Foundation

final class ViewModel: ViewModeling {
    
    @Published var counter: String = "empty"
    
    private var task: Task<Void, Never>?
    
    func onAppear() {
        task = Task {
//            await fetchAllArticles()
            await fetchAllPages()
        }
    }
    
    func onDisappear() {
        task?.cancel()
    }
    
    func fetchAllPages() async {
        let urls = ["page1", "page2", "page3"]

        await withTaskGroup(of: String.self) { group in
            for url in urls {
                group.addTask {
                    return url
                }
            }

            for await page in group {
                print("Received: \(page)")
                await MainActor.run {
                    counter = page
                }
            }
        }
    }
    
    private func fetchAllArticles() async {
        let sources = ["cnn.com", "bbc.com", "reuters.com"]

        await withTaskGroup(of: String.self) { group in
            counter = "loading"
//            var i: UInt32 = 1
//            for source in sources {
//                group.addTask {
//                    // Simulate fetching article from a source
//                    sleep(2)
////                    i += 20
//                    print(i)
//                    return "Article from \(source)"
//                }
//            }
            
            group.addTask {
                sleep(1)
                return "1"
            }
            
            group.addTask {
                sleep(3)
                return "3"
            }
            
            group.addTask {
                sleep(5)
                return "5"
            }
            

            for await article in group {
                print(article)
                counter = article
            }
            
            
        }
    }
}
