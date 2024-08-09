//
//  ViewController.swift
//  TrackerApp
//
//  Created by ezen on 08/08/2024.
//

import UIKit
import SwiftUI

class MainViewController: UIViewController {
	var vm: MainViewModel!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.vm = MainViewModel(host: self)
		
		let _view = MainView(vm: self.vm)

		let _vc = UIHostingController(rootView: _view)
		_vc.view.translatesAutoresizingMaskIntoConstraints = false
		_vc.view.backgroundColor = .clear

		addChild(_vc)
		view.addSubview(_vc.view)
		_vc.didMove(toParent: self)
		
		NSLayoutConstraint.activate([
			NSLayoutConstraint(item: _vc.view!, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: _vc.view!, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: _vc.view!, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: _vc.view!, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0)
		])
	}
}

struct MainView: View {
	@StateObject var vm: MainViewModel
	
	var body: some View {
		ScrollView(showsIndicators: false) {
			LazyVStack(spacing: 15) {
				HStack(spacing: 3) {
					Text("Updates")
						.font(.headline)
					Rectangle()
						.fill(vm.isConnected ? .green : .red)
						.frame(width: 6, height: 6)
						.cornerRadius(3)
						.offset(CGSize(width: 0.0, height: -5.0))
					Spacer()
					if vm.isConnected {
						Button("Connected") {
							//
						}
						.buttonStyle(BorderedButtonStyle())
						.accentColor(.green)
					} else {
						Button("Connect") {
							vm.onConnect()
						}
						.buttonStyle(BorderedButtonStyle())
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(15)
				.background(Color.white.opacity(0.1))
				.cornerRadius(10)
				
				ForEach(Array(vm.data.enumerated()), id: \.0) { _, item in
					Text(item)
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(15)
						.background(Color.white.opacity(0.05))
						.cornerRadius(10)
				}
				.padding(.top, 15)
				
				Spacer()
			}
			.frame(maxWidth: .infinity)
			.padding(15)
			.padding(.bottom, 100)
		}
	}
}

#Preview {
	MainView(vm: MainViewModel(host: UIViewController()))
}
