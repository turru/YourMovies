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
    @IBOutlet weak var m_image: UIImageView!
    @IBOutlet weak var m_title: UILabel!
    @IBOutlet weak var m_date: UILabel!
    @IBOutlet weak var m_runtime: UILabel!
    @IBOutlet weak var m_genre: UILabel!
    @IBOutlet weak var m_site: UILabel!
    @IBOutlet weak var m_sinopsis: UITextView!

    public var m_idMovie: String?

    private let m_activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    private let m_apiFetcher = APIRoute()
    private var m_searchResult = JSON() {
        didSet {
            populateData()
        }
    }

    // MARK: Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadingRecoverDataScreen(enable: true)
        guard let id = m_idMovie else {
            print("Id of movie no found")
            return
        }
        fetchDataById(for: id)
    }

    private func populateData()
    {
        m_title.text = m_searchResult["Title"].stringValue
        m_date.text = m_searchResult["Year"].stringValue
        m_runtime.text = m_searchResult["Runtime"].stringValue
        m_genre.text = m_searchResult["Genre"].stringValue
        m_site.text = m_searchResult["Website"].stringValue
        m_sinopsis.text = m_searchResult["Website"].stringValue

        if let url = m_searchResult["Poster"].string {
            m_apiFetcher.fetchImage(url: url, completionHandler: { image, error in
                if(error == .success)
                {
                    self.m_image.image = image
                }
                else
                {
                    self.m_image.image = UIImage(named: "imagePlaceholer")
                }
            })
        }
        loadingRecoverDataScreen(enable: false)
    }

    private func fetchDataById(for text: String) {
        print("Id of movie: \(m_idMovie!)")
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

    private func loadingRecoverDataScreen(enable: Bool){
        if(enable)
        {
            m_activityIndicator.center = self.view.center
            m_activityIndicator.hidesWhenStopped = true
            m_activityIndicator.frame = UIScreen.main.bounds
            if #available(iOS 13.0, *)
            {
                m_activityIndicator.style = UIActivityIndicatorView.Style.large
            } else {
                m_activityIndicator.style = UIActivityIndicatorView.Style.gray
            }
            m_activityIndicator.isOpaque = true
            m_activityIndicator.backgroundColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
            view.addSubview(m_activityIndicator)
            m_activityIndicator.startAnimating()
        }
        else
        {
            m_activityIndicator.stopAnimating()
            m_activityIndicator.removeFromSuperview()
        }
    }

    // MARK: Actions
    // TODO
    @IBAction func shareObject(_ sender: Any) {

        let activity = UIActivityViewController(activityItems: [], applicationActivities: nil) // TODO saherd website
        if(UIDevice.current.userInterfaceIdiom == .phone)
        {
            self.present(activity, animated: true)
        }
        else
        {
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

    @objc func choseSaveImage (_ sender: Any)
    {
        let action = UIAlertController(title: "Guarda library", message: "Elige saviamente", preferredStyle: .actionSheet)
        action.addAction(UIAlertAction(title: "Carrete", style: .default, handler:{(action:UIAlertAction) in
            self.saveImage ()
        }))

        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(action, animated: true, completion: nil)
    }

    func saveImage ()
    {
        guard let selectedImage = m_image.image else {
            print("Image not found!")
            return
        }
        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(saveImage(_:didFinishSavingWithError:contextInfo:)), nil)

    }

    @objc func saveImage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Saved!", message: "Great! your image has been saved to your photos.")
        }
    }

    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
