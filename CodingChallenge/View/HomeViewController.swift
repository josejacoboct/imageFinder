//
//  ViewController.swift
//  CodingChallenge
//
//  Created by José Jacobo Contreras Trejo on 29/01/22.
//

import UIKit

enum ScrollableViewEndless: Int {
    case firstOption
    case secondOption
}

class HomeViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    //var
    let searchController = UISearchController()
    private let photosViewModel = PhotosViewModel()
    private let historyViewModel = HistoryViewModel()
    private var headerCollectionView = UICollectionReusableView()
    private let headerLabel = UILabel()
    private var numberOfElements = 0
    
    // Edit value of this var to check my two options for scroll view endless
    private let scrollViewOption = ScrollableViewEndless.firstOption
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search some text"
        customPhotosCollectionView()
        customSearchBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //cancel searching if user leave current view
        cancelSearching()
    }
    
    func loadData(text: String){
        
        //DispatchQueue.main.async { [weak self] in
        headerLabel.isHidden = true
        showChargerView(viewToCustom: self.view)
        //}
        
        photosViewModel.loadData(text: text) { [weak self] error in
            
            //show alert if have one error
            if error != nil && (error as NSError?)?.code != NSURLErrorCancelled {
                DispatchQueue.main.async {
                    self?.stopChargerView(viewToCustom: (self?.view)!)
                    self?.showErrorAlert(message: error?.localizedDescription ?? "Try again in few minutes please.", viewTarget: self!)
                    return
                }
            }
            
            //reloading data to show finded images
            DispatchQueue.main.async { [weak self] in
                self?.stopChargerView(viewToCustom: (self?.view)!)
                self?.goToTop()
                self?.photosCollectionView.reloadData()
                self?.headerLabel.isHidden = false
                self?.numberOfElements = self?.photosViewModel.numberOfRows() ?? 0
            }
        }
    }
    
    func cancelSearching(){
        photosViewModel.cancelLoadData()
        stopChargerView(viewToCustom: self.view)
    }
    
    func showErrorAlert(message: String, viewTarget: UIViewController){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        DispatchQueue.main.async {
            viewTarget.present(alert, animated: true, completion: nil)
        }
    }
    
    func showChargerView(viewToCustom: UIView) {
        
        let chargerView = UIView()
        chargerView.tag = 100
        chargerView.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.tintColor = .label
        activityView.startAnimating()
        
        chargerView.addSubview(activityView)
        viewToCustom.addSubview(chargerView)
        
        let safeArea = self.view.safeAreaLayoutGuide
        
        //set constraints to chargerview
        chargerView.translatesAutoresizingMaskIntoConstraints = false
        chargerView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 0).isActive = true
        chargerView.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: 0).isActive = true
        chargerView.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: 0).isActive = true
        chargerView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 0).isActive = true
        
        //set constraints to activityIndicator
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor, constant: 0).isActive = true
        activityView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor, constant: 0).isActive = true
        activityView.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: 0).isActive = true
        activityView.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: 0).isActive = true
        activityView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 0).isActive = true
    }
    
    func stopChargerView(viewToCustom: UIView){
        //removing charger view with tag 100
        if let viewWithTag = viewToCustom.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    @IBAction func goToHistory(_ sender: Any) {
        self.performSegue(withIdentifier: "goToHistory", sender: nil)
    }
    
    @IBAction func unwindSegue( _ seg: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToImageDetail" {
            if let indexPath = sender as? IndexPath {
                
                //sending image for selected item to detail VC
                let detailVC = segue.destination as! DetailImageViewController
                let item = collectionView(photosCollectionView, cellForItemAt: indexPath) as? PhotoCollectionViewCell
                
                if let image = item?.image {
                    detailVC.image = image
                }
            }
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    
    func customSearchBar(){
        //Customizing search bar
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = .label
        
        //changing search bar placeholer text and font
        searchController.searchBar.placeholder = "For example Heidelberg"
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            let atrString = NSAttributedString(string: "For example Heidelberg",
                                               attributes: [.foregroundColor : UIColor.placeholderText,
                                                            .font : UIFont.italicSystemFont(ofSize: 15)])
            textfield.attributedPlaceholder = atrString
            
        }
        
        //add search controller to nav bar
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchController.searchBar.text, text.count != 0 else {
            return
        }
        
        //save searched text in history
        historyViewModel.saveInHistory(text: text, date: Date())
        loadData(text: text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cancelSearching()
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func customPhotosCollectionView(){
        //customizing cell
        photosCollectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "photosCollectionViewCell")
        photosCollectionView.delegate = self
        headerLabel.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 30)
        headerLabel.isHidden = true
        headerLabel.textColor = .gray
        
        if scrollViewOption == .secondOption {
            if let layout = photosCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.sectionHeadersPinToVisibleBounds = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scrollViewOption == .firstOption ? photosViewModel.numberOfRows() : numberOfElements
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        
        
        switch scrollViewOption{
        case .firstOption:
            let photo = photosViewModel.item(indexPath: indexPath)
            customPhotosCell(cell: cell, photo: photo)
        case .secondOption:
            let photo = photosViewModel.item(row: indexPath.row % photosViewModel.numberOfRows())
            customPhotosCell(cell: cell , photo: photo)
            
            //duplicate number of item to create endless scroll view
            if indexPath.row >= numberOfElements - ((numberOfElements * 100) / numberOfElements) {
                numberOfElements += numberOfElements
                photosCollectionView.reloadData()
            }
        }
        
        return cell
    }
    
    func customPhotosCell(cell: PhotoCollectionViewCell, photo: Photo){
        cell.id = photo.id
        cell.image = nil
        photosViewModel.loadImage(photo: photo) { image in
            if (photo.id == cell.id) {
                cell.image = image
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        
        //setting header information (show number of photos finded in server)
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            headerCollectionView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCollectionView", for: indexPath)
            
            headerCollectionView.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 30)
            //do other header related calls or settups
            
            headerLabel.text = "Results: \(photosViewModel.numberOfRows())"
            headerLabel.font = headerLabel.font.withSize(20)
            headerLabel.backgroundColor = .systemBackground
            headerCollectionView.insertSubview(headerLabel, at: 0)
            headerCollectionView.backgroundColor = .systemBackground
            return headerCollectionView
            
            
        default:  fatalError("Unexpected element kind")
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        //infinite collection view (go to top when user reach bottom of photos)
        let scrollHeight = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        
        if distanceFromBottom <= scrollHeight {
            goToTop()
        }
    }
    
    func goToTop(){
        //send to top of collection view only in first type of endless scroll view
        if scrollViewOption == .firstOption {
            let index = IndexPath(item: 0, section: 0)
            let header = UICollectionView.elementKindSectionHeader
            if let attributes = photosCollectionView.collectionViewLayout.layoutAttributesForSupplementaryView(ofKind: header, at: index ) {
                
                photosCollectionView.setContentOffset(CGPoint(x: 0, y: attributes.frame.origin.y - photosCollectionView.contentInset.top), animated: false)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goToImageDetail", sender: indexPath)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //code to set 2 elemets per line in collection view
        let noOfCellsInRow = 2
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
        + flowLayout.sectionInset.right
        + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: size)
    }
}
