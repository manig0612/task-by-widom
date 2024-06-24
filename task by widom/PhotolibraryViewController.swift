//
//  PhotolibraryViewController.swift
//  task by wisdom
//
//  Created by Mani on 23/06/24.
//

import UIKit
import Foundation

class PhotolibraryViewController: UIViewController {
    
    @IBOutlet weak var librarytable: UITableView!
    
    var currentpage = 1
    var isloading = false
    var fetchphotodata:[photodata] = []
    var loadedphotos: [downloadedphotos] = []
    var imageCache = NSCache<NSString, UIImage>()
    var loadmorebutton: UIButton?
    var activityindicator: UIActivityIndicatorView!
    var loadmorectivityindicator: UIActivityIndicatorView!
    var pagelimit =  15

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.FetchPhotos(page: self.currentpage, limit: pagelimit, completion: {
            self.updateData()
        })
    
        loadmorebuttonsetup()
        tableviewsetup()
        setupactivityindicator()
       
    }
    
    // Setup the activityindicator
    func setupactivityindicator() {
        activityindicator = UIActivityIndicatorView(style: .large)
        activityindicator.center = view.center
        activityindicator.hidesWhenStopped = true
        view.addSubview(activityindicator)
        activityindicator.startAnimating()
    }
    
    // Setup loadmorebutton and loadmoreactivityindicator for next page
    func loadmorebuttonsetup() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: librarytable.frame.width, height: 50))
        loadmorebutton = UIButton(frame: footerView.bounds)
        loadmorebutton?.setTitle("Load More", for: .normal)
        loadmorebutton?.setTitleColor(.systemBlue, for: .normal)
        loadmorebutton?.addTarget(self, action: #selector(loadMoretapped), for: .touchUpInside)
        loadmorectivityindicator = UIActivityIndicatorView(style: .medium)
        loadmorectivityindicator.center = footerView.center
        loadmorectivityindicator.hidesWhenStopped = true
        footerView.addSubview(loadmorectivityindicator)
        footerView.addSubview(loadmorebutton!)
        librarytable.tableFooterView = footerView
        loadmorebutton?.isHidden = true
    }
    
    @objc func loadMoretapped() {
        currentpage += 1
        loadmorebutton?.isHidden = true
        loadmorectivityindicator.startAnimating()
        
        FetchPhotos(page: currentpage, limit: pagelimit) {
            DispatchQueue.main.async {
                self.updateData()
                self.librarytable.reloadData()
            }
        }
    }
    
    //Setup for a tableview
    func tableviewsetup() {
        librarytable.refreshControl = UIRefreshControl()
        librarytable.refreshControl?.addTarget(self, action: #selector(refreshPhotos), for: .valueChanged)
    }
    
    @objc func refreshPhotos() {
        currentpage = 1
        loadmorebutton?.isHidden =  true
        activityindicator.startAnimating()
        fetchphotodata.removeAll()
        loadedphotos.removeAll()
        FetchPhotos(page: currentpage, limit: pagelimit) {
            DispatchQueue.main.async {
                self.updateData()
                self.librarytable.reloadData()
            }
            
        }
    }
    
    
    // update the uielements
    func updateData() {
        DispatchQueue.main.async {
            self.librarytable.refreshControl?.endRefreshing()
            self.librarytable.reloadData()
            self.loadimages()
        }
        
    }
    
    // Fetch the details from api using url session
    func FetchPhotos(page: Int, limit: Int, completion: (() -> Void)? = nil) {
        guard let url = URL(string: "https://picsum.photos/v2/list?page=\(page)&limit=\(limit)") else {
            print("Invalid URL")
            completion?()
            return
        }
        
        isloading = true
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            self.isloading = false
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion?()
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion?()
                return
            }
            
            do {
                
                let content = try JSONDecoder().decode([photodata].self, from: data)
                self.fetchphotodata.append(contentsOf: content)
                DispatchQueue.main.async {
                    self.librarytable.reloadData()
                    completion?()
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                completion?()
            }
        }
        task.resume()
    }
    
 
   // fetching the images from the loaded images
    func loadimages() {
        
        let dispatchGroup = DispatchGroup()
                var newLoadedPhotos: [downloadedphotos] = []
                
                for photo in fetchphotodata {
                    guard let urlFromImage = photo.download_url, let url = URL(string: urlFromImage) else {
                        continue
                    }
                    
                    dispatchGroup.enter()
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                            let downloadedPhoto = downloadedphotos(id: photo.id, author: photo.author, width: photo.width, height: photo.height, imagetoshow: image)
                            
                            DispatchQueue.main.async {
                                newLoadedPhotos.append(downloadedPhoto)
                                dispatchGroup.leave()
                            }
                        } else {
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    let uniqueNewPhotos = newLoadedPhotos.filter { newPhoto in
                        !self.loadedphotos.contains(where: { $0.id == newPhoto.id })
                    }
                    self.loadedphotos.append(contentsOf: uniqueNewPhotos)
                    self.loadedphotos.sort { Int($0.id ?? "0") ?? 0 < Int($1.id ?? "0") ?? 0 }
                    self.librarytable.reloadData()
                    self.activityindicator.stopAnimating()
                    self.loadmorebutton?.isHidden = false
                    self.loadmorectivityindicator.stopAnimating()
                   // completion()
                }
            }
        
    
    
    
}

// setup for tableview cell
extension PhotolibraryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadedphotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photocell = librarytable.dequeueReusableCell(withIdentifier: "photodisplaycell", for: indexPath) as! PhotodetailsTableViewCell
        let photos = loadedphotos[indexPath.row]
        photocell.configdata(library: photos, index: indexPath.row)
        photocell.checkboxbutton.tag = indexPath.row
        photocell.checkboxbutton.addTarget(self, action: #selector(checkboxbuttontapped(_:)), for: .touchUpInside)
        
        return photocell
    }
    
    @objc func checkboxbuttontapped(_ sender: CheckboxButton) {
        let index = sender.tag
        loadedphotos[index].ifcheckboxclicked.toggle()

    }
}


extension PhotolibraryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 400
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = loadedphotos[indexPath.row]
        if photo.ifcheckboxclicked {
            let alert = UIAlertController(title: "Author:\(photo.author ?? "No author")", message: "photo width:\(photo.width ?? 0) photo height:\(photo.height ?? 0)" , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Alert", message: "Please choose the photo to get details", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
}

extension PhotolibraryViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let photo = fetchphotodata[indexPath.row]
            guard let urlFromImage = photo.download_url, let url = URL(string: urlFromImage) else {
                continue
            }
            if imageCache.object(forKey: url.absoluteString as NSString) == nil {
                loadImage(from: url)
            }
        }
    }
    
    private func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                }
            }
        }
        
        
    }
}
