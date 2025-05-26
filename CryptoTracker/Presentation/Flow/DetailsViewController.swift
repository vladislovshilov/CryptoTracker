//
//  DetailsViewController.swift
//  CryptoTracker
//
//  Created by lil angee on 26.05.25.
//

import UIKit
import Combine
import SwiftUI
import Charts

struct MonthlyHoursOfSunshine: Identifiable {
    var id: Int
    
    var date: Date
    var hoursOfSunshine: Double

    init(month: Int, hoursOfSunshine: Double) {
        let calendar = Calendar.autoupdatingCurrent
        self.date = calendar.date(from: DateComponents(year: 2020, month: month))!
        self.hoursOfSunshine = hoursOfSunshine
        self.id = month
    }
}

struct SwiftUIView: View {
    var title: String = ""
    
    var data: [MonthlyHoursOfSunshine] = [
        MonthlyHoursOfSunshine(month: 1, hoursOfSunshine: 74),
        MonthlyHoursOfSunshine(month: 2, hoursOfSunshine: 99),
        MonthlyHoursOfSunshine(month: 3, hoursOfSunshine: 11),
        MonthlyHoursOfSunshine(month: 4, hoursOfSunshine: 62),
        MonthlyHoursOfSunshine(month: 5, hoursOfSunshine: 68),
        MonthlyHoursOfSunshine(month: 6, hoursOfSunshine: 44),
        MonthlyHoursOfSunshine(month: 7, hoursOfSunshine: 55),
        MonthlyHoursOfSunshine(month: 8, hoursOfSunshine: 88),
        MonthlyHoursOfSunshine(month: 12, hoursOfSunshine: 99)
    ]
    
    var body: some View {
        ZStack {
//            Color.pink
//            Button(title) {
//                
//            }
//            .font(.title)
//            .buttonStyle(.borderedProminent)
//            .padding()
            Chart(data) { el in
                LineMark(
                    x: .value("Month", el.date),
                    y: .value("Hours of Sunshine", el.hoursOfSunshine)
                )
            }
        }
    }
}

class DetailsViewController: BaseViewController<DetailsViewModel> {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = nil
        
        let vc = UIHostingController(rootView: SwiftUIView(title: viewModel.title))
        
        let swiftuiView = vc.view!
        swiftuiView.translatesAutoresizingMaskIntoConstraints = false

        addChild(vc)
        containerView.addSubview(swiftuiView)

        NSLayoutConstraint.activate([
            swiftuiView.topAnchor.constraint(equalTo: containerView.topAnchor),
            swiftuiView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            swiftuiView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            swiftuiView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])

        vc.didMove(toParent: self)
        
        
        viewModel.$title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.titleLabel.text = value
            }
            .store(in: &cancellables)
        
        viewModel.$price
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.priceLabel.text = value
            }
            .store(in: &cancellables)
    }
}
