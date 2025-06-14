//
//  UpdateProfileView.swift
//  Examples
//
//  Created by Guilherme Souza on 14/05/24.
//

import Supabase
import SwiftUI

struct UpdateProfileView: View {
  let user: User

  @State var email = ""
  @State var phone = ""
  @State var password = ""

  @State var otp = ""
  @State var showTokenField = false

  var formUpdated: Bool {
    emailChanged || phoneChanged || !password.isEmpty
  }

  var emailChanged: Bool {
    email != user.email
  }

  var phoneChanged: Bool {
    phone != user.phone
  }

  var body: some View {
    Form {
      Section {
        TextField("Email", text: $email)
          .textContentType(.emailAddress)
          .autocorrectionDisabled()
        #if !os(macOS)
          .keyboardType(.emailAddress)
          .textInputAutocapitalization(.never)
        #endif
        TextField("Phone", text: $phone)
          .textContentType(.telephoneNumber)
          .autocorrectionDisabled()
        #if !os(macOS)
          .keyboardType(.phonePad)
          .textInputAutocapitalization(.never)
        #endif
        SecureField("New password", text: $password)
          .textContentType(.newPassword)
      }

      Section {
        Button("Update") {
          Task {
            await updateButtonTapped()
          }
        }
        .disabled(!formUpdated)
      }

      if showTokenField {
        Section {
          TextField("OTP", text: $otp)
          Button("Verify") {
            Task {
              await verifyTapped()
            }
          }
        }
      }
    }
    .onAppear {
      email = user.email ?? ""
      phone = user.phone ?? ""
    }
  }

  @MainActor
  private func updateButtonTapped() async {
    var attributes = UserAttributes()
    if emailChanged {
      attributes.email = email
    }

    if phoneChanged {
      attributes.phone = phone
    }

    if password.isEmpty == false {
      attributes.password = password
    }

    do {
      try await supabase.auth.update(user: attributes, redirectTo: Constants.redirectToURL)

      if phoneChanged {
        showTokenField = true
      }
    } catch {
      debug("Fail to update user: \(error)")
    }
  }

  @MainActor
  private func verifyTapped() async {
    do {
      try await supabase.auth.verifyOTP(phone: phone, token: otp, type: .phoneChange)
    } catch {
      debug("Fail to verify OTP: \(error)")
    }
  }
}

#Preview {
  UpdateProfileView(
    user: User(
      id: UUID(),
      appMetadata: [:],
      userMetadata: [:],
      aud: "",
      createdAt: Date(),
      updatedAt: Date()
    )
  )
}

