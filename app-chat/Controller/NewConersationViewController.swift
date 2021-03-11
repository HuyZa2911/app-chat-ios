//
//  newConersationViewController.swift
//  app-chat
//
//  Created by Bui  Huy on 2/18/21.
//

import UIKit
import JGProgressHUD
class NewConersationViewController: UIViewController {

    public var completion: (([String:String]) -> (Void))?
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var users = [[String:String]]()
    private var results = [[String:String]]()

    
    private var hasFetched = false
    
    private let searchBar : UISearchBar = {
        let seachBar = UISearchBar()
        seachBar.placeholder = "Tìm kiếm"
        return seachBar
    }()
    private let tableView : UITableView = {
       let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    private let noResultLable : UILabel = {
        let lable = UILabel()
        lable.isHidden = true
        lable.text = "Không có kết quả"
        lable.textAlignment = .center
        lable.textColor = .brown
        lable.font = .systemFont(ofSize: 21, weight: .medium)
        return lable
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultLable)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hủy",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLable.frame = CGRect(x: view.width/4,
                                     y: (view.heigth-200)/2,
                                     width: view.width/2,
                                     height: 200)
    }
    
    @objc private func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }

}
extension NewConersationViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUserdata  = results[indexPath.row]
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserdata)
        })
        
        
    }
}
extension NewConersationViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: " ").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        results.removeAll()
        spinner.show(in: view)
        self.seachUser(query: text)
    }
    func seachUser(query : String){
//        ktra kqua trả về
        if hasFetched{
            filtterUser(with: query)
        }else{
            DatabaseManager.shared.getAllUser(completion: {[weak self]result in
                switch result{
                case .success(let userColection):
                    self?.hasFetched = true
                    self?.users = userColection
                    self?.filtterUser(with: query)
                case .failure(let error):
                    print("failed: \(error)")
                }
            })
        }
    }
    func filtterUser(with term: String){
//         cập nhật lại UI khi tim kiếm thấy user
        guard hasFetched else {
            return
        }
        self.spinner.dismiss()
        var results: [[String : String]] = self.users.filter({
            guard  let name = $0["name"]?.lowercased()else{
                return false
            }
            return name.hasPrefix(term.lowercased())
        })
        self.results = results
         updateUI()
    }
    func updateUI() {
        if results.isEmpty{
            self.noResultLable.isHidden = false
            self.tableView.isHidden = true
        }else{
            self.noResultLable.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
