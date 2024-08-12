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
		
		self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		vm.timer?.invalidate()
		vm.timer = nil
		super.viewDidDisappear(animated)
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
				Rectangle()
					.fill(vm.timer == nil ? .red : .green)
					.frame(width: 6, height: 6)
					.cornerRadius(3)
					.offset(CGSize(width: 0.0, height: -5.0))
				if vm.isLoading {
					ProgressView()
				}
				Spacer()
				if vm.timer == nil {
					Button("Connect") {
						vm.fetchData()
					}
					.buttonStyle(BorderedButtonStyle())
				} else {
					Button("Disconnect") {
						vm.stopFetching()
					}
					.buttonStyle(BorderedButtonStyle())
					.accentColor(.red)
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(15)
			.background(Color.white.opacity(0.1))
			.cornerRadius(10)
			
			Text(vm.value)
				.font(.largeTitle.bold().monospaced())
				.frame(maxWidth: .infinity, alignment: .center)
				.padding(.vertical, 40)
			
			HStack {
				Text("At :")
					.fontWeight(.black)
				TextField("A valid URL", text: $vm.url, onEditingChanged: { isEditing in
					if !isEditing {
						vm.saveValues()
					}
				})
				.frame(maxWidth: .infinity, alignment: .trailing)
				.multilineTextAlignment(.trailing)
			}
			.padding(.vertical, 10)
			.padding(.horizontal, 12)
			.frame(maxWidth: .infinity)
			.background(Color.white.opacity(0.05))
			.cornerRadius(5)
			
			HStack {
				Text("Selector :")
					.fontWeight(.black)
				TextField("#content-id", text: $vm.querySelector, onEditingChanged: { isEditing in
					if !isEditing {
						vm.saveValues()
					}
				})
				.frame(maxWidth: .infinity, alignment: .trailing)
				.multilineTextAlignment(.trailing)
			}
			.padding(.vertical, 10)
			.padding(.horizontal, 12)
			.frame(maxWidth: .infinity)
			.background(Color.white.opacity(0.05))
			.cornerRadius(5)
			
			HStack {
				Text("Tag Name :")
					.fontWeight(.black)
				TextField("span", text: $vm.tagName, onEditingChanged: { isEditing in
					if !isEditing {
						vm.saveValues()
					}
				})
				.frame(maxWidth: .infinity, alignment: .trailing)
				.multilineTextAlignment(.trailing)
			}
			.padding(.vertical, 10)
			.padding(.horizontal, 12)
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
