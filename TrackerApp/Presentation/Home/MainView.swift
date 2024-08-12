//
//  ViewController.swift
//  TrackerApp
//
//  Created by ezen on 08/08/2024.
//

import UIKit
import SwiftUI
import WidgetKit

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
		
		self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
		
		WidgetCenter.shared.reloadTimelines(ofKind: "TrackerWidget")
	}
	
	@objc
	func hideKeyboard() {
		self.view.endEditing(true)
	}
}

struct MainView: View {
	@StateObject var vm: MainViewModel
	
	var body: some View {
		LazyVStack(spacing: 15) {
			HStack(spacing: 3) {
				Text("Updates")
					.font(.headline)
				if vm.isLoading {
					ProgressView()
				}
				Spacer()
				if vm.isLoading {
					Button("Cancel") {
						//
					}
					.buttonStyle(BorderedButtonStyle())
				} else {
					Button("Refresh") {
						vm.fetchData()
					}
					.buttonStyle(BorderedButtonStyle())
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(15)
			.background(Color.white.opacity(0.1))
			.cornerRadius(10)
			
			HStack(alignment: .top, spacing: 5) {
				Text("\(vm.item.discount)%")
					.font(.system(size: 30))
					.contentTransition(.numericText())
					.foregroundColor(.green)
					.padding(.trailing, 30)
				
				Text("\(vm.item.price)")
					.font(.system(size: 30))
					.contentTransition(.numericText())
			}
			.frame(maxWidth: .infinity, alignment: .center)
			.padding(.vertical, 40)
			
			VStack {
				Text("Product URL")
					.frame(maxWidth: .infinity, alignment: .leading)
				TextEditor(text: $vm.url)
					.scrollContentBackground(.hidden)
					.autocorrectionDisabled()
					.padding(5)
					.frame(minHeight: 100)
					.frame(maxWidth: .infinity)
					.background(Color.white.opacity(0.05))
					.cornerRadius(5)
					.onChange(of: vm.url) { value, _ in
						if value.last == "\n" {
							vm.host.hideKeyboard()
							vm.saveValues()
						}
					}
			}
			.padding(15)
			.frame(maxWidth: .infinity)
			.background(Color.white.opacity(0.05))
			.cornerRadius(5)
			
			Spacer()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
		.padding(15)
	}
}

#Preview {
	MainView(vm: MainViewModel(host: UIViewController()))
}
