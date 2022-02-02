//
//  HistoryTableViewController.swift
//  CodingChallenge
//
//  Created by José Jacobo Contreras Trejo on 31/01/22.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    
    let historyViewModel = HistoryViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        loadData()
        setCustomFooterView(tableView: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        manageHistoryButtons()
    }
    
    func setCustomFooterView(tableView: UITableView){
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
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
            self?.tableView.tableFooterView?.isHidden = true
            self?.navigationItem.rightBarButtonItem = nil
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
        self.navigationItem.rightBarButtonItem = historyViewModel.numberOfRows() > 0 ? self.editButtonItem : nil
        tableView.tableFooterView?.isHidden = historyViewModel.numberOfRows() > 0 ? false : true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "unwindSegue" {
            if let indexPath = sender as? IndexPath {
                let homeVC = segue.destination as! HomeViewController
                let item = historyViewModel.item(indexPath: indexPath)
                homeVC.searchController.searchBar.text = item.text
                
                if let text = item.text {
                    historyViewModel.saveInHistory(text: text, date: Date())
                    homeVC.loadData(text: text)
                }
                
                //_ = segue.destination as! HomeViewController
            }
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return historyViewModel.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
   
  
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }*/


    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
