//
//  CheckoutView.swift
//  iDine
//
//  Created by kore omodara on 1/21/24.
//

import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject var order: Order 
    
    
    let paymentTypes = ["Cash", "Credit Card", "iDine Points"]
    @State private var paymentType = "Cash"
    
    @State private var addLoyaltyDetails = false
    @State private var loyaltyNumber = ""
   
    let tipAmounts = [10, 15, 20, 25, 0]
    @State private var tipAmount = 15
    
    @State private var showingPaymentAlert = false
    @State private var pickupTime = "Now"
    
    var totalPrice: String {
        let total = Double(order.total)
        let tipValue = total / 100 * Double(tipAmount)
        return (total + tipValue).formatted(.currency(code: "USD"))
    }
    
    var body: some View {
        Form {
            Section {
                Picker("How do you want to pay?", selection: $paymentType) {
                    ForEach(paymentTypes, id: \.self) {
                        Text($0)
                    }
                }
                
                Toggle("Add iDine loyalty card", isOn: $addLoyaltyDetails.animation())
                
                if addLoyaltyDetails {
                    TextField("Enter your iDine ID", text: $loyaltyNumber)
                }
            }
            
            Section("Pickup"){
                //I wanted to do one of the challenges at the end to add a pickup time, For the most part the process made sense, I did look up the .tag part since the values werent initialized/numbers like with the other pickers
                Picker("Select Pickup Time", selection: $pickupTime){
                    Text("Now").tag("Now")
                    Text("Tonight").tag("Tonight")
                    Text("Tomorrow Morning").tag("Tomorrow Morning")
                   // Text("Never").tag("Never") hehe 
                }
            }
            
            Section("Add a tip?") {
                Picker("Percentage: ", selection: $tipAmount) {
                    ForEach(tipAmounts, id: \.self) {
                        Text("\($0)%")
                    }
                }
                
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section("Total: \(totalPrice)"){
                Button("Confirm Order") {
                    showingPaymentAlert.toggle()
                }
            }
        }
        .navigationTitle("Payment")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Order Confirmed", isPresented: $showingPaymentAlert) {
            //add buttons
        } message: {
            Text("Your total was \(totalPrice) - Thank you!")
        }
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
            .environmentObject(Order())
    }
}
