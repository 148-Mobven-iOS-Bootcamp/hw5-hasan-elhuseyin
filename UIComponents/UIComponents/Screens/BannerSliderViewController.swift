//
//  BannerSliderViewController.swift
//  UIComponents
//
//  Created by Hasan Elhussein on 21.01.2022.
//

import UIKit

class BannerSliderViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    
    //MARK: - Variables
    let arrOfLabels: [String] = ["Banner 1", "Banner 2", "Banner 3", "Banner 4", "Banner 5"]
    var timer : Timer?
    var currentCellIndex: Int = 0
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect collectionView delegate and datasource to self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Configure pageController
        pageController.numberOfPages = arrOfLabels.count
        
        // Start the timer function
        startTimer()
    }
    
    //MARK: - Functions
    // Function to slide the banner every 10 seconds
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(moveToNextIndex), userInfo: nil, repeats: true)
    }
    
    // Objective-C function for startTimer
    @objc func moveToNextIndex() {
        if currentCellIndex < arrOfLabels.count - 1 {
            currentCellIndex += 1
        } else {
            currentCellIndex = 0
        }
        // Scroll function
        collectionView.scrollToItem(at: IndexPath(item: currentCellIndex, section: 0), at: .centeredHorizontally, animated: true)
        // Set pageController to the proper index
        pageController.currentPage = currentCellIndex
    }
    
}


//MARK: - Extensions

extension BannerSliderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // This function will be used to achieve the 'Infinite Scroll' Effect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Print scrollView contentOffset
        print(scrollView.contentOffset)
        // Calculate maxOffset of the scrollView
        let maxOffset = scrollView.contentSize.width - scrollView.frame.size.width
        // When the scrollView's offset reachs its maximum, reset the offset to 0
        if scrollView.contentOffset.x > maxOffset {
            scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y)
        }
    }
     
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of cells
        return arrOfLabels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create a cell of type 'BannerSliderCell'
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerSliderCell", for: indexPath) as! BannerSliderCell
        // Configure cell's attributes
        cell.label.text = arrOfLabels[indexPath.row]
        cell.view.backgroundColor = UIColor.random
        // Return the cell
        return cell
    }
    
}

extension BannerSliderViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Set the size of the cells programmatically
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // Set the spacing between cells to 0
        return 0
    }
    
}
