//
//  DetailViewController.swift
//  YourMovies
//
//  Created by Francisco José Gonzlález Egea on 04/10/2019.
//  Copyright © 2019 Francisco José Gonzlález Egea. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class DetailViewController: UIViewController {

    //MARK: Variables
    @IBOutlet weak var m_titleTitle: UILabel!
    @IBOutlet weak var m_yearTitle: UILabel!
    @IBOutlet weak var m_runtimeTitle: UILabel!
    @IBOutlet weak var m_genreTitle: UILabel!
    @IBOutlet weak var m_siteTitle: UILabel!
    @IBOutlet weak var m_synopsisTitle: UILabel!

    @IBOutlet weak var m_image: UIImageView!
    @IBOutlet weak var m_titleText: UILabel!
    @IBOutlet weak var m_dateText: UILabel!
    @IBOutlet weak var m_runtimeText: UILabel!
    @IBOutlet weak var m_genreText: UILabel!
    @IBOutlet weak var m_siteText: UILabel!
    @IBOutlet weak var m_sinopsisText: UILabel!

    public var m_idMovie: String?

    private let m_activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    private let m_apiFetcher = APIRoute()
    private var m_searchResult = JSON() {
        didSet {
            populateData()
        }
    }

    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        m_titleTitle.text = NSLocalizedString("Title", comment: "")
        m_yearTitle.text = NSLocalizedString("Year", comment: "")
        m_runtimeTitle.text = NSLocalizedString("Runtime", comment: "")
        m_genreTitle.text = NSLocalizedString("Genre", comment: "")
        m_siteTitle.text = NSLocalizedString("Site", comment: "")
        m_synopsisTitle.text = NSLocalizedString("Synopsis", comment: "")

        loadingRecoverDataScreen(enable: true)
        guard let id = m_idMovie else {
            print("Id of movie no found")
            return
        }
        fetchDataById(for: id)
    }

    private func populateData() {
        m_titleText.text = m_searchResult["Title"].stringValue
        m_dateText.text = m_searchResult["Year"].stringValue
        m_runtimeText.text = m_searchResult["Runtime"].stringValue
        m_genreText.text = m_searchResult["Genre"].stringValue
        m_siteText.text = m_searchResult["Website"].stringValue
        m_sinopsisText.text = m_searchResult["Plot"].stringValue

        if let url = m_searchResult["Poster"].string {
            m_apiFetcher.fetchImage(url: url, completionHandler: { image, error in
                if (error == .success) {
                    self.m_image.image = image
                } else {
                    self.m_image.image = UIImage(named: "imagePlaceholer")
                }
            })
        }
        loadingRecoverDataScreen(enable: false)
    }

    private func fetchDataById(for text: String) {
        m_apiFetcher.searchById(searchText: text, completionHandler: {
            [weak self] results, error in
            if case .failure = error {
                return
            }

            guard let results = results, !results.isEmpty else {
                return
            }
            self?.m_searchResult = results
        })
    }

    private func loadingRecoverDataScreen(enable: Bool) {
        if (enable) {
            m_activityIndicator.center = self.view.center
            m_activityIndicator.hidesWhenStopped = true
            m_activityIndicator.frame = UIScreen.main.bounds
            if #available(iOS 13.0, *) {
                m_activityIndicator.style = UIActivityIndicatorView.Style.large
            } else {
                m_activityIndicator.style = UIActivityIndicatorView.Style.gray
            }
            m_activityIndicator.isOpaque = true
            m_activityIndicator.backgroundColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
            view.addSubview(m_activityIndicator)
            m_activityIndicator.startAnimating()
        } else {
            m_activityIndicator.stopAnimating()
            m_activityIndicator.removeFromSuperview()
        }
    }

    // MARK: Actions
    @IBAction func shareObject(_ sender: Any) {

        guard let textURL = m_siteText.text else {
            print("No url found")
            return
        }

        let myWebsite = NSURL(string: textURL)
        let shaeAll = [myWebsite]

        let activity = UIActivityViewController(activityItems: shaeAll as [Any], applicationActivities: nil)
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            self.present(activity, animated: true)
        } else {
            present(activity, animated: true, completion: nil)
            if let popOver = activity.popoverPresentationController {
                popOver.sourceView = self.view
            }
        }
    }

    @IBAction func showImage(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        let hold = UILongPressGestureRecognizer(target: self, action: #selector(choseSaveImage))
        newImageView.addGestureRecognizer(hold)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }

    @objc func choseSaveImage(_ sender: Any) {
        let action = UIAlertController(title: NSLocalizedString("saveLibrary", comment: ""),
                                       message: NSLocalizedString("Choice", comment: ""), preferredStyle: .actionSheet)

        action.addAction(UIAlertAction(title: NSLocalizedString("Library", comment: ""), style: .default, handler: { (action: UIAlertAction) in
            self.saveImage()
        }))

        action.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))

        if (UIDevice.current.userInterfaceIdiom == .phone) {
            self.present(action, animated: true, completion: nil)
        } else {
            present(action, animated: true, completion: nil)
            if let popOver = action.popoverPresentationController {
                popOver.sourceView = self.view
            }
        }
    }

    func saveImage() {
        guard let selectedImage = m_image.image else {
            print("Image not found!")
            return
        }
        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(saveImage(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func saveImage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlertWith(title: NSLocalizedString("SavedError", comment: ""), message: error.localizedDescription)
        } else {
            showAlertWith(title: NSLocalizedString("Saved", comment: ""), message: NSLocalizedString("SaveSuccess", comment: ""))
        }
    }

    func showAlertWith(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
