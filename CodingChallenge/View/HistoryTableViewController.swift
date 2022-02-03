//
//  HistoryTableViewController.swift
//  CodingChallenge
//
//  Created by José Jacobo Contreras Trejo on 31/01/22.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    
    private let historyViewModel = HistoryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        setCustomFooterView(tableView: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        manageHistoryButtons()
    }
    
    func setCustomFooterView(tableView: UITableView){
        //creating view to use in tableviewfooter
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        //creating and customizing button to clean history
        let cleanHistoryButton = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        cleanHistoryButton.setTitle("Clean history", for: .normal)
        cleanHistoryButton.setTitleColor(.red, for: .normal)
        cleanHistoryButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        footerView.addSubview(cleanHistoryButton)
        tableView.tableFooterView = footerView
    }
    
    func showDeleteAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Clean", style: .destructive, handler: { [weak self] action in
            
            self?.historyViewModel.deleteAllHistory()
            self?.tableView.reloadData()
            //removing unnecesary buttons from view
            self?.manageHistoryButtons()
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func buttonAction(_ sender: UIButton!) {
        showDeleteAlert(title: "Are you sure?", message: "This action cannot be undone")
    }
    
    func loadData(){
        historyViewModel.loadData { error in
            self.tableView.reloadData()
        }
    }
    
    func manageHistoryButtons(){
        //show buttons only if exist more than 0 elements en history
        self.navigationItem.rightBarButtonItem = historyViewModel.numberOfRows() > 0 ? self.editButtonItem : nil
        tableView.tableFooterView?.isHidden = historyViewModel.numberOfRows() > 0 ? false : true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "unwindSegue" {
            if let indexPath = sender as? IndexPath {
                let homeVC = segue.destination as! HomeViewController
                let item = historyViewModel.item(indexPath: indexPath)
                
                //setting data to find in home VC
                homeVC.searchController.searchBar.text = item.text
                
                if let text = item.text {
                    historyViewModel.saveInHistory(text: text, date: Date())
                    homeVC.loadData(text: text)
                }
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return historyViewModel.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyViewModel.numberOfRows()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        
        // Configure the cell...
        let searched = historyViewModel.item(indexPath: indexPath)
        cell.textLabel?.text = searched.text
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //go to root view
        self.performSegue(withIdentifier: "unwindSegue", sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            historyViewModel.deleteFromHistory(index: indexPath.row)
            loadData()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            manageHistoryButtons()
        }
    }
}
