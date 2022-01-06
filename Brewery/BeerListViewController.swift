//
//  BeerListViewController.swift
//  Brewery
//
//  Created by 이니텍 on 2022/01/05.
//

import Foundation
import UIKit

class BeerListViewContoller: UITableViewController {
    var beerList = [Beer]()
    var currentPage = 1
    var dataTasks = [URLSessionTask]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //UINavigationBar 설정
        title = "Brewery🍺"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //UITableView 설정
        tableView.register(BeerListCell.self, forCellReuseIdentifier: "BeerListCell")
        tableView.rowHeight = 150
        tableView.prefetchDataSource = self
        
        fetchBeer(of: currentPage)
    }
}

//UITableView DataSource, Delegate
extension BeerListViewContoller: UITableViewDataSourcePrefetching {
    //셀 개수
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beerList.count
    }
    
    //셀 내용
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BeerListCell", for: indexPath) as? BeerListCell else { return UITableViewCell()}
        let beer = beerList[indexPath.row]
        cell.configure(with: beer)
        return cell
    }
    
    //선택된 셀
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBeer = beerList[indexPath.row]
        let detailViewController = BeerDetailViewController()
        
        detailViewController.beer = selectedBeer
        self.show(detailViewController, sender: nil)
    }
    
    //앞으로 보여질 셀
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard currentPage != 1 else { return }

        //페이징(한 페이지당 25개)
        //다음 페이지 리스트 가져오기
        indexPaths.forEach {
            if ($0.row + 1)/25 + 1 == currentPage {
                self.fetchBeer(of: currentPage)
            }
        }
    }
}

//Data Fetching
private extension BeerListViewContoller {
    func fetchBeer(of page: Int) {
        guard let url = URL(string: "https://api.punkapi.com/v2/beers?page=\(page)"),
              dataTasks.firstIndex(where: { $0.originalRequest?.url == url }) == nil else { return } //dataTaks배열 안에 요청된 url이 없어야함.
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let dataTask = URLSession.shared.dataTask(with: request) {[weak self] data, response, error in
            guard error == nil,
                  let self = self,
                  let response = response as? HTTPURLResponse,
                  let data = data,
                  let beers = try? JSONDecoder().decode([Beer].self, from: data) else {
                    print("Error: URLSession data task \(error?.localizedDescription ?? "")")
                    return
                  }
            switch response.statusCode {
            case (200...299): //성공
                self.beerList += beers
                self.currentPage += 1
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case (400...499): //클라이언트 에러
                print(
                    """
                    ERROR: Client ERROR \(response.statusCode)
                    Response: \(response)
                    """
                )
            case (500...599): //서버 에러
                print(
                    """
                    ERROR: Server ERROR \(response.statusCode)
                    Response: \(response)
                    """
                )
            default:
                print(
                    """
                    ERROR: \(response.statusCode)
                    Response: \(response)
                    """
                )
            }
        }
        dataTask.resume()
    }
}
