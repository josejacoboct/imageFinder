//
//  ViewController.swift
//  CodingChallenge
//
//  Created by José Jacobo Contreras Trejo on 29/01/22.
//

import UIKit

class HomeViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    //var
    let searchController = UISearchController()
    let photosViewModel = PhotosViewModel()
    let historyViewModel = HistoryViewModel()
    var headerCollectionView = UICollectionReusableView()
    let headerLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search some text"
        customPhotosCollectionView()
        customSearchBar()
        
        
    }
    
    func loadData(text: String){
        
        DispatchQueue.main.async { [weak self] in
            self?.headerLabel.isHidden = true
            self?.showChargerView(viewToCustom: (self?.view)!)
        }
        
        photosViewModel.loadData(text: text) { [weak self] error in
            
            if error != nil && (error as NSError?)?.code != NSURLErrorCancelled {
                DispatchQueue.main.async {
                    self?.stopChargerView(viewToCustom: (self?.view)!)
                    self?.showErrorAlert(message: error?.localizedDescription ?? "Try again in few minutes please.", viewTarget: self!)
                    return
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.stopChargerView(viewToCustom: (self?.view)!)
                self?.goToTop()
                self?.photosCollectionView.reloadData()
                self?.headerLabel.isHidden = false
            }
        }
    }
    
    func showErrorAlert(message: String, viewTarget: UIViewController){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        DispatchQueue.main.async {
            viewTarget.present(alert, animated: true, completion: nil)
        }
    }
    
    func showChargerView(viewToCustom: UIView) {
                
        let safeAreaHeight = self.view.safeAreaLayoutGuide.layoutFrame.height
        let navBarHeight = self.view.frame.height - headerLabel.frame.height - safeAreaHeight
        let activityView = UIActivityIndicatorView(style: .large)
        let chargerView = UIView(frame: CGRect(x: 0, y: navBarHeight, width: viewToCustom.frame.width, height: safeAreaHeight))
        chargerView.tag = 100
        activityView.tintColor = .label
        activityView.frame = chargerView.frame
        activityView.center = CGPoint(x: chargerView.frame.width / 2, y: chargerView.frame.height / 2)
        activityView.startAnimating()
        chargerView.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        chargerView.addSubview(activityView)
        viewToCustom.addSubview(chargerView)
        
        //chargerView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleBottomMargin]
        
    }
    
    func stopChargerView(viewToCustom: UIView){
        if let viewWithTag = viewToCustom.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    func showDetailImage(image: UIImage, title: String){
        
        let showAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 250, height: 230))
        imageView.image = image
        showAlert.view.addSubview(imageView)
        let height = NSLayoutConstraint(item: showAlert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        let width = NSLayoutConstraint(item: showAlert.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        showAlert.view.addConstraint(height)
        showAlert.view.addConstraint(width)
        showAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(showAlert, animated: true, completion: nil)
    }
    
    @IBAction func goToHistory(_ sender: Any) {
        self.performSegue(withIdentifier: "goToHistory", sender: nil)
    }
    
    @IBAction func unwindSegue( _ seg: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToImageDetail" {
            if let indexPath = sender as? IndexPath {
                let detailVC = segue.destination as! DetailImageViewController
                let item = collectionView(photosCollectionView, cellForItemAt: indexPath) as? PhotoCollectionViewCell
                detailVC.image = item?.image
                
                if let image = item?.image {
                    detailVC.image = image
                }
                
                //_ = segue.destination as! HomeViewController
            }
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    
    func customSearchBar(){
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.tintColor = .label
        searchController.searchBar.placeholder = "For example Heidelberg"
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            let atrString = NSAttributedString(string: "For example Heidelberg",
                                               attributes: [.foregroundColor : UIColor.placeholderText,
                                                            .font : UIFont.italicSystemFont(ofSize: 15)])
            textfield.attributedPlaceholder = atrString
            
        }
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
        photosViewModel.cancelLoadData()
        stopChargerView(viewToCustom: self.view)
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func customPhotosCollectionView(){
        photosCollectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "photosCollectionViewCell")
        photosCollectionView.delegate = self
        headerLabel.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 30)
        headerLabel.isHidden = true
        headerLabel.textColor = .gray
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosViewModel.numberOfRows()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        let photo = photosViewModel.item(indexPath: indexPath)
        customPhotosCell(cell: cell, photo: photo)
        
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
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            headerCollectionView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCollectionView", for: indexPath)
            
            headerCollectionView.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 30)
            //do other header related calls or settups
            
            headerLabel.text = "Results: \(photosViewModel.numberOfRows())"
            headerLabel.font = headerLabel.font.withSize(20)
            headerCollectionView.insertSubview(headerLabel, at: 0)
            return headerCollectionView
            
            
        default:  fatalError("Unexpected element kind")
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let scrollHeight = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        
        if distanceFromBottom <= scrollHeight {
            goToTop()
        }
    }
    
    func goToTop(){
        let index = IndexPath(item: 0, section: 0)
        let header = UICollectionView.elementKindSectionHeader
        if let attributes = photosCollectionView.collectionViewLayout.layoutAttributesForSupplementaryView(ofKind: header, at: index ) {
            
            photosCollectionView.setContentOffset(CGPoint(x: 0, y: attributes.frame.origin.y - photosCollectionView.contentInset.top), animated: false)
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
        
        let noOfCellsInRow = 2
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
        + flowLayout.sectionInset.right
        + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: size)
    }
}
